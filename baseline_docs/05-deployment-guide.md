---
title: {{PROJECT_NAME}} - Deployment Guide
version: 1.0
last_updated: 2025-11-02
author: ComplianceScorecard Engineering
---

# {{PROJECT_NAME}} — Deployment Guide

## 1. Pre-Deployment Checklist

✅ `.env` file populated with all required variables
✅ `APP_KEY` unique per environment
✅ Database migrations tested
✅ Redis configured for queue and cache
✅ SSL/TLS certificates obtained
✅ Auth0 application configured
✅ Python dependencies installed
✅ All tests passing

---

## 2. Environment Setup

### 2.1 Required Environment Variables

```bash
# Application
APP_NAME={{PROJECT_NAME}}
APP_ENV=production
APP_KEY=base64:{{GENERATE_WITH_php_artisan_key:generate}}
APP_DEBUG=false
APP_URL=https://{{DOMAIN}}

# Database
DB_CONNECTION=mysql
DB_HOST={{DB_HOST}}
DB_PORT=3306
DB_DATABASE={{PROJECT_NAME}}_db
DB_USERNAME={{DB_USER}}
DB_PASSWORD={{DB_PASSWORD}}

# Redis
REDIS_HOST={{REDIS_HOST}}
REDIS_PASSWORD={{REDIS_PASSWORD}}
REDIS_PORT=6379

# Auth0
AUTH0_DOMAIN={{AUTH0_DOMAIN}}
AUTH0_CLIENT_ID={{AUTH0_CLIENT_ID}}
AUTH0_CLIENT_SECRET={{AUTH0_CLIENT_SECRET}}
AUTH0_AUDIENCE={{AUTH0_AUDIENCE}}

# API Configuration
API_RATE_LIMIT_DEFAULT=60
API_JWT_TTL=1440

# Python Scanner Configuration
SCANNER_PYTHON_PATH=/usr/bin/python3
SCANNER_TIMEOUT=300
PYTHONPATH=/usr/local/lib/python3.x/site-packages

# Queue
QUEUE_CONNECTION=redis
HORIZON_ENABLED=true

# Logging
LOG_CHANNEL=stack
LOG_LEVEL=error
```

---

## 3. Deployment Methods

### 3.1 Docker Deployment (Recommended)

**docker-compose.yml**:
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:80"
    environment:
      - APP_ENV=production
    volumes:
      - ./storage:/var/www/html/storage
    depends_on:
      - mysql
      - redis

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
      - ./ssl:/etc/nginx/ssl

  mysql:
    image: mysql:8.0
    environment:
      MYSQL_DATABASE: {{PROJECT_NAME}}_db
      MYSQL_USER: {{DB_USER}}
      MYSQL_PASSWORD: {{DB_PASSWORD}}
      MYSQL_ROOT_PASSWORD: {{DB_ROOT_PASSWORD}}
    volumes:
      - mysql_data:/var/lib/mysql

  redis:
    image: redis:7-alpine
    command: redis-server --requirepass {{REDIS_PASSWORD}}
    volumes:
      - redis_data:/data

  horizon:
    build: .
    command: php artisan horizon
    depends_on:
      - redis

volumes:
  mysql_data:
  redis_data:
```

**Build and Deploy**:
```bash
# Build containers
docker-compose build

# Start services
docker-compose up -d

# Run migrations
docker-compose exec app php artisan migrate --force

# Cache configuration
docker-compose exec app php artisan config:cache
docker-compose exec app php artisan route:cache
docker-compose exec app php artisan view:cache

# Verify deployment
curl https://{{DOMAIN}}/api/v3/health
```

### 3.2 Manual Deployment (VPS/Dedicated Server)

**Prerequisites**:
```bash
# Install PHP 8.2+
sudo apt install php8.2-fpm php8.2-mysql php8.2-redis php8.2-mbstring php8.2-xml

# Install Composer
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install nodejs

# Install Python dependencies
pip3 install checkdmarc python-whois requests beautifulsoup4
```

**Deployment Steps**:
```bash
# Clone repository
cd /var/www
git clone {{REPO_PATH}}
cd {{PROJECT_NAME}}

# Install dependencies
composer install --no-dev --optimize-autoloader
npm ci && npm run build

# Configure environment
cp .env.example .env
nano .env  # Configure variables

# Generate app key
php artisan key:generate

# Run migrations
php artisan migrate --force

# Optimize
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize

# Set permissions
sudo chown -R www-data:www-data storage bootstrap/cache
sudo chmod -R 775 storage bootstrap/cache

# Start queue worker (systemd)
sudo systemctl enable {{PROJECT_NAME}}-horizon
sudo systemctl start {{PROJECT_NAME}}-horizon
```

### 3.3 Laravel Forge Deployment

**Configuration**:
1. Create server in Laravel Forge
2. Link GitHub repository
3. Configure environment variables
4. Enable quick deploy on `main` branch
5. Configure deployment script:

```bash
cd /home/forge/{{DOMAIN}}
git pull origin main
composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader
npm ci && npm run build
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan horizon:terminate  # Graceful restart
```

---

## 4. Database Setup

### 4.1 Initial Migration

```bash
# Fresh install
php artisan migrate:fresh --seed

# Existing database (upgrade)
php artisan migrate --force
```

### 4.2 Seeding Production Data

```bash
# Seed roles and permissions
php artisan db:seed --class=RolesAndPermissionsSeeder

# Seed compliance frameworks
php artisan db:seed --class=ComplianceFrameworkSeeder
```

### 4.3 Database Encryption

**Enable MySQL Tablespace Encryption**:
```sql
ALTER TABLESPACE innodb_system ENCRYPTION='Y';
```

---

## 5. Queue Worker Configuration

### 5.1 Laravel Horizon

**Install Horizon**:
```bash
composer require laravel/horizon
php artisan horizon:install
php artisan horizon:publish
```

**Configure `config/horizon.php`**:
```php
'environments' => [
    'production' => [
        'supervisor-1' => [
            'connection' => 'redis',
            'queue' => ['default', 'high', 'low'],
            'balance' => 'auto',
            'processes' => 10,
            'tries' => 3,
            'timeout' => 300,
        ],
    ],
],
```

**Systemd Service** (`/etc/systemd/system/{{PROJECT_NAME}}-horizon.service`):
```ini
[Unit]
Description={{PROJECT_NAME}} Horizon
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/var/www/{{PROJECT_NAME}}
ExecStart=/usr/bin/php artisan horizon
Restart=always

[Install]
WantedBy=multi-user.target
```

**Enable and Start**:
```bash
sudo systemctl daemon-reload
sudo systemctl enable {{PROJECT_NAME}}-horizon
sudo systemctl start {{PROJECT_NAME}}-horizon
```

---

## 6. Web Server Configuration

### 6.1 Nginx Configuration

**`/etc/nginx/sites-available/{{DOMAIN}}`**:
```nginx
server {
    listen 80;
    listen [::]:80;
    server_name {{DOMAIN}};
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name {{DOMAIN}};

    root /var/www/{{PROJECT_NAME}}/public;
    index index.php;

    ssl_certificate /etc/letsencrypt/live/{{DOMAIN}}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/{{DOMAIN}}/privkey.pem;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;

    add_header X-Frame-Options "DENY";
    add_header X-Content-Type-Options "nosniff";
    add_header X-XSS-Protection "1; mode=block";

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

**Enable Site**:
```bash
sudo ln -s /etc/nginx/sites-available/{{DOMAIN}} /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## 7. SSL/TLS Configuration

### 7.1 Let's Encrypt (Free)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d {{DOMAIN}}

# Auto-renewal (already configured via systemd timer)
sudo systemctl status certbot.timer
```

### 7.2 Commercial Certificate

```bash
# Place certificate files
/etc/nginx/ssl/{{DOMAIN}}.crt
/etc/nginx/ssl/{{DOMAIN}}.key
/etc/nginx/ssl/{{DOMAIN}}.ca-bundle

# Update Nginx configuration
ssl_certificate /etc/nginx/ssl/{{DOMAIN}}.crt;
ssl_certificate_key /etc/nginx/ssl/{{DOMAIN}}.key;
```

---

## 8. Monitoring & Logging

### 8.1 Application Monitoring

**Sentry Integration**:
```bash
composer require sentry/sentry-laravel

# .env
SENTRY_LARAVEL_DSN=https://{{SENTRY_KEY}}@sentry.io/{{PROJECT_ID}}
```

**Datadog Integration**:
```bash
# Install Datadog Agent
DD_API_KEY={{DD_API_KEY}} DD_SITE="datadoghq.com" bash -c "$(curl -L https://s3.amazonaws.com/dd-agent/scripts/install_script.sh)"

# Configure Laravel logging
LOG_CHANNEL=datadog
```

### 8.2 Health Check Endpoint

**Create Route**:
```php
Route::get('/api/v3/health', function () {
    return response()->json([
        'status' => 'healthy',
        'timestamp' => now()->toISOString(),
        'services' => [
            'database' => DB::connection()->getPdo() ? 'up' : 'down',
            'redis' => Redis::ping() ? 'up' : 'down',
            'queue' => Queue::size() >= 0 ? 'up' : 'down',
        ],
    ]);
});
```

---

## 9. Backup & Recovery

### 9.1 Automated Backups

**Database Backup Script**:
```bash
#!/bin/bash
# /usr/local/bin/backup-{{PROJECT_NAME}}.sh

BACKUP_DIR=/backups/{{PROJECT_NAME}}
DATE=$(date +%Y%m%d_%H%M%S)

# MySQL dump
mysqldump -u {{DB_USER}} -p{{DB_PASSWORD}} {{DB_NAME}} | gzip > $BACKUP_DIR/db_$DATE.sql.gz

# Encrypt backup
openssl enc -aes-256-cbc -salt -in $BACKUP_DIR/db_$DATE.sql.gz -out $BACKUP_DIR/db_$DATE.sql.gz.enc -k {{BACKUP_PASSWORD}}
rm $BACKUP_DIR/db_$DATE.sql.gz

# Upload to S3
aws s3 cp $BACKUP_DIR/db_$DATE.sql.gz.enc s3://{{BUCKET}}/backups/

# Cleanup old backups (keep 30 days)
find $BACKUP_DIR -mtime +30 -delete
```

**Cron Job**:
```bash
0 2 * * * /usr/local/bin/backup-{{PROJECT_NAME}}.sh
```

### 9.2 Recovery Procedure

```bash
# Download from S3
aws s3 cp s3://{{BUCKET}}/backups/db_20251102_020000.sql.gz.enc ./

# Decrypt
openssl enc -d -aes-256-cbc -in db_20251102_020000.sql.gz.enc -out db_20251102_020000.sql.gz -k {{BACKUP_PASSWORD}}

# Decompress
gunzip db_20251102_020000.sql.gz

# Restore
mysql -u {{DB_USER}} -p{{DB_PASSWORD}} {{DB_NAME}} < db_20251102_020000.sql
```

---

## 10. Scaling

### 10.1 Horizontal Scaling

**Load Balancer Configuration**:
```nginx
upstream {{PROJECT_NAME}}_backend {
    least_conn;
    server app1.{{DOMAIN}}:80;
    server app2.{{DOMAIN}}:80;
    server app3.{{DOMAIN}}:80;
}

server {
    listen 443 ssl http2;
    server_name {{DOMAIN}};

    location / {
        proxy_pass http://{{PROJECT_NAME}}_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
```

### 10.2 Database Scaling

**Read Replicas** (`config/database.php`):
```php
'mysql' => [
    'write' => [
        'host' => env('DB_WRITE_HOST', '127.0.0.1'),
    ],
    'read' => [
        ['host' => env('DB_READ_HOST_1', '127.0.0.1')],
        ['host' => env('DB_READ_HOST_2', '127.0.0.1')],
    ],
    'sticky' => true,
],
```

---

## 11. Post-Deployment Verification

### 11.1 Verification Checklist

- [ ] Health check endpoint returns 200 OK
- [ ] User can log in via Auth0
- [ ] Database queries execute successfully
- [ ] Queue jobs processing (check Horizon)
- [ ] API endpoints respond correctly
- [ ] SSL certificate valid
- [ ] Logs writing correctly
- [ ] Cron jobs running
- [ ] Backups creating successfully

### 11.2 Smoke Tests

```bash
# Test health endpoint
curl https://{{DOMAIN}}/api/v3/health

# Test API authentication
curl -H "Authorization: Bearer {{JWT_TOKEN}}" https://{{DOMAIN}}/api/v3/auth/user

# Test scan submission
curl -X POST https://{{DOMAIN}}/api/v1/scan \
  -H "Authorization: Bearer {{JWT_TOKEN}}" \
  -H "Content-Type: application/json" \
  -d '{"domain":"example.com"}'
```

---

## See Also

- [Architecture Overview](01-architecture.md) - System components
- [Security Specification](02-security.md) - Security hardening
- [Disaster Recovery](10-disaster-recovery-and-audit.md) - Rollback procedures

---

**Last Updated**: 2025-11-02
**Document Version**: 1.0
**Status**: Production-Ready Baseline
