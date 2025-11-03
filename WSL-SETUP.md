# WSL & Claude Code Integration Guide

**Last Updated**: 2025-11-03
**Maintainer**: TimGolden - aka GoldenEye Engineering

---

## 🎯 Overview

This guide shows you how to work with this repository seamlessly between **Windows** and **WSL (Windows Subsystem for Linux)**, using Claude Code in both environments.

---

## 📁 Accessing Windows Files from WSL

### Understanding the Path Structure

Windows drives are automatically mounted in WSL under `/mnt/`:

| Windows Path | WSL Path |
|--------------|----------|
| `C:\` | `/mnt/c/` |
| `E:\github\` | `/mnt/e/github/` |
| `E:\github\claude_code_baseline\` | `/mnt/e/github/claude_code_baseline/` |

### Navigate to Your Repository

```bash
# From WSL terminal
cd /mnt/e/github/claude_code_baseline

# Verify you're in the right place
pwd
# Output: /mnt/e/github/claude_code_baseline

# List files
ls -la
```

### Create a Convenient Alias

Add this to your WSL `~/.bashrc` or `~/.zshrc`:

```bash
# Quick access to baseline repo
alias baseline='cd /mnt/e/github/claude_code_baseline'
alias repos='cd /mnt/e/github'

# Usage
baseline  # Instantly jump to the baseline repo
```

Apply changes:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

---

## 🔐 Environment Variables in WSL

### Option 1: Use the Same .env File

Your `.env` file on Windows is accessible from WSL:

```bash
# Navigate to repo
cd /mnt/e/github/claude_code_baseline

# Load environment variables
export $(cat .env | xargs)

# Verify
echo $ANTHROPIC_API_KEY
# Should output: sk-ant-api03-Enn8tEU...
```

### Option 2: Source .env Automatically

Add to `~/.bashrc`:

```bash
# Auto-load .env when entering baseline directory
baseline() {
    cd /mnt/e/github/claude_code_baseline
    if [ -f .env ]; then
        export $(cat .env | grep -v '^#' | xargs)
        echo "✅ Environment variables loaded from .env"
    fi
}
```

### Option 3: Create a Symlink to .env

```bash
# Create a symlink in your WSL home directory
ln -s /mnt/e/github/claude_code_baseline/.env ~/.env-baseline

# Load it when needed
export $(cat ~/.env-baseline | xargs)
```

---

## 🤖 Using Claude Code in Both Environments

### From Windows (Current Setup)

Your current setup already works:

```powershell
# Windows PowerShell or Command Prompt
cd E:\github\claude_code_baseline

# Claude Code automatically reads .env
# API key available via environment variables
```

### From WSL Terminal

```bash
# Navigate to repo
cd /mnt/e/github/claude_code_baseline

# Load environment
export $(cat .env | grep -v '^#' | xargs)

# Now you can use Claude Code CLI or API
# Example: Using curl with Claude API
curl https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d '{
    "model": "claude-3-5-sonnet-20241022",
    "max_tokens": 1024,
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### Install Claude Code CLI in WSL

If you want to use Claude Code from the WSL command line:

```bash
# Install Node.js if not already installed
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version
npm --version

# Install Claude Code CLI (if available)
# npm install -g @anthropic/claude-code
```

---

## 🛠️ Setting Up Git in WSL

### Configure Git for Cross-Platform Use

```bash
# Set Git to use Unix line endings in WSL
git config --global core.autocrlf input

# Set your identity
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# View your config
git config --list
```

### Working with the Repository

```bash
# Navigate to repo
cd /mnt/e/github/claude_code_baseline

# Check status
git status

# Make changes, stage, commit
git add .
git commit -m "Your commit message"
git push
```

⚠️ **Important**: When working with files from both Windows and WSL:
- Use a consistent line ending style (recommend LF)
- Add `.gitattributes` file to enforce line endings

---

## 📝 Create .gitattributes for Cross-Platform Work

Create this file in your repository root:

```bash
cd /mnt/e/github/claude_code_baseline
cat > .gitattributes << 'EOF'
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
```

---

## 🚀 Recommended Workflow

### Scenario 1: Quick Edits (Windows)

```powershell
# Windows - for quick edits and automation scripts
cd E:\github\claude_code_baseline
notepad README.md
.\new-project.ps1 -ProjectName "MyApp"
```

### Scenario 2: Development Work (WSL)

```bash
# WSL - for development, testing, and CLI tools
baseline  # Jump to repo
export $(cat .env | xargs)  # Load environment

# Run commands
npm test
./scripts/some-script.sh
```

### Scenario 3: Claude Code Development

**Option A: Windows Claude Code Desktop**
- Use Windows desktop application
- Automatically reads `.env` from `E:\github\claude_code_baseline\.env`

**Option B: WSL Terminal with Claude API**
```bash
cd /mnt/e/github/claude_code_baseline
export $(cat .env | xargs)
# Use Claude API via curl or SDK
```

---

## 🔧 Practical Examples

### Example 1: Run PowerShell Script from WSL

```bash
# From WSL, run Windows PowerShell scripts
cd /mnt/e/github/claude_code_baseline

# Run PowerShell script
powershell.exe -NoProfile -File .claude/scripts/check-services.ps1

# Or with parameters
powershell.exe -NoProfile -File new-project.ps1 \
  -ProjectName "MyApp" \
  -DestinationPath "/mnt/e/projects/myapp"
```

### Example 2: Use Bash Scripts in WSL

Create a helper script in WSL:

```bash
# Create a bash script
cat > ~/scripts/load-baseline-env.sh << 'EOF'
#!/bin/bash
cd /mnt/e/github/claude_code_baseline
export $(cat .env | grep -v '^#' | xargs)
echo "✅ Loaded environment from baseline repo"
echo "📁 Current directory: $(pwd)"
echo "🔑 API Key: ${ANTHROPIC_API_KEY:0:20}..."
EOF

chmod +x ~/scripts/load-baseline-env.sh

# Use it
source ~/scripts/load-baseline-env.sh
```

### Example 3: Create Combined Workflow Script

```bash
# Create a workflow script
cat > ~/scripts/baseline-work.sh << 'EOF'
#!/bin/bash

# Color output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Starting Baseline Repo Workflow${NC}"

# Navigate to repo
cd /mnt/e/github/claude_code_baseline

# Load environment
export $(cat .env | grep -v '^#' | xargs)
echo -e "${GREEN}✅ Environment loaded${NC}"

# Show status
echo -e "${BLUE}📊 Git Status:${NC}"
git status --short

# Show environment info
echo -e "${BLUE}🔑 API Key configured:${NC} ${ANTHROPIC_API_KEY:0:20}..."

# Start interactive shell
exec bash
EOF

chmod +x ~/scripts/baseline-work.sh

# Run it
~/scripts/baseline-work.sh
```

---

## 🐧 Installing Essential WSL Tools

### Basic Development Tools

```bash
# Update package list
sudo apt update

# Essential tools
sudo apt install -y \
  git \
  curl \
  wget \
  vim \
  nano \
  jq \
  tree \
  htop

# Development tools
sudo apt install -y \
  build-essential \
  python3 \
  python3-pip \
  nodejs \
  npm

# Verify installations
git --version
python3 --version
node --version
npm --version
```

### Install Python dotenv (for .env support)

```bash
# Install python-dotenv
pip3 install python-dotenv

# Create a Python test script
cat > test-env.py << 'EOF'
#!/usr/bin/env python3
from dotenv import load_dotenv
import os

# Load .env file
load_dotenv()

# Get API key
api_key = os.getenv('ANTHROPIC_API_KEY')
print(f"✅ API Key loaded: {api_key[:20]}...")
EOF

chmod +x test-env.py
python3 test-env.py
```

---

## 📂 VS Code with WSL

### Install VS Code with WSL Support

1. **Install VS Code on Windows** (if not already)
   - Download from: https://code.visualstudio.com/

2. **Install Remote - WSL Extension**
   - Open VS Code
   - Go to Extensions (Ctrl+Shift+X)
   - Search for "Remote - WSL"
   - Install the extension

### Open Repository in VS Code from WSL

```bash
# Navigate to repo in WSL
cd /mnt/e/github/claude_code_baseline

# Open in VS Code
code .

# VS Code will open with WSL extension active
# You can edit files with full WSL integration
```

### Open WSL Terminal in VS Code

```bash
# From Windows, open VS Code in WSL mode
code --remote wsl+Ubuntu /mnt/e/github/claude_code_baseline

# Or from VS Code terminal:
# Press Ctrl+` (backtick) to open terminal
# Terminal will be running in WSL
```

---

## 🔄 File Permission Considerations

### Windows vs. Linux Permissions

WSL files on Windows drives inherit Windows permissions, which can cause issues:

```bash
# Check file permissions
ls -la /mnt/e/github/claude_code_baseline

# If scripts show wrong permissions, fix them:
chmod +x script-name.sh

# For entire directory of scripts:
find /mnt/e/github/claude_code_baseline -name "*.sh" -exec chmod +x {} \;
```

### Recommendation for Scripts

**Best Practice**: Keep shell scripts in WSL home directory for proper permission handling:

```bash
# Create scripts directory in WSL home
mkdir -p ~/scripts

# Symlink Windows repo
ln -s /mnt/e/github/claude_code_baseline ~/repos/baseline

# Work with scripts from WSL home
cd ~/scripts
```

---

## 🎯 Complete Setup Checklist

### Windows Setup ✅
- [x] Repository at `E:\github\claude_code_baseline`
- [x] `.env` file with Anthropic API key
- [x] `.gitignore` protecting secrets
- [x] PowerShell scripts working

### WSL Setup
- [ ] WSL installed and updated
- [ ] Essential tools installed (git, curl, etc.)
- [ ] Bash aliases configured
- [ ] .env loading script created
- [ ] VS Code with Remote-WSL extension
- [ ] Git configured for cross-platform

### Quick Setup Commands

```bash
# Run these commands in WSL to complete setup

# 1. Add aliases to .bashrc
cat >> ~/.bashrc << 'EOF'

# Baseline repository shortcuts
alias baseline='cd /mnt/e/github/claude_code_baseline'
alias repos='cd /mnt/e/github'

# Load baseline environment
load-baseline() {
    cd /mnt/e/github/claude_code_baseline
    export $(cat .env | grep -v '^#' | xargs)
    echo "✅ Environment loaded"
}
EOF

# 2. Reload bashrc
source ~/.bashrc

# 3. Test access
baseline
ls -la

# 4. Load environment
load-baseline
echo $ANTHROPIC_API_KEY
```

---

## 🚨 Common Issues & Solutions

### Issue: Permission Denied

**Symptom**: `Permission denied` when running scripts

**Solution**:
```bash
chmod +x script-name.sh
# Or for all shell scripts:
find . -name "*.sh" -exec chmod +x {} \;
```

### Issue: Line Ending Problems

**Symptom**: Scripts fail with `^M` or `\r` errors

**Solution**:
```bash
# Convert Windows line endings to Unix
dos2unix filename.sh

# Or manually with sed
sed -i 's/\r$//' filename.sh

# Or install dos2unix
sudo apt install dos2unix
```

### Issue: .env Not Loading

**Symptom**: Environment variables are empty

**Solution**:
```bash
# Verify .env exists and has content
cat /mnt/e/github/claude_code_baseline/.env

# Load with verbose output
set -a
source /mnt/e/github/claude_code_baseline/.env
set +a

# Check if loaded
env | grep ANTHROPIC
```

### Issue: Can't Access Windows Files

**Symptom**: Files not visible from WSL

**Solution**:
```bash
# Check WSL version
wsl --status

# Ensure drives are mounted
ls /mnt/
# Should show c, d, e, etc.

# If not mounted, restart WSL
# From Windows PowerShell:
wsl --shutdown
wsl
```

---

## 🎓 Best Practices

### 1. Use Version Control
```bash
# Always work from Git
cd /mnt/e/github/claude_code_baseline
git pull  # Get latest changes
# Make your changes
git add .
git commit -m "Description"
git push
```

### 2. Keep Sensitive Data Secure
```bash
# Never commit .env
git status | grep .env  # Should be ignored

# Use chmod to restrict .env access
chmod 600 /mnt/e/github/claude_code_baseline/.env
```

### 3. Use Consistent Line Endings
```bash
# Set Git config
git config --global core.autocrlf input

# Create .gitattributes
# (Already covered in earlier section)
```

### 4. Separate Windows and Linux Work
- **Windows**: PowerShell automation, Windows-specific tools
- **WSL**: Development, testing, cross-platform scripts

---

## 📚 Additional Resources

### Official Documentation
- **WSL Documentation**: https://docs.microsoft.com/en-us/windows/wsl/
- **VS Code WSL**: https://code.visualstudio.com/docs/remote/wsl
- **Git for Windows**: https://git-scm.com/download/win

### Useful Commands
```bash
# Check WSL version
wsl --version

# List installed distributions
wsl --list --verbose

# Update WSL
wsl --update

# Set default distribution
wsl --set-default Ubuntu

# Access Windows commands from WSL
explorer.exe .  # Open Windows Explorer in current directory
notepad.exe file.txt  # Open file in Windows Notepad
code .  # Open VS Code
```

---

## 🎉 Quick Start Summary

```bash
# 1. Open WSL terminal
wsl

# 2. Navigate to your repo
cd /mnt/e/github/claude_code_baseline

# 3. Load environment
export $(cat .env | grep -v '^#' | xargs)

# 4. Verify
echo "Repo: $(pwd)"
echo "API Key: ${ANTHROPIC_API_KEY:0:20}..."

# 5. Start working!
git status
ls -la
```

---

**You're now ready to work seamlessly between Windows and WSL!** 🚀

For questions or issues, see [`ENVIRONMENT.md`](ENVIRONMENT.md) for environment configuration details.
