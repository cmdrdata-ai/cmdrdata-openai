# Pre-Commit Hooks Setup Guide

This guide explains how to set up and use pre-commit hooks for the cmdrdata-openai project to ensure code quality and consistency.

## What are Pre-Commit Hooks?

Pre-commit hooks are scripts that run automatically before each commit to check your code for issues. They help:
- Maintain consistent code formatting (black, isort)
- Catch common errors before they're committed
- Run quick tests to verify changes don't break existing functionality
- Ensure code quality standards are met

## Installation

### 1. Install pre-commit

```bash
# Using uv (recommended)
uv add --dev pre-commit

# Or using pip
pip install pre-commit
```

### 2. Install the git hooks

```bash
# This sets up the hooks in your .git/hooks directory
pre-commit install

# Optional: Install pre-push hooks
pre-commit install --hook-type pre-push
```

### 3. (Optional) Run hooks on all files

```bash
# Test that everything is working
pre-commit run --all-files
```

## Hooks Overview

### Code Formatting (Auto-fix)

These hooks automatically fix issues when you commit:

1. **Black** - Formats Python code to a consistent style
2. **isort** - Sorts and organizes imports
3. **trailing-whitespace** - Removes trailing whitespace
4. **end-of-file-fixer** - Ensures files end with a newline
5. **mixed-line-ending** - Converts to Unix line endings (LF)

### Code Quality Checks

These hooks check for issues but don't auto-fix:

1. **Flake8** - Python linter for style and errors
2. **debug-statements** - Detects leftover debugger imports
3. **check-merge-conflict** - Prevents committing merge conflicts
4. **check-added-large-files** - Warns about files >1MB
5. **no-print-statements** - Ensures no print() in production code

### Testing Hooks

1. **Quick Tests (on commit)** - Runs fast validation tests
2. **Full Test Suite (on push)** - Runs complete test suite

## Usage

### Normal Workflow

```bash
# Make your changes
vim cmdrdata_openai/client.py

# Stage changes
git add cmdrdata_openai/client.py

# Commit - hooks run automatically
git commit -m "Update client implementation"

# If hooks fail, they'll show you what needs fixing
# Fix the issues and commit again
```

### Hook Output Example

```bash
$ git commit -m "Add new feature"
Quick Validation Tests...................................Passed
Check Black Formatting...................................Passed
Check Import Sorting.....................................Passed
trailing-whitespace......................................Fixed
end-of-file-fixer........................................Fixed
[main abc1234] Add new feature
 2 files changed, 50 insertions(+)
```

### Manually Running Hooks

```bash
# Run all hooks on staged files
pre-commit run

# Run all hooks on all files
pre-commit run --all-files

# Run specific hook
pre-commit run black
pre-commit run pytest-quick

# Run hooks on specific files
pre-commit run --files cmdrdata_openai/client.py
```

### Skipping Hooks (Emergency Only)

```bash
# Skip all hooks for this commit
git commit --no-verify -m "Emergency fix"

# Or using shorthand
git commit -n -m "Emergency fix"
```

**Note**: Only skip hooks in emergencies. Always run them afterward:
```bash
pre-commit run --all-files
```

## Fixing Common Issues

### Black Formatting Errors

```bash
# Auto-format with black
uv run black cmdrdata_openai/ tests/

# Check without modifying
uv run black --check cmdrdata_openai/ tests/
```

### Import Sorting Errors

```bash
# Auto-sort imports
uv run isort cmdrdata_openai/ tests/

# Check without modifying
uv run isort --check-only cmdrdata_openai/ tests/
```

### Test Failures

```bash
# Run the quick tests manually
uv run pytest tests/test_validation.py tests/test_context.py -xvs

# Run full test suite
uv run pytest tests/

# Run specific test
uv run pytest tests/test_client.py::TestTrackedOpenAI::test_initialization -xvs
```

### Large File Warning

If you get a warning about large files:
1. Consider if the file really needs to be committed
2. If yes, you can add it to `.gitattributes` for Git LFS
3. Or increase the limit in `.pre-commit-config.yaml`

## Customization

### Disable Specific Hooks

Edit `.pre-commit-config.yaml` and comment out hooks you don't want:

```yaml
# - id: flake8  # Disabled temporarily
```

### Change Test Selection

Edit the `pytest-quick` hook to run different tests:

```yaml
- id: pytest-quick
  entry: bash -c 'uv run pytest tests/test_client.py -xvs'
```

### Add Custom Hooks

Add new hooks to the `local` section:

```yaml
- id: my-custom-check
  name: My Custom Check
  entry: bash -c 'echo "Running custom check"'
  language: system
  pass_filenames: false
```

## CI/CD Integration

The same checks run in GitHub Actions. See `.github/workflows/ci.yml` for the full CI pipeline.

## Troubleshooting

### Hooks Not Running

```bash
# Check if hooks are installed
ls .git/hooks/pre-commit

# Reinstall hooks
pre-commit uninstall
pre-commit install
```

### Permission Errors on Windows

```bash
# Use Git Bash or WSL
# Or run with elevated permissions
```

### Slow Hook Performance

```bash
# Skip the full test suite on commit
# It still runs on push
git commit -m "message"  # Quick tests only
git push  # Full tests run here
```

### Update Hook Versions

```bash
# Update all hook repositories to latest versions
pre-commit autoupdate

# This updates the 'rev' fields in .pre-commit-config.yaml
```

## Best Practices

1. **Don't skip hooks regularly** - They're there to help
2. **Fix issues immediately** - Don't let them accumulate
3. **Run on all files periodically** - `pre-commit run --all-files`
4. **Keep hooks fast** - Long-running hooks discourage use
5. **Document exceptions** - If you must skip, document why in the commit

## Summary

Pre-commit hooks help maintain code quality automatically. The setup is:

1. `uv add --dev pre-commit` - Install pre-commit
2. `pre-commit install` - Set up hooks
3. Write code and commit normally - Hooks run automatically
4. Fix any issues the hooks identify
5. Your code stays clean and consistent!

For more information, see the [pre-commit documentation](https://pre-commit.com/).
