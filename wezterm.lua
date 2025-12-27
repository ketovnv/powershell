local wezterm = require("wezterm");
local config = wezterm.config_builder();
local act = wezterm.action;
config.unix_domains = {
    {
        name = 'wsl',
        serve_command = { 'wsl', 'wezterm-mux-server', '--daemonize' },
    },
}


local function prompt_and_new_session(domain)
    return wezterm.action.PromptInputLine {
        description = "New tmux session name",
        action = wezterm.action_callback(function(window, pane, line)
            if not line or line == "" then return end
            window:perform_action(
                wezterm.action.SpawnCommandInNewTab {
                    args = {
                        "wsl", "-d", "Ubuntu", "-u", "root", "--",
                        "tmux", "new", "-s", line -- каждое слово отдельно
                    },
                },
                pane
            )
        end),
    }
end



wezterm.on("gui-startup", function(cmd)
    local _tab, _pane, window = wezterm.mux.spawn_window(cmd or {});
    local gui_window = window:gui_window();
    local dimensions = gui_window:get_dimensions();
    local main_screen = (wezterm.gui.screens()).main;
    local x = 100;
    local y = 50;
    gui_window:set_position(x, y);
end);
local themes = {
    "Catppuccin Mocha",
    "Tokyo Night",
    "OneHalfDark",
    "Gruvbox Dark",
    "Argonaut"
};
local function recompute_padding(window)
    local window_dims = window:get_dimensions();
    local overrides = window:get_config_overrides() or {};
    if not window_dims.is_full_screen then
        -- В оконном режиме используем стандартные отступы
        overrides.window_padding = {
            left = 0,
            right = 1,
            top = 0,
            bottom = 32
        };
    else
        -- В полноэкранном режиме убираем отступы полностью
        overrides.window_padding = {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0
        };
    end;
    window:set_config_overrides(overrides);
end;
wezterm.on("window-resized", function(window, pane)
    recompute_padding(window);
end);
wezterm.on("window-config-reloaded", function(window)
    recompute_padding(window);
end);
local current_theme_index = 1;
wezterm.on("toggle-theme", function(window)
    current_theme_index = current_theme_index % (#themes) + 1;
    local overrides = window:get_config_overrides() or {};
    overrides.color_scheme = themes[current_theme_index];
    window:set_config_overrides(overrides);
    window:toast_notification("WezTerm Theme", "🎨 " .. themes[current_theme_index], nil, 4000);
end);
wezterm.on("toggle-full-screen", function(window, pane)
    window:perform_action(act.ToggleFullScreen, pane);
    recompute_padding(window);
end);
wezterm.on("update-status", function(window, pane)
    if not pane then
        return;
    end;
    local cwd = pane:get_current_working_dir();
    local hostname = "";
    local cwd_path = "";
    if cwd then
        hostname = cwd.host or wezterm.hostname() or "localhost";
        cwd_path = cwd.path or "";
        cwd_path = cwd_path:gsub("^file://[^/]*", "");
        local replacements = {
            ["projects/crypta"] = "💲 ",
            github = "🐙 GITHUB",
            projects = "🏭",
            ["/home"] = "🏰",
            ["C:/Users/ketov"] = "🙂"
        };
        for pattern, icon in pairs(replacements) do
            cwd_path = cwd_path:gsub(pattern, icon);
        end;
    end;
    cwd_path = cwd_path:gsub(".*crypta.*", "💲");
    cwd_path = cwd_path:gsub("^%s*(.-)%s*$", "%1");
    local left_status = string.format("💻");
    local time = wezterm.strftime("%H:%M");
    local date = wezterm.strftime("%d %B");
    local right_status = string.format("  📅 %s 🕐 %s ", date, time);

    window:set_left_status(wezterm.format({
        {
            Background = {
                Color = "#000000"
            }
        },
        {
            Foreground = {
                Color = "#7aa2f7"
            }
        },
        {
            Text = left_status
        }
    }));
    window:set_right_status(wezterm.format({
        {
            Background = {
                Color = "#000000"
            }
        },
        {
            Foreground = {
                Color = "#77DCFF"
            }
        },
        {
            Text = right_status
        }
    }));
end);
config.window_frame = {
    font = wezterm.font('Roboto'),
    font_size = 12,
    --  inactive_titlebar_bg = "#353535",
    --  active_titlebar_bg = "#000000",
    --  inactive_titlebar_fg = "#cccccc",
    --  active_titlebar_fg = "#ffffbb",
    --  inactive_titlebar_border_bottom = "#333333",
    --  active_titlebar_border_bottom = "#000000",
    --  button_fg = "#cccccc",
    --  button_bg = "#000000",
    --  button_hover_fg = "#ffffff",
};

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
    local title = tab.tab_title;
    if not title or title == "" then
        title = tab.active_pane.title;
    end;
    title = title:gsub(".*pwsh%.exe.*", "Pwsh 7.6");
    title = title:gsub(".*powershell%.exe.*", "PS");
    title = title:gsub(".*zsh.*", "Zsh");
    title = title:gsub(".*bash.*", "Bash");
    local icon = tab.is_active and "🚀" or "🥷";
    title = title:gsub("^%s*(.-)%s*$", "%1");
    if #title > 20 then
        title = title:sub(1, 17) .. "...";
    end;
    return string.format(" %s %s ", icon, title);
end);
config.mouse_bindings = {
    {
        event = {
            Up = {
                streak = 1,
                button = "Left"
            }
        },
        mods = "NONE",
        action = act.CompleteSelection("Clipboard")
    },
    {
        event = {
            Drag = {
                streak = 1,
                button = "Left"
            }
        },
        mods = "NONE",
        action = act.ExtendSelectionToMouseCursor("Cell")
    }
};


--config.disable_default_key_bindings = true;
config.enable_kitty_keyboard = true;
config.leader = {
    key = "Delete",
    mods = "CTRL",
    timeout_milliseconds = 3000
};
config.keys = {
    {
        key = "c",
        mods = "LEADER",
        action = act.SpawnTab("CurrentPaneDomain"),
    },
    {
        key = "Enter",
        mods = "SHIFT",
        action = wezterm.action { SendString = "\x1b\r" }
    },
    {
        key = 'L',
        mods = 'CTRL',
        action = act.ShowLauncher,
    },

    {
        key = "PageUp",
        mods = "SHIFT",
        action = act.ScrollByPage(-1)
    },
    {
        key = "PageDown",
        mods = "SHIFT",
        action = act.ScrollByPage(1),
    },
    {
        key = "x",
        mods = "LEADER",
        action = act.CloseCurrentPane({
            confirm = false
        })
    },
    {
        key = "m",
        mods = "LEADER",
        action = wezterm.action.SpawnCommandInNewTab({
            args = {
                "mc"
            }
        })
    },
    {
        key = "F12",
        action = wezterm.action.SpawnCommandInNewTab({
            args = {
                "pwsh.exe",
                "-NoLogo"
            }
        })
    },
    {
        key = "k",
        mods = "CTRL",
        action = wezterm.action.SpawnCommandInNewTab({
            args = {
                "C:\\Program Files\\WSL\\wslg.exe",
                "-d", "kali-linux",
                "-u", "root",
                "--cd", "~",
                "--",
                "kitty-wslg"
            }
        })
    },
    {
        key = "л",
        mods = "CTRL",
        action = wezterm.action.SpawnCommandInNewTab({
            args = {
                "C:\\Program Files\\WSL\\wslg.exe",
                "-d", "kali-linux",
                "-u", "root",
                "--cd", "~",
                "--",
                "kitty-wslg"
            }
        })
    },
    {
        key = "k",
        mods = "ALT",
        action = wezterm.action.SpawnCommandInNewTab({
            args = {
                "wsl",
                "-d",
                "kali-linux",
                "--",
                "kitty",
                "--start-as=fullscreen"
            }
        })
    },
    {
        key = "щ",
        mods = "ALT",
        action = wezterm.action.SpawnCommandInNewTab({
            args = {
                "wsl",
                "-d",
                "kali-linux",
                "--",
                "kitty",
                "--start-as=fullscreen"
            }
        })
    },
    {
        key = "u",
        mods = "CTRL",
        action = wezterm.action.SpawnCommandInNewTab({
            args = {
                "wsl",
                "-u",
                "root"
            }
        })
    },
    {
        key = "г",
        mods = "CTRL",
        action = prompt_and_new_session("WSL:Ubuntu")
    },
    {
        key = "t",
        mods = "CTRL",
        action = wezterm.action.EmitEvent("toggle-theme")
    },
    {
        key = "F11",
        action = wezterm.action.EmitEvent("toggle-full-screen")
    },
    {
        key = "f",
        mods = "CTRL",
        action = act.Search("CurrentSelectionOrEmptyString")
    },
    {
        key = "c",
        mods = "CTRL",
        action = wezterm.action_callback(function(window, pane)
            if pane:has_selection() then
                window:perform_action(act.CopyTo("Clipboard"), pane);
            else
                window:perform_action(act.SendKey({
                    key = "c",
                    mods = "CTRL"
                }), pane);
            end;
        end)
    },
    {
        key = "v",
        mods = "CTRL",
        action = act.PasteFrom("Clipboard")
    },
    {
        key = "F1",
        action = act.CopyTo("Clipboard")
    },
    {
        key = "F2",
        action = act.PasteFrom("Clipboard")
    },
    {
        key = "Insert",
        mods = "SHIFT",
        action = act.PasteFrom("Clipboard")
    },
    {
        key = "Insert",
        mods = "CTRL",
        action = act.CopyTo("Clipboard")
    },
    {
        key = "+",
        mods = "CTRL",
        action = act.IncreaseFontSize
    },
    {
        key = "-",
        mods = "CTRL",
        action = act.DecreaseFontSize
    },
    {
        key = ".",
        mods = "CTRL",
        action = act.ResetFontSize
    },
    {
        key = "RightArrow",
        mods = "ALT|CTRL",
        action = act.AdjustPaneSize({
            "Right",
            5
        })
    },
    {
        key = "\\",
        mods = "CTRL",
        action = act.SplitHorizontal({
            domain = "CurrentPaneDomain"
        })
    },
    {
        key = "|",
        mods = "CTRL",
        action = act.SplitVertical({
            domain = "CurrentPaneDomain"
        })
    },
    {
        key = "b",
        mods = "CTRL",
        action = wezterm.action_callback(function(window, pane)
            local overrides = window:get_config_overrides() or {};
            if not overrides.window_background_opacity then
                overrides.window_background_opacity = 0.1;
            else
                overrides.window_background_opacity = nil;
            end;
            window:set_config_overrides(overrides);
        end)
    },
    {
        key = "p",
        mods = "CTRL",
        action = act.ActivateCommandPalette
    },
    {
        key = "F10",
        mods = "CTRL",
        action = act.ActivateCommandPalette
    },
    {
        key = "0",
        mods = "CTRL",
        action = act.ShowDebugOverlay
    },
    {
        key = "z",
        mods = "CTRL",
        action = act.TogglePaneZoomState
    },
    {
        key = "~",
        mods = "CTRL",
        action = act.ToggleAlwaysOnTop
    },
    -- Полезные дополнительные биндинги
    {
        key = "w",
        mods = "CTRL",
        action = act.CloseCurrentTab({ confirm = false })
    },
    {
        key = "ц",
        mods = "CTRL",
        action = act.CloseCurrentTab({ confirm = false })
    },
    {
        key = "Tab",
        mods = "CTRL",
        action = act.ActivateTabRelative(1)
    },
    {
        key = "Tab",
        mods = "CTRL|SHIFT",
        action = act.ActivateTabRelative(-1)
    },
    {
        key = "Enter",
        mods = "ALT",
        action = wezterm.action.EmitEvent("toggle-full-screen")
    }
};

for i = 1, 9 do
    table.insert(config.keys, {
        key = tostring(i),
        mods = "CTRL",
        action = act.ActivateTab(i - 1)
    });
end;
config.initial_cols = 120;
config.initial_rows = 25;
config.scrollback_lines = 10000;
config.enable_scroll_bar = true;
config.default_prog = {
    "pwsh.exe",
    "-NoLogo"
};
config.default_cwd = "C:/projects/CaaS/frontend";
config.front_end = "WebGpu";
config.webgpu_power_preference = "HighPerformance";
config.animation_fps = 144;
config.max_fps = 144;
config.font = wezterm.font_with_fallback({
    {
        family = "RecMonoCasual Nerd Font",
        weight = "Regular"
    },
    {
        family = "JetBrains Mono",
        assume_emoji_presentation = true,
        weight = "Regular",
        harfbuzz_features = {
            "calt=0",
            "clig=0",
            "liga=0"
        }
    },
    {
        family = "JetBrains Mono"
    }
});
config.freetype_load_target = "Light";
config.freetype_render_target = "Light";
config.anti_alias_custom_block_glyphs = true;
config.display_pixel_geometry = "RGB";
config.line_height = 1.15;
config.foreground_text_hsb = {
    hue = 1,
    saturation = 1.25,
    brightness = 1.1
};
config.font_size = 20;
config.colors = {
    foreground = "#F1F2AB",
    cursor_bg = "#CCff00",
    cursor_fg = "#000000",
    cursor_border = "#FFaa22",
    selection_bg = "#122035",
    selection_fg = "#FFbb55",
    split = "#113972",
    tab_bar = {
        background = "rgba(22,22,33,1)",
        active_tab = {
            bg_color = "#000000",
            fg_color = "#FFF577",
            intensity = "Bold"
        },
        inactive_tab = {
            bg_color = "#000000",
            fg_color = "#343c3F"
        },
        inactive_tab_hover = {
            bg_color = "#000000",
            fg_color = "#7aa2FF"
        },
        new_tab = {
            bg_color = "#000000",
            fg_color = "#3aC2FF"
        },
        new_tab_hover = {
            bg_color = "#000000",
            fg_color = "#FFFFFF"
        }
    },
    scrollbar_thumb = '#222222',
    -- The color of the split lines between panes
    ansi = {
        'black',
        'maroon',
        'green',
        'olive',
        'navy',
        'purple',
        'teal',
        'silver',
    },
    brights = {
        'grey',
        'red',
        'lime',
        'yellow',
        'blue',
        'fuchsia',
        'aqua',
        'white',
    },
    -- Arbitrary colors of the palette in the range from 16 to 255
    indexed = { [136] = '#af8700' },
    -- Since: 20220319-142410-0fcdea07
    -- When the IME, a dead key or a leader key are being processed and are effectively
    -- holding input pending the result of input composition, change the cursor
    -- to this color to give a visual cue about the compose state.
    compose_cursor = 'orange',
    -- Colors for copy_mode and quick_select
    -- available since: 20220807-113146-c2fee766
    -- In copy_mode, the color of the active text is:
    -- 1. copy_mode_active_highlight_* if additional text was selected using the mouse
    -- 2. selection_* otherwise
    copy_mode_active_highlight_bg = { Color = '#000000' },
    -- use `AnsiColor` to specify one of the ansi color palette values
    -- (index 0-15) using one of the names "Black", "Maroon", "Green",
    --  "Olive", "Navy", "Purple", "Teal", "Silver", "Grey", "Red", "Lime",
    -- "Yellow", "Blue", "Fuchsia", "Aqua" or "White".
    copy_mode_active_highlight_fg = { AnsiColor = 'Black' },
    copy_mode_inactive_highlight_bg = { Color = '#52ad70' },
    copy_mode_inactive_highlight_fg = { AnsiColor = 'White' },
    quick_select_label_bg = { Color = 'peru' },
    quick_select_label_fg = { Color = '#ffffff' },
    quick_select_match_bg = { AnsiColor = 'Navy' },
    quick_select_match_fg = { Color = '#ffffff' },
    -- input_selector_label_bg = { AnsiColor = 'Black' }, -- (*Since: Nightly Builds Only*)
    -- input_selector_label_fg = { Color = '#ffffff' },   -- (*Since: Nightly Builds Only*)
    -- launcher_label_bg = { AnsiColor = 'Black' },       -- (*Since: Nightly Builds Only*)
    -- launcher_label_fg = { Color = '#ffffff' },         -- (*Since: Nightly Builds Only*)
};
-- config.window_background_gradient = {
-- colors = {
-- "#000000",
-- "#000000",
-- "#000000",
-- "#000000",
-- "#000000",
-- "#000000",
-- "#000000",
-- "#000000",
-- "#000000",
-- "#000000",
-- "#000000",
-- "#000000",
-- "#000503",
-- "#000504",
-- "#000000",
-- "#030708",
-- "#050607",
-- "#000000",
-- "#091520",
-- "#000305",
-- "#000000",
-- "#000203",
-- "#000305",
-- "#000000",
-- "#091216"
--     },
--     orientation = {
--         Linear = {
--             angle = -75,
--             interpolation = "CatmullRom",
--             blend = "Oklab"
--         }
--     }
-- };
-- config.window_background_opacity = 0.85;
config.window_background_opacity = 0.3
config.win32_system_backdrop = 'Mica'
--config.win32_acrylic_accent_color = "#000000";
config.hide_tab_bar_if_only_one_tab = true;

config.window_decorations = "INTEGRATED_BUTTONS|RESIZE";

config.window_padding = {
    left = 1,
    right = 1,
    top = 1,
    bottom = 32
};
config.enable_tab_bar = true;
config.use_fancy_tab_bar = false;
config.tab_bar_at_bottom = true;
config.tab_max_width = 50;
config.window_close_confirmation = "NeverPrompt";
config.visual_bell = {
    fade_in_function = "EaseIn",
    fade_in_duration_ms = 150,
    fade_out_function = "EaseOut",
    fade_out_duration_ms = 150
};
config.default_cursor_style = "BlinkingBar";
config.cursor_blink_rate = 1000;
config.cursor_blink_ease_in = "Constant";
config.cursor_blink_ease_out = "Constant";

config.launch_menu = {
    {
        label = "📦 Bun Shell",
        args = {
            "bun",
            "repl"
        }
    },
    {
        label = "🚀⚡ PowerShell 7",
        args = {
            "pwsh.exe",
            "-NoLogo"
        }
    },
    {
        label = "🪟 Command Prompt",
        args = {
            "cmd.exe"
        }
    },
    {
        label = "🐙 Git Bash",
        args = {
            "C:/Program Files/Git/bin/bash.exe",
            "-i",
            "-l"
        }
    },
    {
        label = "😺 Kitty",
        args = {
            "wsl.exe",
            "-d",
            "kali-linux",
            "--",
            "kitty",
            "--start-as=fullscreen"
        }
    },
    {
        label = "🐧 Ubuntu Linux",
        args = {
            "wsl.exe",
            "-d",
            "ubuntu",
            "-u",
            "root"
        }
    },
    {
        label = "⚙️ Wezterm Config (Micro)",
        args = {
            "pwsh.exe",
            "-NoExit",
            "-Command",
            "micro ~/.wezterm.lua"
        }
    },
    {
        label = "⚙️ Wezterm Config (Sublime Text)",
        args = {
            "pwsh.exe",
            "-NoExit",
            "-Command",
            "subl ~/.wezterm.lua"
        }
    },
    {
        label = "⚙️ Wezterm Config (Zed)",
        args = {
            "pwsh.exe",
            "-NoExit",
            "-Command",
            "zed C:/Users/ketov/.wezterm.lua"
        }
    }
};



--config.color_scheme = "AdventureTime";
return config;
