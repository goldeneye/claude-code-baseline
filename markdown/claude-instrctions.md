# CLAUDE CODE PROMPT — BASELINE FILE GENERATOR

## 🎯 Objective
Create a **ComplianceScorecard Engineering Baseline Pack** by normalizing all legacy Markdown documentation under `E:\github\claude_code_baseline\tim_wip\markdown` into a clean, modular set of reusable templates.

The output must include exactly **10 Markdown files** formatted for reuse across all future microservices, AI agents, and internal tooling projects.

---

## 📁 OUTPUT DIRECTORY
`E:\github\claude_code_baseline\baseline_docs\`

---

## 🏗️ FILE STRUCTURE TO GENERATE
1. `00-overview.md`
2. `01-architecture.md`
3. `02-security.md`
4. `coding-standards.md`
5. `04-ai-agent-protocol.md`
6. `05-deployment-guide.md`
7. `06-database-schema.md`
8. `07-testing-and-QA.md`
9. `08-api-documentation.md`
10. `09-project-roadmap-template.md`
11. `10-disaster-recovery-and-audit.md`

*(If extra insight is found, include appendix `11-CHANGELOG-TEMPLATE.md`)*

---

## 🧩 SOURCE FILES TO COMBINE

Use and normalize content from:
- `architecture.md`, `security.md`, `guardrails.md`, `deployment_guide.md`
- `CLAUDE_CODE_PROMPT.md`, `CODING_STANDARDS.md`, `Development-Guide.md`
- `API_IMPLEMENTATION_SUMMARY.md`, `API-Documentation.md`
- `COMPLETE_SYSTEM_ANALYSIS.md`, `ROLLBACK_MIGRATION_PLAN_*.md`
- `POLYGON_INTEGRATION_ROADMAP.md`, `POLYGON_10_DAY_SPRINT.md`
- Any other Markdown file that defines procedures, audits, or templates

Ignore `.ps1`, `.sh`, `.php`, and temporary `.html` files.

---

## ⚙️ NORMALIZATION RULES

- Use consistent metadata at top of every file:
  ```yaml
  ---
  title: {{PROJECT_NAME}} - {{DOCUMENT_PURPOSE}}
  version: 1.0
  last_updated: {{DATE}}
  author: ComplianceScorecard Engineering
  ---
Perfect — we’re going **full normalization + bundle creation**.
That means: one coherent set of baseline `.md` templates — clean, modular, and ready to bootstrap any new project.

Here’s your **Claude Code prompt** to generate the complete baseline bundle automatically.

---

## 🧠 **Prompt for Claude Code**

Save this as `CLAUDE_CREATE_BASELINE_PROMPT.md` inside your `/claude_wip` directory.

````markdown
# CLAUDE CODE PROMPT — BASELINE FILE GENERATOR

## 🎯 Objective
Create a **ComplianceScorecard Engineering Baseline Pack** by normalizing all legacy Markdown documentation under `E:\github\claude_code_baseline\tim_wip\markdown` into a clean, modular set of reusable templates.

The output must include exactly **10 Markdown files** formatted for reuse across all future microservices, AI agents, and internal tooling projects.

---

## 📁 OUTPUT DIRECTORY
`E:\github\claude_code_baseline\baseline_docs\`

---

## 🏗️ FILE STRUCTURE TO GENERATE
1. `00-overview.md`
2. `01-architecture.md`
3. `02-security.md`
4. `coding-standards.md`
5. `04-ai-agent-protocol.md`
6. `05-deployment-guide.md`
7. `06-database-schema.md`
8. `07-testing-and-QA.md`
9. `08-api-documentation.md`
10. `09-project-roadmap-template.md`
11. `10-disaster-recovery-and-audit.md`

*(If extra insight is found, include appendix `11-CHANGELOG-TEMPLATE.md`)*

---

## 🧩 SOURCE FILES TO COMBINE

Use and normalize content from:
- `architecture.md`, `security.md`, `guardrails.md`, `deployment_guide.md`
- `CLAUDE_CODE_PROMPT.md`, `CODING_STANDARDS.md`, `Development-Guide.md`
- `API_IMPLEMENTATION_SUMMARY.md`, `API-Documentation.md`
- `COMPLETE_SYSTEM_ANALYSIS.md`, `ROLLBACK_MIGRATION_PLAN_*.md`
- `POLYGON_INTEGRATION_ROADMAP.md`, `POLYGON_10_DAY_SPRINT.md`
- Any other Markdown file that defines procedures, audits, or templates

Ignore `.ps1`, `.sh`, `.php`, and temporary `.html` files.

---

## ⚙️ NORMALIZATION RULES

- Use consistent metadata at top of every file:
  ```yaml
  ---
  title: {{PROJECT_NAME}} - {{DOCUMENT_PURPOSE}}
  version: 1.0
  last_updated: {{DATE}}
  author: ComplianceScorecard Engineering
  ---
````

* Replace all hardcoded project names with:

  * `{{PROJECT_NAME}}`
  * `{{SERVICE_NAME}}`
  * `{{REPO_PATH}}`
  * `{{CONTACT_EMAIL}}`
* Convert HTML files (e.g., `coding-standards.html`, `claude-code-prompt.html`) to Markdown equivalents.
* Preserve any table, list, or code sample formatting.
* Remove time-stamped suffixes (e.g., `_20250804_1200`) from filenames when merging.
* Merge overlapping sections — prefer the newest or most complete version.
* Keep each file under 600 lines for readability.

---

## ✍️ STYLE GUIDELINES

* Tone: professional, instructional, and framework-agnostic.
* Headings: use H2 for major sections (`##`), H3 for subsections.
* Use code blocks for commands, configuration, or API examples.
* Include clear `See Also:` cross-links between documents.
* Where security or policy is described, align with:

  * FTC Safeguards Rule
  * SOC 2 (Security, Availability, Confidentiality)
  * CIS Controls
* Include at least one **Quick Reference Table** per file (if applicable).

---

## 🚀 DELIVERABLE

Output each file to:
`E:\github\claude_code_baseline\baseline_docs\`
and generate a summary index file named `README.md` containing:

* File descriptions
* Purpose
* Version
* Link to each Markdown file

---

## 🧭 EXAMPLE OUTPUT STRUCTURE

```
baseline_docs/
├── 00-overview.md
├── 01-architecture.md
├── 02-security.md
├── coding-standards.md
├── 04-ai-agent-protocol.md
├── 05-deployment-guide.md
├── 06-database-schema.md
├── 07-testing-and-QA.md
├── 08-api-documentation.md
├── 09-project-roadmap-template.md
├── 10-disaster-recovery-and-audit.md
└── README.md
```

---

## 🧠 INTENT SUMMARY

Claude Code should:

1. Analyze all Markdown & HTML documents in `tim_wip/markdown`.
2. Normalize, merge, and deduplicate content under consistent headings.
3. Generate a **baseline pack** containing 10 reusable, framework-agnostic `.md` templates.
4. Output a `README.md` index summarizing their purpose.

---

**End of Prompt**

````

---

## 🪄 How to Run It

In your terminal:
```bash
/claude --prompt "E:\github\claude_code_baseline\claude-instrctions.md"
````

Claude Code will:

* Read all `.md` and `.html` docs under `E:\github\claude_code_baseline\tim_wip\markdown`
* Normalize and merge into `/baseline_docs/`
* Output all 10 standardized baseline templates + index

---

