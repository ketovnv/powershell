# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Environment Overview

Windows PowerShell profile system with advanced theming, interactive menus, and Oh My Posh integration. Ukrainian color palette theme. Bilingual comments (Russian/English).

## Architecture

```
PowerShellProfile.ps1          # Entry point - loads Init.ps1, initializes Oh My Posh
├── Profile/Utils/Init.ps1     # Module loader - defines $scriptsBefore and $scriptsAfter
├── ultra.omp.toml             # Oh My Posh theme config
└── Profile/
    ├── Utils/                 # Core utilities, colors, database CLIs
    ├── Menu/                  # Interactive UI menus
    ├── Segments/              # Oh My Posh custom segments
    ├── Error/                 # Error handling system
    ├── Rich/                  # Python Rich integration
    └── Parser/                # AST analysis tools
```

### Two-Phase Loading (Init.ps1)

**Phase 1 - Immediate** (`$scriptsBefore`):
`EmojiSystem` → `ColorSystem` → `ColorManager` → `Colors` → `NiceColors` → `MenuBehavior` → `Aliases` → `ErrorHandler` → `RichColors` → `PostgreSQL` → `BunCLI`

**Phase 2 - Deferred** (`$global:scriptsAfter`, loaded after Oh My Posh init):
`LS` → `NetworkSystem` → `MenuItem` → `AppsBrowsersMenu` → `Welcome` → `ShowMenu` → `Weather` → `SitesMenu` → `Keyboard`

### Module Pattern

All modules use the Trace-ImportProcess pattern for load tracking:
```powershell
Trace-ImportProcess ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start
# ... module code ...
Trace-ImportProcess ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))
```

## Common Commands

```powershell
# Profile management
chs                              # Test-InitScripts - check module load status
re                               # reloadProfile - reload profile
pp                               # goto Profile folder

# Color system
wrgb "Text" -FC "#FF0000"        # Write-RGB colored output
Show-TestGradientFull            # Test gradient display
Check-ColorSystem                # Color diagnostics
Set-ColorTheme -ThemeName "Nord" # Switch theme

# Database CLIs (NSSM service management)
pg status                        # PostgreSQL status/start/stop/backup/users/logs
rd status                        # Redis status/start/stop/info/clear/logs

# Interactive menus
menu / mm                        # Show-ModernMainMenu

# Navigation aliases
~, c, desktop, downloads, docs   # Quick directory navigation
cd.., cd..., cd....              # Parent directories

# File tools
v <file>                         # view with bat
f <pattern>                      # rgf - ripgrep + fzf
fz <pattern>                     # fsearch - file content search

# Package management
wgs/wgi/wgu/wgl/wgrm            # winget search/install/upgrade/list/uninstall
```

## Key Configuration

| File | Purpose |
|------|---------|
| `ultra.omp.toml` | Oh My Posh theme with Ukrainian colors (`p:primary-blue`, `p:primary-yellow`) |
| `Utils/Init.ps1` | Module loading order and PSReadLine RGB colors |
| `Utils/ColorManager.ps1` | Palettes: Nord, Dracula, Material, Cyber, OneDark, Ukraine |
| `Utils/Aliases.ps1` | All shell aliases and navigation functions |
| `Utils/PostgreSQL.ps1` | PostgreSQL/Redis management via `pg`/`rd` commands (NSSM services) |
| `Menu/ModernMainMenu.ps1` | Interactive main menu system |

## Color System Stack

`ColorSystem.ps1` (base utilities) → `ColorManager.ps1` (palettes/themes) → `Colors.ps1` (file colors) → `NiceColors.ps1` (gradients/rainbow)

Key functions: `Write-RGB` (alias: `wrgb`), `Write-GradientText`, `Write-Rainbow`

## External Dependencies

- **Required**: Oh My Posh, PSFzf, syntax-highlighting, z, mcfly
- **Optional**: ThreadJob (background processing), bat, eza, ripgrep, fzf
- **Python**: Rich CLI for advanced formatting (pipx venv)

## Development Notes

- Global path: `$global:profilePath` points to `Profile/` folder
- Weather API key stored in `$global:openWeatherKey`
- Non-interactive mode detected via `$global:SkipInteractiveSetup`
- Scripts are digitally signed (signature block at end of PowerShellProfile.ps1)
- PSReadLine RGB color scheme configured in `Init.ps1` (Command=cyan, Parameter=orange, String=blue, etc.)
- Database paths use Scoop installations: `$env:USERPROFILE\Scoop\apps\postgresql` and `\redis`


# PROJECT_PLAN Integration
# Added by Claude Config Manager Extension

When working on this project, always refer to and maintain the project plan located at `PROJECT_PLAN.md` in the workspace root.

**Instructions for Claude Code:**
1. **Read the project plan first** - Always check `PROJECT_PLAN.md` when starting work to understand the project context, architecture, and current priorities.
2. **Update the project plan regularly** - When making significant changes, discoveries, or completing major features, update the relevant sections in PROJECT_PLAN.md to keep it current.
3. **Use it for context** - Reference the project plan when making architectural decisions, understanding dependencies, or explaining code to ensure consistency with project goals.

**Plan Mode Integration:**
- **When entering plan mode**: Read the current PROJECT_PLAN.md to understand existing context and priorities
- **During plan mode**: Build upon and refine the existing project plan structure
- **When exiting plan mode**: ALWAYS update PROJECT_PLAN.md with your new plan details, replacing or enhancing the relevant sections (Architecture, TODO, Development Workflow, etc.)
- **Plan persistence**: The PROJECT_PLAN.md serves as the permanent repository for all planning work - plan mode should treat it as the single source of truth

This ensures better code quality and maintains project knowledge continuity across different Claude Code sessions and plan mode iterations.
