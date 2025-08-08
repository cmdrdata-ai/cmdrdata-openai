# Dependency Management Guide

## How CmdrData-OpenAI Works With Your OpenAI Installation

### The Architecture
CmdrData-OpenAI is a **wrapper**, not a replacement. It works by:

1. **Importing** the official OpenAI SDK
2. **Wrapping** it with tracking capabilities
3. **Forwarding** all calls transparently
4. **Tracking** usage without interfering

### Installation Scenarios

#### Scenario 1: You Already Have OpenAI Installed
```bash
# You have:
openai==1.58.0  # Your existing version

# Install CmdrData:
pip install cmdrdata-openai

# Result:
openai==1.58.0  # Keeps your version!
cmdrdata-openai==0.1.0  # Adds tracking
```

#### Scenario 2: Fresh Installation
```bash
# Install CmdrData:
pip install cmdrdata-openai

# Result:
openai==1.58.0  # Latest compatible version
cmdrdata-openai==0.1.0  # With tracking
```

#### Scenario 3: Specific OpenAI Version Required
```bash
# Install specific versions:
pip install openai==1.35.0 cmdrdata-openai

# Result:
openai==1.35.0  # Your specified version
cmdrdata-openai==0.1.0  # Works with it!
```

## Compatibility

### Supported OpenAI Versions
- **Minimum**: 1.0.0 (required for base features)
- **Recommended**: 1.35.0+ (latest stable features)
- **Tested**: 1.0.0 - 1.58.0

### Version Checking
CmdrData-OpenAI checks compatibility at import:

```python
from cmdrdata_openai import TrackedOpenAI
# Automatically validates OpenAI version
# Warns if potential incompatibility detected
```

## Common Questions

### Q: Will CmdrData-OpenAI conflict with my OpenAI version?
**A: No!** CmdrData-OpenAI uses the OpenAI SDK you have installed. It doesn't replace or modify it.

### Q: Can I upgrade OpenAI independently?
**A: Yes!** You can upgrade OpenAI anytime:
```bash
pip install --upgrade openai
# CmdrData-OpenAI continues working
```

### Q: What if I need a specific OpenAI version for another project?
**A: Use virtual environments:**
```bash
# Project A (newer OpenAI):
python -m venv projectA
source projectA/bin/activate
pip install openai==1.58.0 cmdrdata-openai

# Project B (older OpenAI):
python -m venv projectB
source projectB/bin/activate
pip install openai==1.10.0 cmdrdata-openai
```

### Q: How do I check what versions I have?
```bash
pip list | grep -E "openai|cmdrdata"
# Shows both packages and versions
```

## Troubleshooting

### Import Error: OpenAI not found
```python
ImportError: OpenAI SDK not found
```
**Solution**: Install OpenAI first:
```bash
pip install openai>=1.0.0
```

### Version Warning
```python
UserWarning: OpenAI SDK version X.X.X may not be fully compatible
```
**Solution**: Update to recommended version:
```bash
pip install --upgrade openai>=1.35.0
```

### Conflicting Dependencies
If you see dependency conflicts:
```bash
# Clean reinstall:
pip uninstall openai cmdrdata-openai
pip install cmdrdata-openai
```

## Best Practices

### 1. Use Virtual Environments
```bash
python -m venv myproject
source myproject/bin/activate
pip install cmdrdata-openai
```

### 2. Pin Versions in Production
```txt
# requirements.txt
openai==1.58.0
cmdrdata-openai==0.1.0
```

### 3. Test After Upgrades
```python
# Quick test after upgrading:
from cmdrdata_openai import TrackedOpenAI

client = TrackedOpenAI(
    api_key="sk-...",
    tracker_key="tk-..."
)

# Test a simple call:
response = client.chat.completions.create(
    model="gpt-3.5-turbo",
    messages=[{"role": "user", "content": "test"}],
    customer_id="test-customer"
)
print("Integration working!")
```

## Technical Details

### Why OpenAI is a Dependency
1. **Simplicity**: One command installs everything
2. **Compatibility**: pip resolves versions automatically
3. **Maintenance**: We test against specific versions
4. **User Experience**: No manual dependency management

### How the Proxy Pattern Works
```python
# Simplified internal structure:
class TrackedOpenAI:
    def __init__(self, **kwargs):
        # Create real OpenAI client
        self._client = OpenAI(**kwargs)

    def __getattr__(self, name):
        # Forward all calls to real client
        return getattr(self._client, name)
```

### Zero Overhead Design
- Tracking happens asynchronously
- Failures don't affect OpenAI calls
- No performance impact on API calls
- Thread-safe and production-ready

## Support

### Getting Help
- **GitHub Issues**: [Report problems](https://github.com/cmdrdata-ai/cmdrdata-openai/issues)
- **Documentation**: [Full docs](https://github.com/cmdrdata-ai/cmdrdata-openai#readme)
- **Email Support**: hello@cmdrdata.ai

### Version Compatibility Matrix
| CmdrData Version | OpenAI Min | OpenAI Max | Python | Status |
|-----------------|------------|------------|---------|---------|
| 0.1.0 | 1.0.0 | 1.58.0+ | 3.8-3.12 | ✅ Stable |
| 0.2.0 (planned) | 1.35.0 | 2.0.0 | 3.8-3.13 | 🚧 Development |
