Session Flow:

START → session-start (loads context)
  ↓
WORK → Use agents on-demand:
  • code-reviewer
  • refactorer
  • test-runner
  • security-auditor
  • standards-enforcer
  • code-documenter
  • gen-docs
  • git-helper
  ↓
END → end-of-day (runs checks, creates memory)
  • Runs test-runner → test results
  • Runs security-auditor → security scan
  • Runs standards-enforcer → compliance check
  • Runs code-documenter → doc coverage
  • Creates memory files
  • Generates reports
  ↓
NEXT SESSION → session-start (instant context)
```

---

## 📊 Quality Integration

Your agents now form a **quality feedback loop**:

1. **end-of-day** runs quality agents
2. Results stored in memory files
3. **session-start** shows quality status
4. User addresses issues
5. Next **end-of-day** tracks improvement
6. **Quality trends over time** 📈

---

## 💾 Memory System Architecture
```
.claude/
├── memory/
│   ├── quick-ref.md              ← Read by session-start (30s context)
│   ├── session-notes-[date].md   ← Detailed daily notes
│   ├── project-context.json      ← Machine-readable context
│   └── snapshots/
│       └── snapshot-[date].json  ← Quality trends
│
├── context/
│   ├── architecture-decisions.md ← Permanent ADRs
│   ├── api-quirks.md
│   ├── security-findings.md      ← Tracked security issues
│   └── technical-debt.md         ← Tracked tech debt
│
project_docs/
├── session-reports/
│   └── session-[date].html       ← Human-readable session report
│
└── agent-reports/
    ├── test-results-[date].html  ← From test-runner
    ├── security-scan-[date].html ← From security-auditor
    └── standards-[date].html     ← From standards-enforcer