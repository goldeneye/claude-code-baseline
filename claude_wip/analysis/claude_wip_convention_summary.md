# Claude_WIP Directory Convention - Implementation Summary

**Date:** 2025-01-15
**Purpose:** Document the standardized `claude_wip/` working directory convention

---

## What Was Implemented

### 1. CLAUDE.md Updates

Added comprehensive documentation about the `claude_wip/` convention:

**Location:** `CLAUDE.md` lines 260-333

**Sections Added:**
- Working Directory Convention purpose and structure
- What to store (DO/DON'T lists)
- Usage examples for common workflows
- Template variable `{{CLAUDE_WIP_PATH}}`
- .gitignore configuration
- Integration with Claude Code requirements

### 2. Directory Structure Created

```
claude_wip/
├── README.md           # Usage guidelines and conventions
├── drafts/            # Draft implementations
├── analysis/          # Code analysis and research
├── scratch/           # Temporary experiments
└── backups/           # Quick backups during refactoring
```

### 3. Template Variable Added

**New Variable:** `{{CLAUDE_WIP_PATH}}`

**Definition:** Path to claude_wip directory (usually `{{REPO_PATH}}/claude_wip`)

**Updated in:**
- CLAUDE.md Template Variable System section
- File Organization diagram

### 4. Integration with Claude Code

**Added to "What Claude MUST do" section:**
- Use `claude_wip/` directory for all temporary files
- Specific subdirectory usage guidelines
- Clear separation of draft work from production code

---

## Benefits

### For Claude Code AI
- ✅ Clear location for temporary work
- ✅ Organized by work type (drafts/analysis/scratch/backups)
- ✅ Prevents cluttering production directories
- ✅ Safe experimentation space

### For Developers
- ✅ Easy to find Claude's working files
- ✅ Can review drafts before finalizing
- ✅ Clear separation of WIP from production
- ✅ Safe to clean up/delete entire directory

### For Projects
- ✅ Standardized across all projects
- ✅ .gitignore keeps it out of version control
- ✅ Structure preserves itself (README + .gitkeep)
- ✅ Self-documenting with clear conventions

---

## Usage Patterns

### Pattern 1: Drafting New Features

```bash
# Claude creates draft
claude_wip/drafts/NewFeature_v1.php

# Test and iterate
claude_wip/drafts/NewFeature_v2.php

# Finalize and move
app/Services/NewFeature.php

# Clean up drafts
rm claude_wip/drafts/NewFeature_*.php
```

### Pattern 2: Safe Refactoring

```bash
# Backup original
cp app/Services/OldCode.php claude_wip/backups/OldCode_backup.php

# Refactor in place
nano app/Services/OldCode.php

# Test
php artisan test

# Success? Delete backup
rm claude_wip/backups/OldCode_backup.php
```

### Pattern 3: Research and Analysis

```bash
# Analyze code
claude_wip/analysis/performance-bottlenecks.md

# Document findings
claude_wip/analysis/database-optimization-options.md

# Keep as reference for future work
```

### Pattern 4: Quick Experiments

```bash
# Test idea
claude_wip/scratch/test_new_algorithm.php

# Verify approach
php claude_wip/scratch/test_new_algorithm.php

# Use or discard
```

---

## File Naming Conventions

### Drafts
- `{ClassName}_v{version}.{ext}` - Example: `UserService_v2.php`
- `{ClassName}_draft.{ext}` - Example: `AuthController_draft.php`
- `{feature-name}_implementation.{ext}` - Example: `payment-gateway_implementation.php`

### Analysis
- `{topic}-analysis.md` - Example: `security-analysis.md`
- `{component}-research.md` - Example: `caching-research.md`
- `{feature}-investigation.md` - Example: `auth-flow-investigation.md`

### Backups
- `{ClassName}_backup_{timestamp}.{ext}` - Example: `UserService_backup_20250115.php`
- `{file-name}_before_refactor.{ext}` - Example: `payment_before_refactor.php`

### Scratch
- `test_{feature}.{ext}` - Example: `test_scoring.php`
- `experiment_{topic}.{ext}` - Example: `experiment_caching.php`
- `scratch_{date}.{ext}` - Example: `scratch_20250115.php`

---

## .gitignore Configuration

**Add to every project's `.gitignore`:**

```gitignore
# Claude Code working directory
claude_wip/
!claude_wip/README.md
!claude_wip/**/.gitkeep
```

This configuration:
- Ignores all files in `claude_wip/`
- Preserves the README.md
- Preserves .gitkeep files to maintain structure

---

## Integration Points

### CLAUDE.md References
1. **Template Variable System** (lines 47-62) - Defines `{{CLAUDE_WIP_PATH}}`
2. **File Organization** (lines 218-258) - Shows directory structure
3. **Working Directory Convention** (lines 260-333) - Full documentation
4. **Integration with Claude Code** (lines 159-174) - Usage requirements

### Baseline Documentation
- Can be referenced in `04-ai-agent-protocol.md`
- Should be mentioned in project setup guides
- Include in new project templates

---

## Rollout to Other Projects

### For Existing Projects

**Step 1:** Create directory structure
```bash
mkdir -p claude_wip/{drafts,analysis,scratch,backups}
```

**Step 2:** Copy README
```bash
cp baseline_docs/claude_wip/README.md claude_wip/
```

**Step 3:** Update .gitignore
```bash
echo "" >> .gitignore
echo "# Claude Code working directory" >> .gitignore
echo "claude_wip/" >> .gitignore
echo "!claude_wip/README.md" >> .gitignore
```

**Step 4:** Update project's CLAUDE.md
```markdown
## Working Directory

Claude Code uses `claude_wip/` for temporary files and working materials.
See `claude_wip/README.md` for usage guidelines.
```

### For New Projects

**Include in project template:**
- `claude_wip/` directory structure
- `claude_wip/README.md` with conventions
- `.gitignore` entry
- Reference in project's CLAUDE.md

---

## Maintenance

### Weekly Cleanup

```bash
# Review old files
find claude_wip/ -type f -mtime +7 -ls

# Clean up completed drafts
rm claude_wip/drafts/*_complete.php

# Archive valuable analysis
mv claude_wip/analysis/important.md docs/research/

# Remove old backups
find claude_wip/backups/ -mtime +7 -delete
```

### Monthly Review

- Review all analysis files
- Archive useful research to docs/
- Clean out scratch experiments
- Remove outdated backups

---

## Examples from Real Usage

### Example 1: Feature Development
```
claude_wip/drafts/ClientSegmentationService_v1.php
→ Initial implementation with basic logic

claude_wip/drafts/ClientSegmentationService_v2.php
→ Added scoring algorithm

claude_wip/analysis/segmentation-criteria-research.md
→ Documented decision-making process

Final: app/Services/ClientSegmentationService.php
→ Moved to production location
```

### Example 2: Refactoring
```
claude_wip/backups/AssessmentController_before_refactor.php
→ Saved original before changes

claude_wip/analysis/assessment-refactoring-plan.md
→ Documented refactoring approach

app/Http/Controllers/AssessmentController.php
→ Refactored in place

Testing passed → deleted backup
```

### Example 3: Investigation
```
claude_wip/scratch/test_database_query_performance.php
→ Quick performance test

claude_wip/analysis/database-optimization-findings.md
→ Documented results and recommendations

Applied findings to production code
Kept analysis file as reference
```

---

## Related Documentation

- [CLAUDE.md](../../CLAUDE.md) - Main project documentation
- [coding-standards/07-safety-rules.md](../../coding-standards/07-safety-rules.md) - Safety guidelines
- [baseline_docs/04-ai-agent-protocol.md](../../baseline_docs/04-ai-agent-protocol.md) - AI integration

---

## Success Metrics

**This convention is successful if:**
- ✅ Claude consistently uses `claude_wip/` for temporary work
- ✅ No draft/temporary files in production directories
- ✅ Developers can easily find and review Claude's work
- ✅ Clean separation between WIP and production code
- ✅ Adopted across all projects in organization

---

**Implementation Date:** 2025-01-15
**Status:** Active
**Next Review:** 2025-02-15
