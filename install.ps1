#Requires -Version 5.1
$ErrorActionPreference = "Stop"

$RepoUrl = "https://github.com/muharandy-db/dbxf_vibe_de.git"
$RepoDir = "dbxf_vibe_de"
$Profile = "WORKSHOP"

function Write-Step($num, $msg) { Write-Host "`n[$num/7] $msg" -ForegroundColor Blue -NoNewline; Write-Host "" }
function Write-Ok($msg)   { Write-Host "  + $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  ! $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "  x $msg" -ForegroundColor Red }

Write-Host ""
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host "     Vibe Data Engineering Workshop - Setup Installer       " -ForegroundColor Cyan
Write-Host "===========================================================" -ForegroundColor Cyan
Write-Host ""

# --- Step 1: Choose Coding Agent ---------------------------------
Write-Step 1 "Choose your coding agent"

Write-Host ""
Write-Host "  Which coding agent would you like to use?"
Write-Host ""
Write-Host "    1) Claude Code  - by Anthropic (terminal-based)"
Write-Host "    2) Codex CLI    - by OpenAI (terminal-based)"
Write-Host "    3) Cursor       - by Anysphere (IDE-based)"
Write-Host ""
$agentChoice = Read-Host "  Enter your choice (1, 2, or 3)"

if ($agentChoice -eq "2") {
    $AgentName = "Codex CLI"
    $AgentCmd = "codex"
    $AgentInstallNpm = "@openai/codex"
    $AgentConfigDir = ".codex"
    $AgentIsIde = $false
} elseif ($agentChoice -eq "3") {
    $AgentName = "Cursor"
    $AgentCmd = "cursor"
    $AgentInstallNpm = ""
    $AgentConfigDir = ".cursor"
    $AgentIsIde = $true
} else {
    $AgentName = "Claude Code"
    $AgentCmd = "claude"
    $AgentInstallNpm = "@anthropic-ai/claude-code"
    $AgentConfigDir = ".claude"
    $AgentIsIde = $false
}

Write-Ok "Selected: $AgentName"

# --- Step 2: Install Coding Agent --------------------------------
Write-Step 2 "Installing $AgentName"

if ($AgentIsIde) {
    $agentExists = Get-Command $AgentCmd -ErrorAction SilentlyContinue
    if ($agentExists) {
        Write-Ok "$AgentName already installed"
    } else {
        Write-Warn "$AgentName is an IDE application - it cannot be installed from the terminal."
        Write-Host "  Please download and install $AgentName from https://www.cursor.com/ and re-run this script."
        Write-Host ""
        $cursorInstalled = Read-Host "  Have you already installed $AgentName? (y/N)"
        if ($cursorInstalled -eq "y" -or $cursorInstalled -eq "Y") {
            Write-Ok "$AgentName confirmed installed by user"
        } else {
            Write-Err "Please install $AgentName first, then re-run this script."
            exit 1
        }
    }
} else {
    $agentExists = Get-Command $AgentCmd -ErrorAction SilentlyContinue
    if ($agentExists) {
        $ver = & $AgentCmd --version 2>$null
        Write-Ok "$AgentName already installed ($ver)"
    } else {
        $npmExists = Get-Command npm -ErrorAction SilentlyContinue
        if ($npmExists -and $AgentInstallNpm) {
            Write-Host "  Installing via npm..."
            & npm install -g $AgentInstallNpm
        } else {
            Write-Err "npm not found. Please install Node.js 18+ from https://nodejs.org/ and re-run."
            exit 1
        }

        $agentExists = Get-Command $AgentCmd -ErrorAction SilentlyContinue
        if ($agentExists) {
            Write-Ok "$AgentName installed successfully"
        } else {
            Write-Err "$AgentName installation failed. Please install manually and re-run."
            exit 1
        }
    }
}

# --- Step 3: Databricks CLI --------------------------------------
Write-Step 3 "Installing Databricks CLI"

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

# --- Step 4: Configure Databricks CLI Profile ---------------------
Write-Step 4 "Configuring Databricks CLI profile"

$profileOk = $false
try {
    & databricks auth env --profile $Profile 2>$null | Out-Null
    $profileOk = $true
} catch {}

if ($profileOk) {
    Write-Ok "Profile '$Profile' already configured"
    $reconfigure = Read-Host "  Reconfigure? (y/N)"
    if ($reconfigure -eq "y" -or $reconfigure -eq "Y") {
        $ErrorActionPreference = "Continue"
        & databricks configure --profile $Profile
        $ErrorActionPreference = "Stop"
    }
} else {
    Write-Host "  Let's configure the '$Profile' profile to connect to your Databricks workspace."
    Write-Host ""
    $ErrorActionPreference = "Continue"
    & databricks configure --profile $Profile
    $ErrorActionPreference = "Stop"
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

# --- Step 5: Clone Repository ------------------------------------
Write-Step 5 "Cloning workshop repository"

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

# --- Step 6: Install AI Dev Kit ----------------------------------
Write-Step 6 "Installing Databricks AI Dev Kit"

Write-Host "  This will configure $AgentName with Databricks tools and skills."
Write-Host ""
Invoke-RestMethod https://raw.githubusercontent.com/databricks-solutions/ai-dev-kit/main/install.ps1 | Invoke-Expression

Write-Ok "AI Dev Kit installed"

# --- Step 7: Verify Everything ------------------------------------
Write-Step 7 "Verifying installation"

$allOk = $true

if (Get-Command $AgentCmd -ErrorAction SilentlyContinue) {
    $ver = & $AgentCmd --version 2>$null
    Write-Ok "$AgentName`: $ver"
} else {
    Write-Err "$AgentName`: not found"
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

if (Test-Path $AgentConfigDir) {
    Write-Ok "AI Dev Kit: configured"
} else {
    Write-Warn "AI Dev Kit: $AgentConfigDir directory not found (may need manual setup)"
}

Write-Host ""
if ($allOk) {
    Write-Host "Setup complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Next steps:"
    Write-Host "    1. Launch $AgentName`:  $AgentCmd"
    Write-Host "    2. Pick a tutorial:"
    Write-Host "       - FSI (Financial Services):  open TUTORIAL_FSI.md"
    Write-Host "       - Pharma (Pharmaceutical):   open TUTORIAL_PHARMA.md"
    Write-Host ""
} else {
    Write-Host "Setup completed with errors. Please fix the issues above and re-run." -ForegroundColor Red
}
