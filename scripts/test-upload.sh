#!/bin/bash
# Quick script to test TestPyPI upload with a unique name

# Set your TestPyPI token here
TESTPYPI_TOKEN="${TEST_PYPI_API_TOKEN:-your-token-here}"

# Create unique package name for testing
TIMESTAMP=$(date +%Y%m%d%H%M%S)
TEST_NAME="cmdrdata-openai-test-${TIMESTAMP}"

echo "Testing upload with package name: $TEST_NAME"

# Temporarily modify pyproject.toml
cp pyproject.toml pyproject.toml.backup
sed -i "s/name = \"cmdrdata-openai\"/name = \"$TEST_NAME\"/" pyproject.toml

# Clean and build
rm -rf dist/ build/
python -m build

# Upload to TestPyPI
twine upload \
  --repository-url https://test.pypi.org/legacy/ \
  --username __token__ \
  --password "$TESTPYPI_TOKEN" \
  dist/* \
  --verbose

# Restore original pyproject.toml
mv pyproject.toml.backup pyproject.toml

echo ""
echo "If successful, check: https://test.pypi.org/project/$TEST_NAME/"
echo "To test install: pip install -i https://test.pypi.org/simple/ $TEST_NAME"