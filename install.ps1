#Requires -Version 5.1
$ErrorActionPreference = "Stop"

$RepoUrl = "https://github.com/muharandy-db/dbxf_vibe_de.git"
$RepoDir = "dbxf_vibe_de"
$Profile = "WORKSHOP"

function Write-Step($num, $msg) { Write-Host "`n[$num/6] $msg" -ForegroundColor Blue -NoNewline; Write-Host "" }
function Write-Ok($msg)   { Write-Host "  ✓ $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  ! $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "  ✗ $msg" -ForegroundColor Red }

Write-Host ""
Write-Host "╔══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     Vibe Data Engineering Workshop — Setup Installer    ║" -ForegroundColor Cyan
Write-Host "╚══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# ─── Step 1: Claude Code ─────────────────────────────────────────
Write-Step 1 "Installing Claude Code"

$claudeExists = Get-Command claude -ErrorAction SilentlyContinue
if ($claudeExists) {
    $ver = & claude --version 2>$null
    Write-Ok "Claude Code already installed ($ver)"
} else {
    $npmExists = Get-Command npm -ErrorAction SilentlyContinue
    if ($npmExists) {
        Write-Host "  Installing via npm..."
        & npm install -g @anthropic-ai/claude-code
    } else {
        Write-Err "npm not found. Please install Node.js 18+ from https://nodejs.org/ and re-run."
        exit 1
    }

    $claudeExists = Get-Command claude -ErrorAction SilentlyContinue
    if ($claudeExists) {
        Write-Ok "Claude Code installed successfully"
    } else {
        Write-Err "Claude Code installation failed. Please install manually and re-run."
        exit 1
    }
}

# ─── Step 2: Databricks CLI ──────────────────────────────────────
Write-Step 2 "Installing Databricks CLI"

$dbExists = Get-Command databricks -ErrorAction SilentlyContinue
if ($dbExists) {
    $ver = & databricks --version 2>$null
    Write-Ok "Databricks CLI already installed ($ver)"
} else {
    $wingetExists = Get-Command winget -ErrorAction SilentlyContinue
    if ($wingetExists) {
        Write-Host "  Installing via winget..."
        & winget install Databricks.DatabricksCLI --accept-package-agreements --accept-source-agreements
    } else {
        Write-Err "winget not found. Please install the Databricks CLI manually:"
        Write-Host "  https://docs.databricks.com/dev-tools/cli/install.html"
        exit 1
    }

    # Refresh PATH
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

    $dbExists = Get-Command databricks -ErrorAction SilentlyContinue
    if ($dbExists) {
        Write-Ok "Databricks CLI installed successfully"
    } else {
        Write-Warn "Databricks CLI installed but not in PATH. You may need to restart your terminal."
    }
}

# ─── Step 3: Configure Databricks CLI Profile ────────────────────
Write-Step 3 "Configuring Databricks CLI profile"

$profileOk = $false
try {
    & databricks auth env --profile $Profile 2>$null | Out-Null
    $profileOk = $true
} catch {}

if ($profileOk) {
    Write-Ok "Profile '$Profile' already configured"
    $reconfigure = Read-Host "  Reconfigure? (y/N)"
    if ($reconfigure -eq "y" -or $reconfigure -eq "Y") {
        & databricks configure --profile $Profile
    }
} else {
    Write-Host "  Let's configure the '$Profile' profile to connect to your Databricks workspace."
    Write-Host ""
    & databricks configure --profile $Profile
}

Write-Host "  Verifying connection..."
try {
    & databricks workspace list / --profile $Profile 2>$null | Out-Null
    Write-Ok "Successfully connected to workspace"
} catch {
    Write-Err "Could not connect to workspace. Please check your host URL and token."
    Write-Host "  Run 'databricks configure --profile $Profile' to reconfigure."
    exit 1
}

# ─── Step 4: Clone Repository ────────────────────────────────────
Write-Step 4 "Cloning workshop repository"

if (Test-Path $RepoDir) {
    Write-Ok "Repository already exists at .\$RepoDir"
    Set-Location $RepoDir
} elseif ((Test-Path "README.md") -and (Select-String -Path "README.md" -Pattern "Vibe Data Engineering Workshop" -Quiet)) {
    Write-Ok "Already inside the workshop repository"
} else {
    Write-Host "  Cloning from $RepoUrl..."
    & git clone $RepoUrl
    Set-Location $RepoDir
    Write-Ok "Repository cloned to .\$RepoDir"
}

# ─── Step 5: Install AI Dev Kit ──────────────────────────────────
Write-Step 5 "Installing Databricks AI Dev Kit"

Write-Host "  This will configure Claude Code with Databricks tools and skills."
Write-Host ""
Invoke-RestMethod https://raw.githubusercontent.com/databricks-solutions/ai-dev-kit/main/install.ps1 | Invoke-Expression

Write-Ok "AI Dev Kit installed"

# ─── Step 6: Verify Everything ───────────────────────────────────
Write-Step 6 "Verifying installation"

$allOk = $true

if (Get-Command claude -ErrorAction SilentlyContinue) {
    $ver = & claude --version 2>$null
    Write-Ok "Claude Code: $ver"
} else {
    Write-Err "Claude Code: not found"
    $allOk = $false
}

if (Get-Command databricks -ErrorAction SilentlyContinue) {
    $ver = & databricks --version 2>$null
    Write-Ok "Databricks CLI: $ver"
} else {
    Write-Err "Databricks CLI: not found"
    $allOk = $false
}

try {
    & databricks workspace list / --profile $Profile 2>$null | Out-Null
    Write-Ok "Databricks profile '$Profile': connected"
} catch {
    Write-Err "Databricks profile '$Profile': connection failed"
    $allOk = $false
}

if (Test-Path ".claude") {
    Write-Ok "AI Dev Kit: configured"
} else {
    Write-Warn "AI Dev Kit: .claude directory not found (may need manual setup)"
}

Write-Host ""
if ($allOk) {
    Write-Host "Setup complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Next steps:"
    Write-Host "    1. Launch Claude Code:  claude"
    Write-Host "    2. Pick a tutorial:"
    Write-Host "       - FSI (Financial Services):  open TUTORIAL_FSI.md"
    Write-Host "       - Pharma (Pharmaceutical):   open TUTORIAL_PHARMA.md"
    Write-Host ""
} else {
    Write-Host "Setup completed with errors. Please fix the issues above and re-run." -ForegroundColor Red
}
