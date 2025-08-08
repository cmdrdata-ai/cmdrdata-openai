# Release Process for cmdrdata-openai

This guide explains how to release new versions of cmdrdata-openai to PyPI.

## 📋 Overview

The release process involves:
1. Preparing your code for release
2. Creating a GitHub release
3. Automatic publishing to PyPI
4. Verification

## 🚀 Quick Release (Standard Process)

### Step 1: Prepare for Release

```bash
# 1. Ensure you're on main branch with latest changes
git checkout main
git pull origin main

# 2. Run tests locally
uv run pytest

# 3. Update version in pyproject.toml
# Edit: version = "0.2.0"  # or whatever your new version is

# 4. Update CHANGELOG.md (if you maintain one)
# Add your release notes

# 5. Commit version bump
git add pyproject.toml CHANGELOG.md
git commit -m "Bump version to 0.2.0"
git push origin main
```

### Step 2: Create GitHub Release

#### Option A: Using GitHub UI (Easiest)
1. Go to https://github.com/[your-username]/cmdrdata-openai/releases
2. Click "Draft a new release"
3. Click "Choose a tag" → Create new tag: `v0.2.0`
4. Release title: `v0.2.0`
5. Description: Add release notes (what's new, breaking changes, etc.)
6. If pre-release: Check "Set as pre-release"
7. Click "Publish release"

**What happens automatically:**
- GitHub Actions triggers the publish workflow
- Package is built and tested
- Package is uploaded to PyPI
- Artifacts are signed and attached to release

#### Option B: Using GitHub CLI
```bash
# Create and push tag
git tag -a v0.2.0 -m "Release version 0.2.0"
git push origin v0.2.0

# Create release
gh release create v0.2.0 \
  --title "v0.2.0" \
  --notes "Release notes here" \
  --draft=false
```

#### Option C: Using Release Workflow
1. Go to Actions tab in GitHub
2. Select "Create Release" workflow
3. Click "Run workflow"
4. Enter version: `0.2.0`
5. Check pre-release if applicable
6. Click "Run workflow"

This automatically:
- Updates version in pyproject.toml
- Creates git tag
- Generates changelog
- Creates GitHub release
- Triggers publish workflow

### Step 3: Monitor the Release

1. Go to Actions tab
2. Watch the "Publish to PyPI" workflow
3. It should show:
   - ✅ Build distribution
   - ✅ Publish to PyPI
   - ✅ Sign and upload to GitHub Release

### Step 4: Verify

```bash
# Wait 1-2 minutes for PyPI to update
pip install --upgrade cmdrdata-openai

# Verify version
python -c "import cmdrdata_openai; print(cmdrdata_openai.__version__)"
```

## 🧪 Testing with TestPyPI (Recommended for First Release)

### Step 1: Manual Test Upload

1. Go to Actions tab
2. Select "Publish to PyPI" workflow
3. Click "Run workflow"
4. Set `test_pypi: true`
5. Run workflow

### Step 2: Test Installation

```bash
# Install from TestPyPI
pip install --index-url https://test.pypi.org/simple/ \
            --extra-index-url https://pypi.org/simple/ \
            cmdrdata-openai

# Test it works
python -c "from cmdrdata_openai import TrackedOpenAI; print('Success!')"
```

### Step 3: If Test Passes, Release to Production

Follow the standard release process above.

## 🔄 Release Types

### Standard Release (e.g., v0.2.0)
- Full production release
- Automatically publishes to PyPI
- Creates GitHub release with artifacts

### Pre-release/Release Candidate (e.g., v0.2.0rc1)
- Tag with `rc`, `alpha`, or `beta` suffix
- Automatically publishes to TestPyPI
- Marked as pre-release on GitHub

### Patch Release (e.g., v0.2.1)
- For bug fixes only
- Same process as standard release
- Should not introduce new features

### Major Release (e.g., v1.0.0)
- Breaking changes
- Update README with migration guide
- Consider deprecation period for old versions

## 📝 Version Numbering

Follow [Semantic Versioning](https://semver.org/):

```
MAJOR.MINOR.PATCH

1.2.3
│ │ └── Patch: Bug fixes (backwards compatible)
│ └──── Minor: New features (backwards compatible)
└────── Major: Breaking changes
```

### Pre-release Versions
```
0.2.0rc1   # Release candidate 1
0.2.0rc2   # Release candidate 2
0.2.0      # Final release

0.3.0a1    # Alpha release
0.3.0b1    # Beta release
```

## 🎯 Release Checklist

Before releasing, ensure:

- [ ] All tests pass: `uv run pytest`
- [ ] Code is formatted: `uv run black cmdrdata_openai/`
- [ ] Imports are sorted: `uv run isort cmdrdata_openai/`
- [ ] Version updated in `pyproject.toml`
- [ ] CHANGELOG updated (if applicable)
- [ ] Documentation updated for new features
- [ ] Breaking changes clearly documented
- [ ] GitHub secrets configured:
  - [ ] `PYPI_API_TOKEN`
  - [ ] `TEST_PYPI_API_TOKEN` (optional)

## 🔧 Manual Release (Fallback)

If GitHub Actions fails, you can release manually:

```bash
# 1. Build the package
uv run python -m build

# 2. Check the package
uv run twine check dist/*

# 3. Upload to TestPyPI (optional)
uv run twine upload --repository testpypi dist/*

# 4. Upload to PyPI
uv run twine upload dist/* \
  --username __token__ \
  --password $PYPI_API_TOKEN
```

## 🚨 Troubleshooting

### "Version already exists" Error
- PyPI doesn't allow re-uploading the same version
- Increment version number and try again
- Delete local dist/ folder and rebuild

### Authentication Failed
- Check `PYPI_API_TOKEN` secret is set correctly
- Ensure token starts with `pypi-`
- Token might be expired - generate a new one

### Workflow Not Running
- Check you created a tag starting with `v` (e.g., `v0.2.0`)
- Ensure workflow files are on main branch
- Check Actions tab for error messages

### Package Not Installing
- Wait 1-2 minutes after upload for PyPI to update
- Try clearing pip cache: `pip cache purge`
- Check PyPI page: https://pypi.org/project/cmdrdata-openai/

## 📊 Post-Release

After successful release:

1. **Announce the Release**
   - Update project README if needed
   - Post on social media/forums
   - Notify users of breaking changes

2. **Monitor PyPI Statistics**
   - Check download counts
   - Monitor for issues on GitHub

3. **Start Next Development Cycle**
   ```bash
   # Create development branch
   git checkout -b dev/0.3.0

   # Update version for development
   # In pyproject.toml: version = "0.3.0.dev0"
   ```

## 🔄 Release Frequency

Recommended cadence:
- **Patches**: As needed for critical bugs
- **Minor**: Every 2-4 weeks with new features
- **Major**: Every 3-6 months with careful planning

## 📚 Examples

### Example: Releasing a Bug Fix (v0.2.1)
```bash
# Fix bug in code
git add -A
git commit -m "Fix: Handle None values in tracker"

# Update version
# Edit pyproject.toml: version = "0.2.1"
git add pyproject.toml
git commit -m "Bump version to 0.2.1"
git push origin main

# Create release on GitHub
# Tag: v0.2.1
# Title: v0.2.1 - Bug Fix Release
# Notes: "Fixes issue with None values in usage tracker"
```

### Example: Releasing New Feature (v0.3.0)
```bash
# After feature is merged to main
# Update version to 0.3.0
# Create release on GitHub with detailed notes
# Tag: v0.3.0
# Include: - New features
#          - Improvements
#          - Bug fixes
#          - Breaking changes (if any)
```

### Example: Testing Release Candidate
```bash
# Create RC version
# pyproject.toml: version = "0.3.0rc1"
# Push and tag: v0.3.0rc1
# This goes to TestPyPI automatically
# Test thoroughly
# If good, release v0.3.0 to production
```

## 🎉 Success!

Your package is now available on PyPI:
- PyPI page: https://pypi.org/project/cmdrdata-openai/
- Install: `pip install cmdrdata-openai`
- Upgrade: `pip install --upgrade cmdrdata-openai`
