# Agent Ecosystem Integration Guide

**Project:** {{PROJECT_NAME}}  
**Company:** {{COMPANY_NAME}}  
**Last Updated:** {{DATE}}

---

## 🌐 Agent Ecosystem Overview

This document explains how your 10 agents work together to maintain code quality, security, and project memory across sessions.

---

## 🎯 Agent Types

### 1. Session Orchestrators (Start & End)
- **session-start** - Loads context at session beginning
- **end-of-day** - Wraps up session, runs quality checks, creates memory

### 2. Quality Enforcers (Run by end-of-day)
- **test-runner** - Runs tests, fixes failures
- **security-auditor** - Scans for vulnerabilities
- **standards-enforcer** - Enforces coding standards
- **code-documenter** - Ensures documentation completeness

### 3. Code Improvers (On-demand)
- **code-reviewer** - Reviews code quality
- **refactorer** - Refactors and modernizes code
- **gen-docs** - Generates comprehensive documentation

### 4. Development Helpers (On-demand)
- **git-helper** - Git operations assistance

---

## 🔄 Typical Session Flow

```
┌─────────────────────────────────────────────────────────────┐
│                     SESSION START                            │
│                                                              │
│  1. User opens Claude Code                                   │
│  2. User says "What should I work on?" or similar            │
│  3. session-start agent activates                            │
│  4. Loads memory files:                                      │
│     - .claude/memory/quick-ref.md                           │
│     - .claude/memory/session-notes-[date].md                │
│     - .claude/memory/project-context.json                   │
│     - TODO.md                                                │
│  5. Briefs user on:                                          │
│     - What they were working on                              │
│     - Priority tasks                                         │
│     - Quality issues                                         │
│     - Recent decisions and gotchas                           │
│  6. User starts working with full context                    │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                   ACTIVE DEVELOPMENT                         │
│                                                              │
│  Agents used on-demand during development:                   │
│                                                              │
│  ┌──────────────────┐  ┌──────────────────┐                │
│  │  code-reviewer   │  │   refactorer     │                │
│  │  "Review this    │  │   "Refactor this │                │
│  │   code"          │  │    service"      │                │
│  └──────────────────┘  └──────────────────┘                │
│                                                              │
│  ┌──────────────────┐  ┌──────────────────┐                │
│  │   git-helper     │  │   gen-docs       │                │
│  │   "Help me       │  │   "Generate      │                │
│  │    commit"       │  │    API docs"     │                │
│  └──────────────────┘  └──────────────────┘                │
│                                                              │
│  ┌──────────────────┐  ┌──────────────────┐                │
│  │  test-runner     │  │  security-       │                │
│  │  "Run the tests" │  │   auditor        │                │
│  │                  │  │  "Security scan" │                │
│  └──────────────────┘  └──────────────────┘                │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                     SESSION END                              │
│                                                              │
│  1. User says "Wrap up the session" or similar              │
│  2. end-of-day agent activates                               │
│  3. Asks debrief questions                                   │
│  4. Optionally runs quality checks:                          │
│     ├─ test-runner                                           │
│     ├─ security-auditor                                      │
│     ├─ standards-enforcer                                    │
│     └─ code-documenter                                       │
│  5. Creates/updates memory files:                            │
│     ├─ TODO.md (with quality status)                         │
│     ├─ CHANGELOG.md                                          │
│     ├─ .claude/memory/quick-ref.md                          │
│     ├─ .claude/memory/session-notes-[date].md               │
│     ├─ .claude/memory/project-context.json                  │
│     └─ .claude/memory/snapshots/snapshot-[date].json        │
│  6. Generates reports:                                       │
│     ├─ project_docs/session-reports/session-[date].html    │
│     └─ project_docs/agent-reports/[various].html            │
│  7. Provides summary to user                                 │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔗 Agent Integration Matrix

### end-of-day Integrates With:

| Agent | When | How | Output |
|-------|------|-----|--------|
| **test-runner** | Optional at end of session | Runs tests, captures results | Test coverage stats, failed tests |
| **security-auditor** | Optional at end of session | Scans for vulnerabilities | Security issue count by severity |
| **standards-enforcer** | Optional at end of session | Checks coding standards | Compliance %, violations found |
| **code-documenter** | Optional at end of session | Checks doc coverage | Documentation % |
| **code-reviewer** | Manual trigger | Reviews recent changes | Code quality suggestions |
| **git-helper** | When user wants to commit | Helps create commit messages | Formatted commit messages |

### session-start Reads From:

| File | Purpose | Created By |
|------|---------|------------|
| `.claude/memory/quick-ref.md` | Fast context load | end-of-day |
| `.claude/memory/session-notes-[date].md` | Detailed session history | end-of-day |
| `.claude/memory/project-context.json` | Machine-readable context | end-of-day |
| `TODO.md` | Task list with quality status | end-of-day |
| `.claude/memory/snapshots/snapshot-[date].json` | Project state snapshot | end-of-day |

---

## 📊 Quality Check Integration

### Automatic Quality Checks (end-of-day)

When user wraps up session, end-of-day can optionally run:

```
┌─────────────────────────────────────────────┐
│            QUALITY CHECK FLOW                │
└─────────────────────────────────────────────┘

1. Ask user: "Run quality checks before wrapping up?"

2. If yes, run in parallel:
   
   ┌──────────────┐    ┌──────────────────┐    ┌──────────────────┐
   │ test-runner  │    │ security-auditor │    │ standards-       │
   │              │    │                  │    │ enforcer         │
   │ Runs tests   │    │ Scans code for   │    │ Checks coding    │
   │ Fixes fails  │    │ vulnerabilities  │    │ standards        │
   │              │    │                  │    │                  │
   │ Output:      │    │ Output:          │    │ Output:          │
   │ • XX/XX pass │    │ • X critical     │    │ • XX% compliant  │
   │ • XX% cov    │    │ • X high         │    │ • X violations   │
   └──────────────┘    └──────────────────┘    └──────────────────┘
            │                    │                        │
            └────────────────────┼────────────────────────┘
                                 ↓
                    ┌─────────────────────────┐
                    │  code-documenter        │
                    │                         │
                    │  Checks doc coverage    │
                    │                         │
                    │  Output:                │
                    │  • XX% coverage         │
                    │  • X files need docs    │
                    └─────────────────────────┘
                                 ↓
                    ┌─────────────────────────┐
                    │   AGGREGATE RESULTS     │
                    │                         │
                    │   Store in:             │
                    │   • TODO.md             │
                    │   • CHANGELOG.md        │
                    │   • session-notes.md    │
                    │   • project-context.json│
                    │                         │
                    │   Generate reports:     │
                    │   • Session report HTML │
                    │   • Agent reports       │
                    └─────────────────────────┘
```

### On-Demand Quality Checks (During Development)

User can manually trigger at any time:

```
User: "Run the tests"
  → test-runner agent runs
  → Reports results
  → Fixes any failures
  → Updates test coverage

User: "Run security scan"
  → security-auditor agent runs
  → Scans for vulnerabilities
  → Reports findings by severity
  → Suggests fixes

User: "Check coding standards"
  → standards-enforcer agent runs
  → Identifies violations
  → Can auto-fix some issues
  → Reports compliance status
```

---

## 💾 Memory System Architecture

### Memory Files Created by end-of-day

```
{{REPO_PATH}}/
├── .claude/
│   ├── memory/
│   │   ├── quick-ref.md                    ← Fast context (30 sec read)
│   │   ├── session-notes-YYYY-MM-DD.md     ← Daily detailed notes
│   │   ├── project-context.json            ← Machine-readable context
│   │   └── snapshots/
│   │       └── snapshot-YYYY-MM-DD.json    ← Point-in-time state
│   │
│   ├── context/
│   │   ├── architecture-decisions.md       ← Permanent ADRs
│   │   ├── api-quirks.md                   ← API behavior notes
│   │   ├── database-patterns.md            ← DB patterns
│   │   ├── security-findings.md            ← Security issues
│   │   └── technical-debt.md               ← Tracked tech debt
│   │
│   └── logs/
│       └── session-YYYY-MM-DD.json         ← Optional machine logs
│
├── project_docs/
│   ├── session-reports/
│   │   └── session-YYYY-MM-DD.html         ← Visual session report
│   │
│   └── agent-reports/
│       ├── test-results-YYYY-MM-DD.html    ← Test runner output
│       ├── security-scan-YYYY-MM-DD.html   ← Security audit output
│       ├── standards-YYYY-MM-DD.html       ← Standards check output
│       └── code-review-YYYY-MM-DD.html     ← Code review output
│
├── TODO.md                                  ← Tasks + quality status
└── CHANGELOG.md                             ← Changes + quality checks
```

### Memory File Relationships

```
┌─────────────────────────────────────────────────────────┐
│                  MEMORY FILE HIERARCHY                   │
└─────────────────────────────────────────────────────────┘

                    session-start reads ↓

┌──────────────────────────────────────────────────────────┐
│  quick-ref.md                                             │
│  • Project overview                                       │
│  • Key files                                              │
│  • Patterns & gotchas                                     │
│  • Quality status                                         │
│  • Next priorities                                        │
└──────────────────────────────────────────────────────────┘
                           ↑
                  Summarizes from ↓

┌──────────────────────────────────────────────────────────┐
│  session-notes-[date].md                                  │
│  • Detailed decisions                                     │
│  • Learnings                                              │
│  • Issues & resolutions                                   │
│  • Quality check results                                  │
│  • Agent reports generated                                │
└──────────────────────────────────────────────────────────┘
                           ↑
                 Feeds data to ↓

┌──────────────────────────────────────────────────────────┐
│  project-context.json                                     │
│  • Structured project data                                │
│  • Active features                                        │
│  • Architecture decisions                                 │
│  • Quality metrics                                        │
│  • Agent activity                                         │
└──────────────────────────────────────────────────────────┘
                           ↑
             Point-in-time snapshot ↓

┌──────────────────────────────────────────────────────────┐
│  snapshot-[date].json                                     │
│  • File counts, line counts                               │
│  • Dependency hashes                                      │
│  • Quality metrics snapshot                               │
│  • Changes since last snapshot                            │
└──────────────────────────────────────────────────────────┘
```

---

## 🎯 Usage Patterns

### Pattern 1: Start New Session

```
1. User opens Claude Code
2. User: "What should I work on?"
3. session-start loads context
4. User gets briefing in <60 seconds
5. User starts working with full context
```

### Pattern 2: Complete Feature with Quality Checks

```
1. User works on feature
2. User: "I'm done with the feature"
3. User: "Wrap up the session and run quality checks"
4. end-of-day runs:
   - test-runner
   - security-auditor
   - standards-enforcer
   - code-documenter
5. end-of-day creates memory files
6. User gets summary with quality status
```

### Pattern 3: Quick Session Without Quality Checks

```
1. User makes quick fix
2. User: "Wrap up without quality checks"
3. end-of-day creates memory files only
4. User gets summary
```

### Pattern 4: Manual Quality Check During Development

```
1. User working on code
2. User: "Run security scan"
3. security-auditor runs and reports
4. User fixes issues
5. User continues working
```

### Pattern 5: Code Review Before Committing

```
1. User finishes feature
2. User: "Review this code"
3. code-reviewer analyzes changes
4. User addresses suggestions
5. User: "Help me commit this"
6. git-helper creates commit message
7. User: "Wrap up the session"
8. end-of-day runs and creates memory
```

---

## 🔍 Agent Selection Guide

### "When should I use which agent?"

| Situation | Agent | Command Example |
|-----------|-------|-----------------|
| **Starting work** | session-start | "What should I work on?" |
| **Need full context** | session-start | "Remind me what I was doing" |
| **Finishing work** | end-of-day | "Wrap up the session" |
| **Tests failing** | test-runner | "Run the tests" |
| **Security concern** | security-auditor | "Run security scan" |
| **Standards check** | standards-enforcer | "Check coding standards" |
| **Missing docs** | code-documenter | "Document this code" |
| **Review my code** | code-reviewer | "Review this controller" |
| **Need to refactor** | refactorer | "Refactor this service" |
| **Generate docs** | gen-docs | "Generate API documentation" |
| **Git help** | git-helper | "Help me commit this" |

---

## 📈 Quality Tracking Over Time

### How Quality Trends are Tracked

```
Each Session:
  └─ end-of-day creates snapshot-[date].json
      └─ Contains quality metrics

Over Time:
  └─ Compare snapshots to see trends:
      ├─ Test coverage: 78% → 82% → 85% ✅ Improving
      ├─ Security issues: 5 → 3 → 1 ✅ Improving
      ├─ Standards compliance: 90% → 92% → 95% ✅ Improving
      └─ Documentation: 75% → 75% → 73% ⚠️ Declining

Quality Regression Detection:
  └─ end-of-day compares current to last snapshot
      └─ If regression detected:
          └─ Alerts user in session report
              └─ Recommends addressing before next feature
```

### Example Quality Trend Report

```markdown
## Quality Trends (Last 7 Days)

| Metric | 7 Days Ago | Today | Trend |
|--------|------------|-------|-------|
| Test Coverage | 78% | 85% | ↗️ +7% |
| Security Issues | 5 critical | 0 critical | ↗️ Improved |
| Standards Compliance | 90% | 95% | ↗️ +5% |
| Documentation | 80% | 87% | ↗️ +7% |

🎉 Great job! All quality metrics are improving!
```

---

## 🚀 Best Practices

### Do's ✅

1. **Start every session with session-start**
   - Gets you context in <60 seconds
   - Shows priority tasks
   - Highlights quality issues

2. **End every session with end-of-day**
   - Creates memory for next session
   - Optionally runs quality checks
   - Documents decisions and learnings

3. **Run quality checks regularly**
   - Catch issues early
   - Track improvements over time
   - Prevent technical debt

4. **Use on-demand agents during development**
   - Review code before committing
   - Run tests after changes
   - Check security for sensitive code

5. **Read quick-ref.md when returning after time away**
   - Fastest way to get context
   - Shows current priorities
   - Reminds of patterns and gotchas

### Don'ts ❌

1. **Don't skip end-of-day**
   - Next session will have no context
   - Quality issues won't be tracked
   - Decisions won't be documented

2. **Don't ignore quality issues**
   - Technical debt compounds
   - Harder to fix later
   - Blocks future progress

3. **Don't skip quality checks before major releases**
   - Always run before deploying
   - Security issues can be critical
   - Test failures indicate problems

4. **Don't work on critical issues without running security-auditor**
   - Payment processing
   - Authentication
   - User data handling
   - API endpoints

---

## 🎓 Learning Curve

### Week 1: Basic Usage
- Use session-start and end-of-day
- Get comfortable with memory system
- Try manual quality checks

### Week 2: Quality Integration
- Run quality checks at end of sessions
- Address issues as they appear
- Watch trends improve

### Week 3: Full Integration
- Use all agents naturally
- Quality is part of workflow
- Memory system feels automatic

### Week 4+: Mastery
- Agents feel like team members
- Quality stays consistently high
- Context switching is instant

---

## 📊 Success Metrics

### You know the system is working when:

✅ **Context loading takes <60 seconds**  
✅ **You never ask "what was I working on?"**  
✅ **Quality metrics trend upward**  
✅ **Security issues are caught before deployment**  
✅ **Code reviews are automated and consistent**  
✅ **Documentation stays up to date**  
✅ **Technical debt is tracked and addressed**  
✅ **Tests always pass before committing**  
✅ **New team members get instant context**

---

## 🔧 Troubleshooting

### "session-start says no memory files exist"

**Solution:** Run end-of-day once to create initial memory files.

### "Quality checks take too long"

**Solution:** Run them less frequently (every 2-3 sessions) or skip optional ones.

### "Too many quality issues reported"

**Solution:** 
1. Address critical issues first
2. Set realistic targets
3. Improve gradually over time

### "Memory files are getting too large"

**Solution:** Archive old session notes to `.claude/memory/archive/` after 30 days.

### "Context feels stale"

**Solution:** Re-run session-start or check if memory files are outdated.

---

## 🎯 Next Steps

1. **Install all agents** to `{{REPO_PATH}}/.claude/agents/`
2. **Run end-of-day once** to create initial memory files
3. **Start next session with session-start** to load context
4. **Use agents during development** as needed
5. **Run quality checks** at end of sessions
6. **Watch quality improve** over time!

---

**Document Version:** 1.0.0  
**Last Updated:** {{DATE}}  
**Project:** {{PROJECT_NAME}}  
**Company:** {{COMPANY_NAME}}

---

**Questions?** Check `.claude/memory/quick-ref.md` for project-specific context or ask Claude!
