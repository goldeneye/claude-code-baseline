# Environment Configuration Guide

**Last Updated**: 2025-11-03
**Maintainer**: TimGolden - aka GoldenEye Engineering

---

## 🔐 Overview

This repository uses a `.env` file to manage sensitive credentials and configuration for shared resources like API keys, database connections, and cloud services.

---

## 🚀 Quick Setup

### 1. Create Your .env File

```bash
# Copy the example template
cp .env.example .env
```

### 2. Fill in Your Credentials

Open `.env` and replace placeholder values with your actual keys:

```env
# Example - Replace with your actual key
ANTHROPIC_API_KEY=sk-ant-api03-your-actual-key-here
```

### 3. Verify .gitignore

The `.env` file is automatically excluded from Git via `.gitignore`. **Never commit `.env` to version control.**

```bash
# Verify .env is ignored
git status
# .env should NOT appear in untracked files
```

---

## 📋 Available Environment Variables

### Required Variables

| Variable | Purpose | Where to Get |
|----------|---------|--------------|
| `ANTHROPIC_API_KEY` | Claude API access | https://console.anthropic.com/ |

### Optional Variables

| Variable | Purpose | Where to Get |
|----------|---------|--------------|
| `OPENAI_API_KEY` | OpenAI API access (for comparison) | https://platform.openai.com/api-keys |
| `AUTH0_DOMAIN` | Auth0 SSO domain | https://manage.auth0.com/ |
| `AUTH0_CLIENT_ID` | Auth0 client ID | Auth0 Dashboard → Applications |
| `AUTH0_CLIENT_SECRET` | Auth0 client secret | Auth0 Dashboard → Applications |
| `DB_HOST` | Database host | Your database server |
| `DB_DATABASE` | Database name | Your database |
| `DB_USERNAME` | Database user | Your DB credentials |
| `DB_PASSWORD` | Database password | Your DB credentials |
| `AWS_ACCESS_KEY_ID` | AWS access key | AWS IAM Console |
| `AWS_SECRET_ACCESS_KEY` | AWS secret key | AWS IAM Console |
| `AWS_BUCKET` | S3 bucket name | AWS S3 Console |
| `SENTRY_DSN` | Error tracking DSN | https://sentry.io/ |

---

## 🔧 Using Environment Variables

### In PowerShell Scripts

```powershell
# Load .env file
Get-Content .env | ForEach-Object {
    if ($_ -match '^([^=]+)=(.*)$') {
        $name = $matches[1]
        $value = $matches[2]
        [Environment]::SetEnvironmentVariable($name, $value, 'Process')
    }
}

# Use the variable
$apiKey = $env:ANTHROPIC_API_KEY
```

### In Python Scripts

```python
# Install python-dotenv
pip install python-dotenv

# Load .env file
from dotenv import load_dotenv
import os

load_dotenv()

# Use the variable
api_key = os.getenv('ANTHROPIC_API_KEY')
```

### In PHP/Laravel

```php
// Laravel automatically loads .env
$apiKey = env('ANTHROPIC_API_KEY');

// Or use config file
// config/services.php
return [
    'anthropic' => [
        'api_key' => env('ANTHROPIC_API_KEY'),
    ],
];
```

### In Node.js

```javascript
// Install dotenv
npm install dotenv

// Load .env file
require('dotenv').config();

// Use the variable
const apiKey = process.env.ANTHROPIC_API_KEY;
```

---

## 🔒 Security Best Practices

### DO ✅

1. **Add .env to .gitignore** (already done)
2. **Use .env.example as a template** (commit this, not .env)
3. **Share credentials securely**:
   - Password manager (1Password, LastPass, Bitwarden)
   - Encrypted messaging (Signal)
   - Encrypted email
4. **Rotate keys regularly** (every 90 days recommended)
5. **Use different keys for dev/staging/production**
6. **Restrict API key permissions** to minimum required
7. **Monitor API usage** for unusual activity

### DON'T ❌

1. ❌ **Never commit .env to Git**
2. ❌ **Never share keys via Slack, Discord, or plain text**
3. ❌ **Never hardcode keys in source code**
4. ❌ **Never share keys in screenshots or logs**
5. ❌ **Never use production keys in development**
6. ❌ **Never store keys in plain text files** (except .env with proper .gitignore)

---

## 🔄 Key Rotation Process

### When to Rotate Keys

- Every 90 days (best practice)
- Immediately if compromised
- When team members leave
- After security incidents

### How to Rotate

1. **Generate new key** in service provider console
2. **Update .env file** with new key
3. **Test** to ensure new key works
4. **Revoke old key** in service provider console
5. **Notify team** if shared resource

**Example:**

```bash
# 1. Backup current .env
cp .env .env.backup

# 2. Update ANTHROPIC_API_KEY in .env
# (Get new key from https://console.anthropic.com/)

# 3. Test the new key
# Run a test script or automation

# 4. Delete backup if successful
rm .env.backup
```

---

## 📊 Environment Variable Checklist

Use this checklist when setting up a new environment:

### Development Environment

- [ ] `.env` file created from `.env.example`
- [ ] `ANTHROPIC_API_KEY` configured
- [ ] `.env` confirmed in `.gitignore`
- [ ] Keys tested and working
- [ ] Backup of `.env` stored securely (encrypted)

### Production Environment

- [ ] Separate production API keys generated
- [ ] Production keys have restricted permissions
- [ ] Keys stored in secure secret management system
- [ ] Environment variables set in hosting platform
- [ ] Keys rotation schedule documented
- [ ] Monitoring configured for API usage

---

## 🚨 What to Do If Key is Compromised

1. **Immediately revoke the compromised key**
   - Go to service provider console
   - Revoke/delete the key

2. **Generate a new key**
   - Create replacement with minimum required permissions

3. **Update all systems**
   - Update `.env` file
   - Update any automated scripts
   - Restart services if needed

4. **Investigate the breach**
   - How was key exposed?
   - What data was accessed?
   - What systems were affected?

5. **Document the incident**
   - Timeline of events
   - Actions taken
   - Lessons learned

6. **Implement preventive measures**
   - Review security practices
   - Update team training
   - Improve monitoring

---

## 📖 Additional Resources

### Password Managers

- **1Password**: https://1password.com/
- **LastPass**: https://www.lastpass.com/
- **Bitwarden**: https://bitwarden.com/

### Secret Management Services

- **AWS Secrets Manager**: https://aws.amazon.com/secrets-manager/
- **Azure Key Vault**: https://azure.microsoft.com/en-us/products/key-vault/
- **HashiCorp Vault**: https://www.vaultproject.io/
- **Google Secret Manager**: https://cloud.google.com/secret-manager

### API Key Best Practices

- **OWASP**: https://cheatsheetseries.owasp.org/cheatsheets/API_Security_Cheat_Sheet.html
- **Anthropic Security**: https://docs.anthropic.com/claude/docs/api-security

---

## 🔍 Troubleshooting

### Issue: "API key not found"

**Solution**:
```bash
# Check if .env exists
ls -la .env

# Verify .env is loaded
cat .env

# Check environment variable is set
echo $env:ANTHROPIC_API_KEY  # PowerShell
echo $ANTHROPIC_API_KEY      # Bash
```

### Issue: "Invalid API key"

**Solution**:
1. Verify key copied correctly (no extra spaces)
2. Check key hasn't expired
3. Verify key has correct permissions
4. Try regenerating key in console

### Issue: ".env changes not taking effect"

**Solution**:
1. Restart your terminal/IDE
2. Reload environment variables
3. Check for typos in variable names
4. Verify no conflicting system environment variables

---

## 📝 Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-11-03 | Initial environment configuration setup |

---

**Remember**: Your `.env` file contains sensitive credentials. Treat it like a password and never share it insecurely! 🔐
