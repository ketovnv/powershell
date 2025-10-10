# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Environment Overview

This is a sophisticated Windows PowerShell user profile system with advanced theming, monitoring, and extensibility capabilities. The architecture uses a modular approach with 41+ PowerShell files organized across 5 main directories in the `Profile/` folder.

## Architecture Overview

### Core Profile Structure
- `PowerShellProfile.ps1` - Main entry point that loads the modular system
- `Profile/` - Modular components organized in subdirectories:
  - `Utils/` (15 files) - Core utilities, color systems, initialization
  - `Menu/` (7 files) - Interactive UI components and menus
  - `Segments/` (6 files) - Oh My Posh custom segments for system info
  - `Parser/` (4 files) - Text parsing and AST analysis tools
  - `Rich/` (2 files) - Python integration for advanced formatting

### Key Architectural Patterns

**Two-Phase Loading System:**
1. **Fast Initialization** (`$scriptsBefore`): Essential utilities loaded immediately
2. **Deferred Loading** (`$global:scriptsAfter`): UI components loaded after 3-second delay

**Trace-ImportProcess Pattern:**
All modules use standardized import tracking with success/failure monitoring.

## Common Development Commands

### Profile Management
```powershell
# Check module loading status
Test-InitScripts                    # (alias: chs)
Trace-ImportProcess -finalInitialization

# View current status of all systems
Show-OmpSegments                    # (alias: omps) - Show Oh My Posh segments
Reset-OmpSegments                   # (alias: ompr) - Reset and restart segments
Test-OmpSegments                    # (alias: ompt) - Test each segment individually
```

### Development and Analysis Tools
```powershell
# Analyze PowerShell functions and modules
Explore-Command <CommandName>
Export-AstToMarkdown

# Color system testing
Show-TestGradientFull
wrgb "Text" -FC Material_Blue -BC Dracula_Background

# Menu system testing  
Show-Menu -MenuItems @(@{Text="Test"}) -Title "Test Menu"
```

### Oh My Posh Integration
```powershell
# Segment management
Update-WeatherSegment
Update-NetworkSegment  
Update-SystemHealthSegment
Update-DiskUsageSegment

# Set weather API key for real weather data
Set-WeatherApiKey 'your_api_key_here'

# Start/stop background segment updater
Start-OmpSegmentUpdater -IntervalSeconds 30
Stop-OmpSegmentUpdater
```

### System Monitoring
```powershell
# Command usage statistics
Start-CommandMonitor -ShowLiveStats
Show-CommandStatistics -Top10

# Network and system tools
Start-NmapScan
Get-NetworkSegment
Get-SystemHealthSegment
```

## Key Configuration Files

- `PowerShellProfile.ps1` - Main profile entry point with Oh My Posh initialization
- `Profile/Utils/Init.ps1` - Core initialization system with module loading order
- `ultra.omp.toml` - Oh My Posh theme configuration with Ukrainian color palette
- `Profile/Utils/Colors.ps1` - Advanced RGB color system with multiple themes
- `Profile/Segments/SegmentUpdater.ps1` - Background segment update system

## Module Dependencies

Critical loading sequence:
1. Security & encoding setup
2. Color system (Colors.ps1 → NiceColors.ps1 → ColorSystem.ps1)  
3. Input/output systems (Keyboard.ps1, ProgressBar.ps1)
4. External modules (PSFzf, syntax-highlighting, z)
5. PSReadLine advanced configuration
6. Deferred UI components

## Background Processing

The profile includes sophisticated background processing:
- **ThreadJob Integration**: Asynchronous data loading
- **Background Daemon**: Continuous monitoring with configurable intervals
- **Environment Variables**: Oh My Posh segments via `OMP_*` variables
- **Auto-cleanup**: Background job management on PowerShell exit

## Error Handling

Advanced error system with:
- Multi-language support (Russian/English)
- RGB-colored error display
- Stack trace analysis
- Configurable verbosity levels

## Performance Features

- **Deferred Loading**: Heavy functions loaded 3 seconds after startup
- **Module Caching**: Existence checks prevent repeated imports  
- **Memory Management**: Cleanup handlers for background processes
- **Fast Startup**: Core functionality available immediately

When modifying this profile system, always consider the module loading order and use the Trace-ImportProcess pattern for new components.

# PROJECT_PLAN Integration
# Added by Claude Config Manager Extension

When working on this project, always refer to and maintain the project plan located at `.claude/.plans/PROJECT_PLAN.md`.

**Instructions for Claude Code:**
1. **Read the project plan first** - Always check `.claude/.plans/PROJECT_PLAN.md` when starting work to understand the project context, architecture, and current priorities.
2. **Update the project plan regularly** - When making significant changes, discoveries, or completing major features, update the relevant sections in PROJECT_PLAN.md to keep it current.
3. **Use it for context** - Reference the project plan when making architectural decisions, understanding dependencies, or explaining code to ensure consistency with project goals.

**Plan Mode Integration:**
- **When entering plan mode**: Read the current PROJECT_PLAN.md to understand existing context and priorities
- **During plan mode**: Build upon and refine the existing project plan structure
- **When exiting plan mode**: ALWAYS update PROJECT_PLAN.md with your new plan details, replacing or enhancing the relevant sections (Architecture, TODO, Development Workflow, etc.)
- **Plan persistence**: The PROJECT_PLAN.md serves as the permanent repository for all planning work - plan mode should treat it as the single source of truth

This ensures better code quality and maintains project knowledge continuity across different Claude Code sessions and plan mode iterations.
