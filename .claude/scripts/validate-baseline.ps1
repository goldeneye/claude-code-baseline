# Baseline Documentation Validation Script
# Validates all baseline documentation files for consistency and completeness

param(
    [switch]$Verbose,
    [switch]$Fix
)

$ErrorCount = 0
$WarningCount = 0
$baselineDir = "E:\github\claude_code_baseline\baseline_docs"

Write-Host "=== Baseline Documentation Validation ===" -ForegroundColor Cyan
Write-Host ""

# Check if baseline directory exists
if (-not (Test-Path $baselineDir)) {
    Write-Host "ERROR: Baseline directory not found: $baselineDir" -ForegroundColor Red
    exit 1
}

# Get all markdown files
$files = Get-ChildItem -Path $baselineDir -Filter "*.md" | Sort-Object Name

Write-Host "Found $($files.Count) baseline files" -ForegroundColor Green
Write-Host ""

foreach ($file in $files) {
    Write-Host "Validating: $($file.Name)" -ForegroundColor Yellow

    $content = Get-Content $file.FullName -Raw
    $lines = Get-Content $file.FullName

    # Check 1: Frontmatter validation
    if ($content -notmatch '^---\s*\n') {
        Write-Host "  ERROR: Missing YAML frontmatter" -ForegroundColor Red
        $ErrorCount++
    } else {
        # Extract frontmatter
        if ($content -match '(?s)^---(.*?)---') {
            $frontmatter = $matches[1]

            # Check required fields
            if ($frontmatter -notmatch 'title:') {
                Write-Host "  ERROR: Missing 'title' in frontmatter" -ForegroundColor Red
                $ErrorCount++
            }
            if ($frontmatter -notmatch 'version:') {
                Write-Host "  WARNING: Missing 'version' in frontmatter" -ForegroundColor Yellow
                $WarningCount++
            }
            if ($frontmatter -notmatch 'last_updated:') {
                Write-Host "  WARNING: Missing 'last_updated' in frontmatter" -ForegroundColor Yellow
                $WarningCount++
            }
            if ($frontmatter -notmatch 'author:') {
                Write-Host "  WARNING: Missing 'author' in frontmatter" -ForegroundColor Yellow
                $WarningCount++
            }
        }
    }

    # Check 2: Template variables present
    $templateVars = [regex]::Matches($content, '\{\{[A-Z_]+\}\}')
    if ($templateVars.Count -eq 0) {
        Write-Host "  WARNING: No template variables found (expected {{PROJECT_NAME}}, etc.)" -ForegroundColor Yellow
        $WarningCount++
    } else {
        if ($Verbose) {
            Write-Host "  Found $($templateVars.Count) template variables" -ForegroundColor Green
        }
    }

    # Check 3: File length
    $lineCount = $lines.Count
    if ($lineCount -gt 600) {
        Write-Host "  WARNING: File exceeds 600 line limit ($lineCount lines)" -ForegroundColor Yellow
        $WarningCount++
    }

    # Check 4: Cross-references
    if ($content -notmatch '## See Also' -and $content -notmatch '\[.*\]\(.*\.md\)') {
        Write-Host "  WARNING: No cross-references to other documents found" -ForegroundColor Yellow
        $WarningCount++
    }

    # Check 5: Code blocks properly formatted
    $codeBlockStarts = ($content | Select-String -Pattern '^```' -AllMatches).Matches.Count
    if ($codeBlockStarts % 2 -ne 0) {
        Write-Host "  ERROR: Unmatched code block delimiters (```)" -ForegroundColor Red
        $ErrorCount++
    }

    # Check 6: Heading structure (H2 for major sections)
    if ($content -notmatch '## \d+\.' -and $content -notmatch '## [A-Z]') {
        Write-Host "  INFO: Consider using numbered sections (## 1., ## 2., etc.)" -ForegroundColor Cyan
    }

    Write-Host ""
}

# Summary
Write-Host "=== Validation Summary ===" -ForegroundColor Cyan
Write-Host "Files checked: $($files.Count)" -ForegroundColor White
Write-Host "Errors: $ErrorCount" -ForegroundColor $(if ($ErrorCount -eq 0) { "Green" } else { "Red" })
Write-Host "Warnings: $WarningCount" -ForegroundColor $(if ($WarningCount -eq 0) { "Green" } else { "Yellow" })
Write-Host ""

if ($ErrorCount -eq 0 -and $WarningCount -eq 0) {
    Write-Host "All baseline files are valid! " -ForegroundColor Green -NoNewline
    Write-Host "✓" -ForegroundColor Green
    exit 0
} elseif ($ErrorCount -eq 0) {
    Write-Host "Validation passed with warnings" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "Validation failed with errors" -ForegroundColor Red
    exit 1
}
