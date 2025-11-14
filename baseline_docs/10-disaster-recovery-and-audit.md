---
title: {{PROJECT_NAME}} - Disaster Recovery & Audit
version: 1.0
last_updated: 2025-11-02
author: {{USERNAME}} - aka GoldenEye Engineering
---

# {{PROJECT_NAME}} — Disaster Recovery & Audit

## Purpose

This document defines disaster recovery procedures, backup strategies, and audit logging requirements for {{PROJECT_NAME}}. It provides a framework-agnostic template for ensuring business continuity and compliance with audit requirements.

---

## Disaster Recovery Overview

### Recovery Objectives

| Metric | Target | Definition |
|--------|--------|------------|
| **RTO** (Recovery Time Objective) | 4 hours | Maximum acceptable downtime |
| **RPO** (Recovery Point Objective) | 15 minutes | Maximum acceptable data loss |
| **MTTR** (Mean Time To Recovery) | 2 hours | Average time to restore service |
| **MTBF** (Mean Time Between Failures) | 720 hours (30 days) | Average uptime between incidents |

### Business Impact Analysis

| System Component | Business Impact | RTO | RPO |
|-----------------|----------------|-----|-----|
| **Database** | Critical | 2 hours | 15 minutes |
| **Application Servers** | Critical | 4 hours | 1 hour |
| **File Storage** | High | 6 hours | 1 hour |
| **Cache/Redis** | Medium | 8 hours | N/A (ephemeral) |
| **Queue System** | Medium | 4 hours | 1 hour |
| **Static Assets** | Low | 24 hours | 24 hours |

---

## Backup Strategy

### Backup Types

#### 1. Full Backups

**Frequency**: Daily at 2:00 AM UTC
**Retention**: 30 days
**Storage Location**: {{BACKUP_PRIMARY}}, {{BACKUP_SECONDARY}}

**Scope**:
- Complete database dump (all tables, all data)
- Application code repository (tagged release)
- File uploads and user-generated content
- Configuration files and secrets

**Example Command**:
```bash
# MySQL full backup with compression
mysqldump --user={{DB_USER}} \
  --password={{DB_PASSWORD}} \
  --host={{DB_HOST}} \
  --all-databases \
  --single-transaction \
  --quick \
  --lock-tables=false \
  --routines \
  --triggers \
  --events \
  | gzip > /backups/full_backup_$(date +\%Y\%m\%d_\%H\%M\%S).sql.gz

# Verify backup integrity
gunzip -t /backups/full_backup_*.sql.gz && echo "Backup verified"
```

---

#### 2. Incremental Backups

**Frequency**: Every 6 hours
**Retention**: 7 days
**Storage Location**: {{BACKUP_PRIMARY}}

**Scope**:
- Database changes since last backup
- File system changes (new uploads)
- Transaction logs

**Example Command**:
```bash
# Binary log backup for point-in-time recovery
mysqlbinlog --read-from-remote-server \
  --host={{DB_HOST}} \
  --user={{DB_USER}} \
  --password={{DB_PASSWORD}} \
  --stop-never \
  --result-file=/backups/binlog/mysql-bin \
  mysql-bin.000001
```

---

#### 3. Transaction Log Backups

**Frequency**: Every 15 minutes
**Retention**: 24 hours
**Storage Location**: {{BACKUP_PRIMARY}}

**Scope**:
- MySQL binary logs
- Application transaction logs
- Queue job logs

**Purpose**: Enable point-in-time recovery (PITR) to any 15-minute interval.

---

### Backup Automation Scripts

#### Full Database Backup Script

```bash
#!/bin/bash
# File: /scripts/backup-mysql-full.sh

set -e

# Configuration
BACKUP_DIR="/backups/mysql"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RETENTION_DAYS=30
NOTIFICATION_EMAIL="{{CONTACT_EMAIL}}"

# Create backup directory
mkdir -p $BACKUP_DIR

# Perform backup
echo "Starting full backup at $TIMESTAMP"

mysqldump --user=$DB_USER \
  --password=$DB_PASSWORD \
  --host=$DB_HOST \
  --all-databases \
  --single-transaction \
  --quick \
  --lock-tables=false \
  --routines \
  --triggers \
  --events \
  | gzip > $BACKUP_DIR/full_$TIMESTAMP.sql.gz

# Verify backup
if gunzip -t $BACKUP_DIR/full_$TIMESTAMP.sql.gz; then
  echo "Backup verified successfully"
  SIZE=$(du -h $BACKUP_DIR/full_$TIMESTAMP.sql.gz | cut -f1)
  echo "Backup size: $SIZE"
else
  echo "ERROR: Backup verification failed"
  echo "Backup failed for $TIMESTAMP" | mail -s "Backup Failure" $NOTIFICATION_EMAIL
  exit 1
fi

# Upload to remote storage
aws s3 cp $BACKUP_DIR/full_$TIMESTAMP.sql.gz \
  s3://{{BACKUP_BUCKET}}/mysql/full_$TIMESTAMP.sql.gz

# Cleanup old backups
find $BACKUP_DIR -name "full_*.sql.gz" -mtime +$RETENTION_DAYS -delete

echo "Backup completed successfully at $(date)"
```

---

#### Application Files Backup Script

```bash
#!/bin/bash
# File: /scripts/backup-app-files.sh

set -e

APP_DIR="{{REPO_PATH}}"
BACKUP_DIR="/backups/app"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RETENTION_DAYS=30

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup uploaded files and storage
echo "Backing up application files at $TIMESTAMP"

tar -czf $BACKUP_DIR/storage_$TIMESTAMP.tar.gz \
  -C $APP_DIR \
  storage/app \
  storage/logs \
  public/uploads

# Backup configuration (without secrets)
tar -czf $BACKUP_DIR/config_$TIMESTAMP.tar.gz \
  -C $APP_DIR \
  config/ \
  routes/ \
  database/migrations

# Upload to remote storage
aws s3 cp $BACKUP_DIR/storage_$TIMESTAMP.tar.gz \
  s3://{{BACKUP_BUCKET}}/app/storage_$TIMESTAMP.tar.gz

aws s3 cp $BACKUP_DIR/config_$TIMESTAMP.tar.gz \
  s3://{{BACKUP_BUCKET}}/app/config_$TIMESTAMP.tar.gz

# Cleanup old backups
find $BACKUP_DIR -name "*.tar.gz" -mtime +$RETENTION_DAYS -delete

echo "Application files backup completed"
```

---

### Backup Verification

#### Automated Verification

**Daily Verification Tasks**:
1. Verify backup files are not corrupted (checksum validation)
2. Verify backup file sizes are within expected range
3. Test restore of random backup to staging environment
4. Verify backup replication to secondary location

**Weekly Verification Tasks**:
1. Full restore test to isolated environment
2. Verify data integrity post-restore
3. Validate application functionality after restore
4. Document any issues found

**Monthly Verification Tasks**:
1. Full disaster recovery drill
2. Test restore to production-like environment
3. Measure actual RTO and RPO
4. Update disaster recovery procedures based on findings

#### Backup Verification Script

```bash
#!/bin/bash
# File: /scripts/verify-backups.sh

set -e

BACKUP_DIR="/backups/mysql"
TEST_DB="backup_verification_test"

# Find most recent backup
LATEST_BACKUP=$(ls -t $BACKUP_DIR/full_*.sql.gz | head -1)

echo "Verifying backup: $LATEST_BACKUP"

# 1. Verify file integrity
if ! gunzip -t $LATEST_BACKUP; then
  echo "ERROR: Backup file corrupted"
  exit 1
fi

# 2. Verify file size (should be > 10MB)
SIZE=$(stat -c%s $LATEST_BACKUP)
if [ $SIZE -lt 10485760 ]; then
  echo "ERROR: Backup file too small ($SIZE bytes)"
  exit 1
fi

# 3. Test restore to temporary database
echo "Testing restore to temporary database"

mysql -u$DB_USER -p$DB_PASSWORD -e "DROP DATABASE IF EXISTS $TEST_DB; CREATE DATABASE $TEST_DB;"

gunzip < $LATEST_BACKUP | mysql -u$DB_USER -p$DB_PASSWORD $TEST_DB

# 4. Verify critical tables exist
TABLES=$(mysql -u$DB_USER -p$DB_PASSWORD -D$TEST_DB -e "SHOW TABLES;" | wc -l)

if [ $TABLES -lt 10 ]; then
  echo "ERROR: Backup restore incomplete (only $TABLES tables)"
  exit 1
fi

# 5. Cleanup
mysql -u$DB_USER -p$DB_PASSWORD -e "DROP DATABASE $TEST_DB;"

echo "Backup verification successful"
```

---

## Disaster Recovery Procedures

### Scenario 1: Database Corruption/Failure

**Symptoms**:
- Database queries failing
- Data inconsistencies detected
- MySQL service crashes repeatedly

**Recovery Steps**:

1. **Assess Damage** (5 minutes)
   ```bash
   # Check MySQL error logs
   tail -f /var/log/mysql/error.log

   # Attempt connection
   mysql -u$DB_USER -p$DB_PASSWORD -e "SHOW DATABASES;"

   # Check disk space
   df -h
   ```

2. **Stop Application** (2 minutes)
   ```bash
   # Put application in maintenance mode
   php artisan down --message="System maintenance in progress"

   # Stop web servers
   systemctl stop nginx
   systemctl stop php-fpm
   ```

3. **Restore from Backup** (30-60 minutes)
   ```bash
   # Identify last good backup
   ls -lh /backups/mysql/ | tail -5

   # Download from S3 if needed
   aws s3 cp s3://{{BACKUP_BUCKET}}/mysql/full_20251102_020000.sql.gz \
     /backups/restore/

   # Stop MySQL
   systemctl stop mysql

   # Restore database
   gunzip < /backups/restore/full_20251102_020000.sql.gz | \
     mysql -u$DB_USER -p$DB_PASSWORD

   # Start MySQL
   systemctl start mysql
   ```

4. **Point-in-Time Recovery** (15-30 minutes)
   ```bash
   # Apply binary logs from backup time to failure time
   mysqlbinlog --start-datetime="2025-11-02 02:00:00" \
     --stop-datetime="2025-11-02 12:00:00" \
     /backups/binlog/mysql-bin.* | \
     mysql -u$DB_USER -p$DB_PASSWORD
   ```

5. **Verify and Restart** (10 minutes)
   ```bash
   # Run database integrity checks
   mysqlcheck -u$DB_USER -p$DB_PASSWORD --all-databases --check

   # Test critical queries
   mysql -u$DB_USER -p$DB_PASSWORD -e "SELECT COUNT(*) FROM users;"

   # Start application
   systemctl start nginx
   systemctl start php-fpm
   php artisan up

   # Monitor for errors
   tail -f storage/logs/laravel.log
   ```

**Total Estimated Time**: 1-2 hours
**Data Loss**: 0-15 minutes (depending on binary log availability)

---

### Scenario 2: Application Server Failure

**Symptoms**:
- Server unresponsive
- 502 Bad Gateway errors
- SSH connection refused

**Recovery Steps**:

1. **Assess and Failover** (5-10 minutes)
   ```bash
   # Check server health
   ping {{APP_SERVER_IP}}

   # Check from monitoring dashboard
   # - CPU, Memory, Disk usage
   # - Network connectivity

   # If server unreachable, activate standby server
   # Update load balancer to point to standby
   ```

2. **Provision New Server** (20-30 minutes)
   ```bash
   # Launch new EC2 instance / VM
   terraform apply -var="instance_count=1"

   # Or use autoscaling to launch replacement
   aws autoscaling set-desired-capacity \
     --auto-scaling-group-name {{ASG_NAME}} \
     --desired-capacity 3
   ```

3. **Deploy Application** (15-20 minutes)
   ```bash
   # Clone repository
   git clone {{REPO_URL}} /var/www/{{PROJECT_NAME}}

   # Install dependencies
   composer install --no-dev --optimize-autoloader

   # Copy configuration
   aws s3 cp s3://{{CONFIG_BUCKET}}/.env /var/www/{{PROJECT_NAME}}/

   # Set permissions
   chown -R www-data:www-data /var/www/{{PROJECT_NAME}}
   chmod -R 755 storage bootstrap/cache

   # Run migrations if needed
   php artisan migrate --force

   # Clear caches
   php artisan config:cache
   php artisan route:cache
   php artisan view:cache
   ```

4. **Verify and Monitor** (10 minutes)
   ```bash
   # Health check
   curl https://{{DOMAIN}}/health

   # Test critical endpoints
   curl https://{{DOMAIN}}/api/v3/auth/user

   # Monitor logs
   tail -f storage/logs/laravel.log
   ```

**Total Estimated Time**: 45-70 minutes
**Data Loss**: None (database intact)

---

### Scenario 3: Complete Data Center Failure

**Symptoms**:
- All servers in primary region unreachable
- DNS still resolves but connections timeout
- Multiple services down simultaneously

**Recovery Steps**:

1. **Activate Disaster Recovery Site** (30 minutes)
   ```bash
   # Update DNS to point to DR site
   aws route53 change-resource-record-sets \
     --hosted-zone-id {{ZONE_ID}} \
     --change-batch file://failover-to-dr.json

   # DNS TTL: 300 seconds (5 minutes)
   # Full propagation: 30 minutes
   ```

2. **Restore Database in DR Region** (60-90 minutes)
   ```bash
   # Most recent backup replicated to DR region
   aws s3 cp s3://{{BACKUP_BUCKET}}-dr/mysql/full_latest.sql.gz \
     /backups/

   # Restore database
   gunzip < /backups/full_latest.sql.gz | \
     mysql -h {{DR_DB_HOST}} -u$DB_USER -p$DB_PASSWORD

   # Apply latest binary logs
   aws s3 sync s3://{{BACKUP_BUCKET}}-dr/binlog/ /backups/binlog/
   mysqlbinlog /backups/binlog/mysql-bin.* | \
     mysql -h {{DR_DB_HOST}} -u$DB_USER -p$DB_PASSWORD
   ```

3. **Scale DR Environment** (20-30 minutes)
   ```bash
   # Scale up DR application servers
   aws autoscaling set-desired-capacity \
     --auto-scaling-group-name {{DR_ASG_NAME}} \
     --desired-capacity 5

   # Scale up database
   aws rds modify-db-instance \
     --db-instance-identifier {{DR_DB_INSTANCE}} \
     --db-instance-class db.r5.2xlarge \
     --apply-immediately
   ```

4. **Verify Full Functionality** (30 minutes)
   ```bash
   # Comprehensive smoke tests
   php artisan test --filter=SmokeTest

   # Monitor error rates
   # Check all critical user flows
   # Verify data integrity
   ```

**Total Estimated Time**: 2-3 hours
**Data Loss**: 15-60 minutes (depending on replication lag)

---

## Audit Logging

### Audit Requirements

**Compliance Standards**:
- FTC Safeguards Rule: 12-month audit retention
- SOC 2: 24-month audit retention
- CMMC Level 2: Comprehensive audit trail
- GDPR: Data access and modification logs

### Events to Audit

#### Security Events

| Event | Severity | Retention | Details Logged |
|-------|----------|-----------|----------------|
| **User Login** | Info | 24 months | User ID, IP, timestamp, method (SSO/password) |
| **Failed Login** | Warning | 24 months | Attempted username, IP, timestamp, reason |
| **Password Change** | Info | 24 months | User ID, IP, timestamp |
| **Permission Change** | High | 24 months | User ID, old/new permissions, changed by |
| **API Key Created** | High | 24 months | Key ID, created by, permissions |
| **API Key Revoked** | High | 24 months | Key ID, revoked by, reason |

#### Data Access Events

| Event | Severity | Retention | Details Logged |
|-------|----------|-----------|----------------|
| **Client Data Viewed** | Info | 24 months | User ID, client ID, timestamp |
| **Client Data Modified** | Info | 24 months | User ID, client ID, changes (before/after) |
| **Client Data Exported** | High | 24 months | User ID, client ID, export format, timestamp |
| **Assessment Created** | Info | 24 months | User ID, client ID, template ID |
| **Scan Initiated** | Info | 12 months | User ID, domain, scan type |

#### System Events

| Event | Severity | Retention | Details Logged |
|-------|----------|-----------|----------------|
| **Backup Completed** | Info | 12 months | Timestamp, size, duration, status |
| **Backup Failed** | Critical | 24 months | Timestamp, error message, affected system |
| **Configuration Changed** | High | 24 months | Changed by, setting name, old/new value |
| **Database Migration** | High | Permanent | Migration name, timestamp, executed by |
| **Service Started/Stopped** | Info | 12 months | Service name, action, initiated by |

---

### Audit Log Implementation

#### Database Schema

```sql
-- audit_logs table
CREATE TABLE audit_logs (
  id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
  msp_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NULL,
  action VARCHAR(50) NOT NULL,
  entity_type VARCHAR(50) NOT NULL,
  entity_id BIGINT UNSIGNED NULL,
  performed_by VARCHAR(255) NOT NULL,
  ip_address VARCHAR(45),
  user_agent TEXT,
  metadata JSON,
  severity ENUM('info', 'warning', 'high', 'critical') DEFAULT 'info',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

  INDEX idx_msp_created (msp_id, created_at),
  INDEX idx_user_created (user_id, created_at),
  INDEX idx_entity (entity_type, entity_id),
  INDEX idx_action (action, created_at),
  INDEX idx_severity (severity, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

#### Audit Log Service

```php
// app/Services/AuditLogService.php
namespace App\Services;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Crypt;

class AuditLogService
{
    /**
     * Log an audit event
     */
    public function log(array $data): void
    {
        DB::table('audit_logs')->insert([
            'msp_id' => auth()->user()->msp_id ?? $data['msp_id'],
            'user_id' => auth()->id() ?? $data['user_id'] ?? null,
            'action' => $data['action'],
            'entity_type' => $data['entity_type'],
            'entity_id' => $data['entity_id'] ?? null,
            'performed_by' => Crypt::encryptString(
                auth()->user()->email ?? $data['performed_by']
            ),
            'ip_address' => request()->ip(),
            'user_agent' => request()->userAgent(),
            'metadata' => json_encode($this->encryptSensitive($data['metadata'] ?? [])),
            'severity' => $data['severity'] ?? 'info',
            'created_at' => now(),
        ]);
    }

    /**
     * Encrypt sensitive metadata fields
     */
    private function encryptSensitive(array $metadata): array
    {
        $sensitiveFields = ['email', 'name', 'phone', 'changes'];

        foreach ($sensitiveFields as $field) {
            if (isset($metadata[$field])) {
                $metadata[$field] = Crypt::encryptString(
                    json_encode($metadata[$field])
                );
            }
        }

        return $metadata;
    }
}
```

#### Audit Event Examples

```php
// Example 1: Log user login
app(AuditLogService::class)->log([
    'action' => 'user.login',
    'entity_type' => 'user',
    'entity_id' => $user->id,
    'metadata' => [
        'method' => 'auth0',
        'auth0_sub' => $user->auth0_sub,
    ],
    'severity' => 'info',
]);

// Example 2: Log client data modification
app(AuditLogService::class)->log([
    'action' => 'client.updated',
    'entity_type' => 'client',
    'entity_id' => $client->id,
    'metadata' => [
        'changes' => [
            'name' => ['old' => 'Old Name', 'new' => 'New Name'],
            'email' => ['old' => 'old@example.com', 'new' => 'new@example.com'],
        ],
    ],
    'severity' => 'info',
]);

// Example 3: Log permission change
app(AuditLogService::class)->log([
    'action' => 'permission.granted',
    'entity_type' => 'user',
    'entity_id' => $user->id,
    'metadata' => [
        'permission' => 'clients.delete',
        'granted_by' => auth()->user()->email,
    ],
    'severity' => 'high',
]);
```

---

### Audit Reporting

#### Generate Audit Report

```php
// app/Services/AuditReportService.php
public function generateReport(array $filters): array
{
    $query = DB::table('audit_logs')
        ->where('msp_id', auth()->user()->msp_id)
        ->whereBetween('created_at', [$filters['start_date'], $filters['end_date']]);

    if (!empty($filters['action'])) {
        $query->where('action', $filters['action']);
    }

    if (!empty($filters['severity'])) {
        $query->where('severity', $filters['severity']);
    }

    if (!empty($filters['user_id'])) {
        $query->where('user_id', $filters['user_id']);
    }

    return $query->orderBy('created_at', 'desc')
        ->paginate(100)
        ->toArray();
}
```

#### Audit Report Export

```bash
# Export audit logs for compliance review
php artisan audit:export \
  --start="2025-01-01" \
  --end="2025-12-31" \
  --format=csv \
  --output=/exports/audit_2025.csv
```

---

## Monitoring & Alerting

### Critical Alerts

| Alert | Condition | Notification | Action |
|-------|-----------|--------------|--------|
| **Database Down** | Connection fails 3 consecutive times | Email, SMS, PagerDuty | Immediate failover |
| **Backup Failed** | Backup script exits with error | Email | Manual backup within 1 hour |
| **Disk Space Critical** | < 10% free space | Email, Slack | Add storage or cleanup |
| **High Error Rate** | > 5% of requests fail | Email, PagerDuty | Investigate and fix |
| **Security Breach** | Multiple failed logins, unauthorized access | Email, SMS, PagerDuty | Lock accounts, investigate |

### Monitoring Tools

| Tool | Purpose | Metrics Tracked |
|------|---------|----------------|
| **Prometheus + Grafana** | Infrastructure monitoring | CPU, memory, disk, network |
| **New Relic / Datadog** | Application performance | Response times, error rates, throughput |
| **Sentry** | Error tracking | Exceptions, stack traces, user context |
| **CloudWatch** | AWS infrastructure | RDS, EC2, S3, Lambda |
| **UptimeRobot** | External uptime | HTTP status, response time |

---

## Recovery Testing Schedule

### Monthly Tests

- [ ] Restore database backup to staging environment
- [ ] Verify application functionality after restore
- [ ] Test failover to standby server
- [ ] Review and update disaster recovery documentation

### Quarterly Tests

- [ ] Full disaster recovery drill (all services)
- [ ] Measure actual RTO and RPO
- [ ] Test restore to production-like environment
- [ ] Conduct tabletop exercise with all stakeholders

### Annual Tests

- [ ] Complete data center failover to DR region
- [ ] Test restoration from encrypted offsite backups
- [ ] Validate all disaster recovery procedures
- [ ] Update business continuity plan

---

## See Also

- **[02-security.md](02-security.md)** - Security standards and encryption
- **[05-deployment-guide.md](05-deployment-guide.md)** - Deployment procedures
- **[06-database-schema.md](06-database-schema.md)** - Database backup strategies
- **[07-testing-and-QA.md](07-testing-and-QA.md)** - Testing disaster recovery procedures

---

## Template Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `{{PROJECT_NAME}}` | Project display name | MyProject Platform |
| `{{BACKUP_PRIMARY}}` | Primary backup location | s3://backups-primary/mysql |
| `{{BACKUP_SECONDARY}}` | Secondary backup location | s3://backups-dr/mysql |
| `{{BACKUP_BUCKET}}` | S3 backup bucket | company-backups |
| `{{DB_HOST}}` | Database host | db.example.com |
| `{{DB_USER}}` | Database username | backup_user |
| `{{DB_PASSWORD}}` | Database password | secure_password |
| `{{REPO_PATH}}` | Application repository path | /var/www/app |
| `{{REPO_URL}}` | Repository clone URL | git@github.com:org/repo.git |
| `{{DOMAIN}}` | Application domain | https://app.example.com |
| `{{CONTACT_EMAIL}}` | Emergency contact email | ops-team@example.com |

---

**Document Version**: 1.0
**Last Updated**: 2025-11-02
**Author**: {{USERNAME}} - aka GoldenEye Engineering
**Review Cycle**: Quarterly or after major incidents
