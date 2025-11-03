# Global Claude Code Agents

**Reusable agents for all projects**

This directory contains **global agent templates** that can be deployed to any project.

## What Are Agents?

Agents are specialized AI assistants that handle specific tasks. They have:
- Custom system prompts defining their role
- Specific tool access
- Separate context windows
- Automatic activation when tasks match their expertise

## Directory Structure

```
agents/
├── README.md                    # This file
├── gen-docs.md                  # Universal documentation generator
├── code-documenter.md           # Code documentation enforcer
├── code-reviewer.md             # Code quality reviewer
├── test-runner.md               # Test automation
├── security-auditor.md          # Security vulnerability scanner
├── standards-enforcer.md        # Coding standards enforcer
├── git-helper.md                # Git operations assistant
└── refactorer.md                # Code refactoring specialist
```

## Installation

### Option 1: Copy to Project (Recommended)

Copy agents to your project's `.claude/agents/` directory:

```powershell
# Copy all agents
Copy-Item -Recurse E:\github\claude_code_baseline\agents\*.md `
          E:\your-project\.claude\agents\

# Or copy specific agent
Copy-Item E:\github\claude_code_baseline\agents\gen-docs.md `
          E:\your-project\.claude\agents\
```

### Option 2: Symlink (Advanced)

Create symbolic links to keep agents in sync:

```powershell
# Windows (requires admin)
New-Item -ItemType SymbolicLink `
         -Path "E:\your-project\.claude\agents\gen-docs.md" `
         -Target "E:\github\claude_code_baseline\agents\gen-docs.md"
```

### Option 3: Global User Agents

Copy to your global Claude config (available to ALL projects):

```powershell
# Copy to user config
Copy-Item E:\github\claude_code_baseline\agents\*.md `
          $HOME\.claude\agents\
```

## Agent Priority

When agents have the same name:

1. **Project agents** (`.claude/agents/`) - Highest priority
2. **User agents** (`~/.claude/agents/`) - Lower priority

This lets you override global agents with project-specific versions.

## Available Agents

### gen-docs.md
**Purpose:** Generate comprehensive documentation from codebase
**Use when:** Need to document entire project or generate API docs
**Output:** Multiple formats (Markdown, HTML, PHPDoc, JSDoc)

### code-documenter.md
**Purpose:** Ensure all code has proper documentation
**Use when:** Adding docs to existing code or enforcing standards
**Output:** Updated code with PHPDoc/JSDoc comments

### code-reviewer.md
**Purpose:** Review code for quality, security, and best practices
**Use when:** Before commits, after implementing features
**Output:** Review report with issues and suggestions

### test-runner.md
**Purpose:** Run tests and fix failures
**Use when:** After code changes or when tests fail
**Output:** Test results and fixes

### security-auditor.md
**Purpose:** Scan for security vulnerabilities
**Use when:** Regular security audits, before deployment
**Output:** Vulnerability report with severity levels

### standards-enforcer.md
**Purpose:** Enforce coding standards
**Use when:** Code reviews, cleanup tasks
**Output:** Standards compliance report

### git-helper.md
**Purpose:** Git operations (commits, branches, merges)
**Use when:** Need help with git workflows
**Output:** Git operations executed

### refactorer.md
**Purpose:** Refactor and modernize code
**Use when:** Technical debt cleanup, optimization
**Output:** Refactored code with improvements

## Customizing Agents

To customize for your project:

1. Copy agent to `.claude/agents/`
2. Edit the frontmatter and content
3. Save changes

Example customization:

```markdown
---
name: gen-docs
description: Generate docs following OUR standards
tools: Read, Grep, Glob, Bash, Write
model: sonnet
---

# Documentation Generator

You follow the standards in `docs/our-standards.md`...
```

## Creating New Agents

Use the `/agents` command in Claude Code to create new agents, or manually create:

```markdown
---
name: your-agent-name
description: When and why to use this agent
tools: Tool1, Tool2, Tool3  # Optional, leave blank to inherit all
model: sonnet  # or opus, haiku
---

# Your Agent Name

System prompt explaining what this agent does...

## Your Responsibilities

1. Do this
2. Do that

## Your Workflow

Step-by-step instructions...
```

## Usage

Agents activate automatically when Claude detects matching tasks:

```
User: "Generate documentation for this project"
Claude: [Automatically delegates to gen-docs agent]

User: "Run the tests and fix any failures"
Claude: [Automatically delegates to test-runner agent]
```

You can also explicitly invoke agents (if supported by your version of Claude Code).

## Maintenance

### Updating Agents

When you improve an agent template:

1. Update in `E:\github\claude_code_baseline\agents\`
2. Copy to projects that use it
3. Or use symlinks for automatic sync

### Version Control

**Recommended:** Commit project-specific agents to version control:

```gitignore
# .gitignore
.claude/agents/  # Ignore by default
!.claude/agents/project-specific-agent.md  # Include custom ones
```

## Best Practices

1. **Start with templates** - Copy from this directory, then customize
2. **Keep focused** - Each agent should have a single responsibility
3. **Document clearly** - Write detailed instructions in the agent prompt
4. **Test thoroughly** - Test agents before deploying to projects
5. **Share improvements** - Update templates when you discover better patterns

## Getting Help

- **Claude Code Docs**: https://docs.claude.com/en/docs/claude-code/
- **Sub-agents Guide**: https://docs.claude.com/en/docs/claude-code/sub-agents.md
- **This baseline**: See `E:\github\claude_code_baseline\CLAUDE.md`

---

**Last Updated:** 2025-01-15
**Maintainer:** TimGolden - aka GoldenEye Engineering
