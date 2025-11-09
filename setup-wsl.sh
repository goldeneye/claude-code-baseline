#!/bin/bash
# Quick WSL Setup Script for Claude Code Baseline Repository
# Run this from WSL to configure your environment

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  WSL Setup for Claude Code Baseline Repository          ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Detect WSL distribution
WSL_DISTRO=$(cat /etc/os-release | grep "^ID=" | cut -d'=' -f2 | tr -d '"')
echo -e "${GREEN}✓${NC} Detected WSL distribution: $WSL_DISTRO"

# Verify we're in the right directory
REPO_PATH="{{BASELINE_ROOT}}"
if [ ! -d "$REPO_PATH" ]; then
    echo -e "${RED}✗${NC} Repository not found at $REPO_PATH"
    echo -e "${YELLOW}ℹ${NC} Please adjust the REPO_PATH variable in this script"
    exit 1
fi

echo -e "${GREEN}✓${NC} Repository found at $REPO_PATH"
echo ""

# Step 1: Add bash aliases
echo -e "${BLUE}[1/5]${NC} Adding bash aliases..."

if grep -q "alias baseline=" ~/.bashrc; then
    echo -e "${YELLOW}⚠${NC} Aliases already exist in ~/.bashrc"
else
    cat >> ~/.bashrc << 'EOF'

# ============================================================================
# Claude Code Baseline Repository Shortcuts
# ============================================================================

# Quick navigation
alias baseline='cd {{BASELINE_ROOT}}'
alias repos='cd /mnt/e/github'

# Load baseline environment
load-baseline() {
    cd {{BASELINE_ROOT}}
    if [ -f .env ]; then
        export $(cat .env | grep -v '^#' | xargs)
        echo "✅ Environment variables loaded from .env"
        echo "📁 Current directory: $(pwd)"
        echo "🔑 API Key: ${ANTHROPIC_API_KEY:0:20}..."
    else
        echo "❌ .env file not found"
    fi
}

# Quick status check
baseline-status() {
    cd {{BASELINE_ROOT}}
    echo "📊 Repository Status:"
    git status --short
    echo ""
    echo "🔑 Environment:"
    if [ -f .env ]; then
        echo "  ✓ .env file exists"
    else
        echo "  ✗ .env file missing"
    fi
}
EOF
    echo -e "${GREEN}✓${NC} Aliases added to ~/.bashrc"
fi

# Step 2: Configure Git
echo -e "${BLUE}[2/5]${NC} Configuring Git for cross-platform work..."

git config --global core.autocrlf input
echo -e "${GREEN}✓${NC} Git configured to use LF line endings"

# Step 3: Create .gitattributes if missing
echo -e "${BLUE}[3/5]${NC} Checking .gitattributes..."

if [ ! -f "$REPO_PATH/.gitattributes" ]; then
    cat > "$REPO_PATH/.gitattributes" << 'EOF'
# Auto detect text files and normalize to LF
* text=auto eol=lf

# Windows scripts
*.bat text eol=crlf
*.ps1 text eol=crlf

# Shell scripts must have LF
*.sh text eol=lf

# Documentation
*.md text eol=lf

# Don't modify binary files
*.png binary
*.jpg binary
*.gif binary
*.ico binary
*.pdf binary
EOF
    echo -e "${GREEN}✓${NC} Created .gitattributes file"
else
    echo -e "${YELLOW}⚠${NC} .gitattributes already exists"
fi

# Step 4: Fix script permissions
echo -e "${BLUE}[4/5]${NC} Setting executable permissions on shell scripts..."

cd "$REPO_PATH"
SCRIPT_COUNT=$(find . -name "*.sh" -type f | wc -l)
find . -name "*.sh" -type f -exec chmod +x {} \;
echo -e "${GREEN}✓${NC} Set executable permissions on $SCRIPT_COUNT shell script(s)"

# Step 5: Verify .env file
echo -e "${BLUE}[5/5]${NC} Checking environment configuration..."

if [ -f "$REPO_PATH/.env" ]; then
    echo -e "${GREEN}✓${NC} .env file exists"

    # Load and verify API key
    export $(cat "$REPO_PATH/.env" | grep -v '^#' | xargs)

    if [ -z "$ANTHROPIC_API_KEY" ]; then
        echo -e "${RED}✗${NC} ANTHROPIC_API_KEY not found in .env"
        echo -e "${YELLOW}ℹ${NC} Please add your API key to .env"
    else
        echo -e "${GREEN}✓${NC} ANTHROPIC_API_KEY configured: ${ANTHROPIC_API_KEY:0:20}..."
    fi
else
    echo -e "${YELLOW}⚠${NC} .env file not found"
    echo -e "${YELLOW}ℹ${NC} Run: cp .env.example .env"
    echo -e "${YELLOW}ℹ${NC} Then add your Anthropic API key"
fi

echo ""
echo -e "${BLUE}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Setup Complete!                                         ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GREEN}Next Steps:${NC}"
echo ""
echo -e "  1. ${YELLOW}Reload your shell:${NC}"
echo -e "     ${BLUE}source ~/.bashrc${NC}"
echo ""
echo -e "  2. ${YELLOW}Jump to the repository:${NC}"
echo -e "     ${BLUE}baseline${NC}"
echo ""
echo -e "  3. ${YELLOW}Load environment variables:${NC}"
echo -e "     ${BLUE}load-baseline${NC}"
echo ""
echo -e "  4. ${YELLOW}Check status:${NC}"
echo -e "     ${BLUE}baseline-status${NC}"
echo ""
echo -e "${GREEN}Quick Commands:${NC}"
echo -e "  ${BLUE}baseline${NC}        - Navigate to repository"
echo -e "  ${BLUE}repos${NC}           - Navigate to E:\\github\\"
echo -e "  ${BLUE}load-baseline${NC}   - Load environment variables"
echo -e "  ${BLUE}baseline-status${NC} - Check repository status"
echo ""
echo -e "${YELLOW}Documentation:${NC}"
echo -e "  📖 Full Guide: WSL-SETUP.md"
echo -e "  🔐 Environment: ENVIRONMENT.md"
echo -e "  📚 Main README: README.md"
echo ""
