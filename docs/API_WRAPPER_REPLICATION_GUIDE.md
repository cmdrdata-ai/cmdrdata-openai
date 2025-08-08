# API Wrapper Replication Guide

This guide provides a comprehensive framework for replicating the cmdrdata-openai pattern to create usage tracking wrappers for other AI APIs (like Anthropic Claude, Google Gemini, etc.).

## Overview

The cmdrdata SDK pattern provides transparent usage tracking for AI APIs without requiring changes to existing application code. The wrapper intercepts API calls, tracks usage data, and forwards calls to the original client.

## Core Architecture

### 1. Package Structure

```
cmdrdata-{provider}/
├── cmdrdata_{provider}/
│   ├── __init__.py              # Main exports
│   ├── client.py                # Tracked{Provider} main client
│   ├── async_client.py          # Async{Provider} async client
│   ├── proxy.py                 # TrackedProxy for method interception
│   ├── tracker.py               # UsageTracker (reusable)
│   ├── context.py               # Customer context management (reusable)
│   ├── security.py              # Input validation and sanitization (reusable)
│   ├── exceptions.py            # Custom exceptions (reusable)
│   ├── retry.py                 # Retry logic with circuit breakers (reusable)
│   ├── performance.py           # Performance monitoring (reusable)
│   ├── logging_config.py        # Structured logging (reusable)
│   ├── validation.py            # Input validation (reusable)
│   └── version_compat.py        # Provider SDK version checking
├── tests/                       # Comprehensive test suite
├── .github/workflows/           # CI/CD pipeline
├── pyproject.toml              # Python packaging
└── README.md                   # Documentation with badges
```

### 2. Key Components

#### A. Main Client Classes
- **Tracked{Provider}**: Drop-in replacement for the original client
- **Async{Provider}**: Async version of the tracked client
- **TrackedProxy**: Dynamic proxy for transparent method interception

#### B. Reusable Components (copy from cmdrdata-openai)
- **UsageTracker**: HTTP client for sending events to cmdrdata backend
- **Customer Context**: Thread-safe context management
- **Security**: Input validation, sanitization, API key management
- **Performance**: Monitoring, caching, timing decorators
- **Retry Logic**: Exponential backoff, circuit breakers
- **Logging**: Structured logging with security sanitization

## Implementation Steps

### Step 1: Research Target API

Analyze the target API's Python SDK:

```python
# Key research areas:
1. Client class names and structure
2. Authentication methods
3. API methods that consume tokens/credits
4. Response object structure
5. Usage/billing information in responses
6. Async support patterns
7. Exception hierarchy
```

**For Anthropic Claude:**
- Client: `Anthropic` / `AsyncAnthropic`
- Key method: `client.messages.create()`
- Usage info: `response.usage.input_tokens`, `response.usage.output_tokens`
- Model field: `response.model`

### Step 2: Copy Reusable Components

Copy these modules directly from cmdrdata-openai (they're provider-agnostic):

```bash
# Copy these files as-is:
cp cmdrdata_openai/tracker.py cmdrdata_{provider}/
cp cmdrdata_openai/context.py cmdrdata_{provider}/
cp cmdrdata_openai/security.py cmdrdata_{provider}/
cp cmdrdata_openai/exceptions.py cmdrdata_{provider}/
cp cmdrdata_openai/retry.py cmdrdata_{provider}/
cp cmdrdata_openai/performance.py cmdrdata_{provider}/
cp cmdrdata_openai/logging_config.py cmdrdata_{provider}/
cp cmdrdata_openai/validation.py cmdrdata_{provider}/
```

### Step 3: Create Provider-Specific Components

#### A. Version Compatibility Module

```python
# cmdrdata_{provider}/version_compat.py
import warnings
from typing import Dict, Any

class VersionCompatibility:
    SUPPORTED_{PROVIDER}_VERSIONS = {
        "min": "1.0.0",
        "max": "2.0.0",
        "tested": ["1.0.0", "1.1.0", ...]
    }

    def _check_{provider}_version(self):
        try:
            import {provider_package}
            self.{provider}_version = {provider_package}.__version__
            self._validate_{provider}_version()
        except ImportError:
            warnings.warn(f"{provider} SDK not found. Please install: pip install {provider_package}")
```

#### B. Tracking Functions

```python
# cmdrdata_{provider}/proxy.py
def track_{api_method}(result, customer_id, tracker, method_name, args, kwargs):
    """Track {provider} {api_method} usage"""
    effective_customer_id = get_effective_customer_id(customer_id)

    if not effective_customer_id:
        logger.warning("No customer_id provided for tracking")
        return

    if hasattr(result, 'usage') and result.usage:
        tracker.track_usage_background(
            customer_id=effective_customer_id,
            model=getattr(result, 'model', kwargs.get('model', 'unknown')),
            input_tokens=result.usage.input_tokens,
            output_tokens=result.usage.output_tokens,
            provider="{provider}",
            metadata={
                "response_id": getattr(result, 'id', None),
                # Add provider-specific metadata
            }
        )

# Provider tracking configuration
{PROVIDER}_TRACK_METHODS = {
    "{api.method.path}": track_{api_method},
    # Map all token-consuming methods
}
```

#### C. Main Client Classes

```python
# cmdrdata_{provider}/client.py
import {provider_package}
from .proxy import TrackedProxy, {PROVIDER}_TRACK_METHODS

class Tracked{Provider}({provider_package}.{Provider}):
    def __init__(self, api_key: str = None, cmdrdata_api_key: str = None, **kwargs):
        # Initialize original client
        super().__init__(api_key=api_key, **kwargs)

        # Setup usage tracking
        if cmdrdata_api_key:
            from .tracker import UsageTracker
            self._tracker = UsageTracker(cmdrdata_api_key)

            # Wrap the client with proxy
            self._original_client = super()
            for attr_name, attr_value in vars(self._original_client).items():
                if not attr_name.startswith('_'):
                    wrapped_attr = TrackedProxy(attr_value, self._tracker, {PROVIDER}_TRACK_METHODS)
                    setattr(self, attr_name, wrapped_attr)
```

### Step 4: Testing Strategy

#### A. Copy Test Infrastructure
```bash
# Copy test utilities and base classes
cp tests/conftest.py tests_{provider}/
cp tests/test_exceptions.py tests_{provider}/
cp tests/test_security.py tests_{provider}/
# ... copy all reusable component tests
```

#### B. Create Provider-Specific Tests
```python
# tests_{provider}/test_{provider}_client.py
def test_tracked_{api_method}_success(mock_{provider}_response):
    """Test successful API call with tracking"""
    client = Tracked{Provider}(
        api_key="test-key",
        cmdrdata_api_key="test-cmdrdata-key"
    )

    with patch.object(client._tracker, 'track_usage_background') as mock_track:
        # Mock the original API call
        with patch.object(client._original_client.{api_path}, '{method}') as mock_call:
            mock_call.return_value = mock_{provider}_response

            result = client.{api_path}.{method}(
                model="test-model",
                # provider-specific parameters
            )

            # Verify original API was called
            mock_call.assert_called_once()

            # Verify tracking was called
            mock_track.assert_called_once_with(
                customer_id=None,  # No context set
                model="test-model",
                input_tokens=10,
                output_tokens=20,
                provider="{provider}"
            )
```

### Step 5: Configuration Files

#### A. pyproject.toml
```toml
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "cmdrdata-{provider}"
dynamic = ["version"]
description = "Usage tracking wrapper for {Provider} API"
dependencies = [
    "{provider_package}>=1.0.0,<2.0.0",
    "httpx>=0.24.0",
    "pydantic>=2.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "pytest-cov>=4.0.0",
    "pytest-asyncio>=0.21.0",
    "black>=23.0.0",
    "isort>=5.12.0",
]
```

#### B. GitHub Actions CI/CD
```yaml
# .github/workflows/ci.yml - Copy from cmdrdata-openai and update:
# 1. Package name references
# 2. Provider-specific test commands
# 3. Coverage paths
```

### Step 6: Documentation

#### A. README.md Template
```markdown
# cmdrdata-{provider}

[![CI](https://github.com/cmdrdata-ai/cmdrdata-{provider}/workflows/CI/badge.svg)](...)
[![codecov](https://codecov.io/gh/cmdrdata-ai/cmdrdata-{provider}/branch/main/graph/badge.svg)](...)

**Transparent usage tracking for {Provider} API calls**

## 🛡️ Production Ready
- **100% Test Coverage** - Comprehensive tests ensuring reliability
- **Non-blocking I/O** - Fire-and-forget tracking never slows your app
- **Zero Code Changes** - Drop-in replacement for existing {Provider} clients

## Quick Start

```python
# Before
import {provider_package}
client = {provider_package}.{Provider}()

# After
import cmdrdata_{provider}
client = cmdrdata_{provider}.Tracked{Provider}(cmdrdata_api_key="your-key")

# Same API, automatic usage tracking!
response = client.{api_path}.{method}(...)
```
```

## Provider-Specific Adaptations

### Anthropic Claude
```python
# Key differences:
- Client: anthropic.Anthropic -> TrackedAnthropic
- Method: client.messages.create()
- Usage: response.usage.input_tokens, response.usage.output_tokens
- Provider: "anthropic"
- Package: "anthropic"
```

### Google Gemini
```python
# Key differences:
- Client: google.generativeai -> TrackedGemini
- Method: model.generate_content()
- Usage: response.usage_metadata.prompt_token_count, response.usage_metadata.candidates_token_count
- Provider: "google"
- Package: "google-generativeai"
```

### Azure OpenAI
```python
# Key differences:
- Client: openai.AzureOpenAI -> TrackedAzureOpenAI
- Method: client.chat.completions.create()
- Usage: Same as OpenAI (response.usage.prompt_tokens, response.usage.completion_tokens)
- Provider: "azure_openai"
- Package: "openai"
```

## Advanced Features

### 1. Customer Context Management
```python
# Thread-safe customer context (works across all providers)
from cmdrdata_{provider}.context import customer_context

with customer_context("customer-123"):
    response = client.{api_method}(...)  # Automatically tracked for customer-123
```

### 2. Performance Monitoring
```python
# Built-in performance tracking
from cmdrdata_{provider}.performance import PerformanceMonitor

monitor = PerformanceMonitor()
with monitor.time_operation("api_call"):
    response = client.{api_method}(...)

print(monitor.get_stats("api_call"))  # Response times, counts, etc.
```

### 3. Security & Validation
```python
# Automatic input sanitization and API key validation
# Sensitive data automatically redacted from logs
# Input validation prevents injection attacks
```

## Testing Requirements

### Minimum Test Coverage
- **Unit tests**: 100% coverage for tracking logic
- **Integration tests**: End-to-end API call tracking
- **Error handling**: Network failures, invalid responses
- **Security tests**: Input validation, sanitization
- **Performance tests**: Non-blocking behavior verification
- **Async tests**: Concurrent tracking operations

### Key Test Scenarios
```python
def test_api_call_tracking():
    """Verify API calls are tracked correctly"""

def test_no_customer_context():
    """Verify graceful handling when no customer ID provided"""

def test_tracking_failure_resilience():
    """Verify app continues when tracking fails"""

def test_non_blocking_behavior():
    """Verify tracking never blocks the main thread"""

def test_context_isolation():
    """Verify customer contexts don't leak between threads"""
```

## Deployment Checklist

### Pre-Release
- [ ] All tests passing (100% success rate)
- [ ] Code formatted with black
- [ ] Imports sorted with isort
- [ ] Security scan passed
- [ ] Coverage >= 90%
- [ ] Documentation complete
- [ ] Version compatibility tested

### Release Process
- [ ] Tag version in git
- [ ] GitHub Actions builds and tests
- [ ] PyPI package published automatically
- [ ] Documentation deployed
- [ ] Release notes created

### Post-Release
- [ ] Integration testing with real API
- [ ] Performance benchmarking
- [ ] Customer feedback collection
- [ ] Monitor error rates

## Maintenance

### Regular Updates
1. **Provider SDK compatibility**: Test new versions as they're released
2. **Security patches**: Apply security updates promptly
3. **Performance optimization**: Monitor and improve tracking performance
4. **Documentation**: Keep examples and API docs current

### Monitoring
- Track wrapper adoption rates
- Monitor API call success rates
- Watch for performance regressions
- Collect customer feedback

This guide provides a complete framework for replicating the cmdrdata pattern across any AI API provider while maintaining consistency, reliability, and ease of use.
