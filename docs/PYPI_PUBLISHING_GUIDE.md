# PyPI Publishing Guide for cmdrdata-openai

## Manual Upload Instructions

### Prerequisites

1. **PyPI Account**: Create an account at https://pypi.org/account/register/
2. **API Token**: Generate at https://pypi.org/manage/account/token/
   - Choose scope: "Entire account" for first upload, or specific project later
   - Save the token securely (starts with `pypi-`)

### Building the Package

```bash
# Clean previous builds
rm -rf dist/ build/ *.egg-info

# Install build tools
uv add --dev build twine

# Build the package
uv run python -m build

# Verify the build
uv run twine check dist/*
```

### Manual Upload to PyPI

#### Method 1: Using API Token (Recommended)

```bash
# Upload to PyPI
uv run twine upload dist/* --username __token__ --password <your-pypi-token>

# Or set environment variables
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=pypi-xxxxxxxxxxxxxxxxxxxxx
uv run twine upload dist/*
```

#### Method 2: Using .pypirc Configuration

Create `~/.pypirc` file:
```ini
[distutils]
index-servers =
    pypi
    testpypi

[pypi]
username = __token__
password = pypi-xxxxxxxxxxxxxxxxxxxxx

[testpypi]
repository = https://test.pypi.org/legacy/
username = __token__
password = pypi-xxxxxxxxxxxxxxxxxxxxx
```

Then upload:
```bash
uv run twine upload dist/*
```

#### Method 3: Interactive Upload

```bash
# Will prompt for username and password
uv run twine upload dist/*
# Username: __token__
# Password: <paste your token>
```

### Testing on TestPyPI First (Recommended)

```bash
# Upload to TestPyPI
uv run twine upload --repository testpypi dist/*

# Test installation from TestPyPI
pip install --index-url https://test.pypi.org/simple/ --extra-index-url https://pypi.org/simple/ cmdrdata-openai
```

## GitHub Actions Setup

### Environment Variable Names

The conventional environment variable names for PyPI in GitHub Actions are:

- **`PYPI_API_TOKEN`** - Most common convention
- **`PYPI_TOKEN`** - Also widely used
- **`PYPI_PASSWORD`** - When using with TWINE

### Setting up GitHub Secrets

1. Go to your repository on GitHub
2. Navigate to Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add the following secrets:
   - Name: `PYPI_API_TOKEN`
   - Value: `pypi-xxxxxxxxxxxxxxxxxxxxx` (your actual token)

### GitHub Actions Workflow Example

Create `.github/workflows/publish.yml`:

```yaml
name: Publish to PyPI

on:
  release:
    types: [published]
  workflow_dispatch:  # Allow manual trigger

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install build twine

      - name: Build package
        run: python -m build

      - name: Check package
        run: twine check dist/*

      - name: Publish to PyPI
        env:
          TWINE_USERNAME: __token__
          TWINE_PASSWORD: ${{ secrets.PYPI_API_TOKEN }}
        run: twine upload dist/*
```

### Alternative: Using PyPA's Official Action

```yaml
name: Publish to PyPI

on:
  release:
    types: [published]

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Build package
        run: |
          python -m pip install --upgrade pip build
          python -m build

      - name: Publish to PyPI
        uses: pypa/gh-action-pypi-publish@release/v1
        with:
          password: ${{ secrets.PYPI_API_TOKEN }}
```

## API Key Management Recommendations

### 1. **1Password** (Recommended for Teams/Personal)
- Purpose-built for secrets management
- Categories for API keys, secure notes
- Browser extension for easy access
- Team sharing capabilities
- CLI tool for automation: `op`
- Pricing: $3/month personal, $8/user/month teams

### 2. **Bitwarden** (Open Source Alternative)
- Free tier available
- Custom fields for API keys
- Self-hosting option
- CLI tool: `bw`
- Browser extension
- Pricing: Free for personal, $3/month premium

### 3. **KeePassXC** (Local, Open Source)
- Completely offline
- No cloud dependency
- Database file you control
- Good for sensitive keys
- Free and open source

### 4. **HashiCorp Vault** (Enterprise)
- API-first design
- Dynamic secrets
- Audit logging
- Best for teams/production
- Self-hosted or cloud

### 5. **AWS Secrets Manager** (Cloud Native)
- If already using AWS
- Automatic rotation
- IAM integration
- $0.40/secret/month

### 6. **Environment File with Git-Crypt**
For development teams:
```bash
# .env.secrets (git-crypted)
PYPI_API_TOKEN=pypi-xxxxxxxxxxxxxxxxxxxxx
OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxx
CMDRDATA_API_KEY=tk-xxxxxxxxxxxxxxxxxxxxx

# Install git-crypt
brew install git-crypt  # macOS
apt-get install git-crypt  # Linux

# Initialize in repo
git-crypt init
git-crypt add-gpg-user YOUR_GPG_KEY_ID
```

### 7. **Pass** (Unix Password Manager)
```bash
# Install
brew install pass  # macOS
apt-get install pass  # Linux

# Store API key
pass insert api/pypi
pass insert api/openai

# Retrieve
pass api/pypi
```

### Quick Comparison

| Tool | Best For | Cloud Sync | CLI | Free Tier | Browser Ext |
|------|----------|------------|-----|-----------|-------------|
| 1Password | Personal/Teams | Yes | Yes | No (30-day trial) | Yes |
| Bitwarden | Personal | Yes | Yes | Yes | Yes |
| KeePassXC | Security-focused | No | Yes | Yes | Yes |
| Vault | Enterprise | Optional | Yes | Yes (OSS) | No |
| AWS Secrets | AWS users | Yes | Yes | Pay-per-use | No |
| git-crypt | Dev teams | Via Git | Yes | Yes | No |
| pass | Unix users | Optional | Yes | Yes | Limited |

### Security Best Practices

1. **Never commit secrets to Git**
   ```bash
   # Add to .gitignore
   .env
   .env.*
   *.key
   *.pem
   ```

2. **Use different tokens for different environments**
   - Development: Limited scope token
   - CI/CD: Project-specific token
   - Production: Separate deployment token

3. **Rotate tokens regularly**
   - Set calendar reminders
   - Use tools that support rotation
   - Keep audit logs

4. **Limit token scope**
   - PyPI: Use project-specific tokens after first upload
   - GitHub: Minimal required permissions
   - Never use account-wide tokens in automation

5. **Enable 2FA everywhere**
   - PyPI account
   - GitHub account
   - Password manager

## Version Management

Before publishing, update version in `pyproject.toml`:

```toml
[project]
name = "cmdrdata-openai"
version = "0.2.0"  # Increment appropriately
```

### Semantic Versioning
- **MAJOR.MINOR.PATCH** (e.g., 1.2.3)
- **MAJOR**: Breaking changes
- **MINOR**: New features, backwards compatible
- **PATCH**: Bug fixes

### Pre-release Versions
```toml
version = "1.0.0a1"  # Alpha
version = "1.0.0b1"  # Beta
version = "1.0.0rc1" # Release candidate
```

## Post-Upload Checklist

1. **Verify on PyPI**: https://pypi.org/project/cmdrdata-openai/
2. **Test installation**: `pip install cmdrdata-openai`
3. **Create GitHub Release**: Tag with version number
4. **Update documentation**: README, CHANGELOG
5. **Announce**: Twitter, Discord, mailing list

## Troubleshooting

### Common Issues

1. **"File already exists"**
   - Version already uploaded
   - Increment version in pyproject.toml

2. **Authentication failed**
   - Check token starts with `pypi-`
   - Ensure using `__token__` as username
   - Verify token hasn't expired

3. **Invalid distribution**
   - Run `twine check dist/*`
   - Rebuild with clean environment
   - Check pyproject.toml syntax

4. **Network timeout**
   - Use `--verbose` flag
   - Try different network
   - Check PyPI status: https://status.python.org/

## Automation Script

Save as `scripts/publish.sh`:

```bash
#!/bin/bash
set -e

echo "Building cmdrdata-openai for PyPI..."

# Clean old builds
rm -rf dist/ build/ *.egg-info

# Build
python -m build

# Check
twine check dist/*

# Upload (will use TWINE_USERNAME and TWINE_PASSWORD from env)
if [ "$1" == "--test" ]; then
    echo "Uploading to TestPyPI..."
    twine upload --repository testpypi dist/*
else
    echo "Uploading to PyPI..."
    echo "Press Ctrl+C to cancel, Enter to continue"
    read
    twine upload dist/*
fi

echo "Done! Package uploaded successfully."
```

Make executable: `chmod +x scripts/publish.sh`

Usage:
```bash
# Test upload
./scripts/publish.sh --test

# Production upload
TWINE_USERNAME=__token__ TWINE_PASSWORD=pypi-xxx ./scripts/publish.sh
```
