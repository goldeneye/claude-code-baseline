# Quick Agent Installation Guide

## 🎯 Problem: VS Code shows "No agents found"

**Cause:** Agents need to be in your **project's** `.claude/agents/` directory, not just the global user directory.

---

## ✅ Solution: Install Agents in Your Project

### Option 1: Automated Setup (Recommended)

**Step 1:** Download the setup script
- Save `setup-agents.ps1` to your project root

**Step 2:** Run in PowerShell (from project root)
```powershell
# Basic installation
.\setup-agents.ps1

# If agents are in different location
.\setup-agents.ps1 -SourcePath "C:\path\to\agents"

# Overwrite existing agents
.\setup-agents.ps1 -Force
```

**Step 3:** Verify
```powershell
# Check that agents directory was created
ls .claude\agents

# Open VS Code
code .

# Type /agents and you should see your agents!
```

---

### Option 2: Manual Installation

**Step 1:** Create directory structure
```powershell
# In your project root
New-Item -ItemType Directory -Path ".claude\agents" -Force
New-Item -ItemType Directory -Path ".claude\memory\snapshots" -Force
New-Item -ItemType Directory -Path ".claude\context" -Force
New-Item -ItemType Directory -Path "project_docs\session-reports" -Force
New-Item -ItemType Directory -Path "project_docs\agent-reports" -Force
```

**Step 2:** Copy agents
```powershell
# Copy from global agents directory
Copy-Item "C:\Users\User-hom\.claude\agents\*.md" ".\.claude\agents\"

# Or copy downloaded agents individually
Copy-Item "Downloads\end-of-day-integrated.md" ".\.claude\agents\end-of-day.md"
Copy-Item "Downloads\session-start.md" ".\.claude\agents\session-start.md"
```

**Step 3:** Copy other agents
```powershell
# Copy all your existing agents
$agents = @(
    "code-reviewer.md",
    "test-runner.md", 
    "security-auditor.md",
    "standards-enforcer.md",
    "code-documenter.md",
    "gen-docs.md",
    "git-helper.md",
    "refactorer.md"
)

foreach ($agent in $agents) {
    Copy-Item "C:\Users\User-hom\.claude\agents\$agent" ".\.claude\agents\$agent"
}
```

---

## 📁 Expected Directory Structure

After installation, your project should look like:

```
YourProject/
├── .claude/
│   ├── agents/                    ← Agents go here!
│   │   ├── end-of-day.md
│   │   ├── session-start.md
│   │   ├── code-reviewer.md
│   │   ├── test-runner.md
│   │   ├── security-auditor.md
│   │   ├── standards-enforcer.md
│   │   ├── code-documenter.md
│   │   ├── gen-docs.md
│   │   ├── git-helper.md
│   │   └── refactorer.md
│   │
│   ├── memory/                    ← Created by end-of-day
│   │   ├── quick-ref.md
│   │   ├── session-notes-*.md
│   │   ├── project-context.json
│   │   └── snapshots/
│   │
│   └── context/                   ← Created by end-of-day
│       ├── architecture-decisions.md
│       ├── api-quirks.md
│       └── security-findings.md
│
├── project_docs/                  ← Created by end-of-day
│   ├── session-reports/
│   └── agent-reports/
│
├── src/
├── tests/
└── ... (your project files)
```

---

## 🔍 Verification

### Check Agents are Installed

```powershell
# Should show all agents
ls .claude\agents

# Should show 10+ agents
(Get-ChildItem .claude\agents\*.md).Count
```

### Test in VS Code

1. Open VS Code in your project: `code .`
2. Open a file
3. Type `/agents`
4. You should see a list like:
   ```
   code-reviewer
   code-documenter
   end-of-day
   gen-docs
   git-helper
   refactorer
   security-auditor
   session-start
   standards-enforcer
   test-runner
   ```

---

## 🚀 First Use

### Create Initial Memory Files

**In VS Code/Claude Code:**
```
You: "Wrap up the session"

Claude: [end-of-day agent activates]
[Asks debrief questions]
[Creates memory files]
[Generates reports]
```

### Start Next Session with Context

**In VS Code/Claude Code:**
```
You: "What should I work on?"

Claude: [session-start agent activates]
[Loads memory files]
[Provides comprehensive briefing]
[Shows priority tasks]
```

---

## 🎯 Quick Reference

| Command | What Happens |
|---------|-------------|
| `/agents` | Lists all available agents |
| "What should I work on?" | Triggers session-start |
| "Wrap up the session" | Triggers end-of-day |
| "Run the tests" | Triggers test-runner |
| "Run security scan" | Triggers security-auditor |
| "Review this code" | Triggers code-reviewer |
| "Document this code" | Triggers code-documenter |

---

## ❓ Troubleshooting

### Issue: `/agents` still shows "No agents found"

**Solutions:**
1. Verify you're in the project root directory
2. Check `.claude\agents\` exists: `ls .claude\agents`
3. Check agents have `.md` extension
4. Restart VS Code
5. Check VS Code is using Claude Code extension

### Issue: Agents don't activate automatically

**Solutions:**
1. Try explicit invocation: `@agent-name do something`
2. Check agent has proper YAML frontmatter (---name:---description:---)
3. Check agent file syntax is valid markdown

### Issue: Memory files not created

**Solutions:**
1. Check directories exist: `ls .claude\memory`, `ls .claude\context`
2. Run end-of-day agent manually
3. Check file permissions (can Claude write to directory?)

---

## 📚 Related Files

- **setup-agents.ps1** - Automated installation script
- **agent-ecosystem-guide.md** - How agents work together
- **end-of-day-integrated.md** - Main orchestration agent
- **session-start.md** - Context loading agent

---

## 💡 Pro Tips

1. **Global vs Project Agents:**
   - Global (`C:\Users\User-hom\.claude\agents\`) - Available everywhere
   - Project (`.\.claude\agents\`) - Only this project
   - Project agents override global if same name

2. **Custom Per-Project Agents:**
   - Copy global agent to project
   - Modify for project-specific needs
   - Original global agent unchanged

3. **Version Control:**
   - Add `.claude/agents/` to git (if you want to share with team)
   - Or add to `.gitignore` (if agents are personal)
   - Always add `.claude/memory/` to `.gitignore` (session-specific)

4. **Multiple Projects:**
   - Run setup script in each project
   - Agents work independently per project
   - Memory systems don't mix

---

## 🎉 Success!

Once installed, you'll have:
- ✅ 10+ specialized agents available in VS Code
- ✅ Memory system for persistent context
- ✅ Quality checks integrated into workflow
- ✅ Never lose context between sessions

**Next:** Run `end-of-day` once to create initial memory, then `session-start` next session for instant context!

---

**Last Updated:** 2025-11-04
