---
title: {{PROJECT_NAME}} - System Overview
version: 1.0
last_updated: 2025-11-02
author: {{USERNAME}} - aka GoldenEye Engineering timgolden.com
---

# {{PROJECT_NAME}} — System Overview

## Purpose

This document provides a high-level overview of {{PROJECT_NAME}}, a compliance and security assessment platform designed for MSPs, MSSPs, and vCISOs. The system enables automated compliance scanning, client assessment management, and regulatory framework alignment.

---

## System Identity

| Attribute | Value |
|-----------|-------|
| **Project Name** | {{PROJECT_NAME}} |
| **Service Type** | Multi-tenant SaaS Platform |
| **Primary Framework** | Laravel 11+ / React |
| **Target Users** | MSPs, MSSPs, vCISOs, Compliance Teams |
| **Deployment Model** | Docker-first, cloud-native |
| **Repository Path** | {{REPO_PATH}} |

---

## Core Capabilities

### 1. Compliance Scanning & Assessment
- Automated domain security scanning (DNS, WHOIS, Email Security, Web Privacy)
- Multi-framework compliance mapping (FTC Safeguards, SOC 2, CIS Controls, CMMC)
- Real-time scan progress tracking
- Letter-grade scoring system (A-F) with detailed breakdowns

### 2. Client & Assessment Management
- Multi-tenant MSP architecture with client isolation
- Assessment template creation and versioning
- Assessment event scheduling and tracking
- Role-based access control (RBAC) with 201+ permissions

### 3. AI-Driven Analysis
- Client segmentation and risk scoring
- Bring-Your-Own (BYO) AI model support (OpenAI, Anthropic, etc.)
- Default open-source GPT integration
- Field-level encryption for sensitive AI data

### 4. API & Integration
- RESTful API with JWT authentication
- Rate limiting and IP whitelisting
- Service-to-service authentication via Auth0
- Webhook support for async notifications

### 5. Reporting & Export
- PDF report generation
- Executive vs. technical report views
- Compliance framework mapping
- Automated scheduled reports

---

## Technology Stack

### Backend
- **Framework**: Laravel 11+ (PHP 8.2+)
- **Database**: MySQL 8 with InnoDB tablespace encryption
- **Cache/Queue**: Redis
- **Authentication**: Auth0 (OIDC/JWT)
- **API Security**: JWT Bearer tokens, encrypted API keys

### Frontend
- **Framework**: React 18+ with Redux Toolkit
- **UI Library**: Material-UI
- **Build Tool**: Vite
- **Styling**: Tailwind CSS + Custom themes

### Infrastructure
- **Containerization**: Docker + Docker Compose
- **Orchestration**: Laravel Horizon (queue management)
- **Logging**: Monolog → Datadog/Sentry
- **Monitoring**: Health checks + metrics dashboard

### Specialized Components
- **Python Scanners**: DNS, WHOIS, Web Privacy analyzers
- **AI Integration**: Multi-provider support with encryption
- **PDF Generation**: Laravel Dompdf/Snappy

---

## System Architecture (Simplified)

```
┌─────────────────────────────────────────────────────────┐
│                     Frontend Layer                       │
│  React App → Auth0 Login → API Gateway                  │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                   API Layer (Laravel)                    │
│  Controllers → Services → Jobs → External Scanners      │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│                  Data Layer (MySQL)                      │
│  Encrypted Storage → Audit Logs → Relationship Mgmt     │
└─────────────────────────────────────────────────────────┘
```

---

## Key Differentiators

### Security-First Design
- Field-level encryption for PII and sensitive data
- Auth0 SSO with JWT validation
- IP whitelisting and rate limiting
- No plaintext storage of keys or tokens
- Audit trail for all actions

### Multi-Tenant Isolation
- `msp_id` filtering on all queries
- Dedicated API keys per MSP
- Per-MSP AI configuration
- Data segregation at database level

### Framework-Agnostic
- Supports custom compliance frameworks
- Template variables for easy reuse
- No hardcoded client/project names
- Portable across deployments

### Compliance Alignment
- **FTC Safeguards Rule**: Encryption, access control, audit logging
- **SOC 2**: Security, availability, confidentiality controls
- **CIS Controls**: Automated security checks
- **CMMC Level 2**: 110+ control mappings

---

## User Roles & Permissions

| Role | Description | Key Permissions |
|------|-------------|-----------------|
| **Super Admin** | Full system access | All permissions (201+) |
| **MSP Admin** | Company-wide admin | Manage clients, users, settings |
| **Company User** | Internal team member | View/edit assigned clients |
| **Client User** | End-client access | View own assessments only |
| **Auditor** | Read-only compliance view | Read assessments, generate reports |
| **Peer Group Admin** | Cross-org collaboration | Manage peer group data |

---

## Deployment Models

### 1. Local Development
```bash
php artisan serve --port=3100  # Backend
npm run dev                     # Frontend (port 3101)
```

### 2. Docker Compose (Staging/Prod)
```bash
docker-compose up -d
```

### 3. Managed Cloud (Laravel Forge/Vapor)
- Single container or multi-node
- Auto-scaling with load balancer
- Managed database (RDS) and Redis cluster

---

## Service Ports

| Service | Port | Description |
|---------|------|-------------|
| Main Platform API | 3000 | Primary Laravel backend |
| Client Segmentation API | 3100 | Microservice for AI analysis |
| Frontend Dev Server | 3101 | Vite development server |
| GPT-OSS Local Engine | 5000 | Optional local AI inference |
| MySQL | 3306 | Database server |
| Redis | 6379 | Cache and queue |

---

## Quick Reference

### Essential Commands
```bash
# Database setup
php artisan migrate:fresh --seed

# Clear caches
php artisan cache:clear && php artisan config:clear && php artisan route:clear

# Queue worker
php artisan queue:listen --tries=1

# Run tests
php artisan test --coverage

# Development environment (all services)
composer run dev
```

### Environment Variables
```env
APP_NAME={{PROJECT_NAME}}
APP_ENV=local
APP_KEY=base64:...

DB_DATABASE={{PROJECT_NAME}}_db
REDIS_HOST=127.0.0.1

AUTH0_DOMAIN={{AUTH0_DOMAIN}}
AUTH0_CLIENT_ID={{AUTH0_CLIENT_ID}}
AUTH0_CLIENT_SECRET={{AUTH0_CLIENT_SECRET}}

API_RATE_LIMIT_DEFAULT=60
```

---

## Success Metrics

### Technical Metrics
- API response times < 2s
- 99.9% uptime
- Queue job processing < 5 min average
- Zero critical security vulnerabilities

### Business Metrics
- Assessment completion rate > 80%
- User adoption across MSP teams
- Export/report generation frequency
- Client satisfaction scores

---

## Documentation Index

| Document | Purpose |
|----------|---------|
| `01-architecture.md` | Detailed system architecture and data flows |
| `02-security.md` | Security model, encryption, authentication |
| `coding-standards.md` | Development guidelines and code style |
| `04-ai-agent-protocol.md` | AI integration patterns and Claude Code workflow |
| `05-deployment-guide.md` | Deployment procedures and environment setup |
| `06-database-schema.md` | Database tables, relationships, and migrations |
| `07-testing-and-QA.md` | Testing strategy and quality assurance |
| `08-api-documentation.md` | API endpoints, authentication, and examples |
| `09-project-roadmap-template.md` | Feature planning and sprint templates |
| `10-disaster-recovery-and-audit.md` | Backup, rollback, and audit procedures |

---

## See Also

- [Architecture Overview](01-architecture.md) - Deep dive into system components
- [Security Specification](02-security.md) - Authentication and encryption details
- [Deployment Guide](05-deployment-guide.md) - Setup and scaling instructions

---

## Contact & Support

- **Engineering Team**: {{CONTACT_EMAIL}}
- **Documentation**: {{REPO_PATH}}/baseline_docs/
- **Issue Tracker**: {{REPO_PATH}}/issues

---

**Last Updated**: 2025-11-02
**Document Version**: 1.0
**Status**: Production-Ready Baseline
