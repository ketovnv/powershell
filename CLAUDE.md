# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Environment Overview

Windows PowerShell 7.2+ profile system with advanced theming, interactive menus, and Oh My Posh integration. Ukrainian color palette theme (`#0057B7`/`#FFD500`). Bilingual comments (Russian/English). Requires `$PSStyle` support.

## Architecture

```
PowerShellProfile.ps1          # Entry point - loads Init.ps1, initializes Oh My Posh
├── Profile/Utils/Init.ps1     # Module loader - defines $scriptsBefore and $scriptsAfter
├── ultra.omp.toml             # Oh My Posh theme config (Ukrainian palette)
├── wezterm.lua                # WezTerm terminal config (font, opacity, WSL keybindings)
└── Profile/
    ├── Utils/                 # Core utilities, colors, database CLIs
    ├── Menu/                  # Interactive UI menus (including LS.ps1 - PowerColorLS)
    ├── Segments/              # Oh My Posh custom segments (Weather, Network, DiskUsage, etc.)
    ├── Error/                 # Error handling: ExtractErrorDetails → SmartError → ShowError
    ├── Rich/                  # Python Rich integration (Show-PrettyObject, syntax highlighting)
    └── Parser/                # AST analysis tools
```

### Two-Phase Loading (Init.ps1)

**Phase 1 - Immediate** (`$scriptsBefore`):
`EmojiSystem` → `ColorSystem` → `ColorManager` → `Colors` → `NiceColors` → `MenuBehavior` → `Aliases` → `ErrorHandler` → `RichColors` → `PostgreSQL` → `BunCLI`

**Phase 2 - Deferred** (`$global:scriptsAfter`, loaded after Oh My Posh init):
`LS` → `NetworkSystem` → `MenuItem` → `AppsBrowsersMenu` → `Welcome` → `ShowMenu` → `Weather` → `SitesMenu` → `Keyboard`

Then `ModernMainMenu.ps1` is dot-sourced explicitly at the end of `PowerShellProfile.ps1`.

### Module Pattern

**Dot-sourcing only** — no `.psm1` modules. All scripts are dot-sourced via `. "${global:profilePath}${script}.ps1"`, keeping all functions in the global scope.

Every module uses Trace-ImportProcess for load tracking:
```powershell
Trace-ImportProcess ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)) -start
# ... module code ...
Trace-ImportProcess ([System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name))
```
This populates `$global:initStartScripts` and `$global:initEndScripts`. Use `chs` (Test-InitScripts) to check load status.

## Common Commands

```powershell
# Profile management
chs                              # Test-InitScripts - check module load status
re                               # reloadProfile - reload profile
pp                               # goto Profile folder

# Color system
wrgb "Text" -FC "#FF0000"        # Write-RGB (accepts HEX, palette name, or system color)
wgt "Text" -StartColor "#0057B7" -EndColor "#FFD500"  # Write-GradientText
Show-TestGradientFull            # Test gradient display
Check-ColorSystem                # Color diagnostics
Set-ColorTheme -ThemeName "Nord" # Switch theme (Nord/Dracula/Material/Cyber/OneDark/Ukraine)

# Database CLIs (NSSM service management, Scoop paths)
pg status                        # PostgreSQL status/start/stop/backup/users/logs
rd status                        # Redis status/start/stop/info/clear/logs

# Interactive menus
menu / mm                        # Show-ModernMainMenu
fm/nt/sm/dt/ql/ps/cs/db/hd      # Sub-menu shortcuts

# Rich/Python integration
spj $object                      # Show-PrettyObject -View Json
spt $object                      # Show-PrettyObject -View Tree
sptb $object                     # Show-PrettyObject -View Table
spkv $object                     # Show-PrettyObject -View KeyValue
pex <file>                       # Syntax-highlighted file view via Python Rich
grad "text"                      # Rich gradient panel

# Navigation aliases
~, c, desktop, downloads, docs   # Quick directory navigation
cd.., cd..., cd....              # Parent directories
kr, cy, ad, pm                   # Project directory shortcuts

# File tools
v <file>                         # view with bat
f <pattern>                      # rgf - ripgrep + fzf
fz <pattern>                     # fsearch - file content search
ez                               # eza (enhanced ls)

# Package management
wgs/wgi/wgu/wgl/wgrm            # winget search/install/upgrade/list/uninstall
```

## Key Configuration

| File | Purpose |
|------|---------|
| `ultra.omp.toml` | Oh My Posh theme with Ukrainian colors (`p:primary-blue`, `p:primary-yellow`) |
| `Utils/Init.ps1` | Module loading order and PSReadLine RGB colors |
| `Utils/ColorManager.ps1` | Palettes: Nord, Dracula, Material, Cyber, OneDark, Ukraine |
| `Utils/Aliases.ps1` | All shell aliases, navigation functions, and environment variables |
| `Utils/PostgreSQL.ps1` | PostgreSQL/Redis management via `pg`/`rd` commands (NSSM services) |
| `Menu/ModernMainMenu.ps1` | Interactive main menu system (current, Ukraine gradient) |
| `Menu/LS.ps1` | PowerColorLS - custom `ls` replacement |
| `wezterm.lua` | WezTerm: pwsh default, Ctrl+k=Kali WSL, Ctrl+u=Ubuntu, F12=new tab, Cyrillic bindings |

## Color System Stack

```
ColorSystem.ps1    → Base: HEX↔RGB conversion, gradient engine, $script:ColorSystemConfig
ColorManager.ps1   → Palettes ($global:ColorPalettes), themes ($global:ColorThemes), $script:ColorManagerConfig
Colors.ps1         → Data: $global:newHexColors, $global:additionalColors, $global:colorsRGB, $global:RAINBOWGRADIENT, Get-FileColor, LS_COLORS
NiceColors.ps1     → Output: Write-RGB (wrgb), Write-GradientText, Write-Rainbow, Show-Palette, $global:RGB hashtable
```

`Write-RGB` params: `-FC` (foreground), `-BC` (background), `-Style` (Normal/Bold/Italic/Underline/Blink), `-newline`. Resolves names against `$global:RGB`.

## OMP Custom Segments

Segments in `Profile/Segments/` update environment variables (`$env:OMP_WEATHER`, `$env:OMP_NETWORK`, `$env:OMP_DISK_USAGE`, etc.) that OMP reads via `env` segment type. `SegmentUpdater.ps1` runs a background updater every ~30s using `ThreadJob` or `System.Timers.Timer`.

## Key Global Variables

| Variable | Source | Purpose |
|----------|--------|---------|
| `$global:profilePath` | PowerShellProfile.ps1 | Path to `Profile/` folder |
| `$global:RGB` | Colors.ps1/NiceColors.ps1 | Master hashtable: name → `{R,G,B}` |
| `$global:newHexColors` | Colors.ps1 | HEX palettes (Nord, Dracula, etc.) |
| `$global:ColorPalettes` | ColorManager.ps1 | Structured palette definitions |
| `$global:ColorThemes` | ColorManager.ps1 | Themes with Primary/Secondary/Success/Warning/Error/Info |
| `$global:openWeatherKey` | PowerShellProfile.ps1 | OpenWeatherMap API key |
| `$global:SkipInteractiveSetup` | PowerShellProfile.ps1 | Set when non-interactive |
| `$global:icons` | NiceColors.ps1 | Lazy-loaded from `glyphs.psd1` |
| `$global:richFolder` | RichColors.ps1 | Path to `Profile/Rich/` |

## External Dependencies

- **Required**: Oh My Posh, PSFzf, syntax-highlighting, z, mcfly
- **Optional**: ThreadJob (background segments), bat, eza, ripgrep, fzf, micro, btop
- **Python**: Rich CLI for advanced formatting (pipx venv), pygmentize for `lessh`/`cath`
- **Services**: NSSM (service manager), Scoop (PostgreSQL/Redis installed via Scoop)
- **Terminal**: WezTerm (configured via `wezterm.lua`)

## Development Notes

- Scripts are digitally signed (signature block at end of `PowerShellProfile.ps1`)
- PSReadLine RGB color scheme in `Init.ps1`: Command=cyan-green, Parameter=orange, String=light-blue, Variable=purple, Number=magenta
- Database paths: `$env:USERPROFILE\Scoop\apps\postgresql` and `\redis`
- API keys and tokens are stored directly in `Aliases.ps1` (existing pattern — be aware when committing)
- Known function duplication: `Show-DatabaseMenu` and `Show-DevToolsMenu` exist in both `MenuItem.ps1` and `ModernMainMenu.ps1`; color conversion helpers duplicated between `ColorSystem.ps1` and `NiceColors.ps1` with fallback logic
- `Welcome.ps1` detects WezTerm via `$env:WEZTERM_CONFIG_DIR` for emoji rendering decisions
- Tests directory exists (18 scripts) but is gitignored — uses PowerShell native syntax parsing, not Pester
