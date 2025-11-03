# Claude Code Working Directory

**Purpose:** This directory is used by Claude Code for temporary files, drafts, analysis, and working materials during development.

## Directory Structure

```
claude_wip/
├── drafts/        # Draft implementations before finalizing
├── analysis/      # Code analysis and research notes
├── scratch/       # Temporary experiments and calculations
├── backups/       # Quick backups during refactoring
└── README.md      # This file
```

## Usage Guidelines

### What Goes Here

**✅ DO store:**
- Draft code implementations being tested
- Refactored code before replacing originals
- Analysis documents and research notes
- Temporary test files and experiments
- Generated reports and documentation drafts
- Code snippets for comparison
- Performance benchmarking results

**❌ DON'T store:**
- Final production code (use proper directories)
- Committed code (use git for version control)
- Large binary files or datasets
- Sensitive data or credentials
- Long-term documentation (use docs/ instead)

## Common Workflows

### Drafting New Features

```bash
1. Create draft in claude_wip/drafts/
2. Test and iterate
3. When ready, move to proper location in project
4. Clean up draft file
```

**Example:**
```
claude_wip/drafts/UserAuthService_v2.php
→ app/Services/UserAuthService.php
```

### Safe Refactoring

```bash
1. Copy original to claude_wip/backups/
2. Make changes to file in place
3. Test thoroughly
4. If successful, delete backup
5. If failed, restore from backup
```

### Code Analysis

```bash
1. Store analysis in claude_wip/analysis/
2. Document findings
3. Keep as reference for future work
```

## File Naming Conventions

### Drafts
```
{ClassName}_v{version}.{ext}
{ClassName}_draft.{ext}
{feature-name}_implementation.{ext}
```

### Analysis
```
{topic}-analysis.md
{component}-research.md
{feature}-investigation.md
```

### Backups
```
{ClassName}_backup_{timestamp}.{ext}
{file-name}_before_refactor.{ext}
```

### Scratch Work
```
test_{feature}.{ext}
experiment_{topic}.{ext}
scratch_{date}.{ext}
```

## Cleanup Policy

**Regular Cleanup:**
- Review files weekly
- Delete outdated drafts
- Archive useful analysis to docs/
- Remove completed experiments

**Keep:**
- Active drafts in progress
- Recent analysis (< 30 days)
- Valuable research notes

**Delete:**
- Completed drafts (already moved to final location)
- Failed experiments
- Outdated backups (> 7 days)
- Duplicate files

## Git Configuration

This directory should be in `.gitignore`:

```gitignore
# Claude Code working directory
claude_wip/
!claude_wip/README.md
```

This keeps temporary files out of version control while preserving the directory structure.

## Example File Organization

```
claude_wip/
├── drafts/
│   ├── AssessmentScoringService_v2.php    # Testing new scoring algorithm
│   └── ClientSegmentation_draft.php       # New feature in progress
│
├── analysis/
│   ├── database-performance-analysis.md   # Query optimization research
│   └── security-review-findings.md        # Security audit notes
│
├── scratch/
│   ├── test_calculation.php               # Quick math verification
│   └── experiment_caching.php             # Testing cache strategies
│
└── backups/
    └── UserService_backup_20250115.php    # Pre-refactor backup
```

## Tips for Claude Code

When working on this project, Claude should:

1. **Always use subdirectories** - Don't dump files at root level
2. **Use descriptive names** - Make file purpose clear
3. **Clean up after yourself** - Delete files when done
4. **Document complex work** - Add notes to analysis files
5. **Respect the structure** - Follow the directory conventions

## Project-Specific Notes

<!-- Add any project-specific instructions or conventions here -->

---

**Last Updated:** {{DATE}}
**Project:** {{PROJECT_NAME}}
