# Manual Upload to TestPyPI

## Important: TestPyPI is Separate from PyPI

**TestPyPI (test.pypi.org) is a completely separate service from PyPI (pypi.org)**:
- Different accounts (need to register separately)
- Different API tokens
- Different package namespace
- Purpose: Testing your release process without affecting production

## Step 1: Create TestPyPI Account

1. Go to https://test.pypi.org/account/register/
2. Create a new account (even if you have a PyPI account)
3. Verify your email
4. Enable 2FA (recommended)

## Step 2: Generate TestPyPI API Token

1. Log in to https://test.pypi.org
2. Go to Account Settings → API tokens
3. Click "Add API token"
4. Token name: `cmdrdata-openai-manual-upload`
5. Scope: "Entire account" (for first upload)
6. **Copy the token** - it will look like: `pypi-AgEIcHlwaS5vcmcC...`

## Step 3: Build Your Package

```bash
# Clean old builds
rm -rf dist/ build/ *.egg-info

# Build the package
uv run python -m build

# Verify the build
uv run twine check dist/*
```

## Step 4: Upload to TestPyPI

### Method 1: Direct with Password
```bash
uv run twine upload --repository testpypi dist/* \
  --username __token__ \
  --password pypi-AgEIcHlwaS5vcmcC...  # Your TestPyPI token
```

### Method 2: Using Environment Variables
```bash
export TWINE_USERNAME=__token__
export TWINE_PASSWORD=pypi-AgEIcHlwaS5vcmcC...  # Your TestPyPI token
export TWINE_REPOSITORY_URL=https://test.pypi.org/legacy/

uv run twine upload dist/*
```

### Method 3: Using .pypirc Config
Create `~/.pypirc`:
```ini
[distutils]
index-servers =
    pypi
    testpypi

[pypi]
repository = https://upload.pypi.org/legacy/
username = __token__
password = pypi-YOUR-PRODUCTION-TOKEN

[testpypi]
repository = https://test.pypi.org/legacy/
username = __token__
password = pypi-YOUR-TESTPYPI-TOKEN
```

Then upload:
```bash
uv run twine upload --repository testpypi dist/*
```

## Step 5: Test Installation

```bash
# Install from TestPyPI
pip install --index-url https://test.pypi.org/simple/ \
            --extra-index-url https://pypi.org/simple/ \
            cmdrdata-openai

# Why --extra-index-url?
# TestPyPI doesn't have all dependencies (like openai, httpx)
# So we need to also check regular PyPI for dependencies
```

## Troubleshooting 403 Forbidden Error

### Common Causes and Solutions

#### 1. **Wrong Token (Most Common)**
- **Issue**: Using PyPI token instead of TestPyPI token
- **Fix**: Generate a new token specifically from https://test.pypi.org
- **Check**: Token should work with test.pypi.org, not pypi.org

#### 2. **Package Name Already Taken**
- **Issue**: Someone else already uploaded `cmdrdata-openai` to TestPyPI
- **Fix**: Try with a unique name for testing:
  ```toml
  # Temporarily in pyproject.toml:
  name = "cmdrdata-openai-yourname"  # Add suffix for testing
  ```
- Then rebuild and upload

#### 3. **Token Scope Issues**
- **Issue**: Token doesn't have permission for this package
- **Fix**: Create token with "Entire account" scope for first upload
- After first upload, you can create project-specific tokens

#### 4. **Authentication Format**
- **Issue**: Not using `__token__` as username
- **Fix**: Username must be exactly `__token__` (not your email or username)
  ```bash
  --username __token__  # Literally this string
  --password pypi-xxx   # Your actual token
  ```

#### 5. **Repository URL**
- **Issue**: Uploading to wrong repository
- **Fix**: Explicitly specify TestPyPI:
  ```bash
  uv run twine upload \
    --repository-url https://test.pypi.org/legacy/ \
    dist/* \
    --username __token__ \
    --password YOUR-TESTPYPI-TOKEN
  ```

## Debug Your 403 Error

Run this diagnostic:

```bash
# 1. Verify your token by checking which service it's for
echo "YOUR-TOKEN" | head -c 20
# Should show: pypi-AgEIcHlwaS5vcmcC for TestPyPI
# Different prefix for regular PyPI

# 2. Try verbose upload to see exact error
uv run twine upload \
  --repository-url https://test.pypi.org/legacy/ \
  --verbose \
  dist/* \
  --username __token__ \
  --password YOUR-TESTPYPI-TOKEN

# 3. Check if package name exists
# Visit: https://test.pypi.org/project/cmdrdata-openai/
# If it exists and you don't own it, you need different name
```

## Quick Test Script

Save as `test_upload.sh`:

```bash
#!/bin/bash
echo "Testing TestPyPI upload..."

# Configuration
TESTPYPI_TOKEN="pypi-YOUR-TESTPYPI-TOKEN-HERE"
PACKAGE_NAME="cmdrdata-openai-test-$USER"  # Unique name

# Clean and build
rm -rf dist/ build/
python -m build

# Upload
twine upload \
  --repository-url https://test.pypi.org/legacy/ \
  --username __token__ \
  --password "$TESTPYPI_TOKEN" \
  dist/* \
  --verbose

echo "Check: https://test.pypi.org/project/$PACKAGE_NAME/"
```

## GitHub Actions Fix

For your GitHub Actions 403 error, update your secret:

1. Go to GitHub repo → Settings → Secrets → Actions
2. Delete `TEST_PYPI_API_TOKEN` if it exists
3. Create new secret:
   - Name: `TEST_PYPI_API_TOKEN`
   - Value: Token from https://test.pypi.org (NOT from pypi.org)
4. Verify the token:
   - Must start with `pypi-`
   - Must be from test.pypi.org account
   - Must have "Entire account" scope

## Alternative: Skip TestPyPI

If TestPyPI is giving you trouble, you can:

1. **Test locally** with pip install from dist/:
   ```bash
   pip install dist/cmdrdata_openai-*.whl
   python -c "from cmdrdata_openai import TrackedOpenAI; print('Works!')"
   ```

2. **Use a private PyPI server** (like devpi)

3. **Go straight to production** PyPI (if you're confident)

## Summary Checklist

To fix your 403 error:

- [ ] You have a **separate** TestPyPI account (not your PyPI account)
- [ ] You generated token from https://test.pypi.org (not pypi.org)
- [ ] Token has "Entire account" scope
- [ ] Using `__token__` as username (literally)
- [ ] Package name is available on TestPyPI
- [ ] Using correct repository URL: https://test.pypi.org/legacy/

The most common issue is accidentally using a PyPI token for TestPyPI - they're completely separate services!
