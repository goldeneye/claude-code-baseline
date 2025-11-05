# Claude Code Agents - Quick Reference Guide

**System-Wide AI Assistants for All Your Projects**

---

## ✅ Installation Complete

Your Claude Code agents are installed and ready to use!

### Global Agents (Active System-Wide)
**Location:** `C:\Users\TimGolden\.claude\agents\`

All 9 agents are now available to **every project** on your system:

| Agent | Purpose | When to Use |
|-------|---------|-------------|
| **security-auditor** | Scan for vulnerabilities | "Scan for security issues" |
| **standards-enforcer** | Enforce coding standards | "Check code standards" |
| **gen-docs** | Generate documentation | "Generate project docs" |
| **code-documenter** | Add code documentation | "Document this code" |
| **code-reviewer** | Review code quality | "Review this code" |
| **test-runner** | Run and fix tests | "Run tests" |
| **git-helper** | Git operations | "Create a commit" |
| **refactorer** | Refactor code | "Refactor this service" |

---

## 🚀 How to Use

### Automatic Activation

Agents activate automatically when Claude detects matching tasks:

```
You: "Scan this project for security vulnerabilities"
→ security-auditor agent activates automatically

You: "Generate documentation for this codebase"
→ gen-docs agent activates automatically

You: "Check if this code follows our standards"
→ standards-enforcer agent activates automatically
```

### Explicit Requests

You can also explicitly request agents:

```
You: "Use the code-reviewer agent to review my changes"
You: "Run the test-runner agent"
You: "Use gen-docs to create API documentation"
```

---

## 📋 Agent Details

### 🔒 security-auditor
**Scans for security vulnerabilities**

Detects:
- SQL injection risks
- XSS vulnerabilities
- Authentication/authorization flaws
- Multi-tenant isolation issues (critical for your projects)
- Hardcoded credentials
- Weak cryptography

**Example usage:**
```
"Scan for SQL injection vulnerabilities"
"Security audit before deployment"
"Check multi-tenant isolation"
```

**Output:** Comprehensive security report with severity levels and fixes

---

### ✓ standards-enforcer
**Enforces your coding standards**

Checks:
- Logging format: `Log::info("File: " . __FILE__ . ":" . __LINE__ . " - Message")`
- Multi-tenant filtering (msp_id)
- Safety rules (no DROP, TRUNCATE, DELETE without WHERE)
- PHPDoc compliance
- Naming conventions

**Example usage:**
```
"Check if code follows our standards"
"Verify logging format compliance"
"Ensure multi-tenant isolation"
```

**Output:** Standards compliance report with violations categorized by severity

---

### 📚 gen-docs
**Generates comprehensive documentation**

Creates:
- Markdown documentation
- HTML documentation (PHPDoc, JSDoc, Sphinx)
- API reference docs
- Architecture documentation
- Installation guides

**Example usage:**
```
"Generate documentation for this project"
"Create API docs with HTML output"
"Generate PHPDoc for the entire codebase"
```

**Output:** Complete documentation in `/project_docs` directory

---

### 📝 code-documenter
**Ensures code has proper documentation**

Adds:
- PHPDoc to all public methods
- Pseudo code for complex logic
- Parameter and return type documentation
- Exception documentation
- Usage examples

**Example usage:**
```
"Document all public methods"
"Add PHPDoc to this service"
"Ensure documentation compliance"
```

**Output:** Updated code with complete documentation

---

### 👁️ code-reviewer
**Reviews code for quality and security**

Reviews:
- Code quality and readability
- Security vulnerabilities
- Best practices compliance
- Performance issues
- Test coverage

**Example usage:**
```
"Review this code before I commit"
"Code review for pull request"
"Check for performance issues"
```

**Output:** Detailed review with Critical/Important/Suggestions categories

---

### 🧪 test-runner
**Runs tests and fixes failures**

Handles:
- Running test suites (PHPUnit, Jest, pytest)
- Analyzing test failures
- Fixing tests while preserving intent
- Reporting coverage

**Example usage:**
```
"Run tests and fix any failures"
"Tests are failing, please investigate"
"Run test suite with coverage"
```

**Output:** Test results and fixed test code

---

### 🌿 git-helper
**Assists with Git operations**

Helps with:
- Creating meaningful commits
- Branch management
- Merge conflict resolution
- Pull request creation
- Git history analysis

**Example usage:**
```
"Create a commit for these changes"
"Help resolve this merge conflict"
"Create a pull request"
```

**Output:** Executed git operations with proper conventions

---

### ♻️ refactorer
**Refactors and modernizes code**

Performs:
- Code cleanup (remove duplication)
- Modernization (latest language features)
- Performance optimization
- Maintainability improvements

**Example usage:**
```
"Refactor this service to remove duplication"
"Modernize this code to PHP 8.2"
"Optimize this database query"
```

**Output:** Refactored code maintaining functionality

---

## 🎯 Priority System

When you use agents, Claude Code checks in this order:

1. **Project agents** (`.claude/agents/`) - Highest priority
2. **Global agents** (`~/.claude/agents/`) - **← Your default**
3. **Built-in agents** - Fallback

This means you can override global agents per-project when needed.

---

## 🔧 Customization

### Override for Specific Project

If a project needs different behavior:

```powershell
# Copy global agent to project
Copy-Item C:\Users\TimGolden\.claude\agents\standards-enforcer.md `
          E:\your-project\.claude\agents\

# Edit to customize
code E:\your-project\.claude\agents\standards-enforcer.md
```

### Update Global Agent

To improve an agent for all projects:

```powershell
# 1. Edit the template source
code E:\github\claude_code_baseline\agents\security-auditor.md

# 2. Copy to global
Copy-Item E:\github\claude_code_baseline\agents\security-auditor.md `
          C:\Users\TimGolden\.claude\agents\

# Now all projects use the updated version!
```

---

## 📁 Directory Structure

```
E:\github\claude_code_baseline\
└── agents/                          # Template library (commit to git)
    ├── README.md
    ├── security-auditor.md
    ├── standards-enforcer.md
    ├── gen-docs.md
    ├── code-documenter.md
    ├── code-reviewer.md
    ├── test-runner.md
    ├── git-helper.md
    └── refactorer.md

C:\Users\TimGolden\.claude\agents\   # Global (active system-wide)
    ├── (same 9 files)               # Available to ALL projects

E:\your-project\.claude\agents\      # Project override (optional)
    └── (custom versions)            # When project needs different behavior
```

---

## ✅ Quick Start Checklist

Test your agents in any project:

```powershell
# Navigate to any project
cd E:\your-project\

# Try these commands:
```

**Security Check:**
```
"Scan this project for security vulnerabilities"
```

**Standards Check:**
```
"Check if code follows our standards"
```

**Documentation:**
```
"Generate documentation for this project"
```

**Code Review:**
```
"Review the code in src/Services/"
```

**Run Tests:**
```
"Run the test suite"
```

---

## 🎓 Best Practices

1. **Use security-auditor regularly** - Before deployment, after major changes
2. **Run standards-enforcer** - Before commits, during code review
3. **Generate docs early** - Keep documentation in sync with code
4. **Review before merge** - Use code-reviewer on all PRs
5. **Test frequently** - Let test-runner catch issues early

---

## 📖 Additional Resources

- **Full Agent Documentation:** `E:\github\claude_code_baseline\agents\README.md`
- **Individual Agent Details:** `E:\github\claude_code_baseline\agents\[agent-name].md`
- **Coding Standards:** `E:\github\claude_code_baseline\coding-standards\`
- **Project Setup:** `E:\github\claude_code_baseline\NEW-PROJECT-SETUP.md`

---

## 🆘 Troubleshooting

### Agent Not Activating?

1. Verify installation:
   ```powershell
   ls C:\Users\TimGolden\.claude\agents\
   ```

2. Check agent files are .md format
3. Restart Claude Code if needed

### Need to Disable an Agent Temporarily?

Rename the file:
```powershell
Rename-Item C:\Users\TimGolden\.claude\agents\security-auditor.md `
            C:\Users\TimGolden\.claude\agents\security-auditor.md.disabled
```

### Want to Remove an Agent?

Delete the file:
```powershell
Remove-Item C:\Users\TimGolden\.claude\agents\refactorer.md
```

---

**Last Updated:** November 2025
**Version:** 1.0
**Maintainer:** TimGolden - aka GoldenEye Engineering

**You're all set! Your agents are protecting and improving all your projects system-wide.** 🚀
