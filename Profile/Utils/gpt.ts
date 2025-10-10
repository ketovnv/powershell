#!/usr/bin/env bun
/**
 * GPT helper for WebStorm / CLI (Bun)
 * Usage examples:
 *   bun run gpt.ts review src/file.ts
 *   bun run gpt.ts --model gpt-4o-mini explain "const x = 1"
 *   type src\file.ts | bun run gpt.ts tests
 *   bun run gpt.ts -- refactor src/file.ts   // `--` splits flags from args
 *
 * Env:
 *   OPENAI_API_KEY   - required
 *   GPT_MODEL        - default model (fallback if --model not provided)
 */

import OpenAI from "openai";
import { statSync, readFileSync, existsSync } from "fs";

type Mode = "review" | "explain" | "tests" | "refactor";

// ---------- small flag parser (no deps) ----------
type Flags = {
  model?: string;
  temperature?: number;
  maxTokens?: number;
  timeoutMs?: number;
  noMarkdown?: boolean;
};

function parseFlags(argv: string[]): { flags: Flags; rest: string[] } {
  const flags: Flags = {};
  const rest: string[] = [];
  let afterDashDash = false;

  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (afterDashDash) {
      rest.push(a);
      continue;
    }
    if (a === "--") {
      afterDashDash = true;
      continue;
    }
    if (a.startsWith("--model=")) {
      flags.model = a.slice(8);
      continue;
    }
    if (a === "--model") {
      flags.model = argv[++i];
      continue;
    }
    if (a.startsWith("--temperature=")) {
      flags.temperature = Number(a.slice(14));
      continue;
    }
    if (a === "--temperature") {
      flags.temperature = Number(argv[++i]);
      continue;
    }
    if (a.startsWith("--max-tokens=")) {
      flags.maxTokens = Number(a.slice(13));
      continue;
    }
    if (a === "--max-tokens") {
      flags.maxTokens = Number(argv[++i]);
      continue;
    }
    if (a.startsWith("--timeout=")) {
      flags.timeoutMs = Number(a.slice(10));
      continue;
    }
    if (a === "--timeout") {
      flags.timeoutMs = Number(argv[++i]);
      continue;
    }
    if (a === "--no-md" || a === "--no-markdown") {
      flags.noMarkdown = true;
      continue;
    }
    rest.push(a);
  }
  return { flags, rest };
}

// ---------- robust stdin/file detection ----------
function stdinHasData(): boolean {
  try {
    // Works in Node & Bun
    const s = statSync(0);
    // isFIFO (pipe) or isFile (redirected file)
    // @ts-ignore - Bun's statSync returns Stats-compatible
    return typeof s.isFIFO === "function" && (s.isFIFO() || s.isFile());
  } catch {
    return false;
  }
}

async function readStdinText(): Promise<string> {
  try {
    // Bun provides Bun.stdin, but this also works in Node via streams
    // @ts-ignore
    if (typeof Bun !== "undefined" && Bun.stdin) {
      // @ts-ignore
      return await Bun.stdin.text();
    }
  } catch {}
  // Node fallback
  const chunks: Buffer[] = [];
  for await (const chunk of process.stdin) {
    chunks.push(chunk as Buffer);
  }
  return Buffer.concat(chunks).toString("utf-8");
}

// ---------- input picking ----------
const INPUT_LIMIT = 200 * 1024; // 200KB soft limit

function isReadableFile(p: string): boolean {
  if (!existsSync(p)) return false;
  try {
    const st = statSync(p);
    return st.isFile();
  } catch { return false; }
}

function systemPromptFor(mode: Mode, noMd: boolean): string {
  switch (mode) {
    case "review":
      return "Ты строгий тимлид фронтенда. Сделай ревью: баги, запахи кода, риски производительности и безопасности, краткий план улучшений. Пиши по делу, списком.";
    case "explain":
      return "Объясни код простыми словами. Кратко, структурировано, с примерами.";
    case "tests":
      return "Напиши unit-тесты на Vitest по AAA-паттерну. Покрой граничные случаи. Верни только тестовый код"
        + (noMd ? " без Markdown-разметки." : ".");
    case "refactor":
      return "Перепиши код по принципам Clean Code и SOLID, сохрани поведение, убери дублирование. Верни только код"
        + (noMd ? " без Markdown-разметки." : ".");
  }
}

function defaultModel(): string {
  // safer default than "gpt-5"
  // You can change it via --model or GPT_MODEL env
  // Popular options: "gpt-4o-mini", "gpt-4o"
  // Thinking/advanced models may have tight quotas.
  // @ts-ignore
  return (typeof Bun !== "undefined" && Bun.env?.GPT_MODEL)
    // @ts-ignore
    || process.env.GPT_MODEL
    || "gpt-4o-mini";
}

function pickModeAndInput(args: string[]): { mode: Mode; maybe: string | undefined } {
  const [arg2, arg3] = args;
  const modes: Record<string, Mode> = { review: "review", r: "review", explain: "explain", e: "explain", tests: "tests", t: "tests", refactor: "refactor", f: "refactor" };

  // If arg2 is a file, treat it as input (avoid conflict when file named 'review')
  if (arg2 && isReadableFile(arg2)) {
    return { mode: "review", maybe: arg2 };
  }
  // If arg2 maps to a mode -> use it; maybe is arg3
  if (arg2 && modes[arg2.toLowerCase()]) {
    return { mode: modes[arg2.toLowerCase()], maybe: arg3 };
  }
  // Otherwise treat arg2 as content (string or missing)
  return { mode: "review", maybe: arg2 };
}

// ---------- main ----------
async function main() {
  // @ts-ignore
  const apiKey = (typeof Bun !== "undefined" && Bun.env?.OPENAI_API_KEY) || process.env.OPENAI_API_KEY;
  if (!apiKey) {
    console.error("❌ OPENAI_API_KEY is not set.");
    process.exit(1);
  }

  const { flags, rest } = parseFlags(process.argv);
  const { mode, maybe } = pickModeAndInput(rest);
  let content = "";

  // priority: explicit arg -> readable file or text
  if (maybe) {
    if (isReadableFile(maybe)) {
      content = readFileSync(maybe, "utf-8");
    } else {
      content = maybe;
    }
  } else if (stdinHasData()) {
    content = (await readStdinText()).trim();
  } else {
    console.error("Usage: bun run gpt.ts [mode] <file_or_text>\n       bun run gpt.ts --model gpt-4o-mini review src/file.ts");
    process.exit(2);
  }

  if (!content) {
    console.error("❌ No input content provided (empty file or stdin).");
    process.exit(2);
  }

  if (content.length > INPUT_LIMIT) {
    console.error(`⚠️ Input is ${content.length} bytes (> ${INPUT_LIMIT}). Trimming to ${INPUT_LIMIT}.`);
    content = content.slice(0, INPUT_LIMIT);
  }

  const model = flags.model || defaultModel();
  const temperature =
    typeof flags.temperature === "number"
      ? flags.temperature
      : (mode === "review" || mode === "refactor" || mode === "tests") ? 0.1 : 0.3;
  const maxTokens = typeof flags.maxTokens === "number" ? flags.maxTokens : undefined;

  const system = systemPromptFor(mode, !!flags.noMarkdown);

  const client = new OpenAI({ apiKey });

  // timeout/abort
  const timeoutMs = flags.timeoutMs ?? 120_000;
  const controller = new AbortController();
  const t = setTimeout(() => controller.abort(), timeoutMs);

  try {
    const resp = await client.chat.completions.create({
      model,
      messages: [
        { role: "system", content: system },
        { role: "user", content },
      ],
      temperature,
      max_tokens: maxTokens,
    }, { signal: controller.signal as any });

    const out = resp.choices?.[0]?.message?.content?.trim() ?? "";
    if (!out) {
      console.error("⚠️ Empty response.");
      process.exit(3);
    }
    console.log(out);
  } catch (err: any) {
    // Normalize common API errors
    const msg = String(err?.message || err);
    if (msg.includes("401")) {
      console.error("❌ 401 Unauthorized. Check OPENAI_API_KEY.");
    } else if (msg.includes("404")) {
      console.error(`❌ 404 Not Found. Check model name "${model}".`);
    } else if (msg.includes("429")) {
      console.error("❌ 429 Rate limit. Try later or lower usage.");
    } else if (msg.includes("abort")) {
      console.error(`❌ Request timed out after ${timeoutMs}ms.`);
    } else {
      console.error("❌ Request failed:", msg);
    }
    process.exit(1);
  } finally {
    clearTimeout(t);
  }
}

main();
