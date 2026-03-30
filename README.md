# devkit

PowerShell installer for Cursor and VSCode -- opinionated settings, extensions, and color palette for a fresh Windows setup.

## Quick Start

```powershell
# Install Cursor only
.\install.ps1 -Editor Cursor

# Install VSCode only
.\install.ps1 -Editor VSCode

# Install both
.\install.ps1 -Editor Cursor,VSCode
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `-Editor` | (required) | `Cursor`, `VSCode`, or both |
| `-WindowsUser` | current user | Windows username |
| `-Theme` | `"Tokyo Night Light"` | Color theme |
| `-ColorEditor` | `#e8e3d8` | Editor background |
| `-ColorSidebar` | `#ddd8cc` | Sidebar background |
| `-ColorActivityBar` | `#ccc8bc` | Activity bar background |
| `-ColorStatusBar` | `#4a8fa3` | Status bar |
| `-ColorTitleBar` | `#ddd8cc` | Title bar |
| `-ColorTerminalBg` | `#f0ece0` | Terminal background |
| `-ColorTabActive` | `""` | Active tab |
| `-ColorTabInactive` | `""` | Inactive tab |
| `-ColorScrollbar` | `#00000040` | Scrollbar |
| `-ColorScrollbarHover` | `#00000060` | Scrollbar hover |
| `-ColorScrollbarActive` | `#00000080` | Scrollbar active |

## Extensions

**Cursor** (24 extensions):
Git tools (GitLens, etc.), Remote (SSH, WSL, Containers), Languages (Go, Rust, Python, TypeScript), DevOps (Terraform, Docker, Kubernetes, Makefile), Productivity (Error Lens, Spell Checker, Material Icons), Theme (Tokyo Night). Also uninstalls bundled Google Gemini/Cloud extensions.

**VSCode** (14 extensions):
Remote (SSH, WSL, Containers), Languages (Go, Rust, TypeScript), DevOps (Terraform), Productivity (Error Lens, Spell Checker, Material Icons), plus Spanish speech extensions.

## Defaults

- **Font:** JetBrains Mono with Cascadia Code fallback, ligatures enabled
- **Color palette:** Warm parchment tones -- pass `""` to any color parameter to use theme defaults instead

## Prerequisites

- Windows 10 1709+ or Windows 11
- [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) installed
- Restart the editor after the first run to activate extensions and settings

## License

MIT
