# cmdrdata-openai

[![CI](https://github.com/cmdrdata-ai/cmdrdata-openai/workflows/CI/badge.svg)](https://github.com/cmdrdata-ai/cmdrdata-openai/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/cmdrdata-ai/cmdrdata-openai/branch/main/graph/badge.svg)](https://codecov.io/gh/cmdrdata-ai/cmdrdata-openai)
[![PyPI version](https://badge.fury.io/py/cmdrdata-openai.svg)](https://badge.fury.io/py/cmdrdata-openai)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python Versions](https://img.shields.io/pypi/pyversions/cmdrdata-openai)](https://pypi.org/project/cmdrdata-openai/)
[![Downloads](https://pepy.tech/badge/cmdrdata-openai)](https://pepy.tech/project/cmdrdata-openai)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)

Drop-in replacement for the OpenAI Python SDK with automatic usage tracking for billing and analytics.

## 🛡️ Production Ready

**Extremely robust and reliable** - Built for production environments with:

- **100% Test Coverage** - 293 comprehensive tests ensuring reliability
- **Non-blocking I/O** - Fire-and-forget tracking never slows your app  
- **Zero Dependencies on Tracking** - OpenAI calls succeed even if tracking fails
- **Enterprise Security** - API key sanitization and input validation
- **Thread-safe** - Safe for multi-threaded and async applications
- **Comprehensive Error Handling** - Circuit breakers, retries, graceful degradation

## 🎯 What it does

`cmdrdata-openai` automatically tracks every OpenAI API call and sends usage data to your cmdrdata backend, enabling:

- **Per-customer usage tracking** - Track exactly how much each of your customers uses AI
- **Accurate billing** - Bill customers based on actual AI usage  
- **Usage analytics** - Understand AI usage patterns across your application
- **Cost management** - Monitor and control AI costs

## 🚀 Quick Start

### 1. Install

```bash
pip install cmdrdata-openai
```

### 2. Replace Your OpenAI Import

**Before:**
```python
from openai import OpenAI
client = OpenAI(api_key="your-openai-key")
```

**After:**
```python
from cmdrdata_openai import TrackedOpenAI
client = TrackedOpenAI(
    api_key="your-openai-key",
    tracker_key="your-cmdrdata-api-key"  # Get this at cmdrdata.ai
)
```

Package Installation

pip install cmdrdata-openai

API Keys Required

1. OpenAI API Key: export OPENAI_API_KEY="sk-your-key"
2. CmdrData API Key: export CMDRDATA_API_KEY="cmd-live-v1-your-key"

Basic Usage

```python
from cmdrdata_openai import TrackedOpenAI

client = TrackedOpenAI(
	api_key="sk-your-openai-key",  # or uses env var
	tracker_key="tk-your-tracker-key"  # required
)

response = client.chat.completions.create(
	model="gpt-4",
	messages=[{"role": "user", "content": "Hello!"}],
	customer_id="customer-123"  # enables tracking
)
```

### 3. Add Customer Tracking

```python
# Method 1: Explicit customer_id
response = client.chat.completions.create(
    model="gpt-4",
    messages=[{"role": "user", "content": "Hello!"}],
    customer_id="customer-123"  # Track usage for this customer
)

# Method 2: Context-based (recommended for web apps)
from cmdrdata_openai import set_customer_context

set_customer_context("customer-123")
response = client.chat.completions.create(
    model="gpt-4",
    messages=[{"role": "user", "content": "Hello!"}]
    # Automatically tracked for customer-123
)
```

That's it! **Every API call now automatically tracks token usage for billing and analytics.**

## 📖 Usage Patterns

### Flask/FastAPI Integration

```python
from flask import Flask, request, jsonify
from cmdrdata_openai import TrackedOpenAI, set_customer_context, clear_customer_context

app = Flask(__name__)
client = TrackedOpenAI(
    api_key="your-openai-key",
    tracker_key="your-cmdrdata-key"
)

@app.route('/chat', methods=['POST'])
def chat():
    data = request.json
    customer_id = data['customer_id']
    
    # Set context for this request
    set_customer_context(customer_id)
    
    try:
        response = client.chat.completions.create(
            model="gpt-4",
            messages=[{"role": "user", "content": data['message']}]
        )
        return jsonify({"response": response.choices[0].message.content})
    finally:
        clear_customer_context()
```

### Context Manager (Automatic Cleanup)

```python
from cmdrdata_openai import customer_context

with customer_context("customer-456"):
    response1 = client.chat.completions.create(...)
    response2 = client.chat.completions.create(...)
    # Both calls tracked for customer-456
# Context automatically cleared
```

### Async Support

```python
from cmdrdata_openai import AsyncTrackedOpenAI

client = AsyncTrackedOpenAI(
    api_key="your-openai-key",
    tracker_key="your-cmdrdata-key"
)

response = await client.chat.completions.create(
    model="gpt-4",
    messages=[{"role": "user", "content": "Hello!"}],
    customer_id="customer-789"
)
```

## 🔧 Configuration

### Basic Configuration

```python
client = TrackedOpenAI(
    api_key="your-openai-key",           # OpenAI API key
    tracker_key="your-cmdrdata-key",     # cmdrdata API key
    tracker_endpoint="https://cmdrdata.ai/api/events",  # cmdrdata endpoint
    tracker_timeout=5.0                   # Timeout for tracking requests
)
```

### Environment Variables

```bash
export OPENAI_API_KEY="your-openai-key"
export CMDRDATA_API_KEY="your-cmdrdata-key"
```

```python
import os
client = TrackedOpenAI(
    api_key=os.getenv("OPENAI_API_KEY"),
    tracker_key=os.getenv("CMDRDATA_API_KEY")
)
```

## 🎛️ Advanced Features

### Disable Tracking for Specific Calls

```python
response = client.chat.completions.create(
    model="gpt-4",
    messages=[{"role": "user", "content": "Internal query"}],
    track_usage=False  # This call won't be tracked
)
```

### Priority System

Customer ID resolution follows this priority:

1. **Explicit `customer_id` parameter** (highest priority)
2. **Customer ID from context**
3. **No tracking** (warning logged)

```python
set_customer_context("context-customer")

# This will be tracked for "explicit-customer"
response = client.chat.completions.create(
    model="gpt-4",
    messages=[{"role": "user", "content": "Hello"}],
    customer_id="explicit-customer"  # Overrides context
)
```

### Error Handling

cmdrdata-openai is designed to never break your OpenAI calls:

- **Tracking failures are logged but don't raise exceptions**
- **OpenAI calls proceed normally even if tracking fails**
- **Background tracking doesn't block your application**

```python
# Even if cmdrdata is down, this still works
response = client.chat.completions.create(
    model="gpt-4",
    messages=[{"role": "user", "content": "Hello"}],
    customer_id="customer-123"
)
# OpenAI call succeeds, tracking failure is logged
```

## 📊 What Gets Tracked

For each OpenAI API call, cmdrdata-openai automatically tracks:

- **Customer ID** (from parameter or context)
- **Model used** (e.g., gpt-4, gpt-3.5-turbo)
- **Token usage** (input tokens, output tokens, total tokens)
- **Provider** (openai)
- **Timestamp** (when the call was made)
- **Metadata** (response ID, finish reason, etc.)

Example tracked event:
```json
{
  "customer_id": "customer-123",
  "model": "gpt-4",
  "input_tokens": 15,
  "output_tokens": 25,
  "total_tokens": 40,
  "provider": "openai",
  "timestamp": "2025-07-04T10:30:00Z",
  "metadata": {
    "response_id": "chatcmpl-abc123",
    "finish_reason": "stop"
  }
}
```

## 🔌 Compatibility

- **OpenAI SDK**: Compatible with OpenAI SDK v1.0.0+
- **Python**: Requires Python 3.8+
- **Async**: Full support for both sync and async usage
- **Frameworks**: Works with Flask, FastAPI, Django, etc.

## 📦 Installation

```bash
# Basic installation
pip install cmdrdata-openai

# With development dependencies
pip install cmdrdata-openai[dev]

# With test dependencies
pip install cmdrdata-openai[test]
```

## 🛠️ Development

### Setup

```bash
# Install uv (if not already installed)
curl -LsSf https://astral.sh/uv/install.sh | sh

# Install with dev dependencies
uv pip install -e .[dev]
```

### Running Tests

```bash
# Run all tests (100% pass rate!)
uv run pytest

# Run with coverage reporting
uv run pytest --cov=cmdrdata_openai --cov-report=term-missing

# Run specific test file
uv run pytest tests/test_client.py -v
```

### Code Quality

```bash
# Format code
uv run black cmdrdata_openai/

# Sort imports
uv run isort cmdrdata_openai/

# Type checking
uv run mypy cmdrdata_openai/ --ignore-missing-imports

# Security check
uv run safety check
```

### CI/CD

The project uses GitHub Actions for:

- **Continuous Integration** - Tests across Python 3.8-3.12
- **Code Quality** - Black, isort, mypy, safety checks  
- **Coverage Reporting** - Automatic coverage tracking with Codecov
- **Automated Publishing** - PyPI releases on GitHub releases

## 🆘 Troubleshooting

### Common Issues

**"tracker_key is required" error:**
```python
# Make sure you provide the tracker_key
client = TrackedOpenAI(
    api_key="your-openai-key",
    tracker_key="your-cmdrdata-key"  # Don't forget this!
)
```

**No usage tracking:**
```python
# Make sure you provide customer_id or set context
set_customer_context("customer-123")
# OR
response = client.chat.completions.create(..., customer_id="customer-123")
```

**Tracking timeouts:**
```python
# Increase timeout for slow networks
client = TrackedOpenAI(
    api_key="your-openai-key",
    tracker_key="your-cmdrdata-key",
    tracker_timeout=10.0  # Increase from default 5.0
)
```

### Get Help

- 📧 **Email**: hello@cmdrdata.ai
- 🐛 **Issues**: [GitHub Issues](https://github.com/cmdrdata-ai/cmdrdata-openai/issues)
- 📖 **Docs**: [Documentation](https://github.com/cmdrdata-ai/cmdrdata-openai#readme)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🚨 Important Notes

- **Never commit API keys** to version control
- **Always clean up context** in web applications
- **Test with small limits** before production deployment
- **Monitor tracking errors** in your logs

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Run the test suite
5. Submit a pull request

For more details, see [CONTRIBUTING.md](CONTRIBUTING.md).
