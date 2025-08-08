# GitHub Secrets Setup for cmdrdata-openai

This document outlines the required GitHub secrets for automated publishing to PyPI.

## Required Secrets

### 1. `PYPI_API_TOKEN` (Required)
**Purpose**: Authentication for publishing to PyPI
**How to create**:
1. Log in to https://pypi.org
2. Go to Account Settings → API tokens
3. Click "Add API token"
4. Name: `cmdrdata-openai-github-actions`
5. Scope:
   - First time: "Entire account" (can restrict after first upload)
   - After first upload: "Project: cmdrdata-openai"
6. Copy the token (starts with `pypi-`)
7. Add to GitHub repository:
   - Go to Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Name: `PYPI_API_TOKEN`
   - Value: Paste your token

### 2. `TEST_PYPI_API_TOKEN` (Optional but Recommended)
**Purpose**: Authentication for publishing to TestPyPI for testing
**How to create**:
1. Log in to https://test.pypi.org (separate account from PyPI)
2. Go to Account Settings → API tokens
3. Click "Add API token"
4. Name: `cmdrdata-openai-github-actions-test`
5. Scope: "Entire account" (for test environment)
6. Copy the token
7. Add to GitHub repository:
   - Name: `TEST_PYPI_API_TOKEN`
   - Value: Paste your test token

### 3. `CODECOV_TOKEN` (Already Set Up)
**Purpose**: Upload coverage reports to Codecov
**Status**: Already configured in CI workflow

## GitHub Environments (Optional)

For additional security, you can set up GitHub environments:

### Production Environment (pypi)
1. Go to Settings → Environments
2. Click "New environment"
3. Name: `pypi`
4. Add protection rules:
   - Required reviewers (optional)
   - Restrict to protected branches
5. Add environment secrets:
   - `PYPI_API_TOKEN`

### Test Environment (testpypi)
1. Create environment: `testpypi`
2. No protection rules needed
3. Add environment secrets:
   - `TEST_PYPI_API_TOKEN`

## Workflow Triggers

The publish workflow supports multiple triggers:

### 1. Automatic on Release
```bash
# Create a release on GitHub
# The workflow will automatically:
# - Build the package
# - Upload to PyPI (if not a pre-release)
# - Upload to TestPyPI (if it's a release candidate)
# - Sign and attach artifacts to the release
```

### 2. Manual Trigger for Testing
```bash
# From GitHub Actions tab:
# 1. Select "Publish to PyPI" workflow
# 2. Click "Run workflow"
# 3. Choose options:
#    - test_pypi: true  → Uploads to TestPyPI
#    - test_pypi: false → Uploads to PyPI
```

### 3. Using the Release Workflow
```bash
# From GitHub Actions tab:
# 1. Select "Create Release" workflow
# 2. Click "Run workflow"
# 3. Enter version (e.g., 0.2.0)
# 4. Check "prerelease" if applicable
# This will:
# - Update version in pyproject.toml
# - Create a git tag
# - Create GitHub release
# - Trigger the publish workflow
```

## Testing Your Setup

### 1. Test with TestPyPI First
```bash
# Manually trigger workflow with test_pypi = true
# Or create a release candidate (e.g., v0.2.0rc1)
```

### 2. Verify on TestPyPI
```bash
pip install --index-url https://test.pypi.org/simple/ \
            --extra-index-url https://pypi.org/simple/ \
            cmdrdata-openai
```

### 3. Production Release
```bash
# Create a GitHub release with tag v0.2.0
# Workflow will automatically publish to PyPI
```

## Security Best Practices

1. **Use Fine-Grained Tokens**
   - After first upload, create project-specific tokens
   - Revoke and rotate tokens regularly

2. **Enable 2FA**
   - On PyPI account
   - On GitHub account

3. **Use Environment Protection**
   - Require approval for production deployments
   - Restrict to protected branches

4. **Monitor Usage**
   - Check PyPI download statistics
   - Review GitHub Actions logs
   - Set up alerts for failed publishes

## Troubleshooting

### Common Issues

1. **Authentication Failed**
   - Verify token starts with `pypi-`
   - Check secret name matches exactly: `PYPI_API_TOKEN`
   - Ensure token hasn't expired

2. **Version Already Exists**
   - PyPI doesn't allow overwriting versions
   - Increment version in pyproject.toml
   - Delete the tag and release if needed

3. **TestPyPI vs PyPI Confusion**
   - TestPyPI and PyPI are separate services
   - Need separate accounts and tokens
   - TestPyPI may have dependency issues

4. **Workflow Not Triggering**
   - Check branch protection rules
   - Verify workflow file syntax
   - Check GitHub Actions is enabled

## Manual Publishing (Fallback)

If GitHub Actions fails, you can publish manually:

```bash
# Build locally
uv run python -m build

# Check the package
uv run twine check dist/*

# Upload to PyPI
uv run twine upload dist/* \
  --username __token__ \
  --password pypi-xxxxxxxxxxxxx
```

## Verification Checklist

- [ ] `PYPI_API_TOKEN` secret added
- [ ] `TEST_PYPI_API_TOKEN` secret added (optional)
- [ ] Test publish to TestPyPI successful
- [ ] Production publish to PyPI successful
- [ ] Artifacts attached to GitHub release
- [ ] Package installable via `pip install cmdrdata-openai`
