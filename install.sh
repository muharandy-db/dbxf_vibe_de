#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

REPO_URL="https://github.com/muharandy-db/dbxf_vibe_de.git"
REPO_DIR="dbxf_vibe_de"

print_step() { echo -e "\n${BLUE}${BOLD}[$1/7]${NC} ${BOLD}$2${NC}"; }
print_ok()   { echo -e "  ${GREEN}✓${NC} $1"; }
print_warn() { echo -e "  ${YELLOW}!${NC} $1"; }
print_err()  { echo -e "  ${RED}✗${NC} $1"; }

echo -e "${BOLD}"
echo "╔══════════════════════════════════════════════════════════╗"
echo "║     Vibe Data Engineering Workshop — Setup Installer    ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ─── Step 1: Choose Coding Agent ─────────────────────────────────
print_step 1 "Choose your coding agent"

echo ""
echo "  Which coding agent would you like to use?"
echo ""
echo "    1) Claude Code  — by Anthropic (terminal-based)"
echo "    2) Codex CLI    — by OpenAI (terminal-based)"
echo "    3) Cursor        — by Anysphere (IDE-based)"
echo ""
read -p "  Enter your choice (1, 2, or 3): " agent_choice

case "$agent_choice" in
    2)
        AGENT_NAME="Codex CLI"
        AGENT_CMD="codex"
        AGENT_INSTALL_NPM="@openai/codex"
        AGENT_INSTALL_BREW=""
        AGENT_CONFIG_DIR=".codex"
        AGENT_IS_IDE=false
        ;;
    3)
        AGENT_NAME="Cursor"
        AGENT_CMD="cursor"
        AGENT_INSTALL_NPM=""
        AGENT_INSTALL_BREW=""
        AGENT_CONFIG_DIR=".cursor"
        AGENT_IS_IDE=true
        ;;
    *)
        AGENT_NAME="Claude Code"
        AGENT_CMD="claude"
        AGENT_INSTALL_NPM="@anthropic-ai/claude-code"
        AGENT_INSTALL_BREW="claude-code"
        AGENT_CONFIG_DIR=".claude"
        AGENT_IS_IDE=false
        ;;
esac

print_ok "Selected: $AGENT_NAME"

# ─── Step 2: Install Coding Agent ────────────────────────────────
print_step 2 "Installing $AGENT_NAME"

if $AGENT_IS_IDE; then
    if command -v "$AGENT_CMD" &>/dev/null; then
        print_ok "$AGENT_NAME already installed"
    else
        print_warn "$AGENT_NAME is an IDE application — it cannot be installed from the terminal."
        echo "  Please download and install $AGENT_NAME from https://www.cursor.com/ and re-run this script."
        echo ""
        read -p "  Have you already installed $AGENT_NAME? (y/N): " cursor_installed
        if [[ "$cursor_installed" =~ ^[Yy]$ ]]; then
            print_ok "$AGENT_NAME confirmed installed by user"
        else
            print_err "Please install $AGENT_NAME first, then re-run this script."
            exit 1
        fi
    fi
else
    if command -v "$AGENT_CMD" &>/dev/null; then
        print_ok "$AGENT_NAME already installed ($($AGENT_CMD --version 2>/dev/null || echo 'unknown version'))"
    else
        if [ -n "$AGENT_INSTALL_BREW" ] && command -v brew &>/dev/null; then
            echo "  Installing via Homebrew..."
            brew install "$AGENT_INSTALL_BREW"
        elif [ -n "$AGENT_INSTALL_NPM" ] && command -v npm &>/dev/null; then
            echo "  Installing via npm..."
            npm install -g "$AGENT_INSTALL_NPM"
        else
            print_err "Neither Homebrew nor npm found."
            echo "  Please install Node.js 18+ from https://nodejs.org/ and re-run this script."
            exit 1
        fi

        if command -v "$AGENT_CMD" &>/dev/null; then
            print_ok "$AGENT_NAME installed successfully"
        else
            print_err "$AGENT_NAME installation failed. Please install manually and re-run."
            exit 1
        fi
    fi
fi

# ─── Step 3: Databricks CLI ──────────────────────────────────────
print_step 3 "Installing Databricks CLI"

if command -v databricks &>/dev/null; then
    print_ok "Databricks CLI already installed ($(databricks --version 2>/dev/null || echo 'unknown version'))"
else
    if command -v brew &>/dev/null; then
        echo "  Installing via Homebrew..."
        brew tap databricks/tap
        brew install databricks
    elif command -v curl &>/dev/null; then
        echo "  Installing via curl..."
        curl -fsSL https://raw.githubusercontent.com/databricks/setup-cli/main/install.sh | sh
    else
        print_err "Neither Homebrew nor curl found. Please install the Databricks CLI manually."
        exit 1
    fi

    if command -v databricks &>/dev/null; then
        print_ok "Databricks CLI installed successfully"
    else
        print_err "Databricks CLI installation failed. Please install manually and re-run."
        exit 1
    fi
fi

# ─── Step 4: Configure Databricks CLI Profile ────────────────────
print_step 4 "Configuring Databricks CLI profile"

PROFILE="WORKSHOP"

if databricks auth env --profile "$PROFILE" &>/dev/null; then
    print_ok "Profile '$PROFILE' already configured"
    echo ""
    read -p "  Reconfigure? (y/N): " reconfigure
    if [[ "$reconfigure" =~ ^[Yy]$ ]]; then
        databricks configure --profile "$PROFILE"
    fi
else
    echo "  Let's configure the '$PROFILE' profile to connect to your Databricks workspace."
    echo ""
    databricks configure --profile "$PROFILE"
fi

echo "  Verifying connection..."
if databricks workspace list / --profile "$PROFILE" &>/dev/null; then
    print_ok "Successfully connected to workspace"
else
    print_err "Could not connect to workspace. Please check your host URL and token."
    echo "  Run 'databricks configure --profile $PROFILE' to reconfigure."
    exit 1
fi

# ─── Step 5: Clone Repository ────────────────────────────────────
print_step 5 "Cloning workshop repository"

if [ -d "$REPO_DIR" ]; then
    print_ok "Repository already exists at ./$REPO_DIR"
    cd "$REPO_DIR"
elif [ -f "README.md" ] && grep -q "Vibe Data Engineering Workshop" README.md 2>/dev/null; then
    print_ok "Already inside the workshop repository"
else
    echo "  Cloning from $REPO_URL..."
    git clone "$REPO_URL"
    cd "$REPO_DIR"
    print_ok "Repository cloned to ./$REPO_DIR"
fi

# ─── Step 6: Install AI Dev Kit ──────────────────────────────────
print_step 6 "Installing Databricks AI Dev Kit"

echo "  This will configure $AGENT_NAME with Databricks tools and skills."
echo ""
bash <(curl -sL https://raw.githubusercontent.com/databricks-solutions/ai-dev-kit/main/install.sh)

print_ok "AI Dev Kit installed"

# ─── Step 7: Verify Everything ───────────────────────────────────
print_step 7 "Verifying installation"

all_ok=true

if command -v "$AGENT_CMD" &>/dev/null; then
    print_ok "$AGENT_NAME: $($AGENT_CMD --version 2>/dev/null || echo 'installed')"
else
    print_err "$AGENT_NAME: not found"
    all_ok=false
fi

if command -v databricks &>/dev/null; then
    print_ok "Databricks CLI: $(databricks --version 2>/dev/null || echo 'installed')"
else
    print_err "Databricks CLI: not found"
    all_ok=false
fi

if databricks workspace list / --profile "$PROFILE" &>/dev/null; then
    print_ok "Databricks profile '$PROFILE': connected"
else
    print_err "Databricks profile '$PROFILE': connection failed"
    all_ok=false
fi

if [ -d "$AGENT_CONFIG_DIR" ]; then
    print_ok "AI Dev Kit: configured"
else
    print_warn "AI Dev Kit: $AGENT_CONFIG_DIR directory not found (may need manual setup)"
fi

echo ""
if $all_ok; then
    echo -e "${GREEN}${BOLD}Setup complete!${NC}"
    echo ""
    echo "  Next steps:"
    echo "    1. Launch $AGENT_NAME:  $AGENT_CMD"
    echo "    2. Pick a tutorial:"
    echo "       - FSI (Financial Services):  open TUTORIAL_FSI.md"
    echo "       - Pharma (Pharmaceutical):   open TUTORIAL_PHARMA.md"
    echo ""
else
    echo -e "${RED}${BOLD}Setup completed with errors.${NC} Please fix the issues above and re-run."
fi
