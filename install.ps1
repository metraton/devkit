# =============================================================================
# devkit/install.ps1 — Install and configure editors on a new Windows PC
# Usage:
#   .\install.ps1 -Editor Cursor
#   .\install.ps1 -Editor VSCode
#   .\install.ps1 -Editor Cursor,VSCode
# =============================================================================

param(
    [Parameter(Mandatory=$true)]
    [string[]]$Editor,

    [string]$WindowsUser = $env:USERNAME,
    [string]$WslDistro   = "sandbox--aaxis-env",
    [string]$Theme       = "Tokyo Night Light",

    # Color overrides — leave empty ("") to use theme defaults
    [string]$ColorEditor       = "#c0c0c0",  # background where you write code
    [string]$ColorSidebar      = "#c7d0d4",  # file explorer panel (left)
    [string]$ColorActivityBar  = "#c0c0c0",  # icon bar (far left)
    [string]$ColorStatusBar    = "#4a8fa3",  # bottom bar with git/errors
    [string]$ColorTitleBar     = "#c0c0c0",  # top bar with file name
    [string]$ColorTerminalBg   = "#c0c0c0",  # integrated terminal background
    [string]$ColorTabActive    = "",          # active tab (current file)
    [string]$ColorTabInactive  = ""           # inactive tabs
)

$installCursor = $Editor -contains "Cursor"
$installVSCode = $Editor -contains "VSCode"

if (-not $installCursor -and -not $installVSCode) {
    Write-Error "Invalid -Editor value. Use: Cursor, VSCode, or Cursor,VSCode"
    exit 1
}

function Log($msg)  { Write-Host "[devkit] $msg" -ForegroundColor Cyan }
function Ok($msg)   { Write-Host "  OK  $msg" -ForegroundColor Green }
function Skip($msg) { Write-Host " SKIP $msg" -ForegroundColor DarkGray }
function Warn($msg) { Write-Host " WARN $msg" -ForegroundColor Yellow }

# =============================================================================
# Install editors via winget
# =============================================================================

if ($installCursor) {
    Log "Installing Cursor..."
    $out = winget install --id Anysphere.Cursor -e --silent 2>&1
    if ($LASTEXITCODE -eq 0) { Ok "Cursor installed" }
    else { Warn "Cursor may already be installed or winget failed — continuing" }
}

if ($installVSCode) {
    Log "Installing VSCode..."
    $out = winget install --id Microsoft.VisualStudioCode -e --silent 2>&1
    if ($LASTEXITCODE -eq 0) { Ok "VSCode installed" }
    else { Warn "VSCode may already be installed or winget failed — continuing" }
}

# Reload PATH so cursor/code CLIs are available in this session
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("PATH", "User")

# =============================================================================
# Build color customizations block
# =============================================================================

$colorBlock = ""
$colorEntries = @()
if ($ColorEditor)      { $colorEntries += "        `"editor.background`": `"$ColorEditor`"" }
if ($ColorSidebar)     { $colorEntries += "        `"sideBar.background`": `"$ColorSidebar`"" }
if ($ColorActivityBar) { $colorEntries += "        `"activityBar.background`": `"$ColorActivityBar`"" }
if ($ColorStatusBar)   { $colorEntries += "        `"statusBar.background`": `"$ColorStatusBar`"" }
if ($ColorTitleBar)    { $colorEntries += "        `"titleBar.activeBackground`": `"$ColorTitleBar`"" }
if ($ColorTerminalBg)  { $colorEntries += "        `"terminal.background`": `"$ColorTerminalBg`"" }
if ($ColorTabActive)   { $colorEntries += "        `"tab.activeBackground`": `"$ColorTabActive`"" }
if ($ColorTabInactive) { $colorEntries += "        `"tab.inactiveBackground`": `"$ColorTabInactive`"" }

if ($colorEntries.Count -gt 0) {
    $inner = $colorEntries -join ",`n"
    $colorBlock = @"
,
    "workbench.colorCustomizations": {
        "[$Theme]": {
$inner
        }
    }
"@
}

# =============================================================================
# Settings
# =============================================================================

$cursorSettingsPath = "C:\Users\$WindowsUser\AppData\Roaming\Cursor\User\settings.json"
$vscodeSettingsPath = "C:\Users\$WindowsUser\AppData\Roaming\Code\User\settings.json"

$cursorSettings = @"
{
    "window.commandCenter": 1,
    "files.associations": { "*.hcl": "terraform" },
    "redhat.telemetry.enabled": false,
    "terminal.integrated.defaultProfile.windows": "$WslDistro (WSL)",
    "terminal.integrated.defaultProfile.linux": "bash",
    "git.suggestSmartCommit": false,
    "git.replaceTagsWhenPull": true,
    "workbench.activityBar.orientation": "vertical",
    "claudeCodeChat.wsl.enabled": true,
    "claudeCodeChat.wsl.distro": "$WslDistro",
    "claudeCodeChat.wsl.nodePath": "/home/$WindowsUser/.volta/bin/node",
    "claudeCodeChat.wsl.claudePath": "/usr/local/bin/claude",
    "claudeCode.environmentVariables": [],
    "claudeCode.preferredLocation": "sidebar",
    "editor.fontSize": 18,
    "editor.fontFamily": "JetBrains Mono, Cascadia Code, Consolas, monospace",
    "editor.fontLigatures": true,
    "editor.fontWeight": "400",
    "editor.lineHeight": 1.4,
    "terminal.integrated.fontSize": 18,
    "terminal.integrated.fontFamily": "JetBrains Mono, Cascadia Code, monospace",
    "terminal.integrated.lineHeight": 1.2,
    "terminal.integrated.smoothScrolling": false,
    "terminal.integrated.mouseWheelScrollSensitivity": 1,
    "terminal.integrated.scrollback": 100000,
    "terminal.integrated.gpuAcceleration": "on",
    "terminal.integrated.shellIntegration.enabled": true,
    "remote.autoForwardPortsSource": "hybrid",
    "workbench.colorTheme": "$Theme"$colorBlock
}
"@

$vscodeSettings = @"
{
    "editor.minimap.enabled": false,
    "window.customTitleBarVisibility": "windowed",
    "docker.extension.dockerEngineAvailabilityPrompt": false,
    "json.format.keepLines": true,
    "[yaml]": {
        "editor.defaultFormatter": "redhat.vscode-yaml",
        "editor.formatOnSave": true
    },
    "yaml.format.singleQuote": false,
    "yaml.format.proseWrap": "preserve",
    "accessibility.voice.speechLanguage": "es-MX",
    "files.associations": { "*.hcl": "terraform" },
    "git.suggestSmartCommit": false,
    "git.replaceTagsWhenPull": true,
    "terminal.integrated.defaultProfile.windows": "$WslDistro (WSL)",
    "terminal.integrated.defaultProfile.linux": "bash",
    "terminal.integrated.scrollback": 100000,
    "terminal.integrated.gpuAcceleration": "on",
    "terminal.integrated.shellIntegration.enabled": true,
    "editor.fontSize": 14,
    "editor.fontFamily": "JetBrains Mono, Cascadia Code, Consolas, monospace",
    "editor.fontLigatures": true,
    "editor.lineHeight": 1.4,
    "remote.autoForwardPortsSource": "hybrid",
    "workbench.colorTheme": "$Theme"$colorBlock
}
"@

# =============================================================================
# Extensions
# =============================================================================

$cursorExtensions = @(
    # AI
    "anthropic.claude-code",
    # Git
    "eamodio.gitlens",
    "donjayamanne.git-extension-pack",
    "codezombiech.gitignore",
    "ziyasal.vscode-open-in-github",
    # Remote
    "ms-vscode-remote.remote-ssh",
    "ms-vscode-remote.remote-wsl",
    "ms-vscode-remote.remote-containers",
    # Languages
    "golang.go",
    "rust-lang.rust-analyzer",
    "tamasfe.even-better-toml",
    "ms-python.python",
    "ms-python.vscode-pylance",
    "ms-python.debugpy",
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    # Shell / DevOps
    "timonwong.shellcheck",
    "foxundermoon.shell-format",
    "hashicorp.terraform",
    "redhat.vscode-yaml",
    "ms-azuretools.vscode-docker",
    "ms-kubernetes-tools.vscode-kubernetes-tools",
    "ms-vscode.makefile-tools",
    # Productivity
    "usernamehw.errorlens",
    "streetsidesoftware.code-spell-checker",
    "pkief.material-icon-theme",
    "alefragnani.project-manager",
    # Theme
    "enkia.tokyo-night"
)

$vscodeExtensions = @(
    # Remote
    "ms-vscode-remote.remote-ssh",
    "ms-vscode-remote.remote-wsl",
    "ms-vscode-remote.remote-containers",
    # Languages
    "golang.go",
    "rust-lang.rust-analyzer",
    "tamasfe.even-better-toml",
    "dbaeumer.vscode-eslint",
    "esbenp.prettier-vscode",
    # Shell / DevOps
    "timonwong.shellcheck",
    "foxundermoon.shell-format",
    "hashicorp.terraform",
    "redhat.vscode-yaml",
    # Productivity
    "usernamehw.errorlens",
    "streetsidesoftware.code-spell-checker",
    "pkief.material-icon-theme",
    # Speech (ES)
    "ms-vscode.vscode-speech",
    "ms-vscode.vscode-speech-language-pack-es-mx"
)

$cursorUninstall = @(
    "google.geminicodeassist",
    "googlecloudtools.cloudcode"
)

# =============================================================================
# Apply settings + extensions
# =============================================================================

if ($installCursor) {
    Log "Writing Cursor settings..."
    $dir = Split-Path $cursorSettingsPath
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Content -Path $cursorSettingsPath -Value $cursorSettings -Encoding UTF8
    Ok $cursorSettingsPath

    if (Get-Command cursor -ErrorAction SilentlyContinue) {
        Log "Uninstalling unwanted Cursor extensions..."
        foreach ($ext in $cursorUninstall) {
            $out = cursor --uninstall-extension $ext 2>&1
            if ($out -match "successfully uninstalled") { Ok "removed $ext" }
            else { Skip "$ext (not installed)" }
        }
        Log "Installing Cursor extensions..."
        foreach ($ext in $cursorExtensions) {
            $out = cursor --install-extension $ext 2>&1
            if ($out -match "successfully installed") { Ok $ext }
            else { Skip "$ext (already installed)" }
        }
    } else {
        Warn "cursor CLI not found — restart PowerShell after install and re-run"
    }
}

if ($installVSCode) {
    Log "Writing VSCode settings..."
    $dir = Split-Path $vscodeSettingsPath
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Content -Path $vscodeSettingsPath -Value $vscodeSettings -Encoding UTF8
    Ok $vscodeSettingsPath

    if (Get-Command code -ErrorAction SilentlyContinue) {
        Log "Installing VSCode extensions..."
        foreach ($ext in $vscodeExtensions) {
            $out = code --install-extension $ext 2>&1
            if ($out -match "successfully installed") { Ok $ext }
            else { Skip "$ext (already installed)" }
        }
    } else {
        Warn "code CLI not found — restart PowerShell after install and re-run"
    }
}

Write-Host ""
Write-Host "Done! Restart your editors to apply all changes." -ForegroundColor Green
Write-Host "Note: WSL profile '$WslDistro (WSL)' requires that distro to be installed first." -ForegroundColor DarkGray
