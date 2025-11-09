# Claude Code Baseline - HTML Documentation Site

**Location:** `{{BASELINE_ROOT}}\project_docs\`

## Overview

This directory contains a complete HTML documentation website for the Claude Code Baseline project. The site provides comprehensive documentation including code structure, changelogs, TODO lists, and how-to guides.

## Site Structure

```
project_docs/
├── index.html                 # Home page
├── code-documentation.html    # Code structure & components
├── changelog.html             # Version history & updates
├── todo.html                  # Task list & roadmap
├── how-to-guides.html         # Step-by-step guides
├── css/
│   └── custom.css            # Custom Bootstrap theme
├── js/
│   └── (JavaScript files)
├── images/
│   └── (Image assets)
└── includes/
    ├── header.html           # Shared header/navigation
    └── footer.html           # Shared footer

## Features

- **Bootstrap 5** - Modern, responsive design
- **Shared Components** - Consistent header/footer across all pages
- **Custom Theme** - Purple gradient design with smooth animations
- **Responsive** - Mobile-friendly layout
- **Print-Friendly** - Optimized for printing
- **Smooth Navigation** - Inter-page and anchor linking

## Viewing the Site

### Option 1: Open Directly
```powershell
# Open in default browser
start project_docs/index.html
```

### Option 2: Local Server
```powershell
# Using Python
cd project_docs
python -m http.server 8000

# Then visit: http://localhost:8000
```

### Option 3: VS Code Live Server
- Install "Live Server" extension
- Right-click `index.html`
- Select "Open with Live Server"

## Pages Overview

### 1. Home Page (`index.html`)
- Project status overview
- Quick links to all sections
- Recent updates timeline
- Key features highlight
- Quick start commands

### 2. Code Documentation (`code-documentation.html`)
**To be created - includes:**
- Project structure tree
- PowerShell scripts documentation
- AI agent system overview
- Baseline documentation templates
- Coding standards structure
- File organization details

### 3. Changelog (`changelog.html`)
**To be created - includes:**
- Version history
- Release notes
- Feature additions
- Bug fixes
- Breaking changes

### 4. TODO List (`todo.html`)
**To be created - includes:**
- Pending tasks
- In-progress items
- Completed tasks
- Future enhancements
- Priority levels

### 5. How-To Guides (`how-to-guides.html`)
**To be created - includes:**
- Creating new projects
- Adding to existing projects
- Using AI agents
- Customizing standards
- Template variable replacement
- Backup and rollback procedures

## Next Steps

Use the gen-docs agent to generate the remaining pages:

```powershell
# Generate code documentation page
# Use the agent at: {{USER_HOME}}\.claude\agents\gen-docs.md

# Or create manually following the structure of index.html
```

## Design System

### Colors
- **Primary:** `#667eea` (Purple)
- **Secondary:** `#764ba2` (Deep Purple)
- **Gradient:** `linear-gradient(135deg, #667eea 0%, #764ba2 100%)`

### Components
- **doc-card:** Elevated card with hover effect
- **hero-section:** Large header with gradient background
- **timeline:** Vertical timeline for updates
- **icon-box:** Colored icon containers
- **breadcrumb-custom:** Navigation breadcrumbs

### Typography
- **Headings:** Bold, dark color
- **Body:** 16px, line-height 1.6
- **Code:** Monospace with light background

## Maintenance

### Adding New Pages
1. Copy template from `index.html`
2. Update `<title>` and content
3. Add link to `includes/header.html`
4. Add link to `includes/footer.html`
5. Test navigation

### Updating Styles
Edit `css/custom.css` - changes apply to all pages automatically.

### Updating Navigation
Edit `includes/header.html` and `includes/footer.html` - changes apply to all pages.

## Browser Compatibility

- ✅ Chrome/Edge (Latest)
- ✅ Firefox (Latest)
- ✅ Safari (Latest)
- ✅ Mobile browsers

## Technologies Used

- **Bootstrap 5.3.0** - UI framework
- **Font Awesome 6.4.0** - Icons
- **Vanilla JavaScript** - Interactions
- **CSS3** - Custom styling
- **HTML5** - Semantic markup

## Credits

**Created by:** {{USERNAME}} - aka GoldenEye Engineering
**Date:** January 2025
**Purpose:** Comprehensive HTML documentation for Claude Code Baseline

---

**For the complete project documentation, visit:** [index.html](index.html)
