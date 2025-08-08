# Enterprise-Grade API Wrapper Development Guide

## Overview

This guide provides a comprehensive blueprint for creating production-ready API wrappers that developers can trust for business-critical applications. It's based on the patterns and practices implemented in the cmdrdata-openai wrapper and can be adapted for any API (Anthropic, Gemini, etc.).

## Table of Contents

1. [Core Architecture](#core-architecture)
2. [Essential Components](#essential-components)
3. [Implementation Steps](#implementation-steps)
4. [Security Considerations](#security-considerations)
5. [Performance Optimizations](#performance-optimizations)
6. [Testing Strategy](#testing-strategy)
7. [Monitoring & Observability](#monitoring--observability)
8. [API-Specific Adaptations](#api-specific-adaptations)
9. [Production Deployment](#production-deployment)
10. [Maintenance & Updates](#maintenance--updates)

## Core Architecture

### 1. Layered Architecture Pattern

```
┌─────────────────────────────────────────┐
│            Public API Layer             │  ← Clean, consistent interface
├─────────────────────────────────────────┤
│        Validation & Security Layer      │  ← Input validation, sanitization
├─────────────────────────────────────────┤
│       Tracking & Monitoring Layer       │  ← Usage tracking, metrics
├─────────────────────────────────────────┤
│    Resilience Layer (Retry/Circuit)     │  ← Error handling, retries
├─────────────────────────────────────────┤
│         Performance Layer               │  ← Caching, connection pooling
├─────────────────────────────────────────┤
│        Native API Client Layer          │  ← Original SDK integration
└─────────────────────────────────────────┘
```

### 2. Key Design Principles

- **Transparency**: Drop-in replacement with identical interface
- **Fail-Safe**: Never break original functionality
- **Observable**: Rich logging and monitoring
- **Secure**: Input validation and sanitization
- **Resilient**: Robust error handling and retries
- **Performant**: Optimized for production workloads

## Essential Components

### 1. Exception Hierarchy

Create a comprehensive exception hierarchy:

```python
# exceptions.py
class BaseWrapperError(Exception):
    """Base exception for all wrapper errors"""
    def __init__(self, message: str, error_code: str = None, details: dict = None):
        super().__init__(message)
        self.error_code = error_code
        self.details = details or {}

class ConfigurationError(BaseWrapperError): pass
class AuthenticationError(BaseWrapperError): pass
class ValidationError(BaseWrapperError): pass
class RateLimitError(BaseWrapperError): pass
class NetworkError(BaseWrapperError): pass
class RetryExhaustedError(BaseWrapperError): pass
class SecurityError(BaseWrapperError): pass
```

### 2. Retry & Circuit Breaker System

Implement robust retry mechanisms:

```python
# retry.py
class RetryConfig:
    def __init__(self, max_attempts=3, backoff_policy='exponential'):
        self.max_attempts = max_attempts
        self.backoff_policy = backoff_policy
        # ... implementation

class CircuitBreaker:
    def __init__(self, failure_threshold=5, recovery_timeout=60):
        self.failure_threshold = failure_threshold
        self.recovery_timeout = recovery_timeout
        # ... implementation
```

### 3. Input Validation & Security

Create comprehensive input validation:

```python
# validation.py
class InputValidator:
    @staticmethod
    def validate_api_key(key: str, provider: str) -> bool:
        patterns = {
            'openai': r'^sk-[a-zA-Z0-9]{48}$',
            'anthropic': r'^sk-ant-[a-zA-Z0-9-]+$',
            'gemini': r'^[a-zA-Z0-9_-]{32,}$'
        }
        # ... implementation

    @staticmethod
    def sanitize_input(data: Any) -> Any:
        # Remove suspicious patterns, validate formats
        pass
```

### 4. Structured Logging

Implement structured, secure logging:

```python
# logging_config.py
class StructuredFormatter(logging.Formatter):
    def format(self, record):
        return json.dumps({
            'timestamp': datetime.utcnow().isoformat(),
            'level': record.levelname,
            'message': record.getMessage(),
            'context': getattr(record, 'context', {}),
            # ... additional fields
        })

class SecurityFormatter(logging.Formatter):
    def format(self, record):
        # Sanitize sensitive data before logging
        pass
```

### 5. Performance Optimizations

Add caching and connection pooling:

```python
# performance.py
class LRUCache:
    def __init__(self, max_size=1000, ttl=300):
        # ... implementation

class ConnectionPool:
    def __init__(self, max_connections=10):
        # ... implementation

class RateLimiter:
    def __init__(self, rate=100, burst=200):
        # ... implementation
```

## Implementation Steps

### Step 1: Project Setup

1. **Initialize project structure**:
```
your_api_wrapper/
├── your_api_wrapper/
│   ├── __init__.py
│   ├── client.py              # Main client class
│   ├── async_client.py        # Async client class
│   ├── exceptions.py          # Custom exceptions
│   ├── validation.py          # Input validation
│   ├── retry.py              # Retry logic
│   ├── logging_config.py     # Logging setup
│   ├── performance.py        # Performance optimizations
│   ├── security.py           # Security utilities
│   ├── context.py            # Context management
│   ├── tracker.py            # Usage tracking
│   └── version_compat.py     # Version compatibility
├── tests/
│   ├── unit/
│   ├── integration/
│   └── performance/
├── docs/
├── pyproject.toml
└── README.md
```

2. **Set up dependencies**:
```toml
# pyproject.toml
[project]
dependencies = [
    "httpx>=0.24.0",
    "pydantic>=2.0.0",
    "typing-extensions>=4.0.0",
    "original-sdk>=1.0.0",  # Replace with actual SDK
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "pytest-asyncio>=0.21.0",
    "pytest-mock>=3.10.0",
    "pytest-cov>=4.0.0",
    "black>=23.0.0",
    "isort>=5.12.0",
    "mypy>=1.0.0",
    "pre-commit>=3.0.0",
]
```

### Step 2: Core Client Implementation

1. **Create the main client class**:
```python
# client.py
from typing import Optional, Any, Dict
from .exceptions import ConfigurationError, ValidationError
from .validation import InputValidator
from .tracker import UsageTracker
from .logging_config import get_logger
from .performance import timed, cached

logger = get_logger(__name__)

class TrackedAPIClient:
    def __init__(
        self,
        api_key: Optional[str] = None,
        tracker_key: Optional[str] = None,
        endpoint: str = "https://api.example.com",
        timeout: float = 30.0,
        **kwargs
    ):
        # Validate inputs
        if not api_key:
            raise ConfigurationError("API key is required")

        InputValidator.validate_api_key(api_key, 'your_provider')

        # Initialize original client
        self._original_client = OriginalAPIClient(api_key=api_key, **kwargs)

        # Initialize tracker
        self._tracker = UsageTracker(tracker_key, endpoint) if tracker_key else None

        # Initialize performance components
        self._setup_performance()

        logger.info("TrackedAPIClient initialized successfully")

    def _setup_performance(self):
        # Configure caching, connection pooling, etc.
        pass

    def __getattr__(self, name: str) -> Any:
        # Delegate to original client while adding tracking
        return getattr(self._original_client, name)
```

2. **Implement method interception**:
```python
class TrackedProxy:
    def __init__(self, client, tracker, track_methods):
        self._client = client
        self._tracker = tracker
        self._track_methods = track_methods

    def __getattr__(self, name: str) -> Any:
        attr = getattr(self._client, name)

        if callable(attr) and name in self._track_methods:
            return self._wrap_method(attr, name)

        return attr

    def _wrap_method(self, method, method_name):
        def wrapped(*args, **kwargs):
            # Extract tracking parameters
            customer_id = kwargs.pop('customer_id', None)
            track_usage = kwargs.pop('track_usage', True)

            # Call original method
            result = method(*args, **kwargs)

            # Track usage
            if track_usage and self._tracker:
                self._track_usage(result, customer_id, method_name)

            return result

        return wrapped
```

### Step 3: Async Implementation

```python
# async_client.py
import asyncio
from typing import Optional, Any

class AsyncTrackedAPIClient:
    def __init__(self, api_key: str, tracker_key: Optional[str] = None, **kwargs):
        self._original_client = OriginalAsyncAPIClient(api_key=api_key, **kwargs)
        self._tracker = UsageTracker(tracker_key) if tracker_key else None

    async def __aenter__(self):
        if hasattr(self._original_client, '__aenter__'):
            await self._original_client.__aenter__()
        return self

    async def __aexit__(self, exc_type, exc_val, exc_tb):
        if hasattr(self._original_client, '__aexit__'):
            await self._original_client.__aexit__(exc_type, exc_val, exc_tb)
```

### Step 4: Usage Tracking System

```python
# tracker.py
import asyncio
import json
from datetime import datetime
from typing import Dict, Any, Optional

class UsageTracker:
    def __init__(self, api_key: str, endpoint: str, timeout: float = 5.0):
        self.api_key = api_key
        self.endpoint = endpoint
        self.timeout = timeout
        self.client = httpx.AsyncClient(timeout=timeout)

    async def track_usage(
        self,
        customer_id: str,
        model: str,
        input_tokens: int,
        output_tokens: int,
        provider: str,
        metadata: Optional[Dict[str, Any]] = None
    ) -> bool:
        event_data = {
            'customer_id': customer_id,
            'model': model,
            'input_tokens': input_tokens,
            'output_tokens': output_tokens,
            'provider': provider,
            'metadata': metadata or {},
            'timestamp': datetime.utcnow().isoformat()
        }

        try:
            response = await self.client.post(
                self.endpoint,
                json=event_data,
                headers={'Authorization': f'Bearer {self.api_key}'}
            )
            return response.status_code == 200
        except Exception as e:
            logger.error(f"Failed to track usage: {e}")
            return False
```

## Security Considerations

### 1. Input Validation

- **API Key Validation**: Validate format and patterns
- **Parameter Sanitization**: Remove suspicious content
- **Size Limits**: Prevent DoS through large inputs
- **Injection Prevention**: Sanitize all string inputs

### 2. Secrets Management

```python
# security.py
import os
from typing import Optional

class SecretManager:
    @staticmethod
    def get_api_key(provider: str) -> Optional[str]:
        env_var = f"{provider.upper()}_API_KEY"
        return os.getenv(env_var)

    @staticmethod
    def validate_key_format(key: str, provider: str) -> bool:
        # Provider-specific validation
        pass
```

### 3. Rate Limiting

```python
# Implement rate limiting to prevent abuse
class RateLimiter:
    def __init__(self, rate: int, window: int):
        self.rate = rate
        self.window = window
        self.requests = []

    def is_allowed(self) -> bool:
        now = time.time()
        # Clean old requests
        self.requests = [req for req in self.requests if now - req < self.window]

        if len(self.requests) < self.rate:
            self.requests.append(now)
            return True
        return False
```

## Performance Optimizations

### 1. Caching Strategy

```python
# Implement multi-level caching
class CacheManager:
    def __init__(self):
        self.memory_cache = LRUCache(max_size=1000)
        self.redis_cache = RedisCache() if redis_available else None

    def get(self, key: str) -> Any:
        # Try memory cache first
        result = self.memory_cache.get(key)
        if result is not None:
            return result

        # Try Redis cache
        if self.redis_cache:
            result = self.redis_cache.get(key)
            if result is not None:
                self.memory_cache.set(key, result)
                return result

        return None
```

### 2. Connection Pooling

```python
# Optimize HTTP connections
class ConnectionManager:
    def __init__(self, max_connections: int = 100):
        self.session = httpx.AsyncClient(
            limits=httpx.Limits(
                max_connections=max_connections,
                max_keepalive_connections=20
            )
        )
```

### 3. Request Batching

```python
# Batch similar requests when possible
class RequestBatcher:
    def __init__(self, batch_size: int = 10, timeout: float = 0.1):
        self.batch_size = batch_size
        self.timeout = timeout
        self.pending = []

    async def add_request(self, request: Any) -> Any:
        # Add to batch and process when full or timeout
        pass
```

## Testing Strategy

### 1. Test Structure

```
tests/
├── unit/                    # Unit tests
│   ├── test_client.py
│   ├── test_validation.py
│   ├── test_retry.py
│   └── test_performance.py
├── integration/             # Integration tests
│   ├── test_api_integration.py
│   └── test_tracking.py
├── performance/             # Performance tests
│   ├── test_load.py
│   └── test_stress.py
├── security/               # Security tests
│   ├── test_validation.py
│   └── test_injection.py
└── conftest.py             # Test configuration
```

### 2. Test Categories

1. **Unit Tests**: Test individual components
2. **Integration Tests**: Test with real APIs
3. **Performance Tests**: Load and stress testing
4. **Security Tests**: Validation and injection tests
5. **Compatibility Tests**: Test with different SDK versions

### 3. Test Implementation

```python
# tests/unit/test_client.py
import pytest
from unittest.mock import Mock, patch
from your_wrapper import TrackedAPIClient

class TestTrackedAPIClient:
    def test_initialization_success(self):
        client = TrackedAPIClient(api_key="valid-key", tracker_key="tracker-key")
        assert client is not None

    def test_initialization_invalid_key(self):
        with pytest.raises(ValidationError):
            TrackedAPIClient(api_key="invalid-key")

    @patch('your_wrapper.OriginalAPIClient')
    def test_method_delegation(self, mock_original):
        client = TrackedAPIClient(api_key="valid-key")
        client.some_method()
        mock_original.return_value.some_method.assert_called_once()
```

## API-Specific Adaptations

### Anthropic Claude
```python
# anthropic_wrapper/client.py
class TrackedAnthropic:
    def __init__(self, api_key: str, tracker_key: str = None):
        self._client = anthropic.Anthropic(api_key=api_key)
        self._tracker = UsageTracker(tracker_key)

    # Map Anthropic-specific methods
    TRACK_METHODS = {
        'messages.create': track_message_completion,
        'completions.create': track_completion,
    }
```

### Google Gemini
```python
# gemini_wrapper/client.py
class TrackedGemini:
    def __init__(self, api_key: str, tracker_key: str = None):
        import google.generativeai as genai
        genai.configure(api_key=api_key)
        self._client = genai.GenerativeModel('gemini-pro')
        self._tracker = UsageTracker(tracker_key)

    # Map Gemini-specific methods
    TRACK_METHODS = {
        'generate_content': track_content_generation,
        'generate_content_async': track_content_generation_async,
    }
```

### Provider-Specific Considerations

| Provider | Key Considerations | Token Tracking | Rate Limits |
|----------|-------------------|----------------|-------------|
| OpenAI | Standard REST API | `usage.prompt_tokens` | 3500 RPM |
| Anthropic | Messages API | `usage.input_tokens` | 2000 RPM |
| Gemini | Different auth flow | Custom parsing | 1000 RPM |

## Monitoring & Observability

### 1. Metrics Collection

```python
# monitoring.py
from prometheus_client import Counter, Histogram, Gauge

# Define metrics
REQUEST_COUNT = Counter('api_requests_total', 'Total requests', ['method', 'status'])
REQUEST_DURATION = Histogram('api_request_duration_seconds', 'Request duration')
ACTIVE_CONNECTIONS = Gauge('api_active_connections', 'Active connections')

def track_request(method: str, status: str, duration: float):
    REQUEST_COUNT.labels(method=method, status=status).inc()
    REQUEST_DURATION.observe(duration)
```

### 2. Health Checks

```python
# health.py
class HealthChecker:
    def __init__(self, client):
        self.client = client

    async def check_health(self) -> Dict[str, Any]:
        return {
            'status': 'healthy',
            'timestamp': datetime.utcnow().isoformat(),
            'checks': {
                'api_connectivity': await self._check_api(),
                'tracker_connectivity': await self._check_tracker(),
                'cache_status': self._check_cache(),
            }
        }
```

### 3. Alerting

```python
# alerts.py
class AlertManager:
    def __init__(self, webhook_url: str):
        self.webhook_url = webhook_url

    async def send_alert(self, severity: str, message: str, context: Dict[str, Any]):
        payload = {
            'severity': severity,
            'message': message,
            'context': context,
            'timestamp': datetime.utcnow().isoformat()
        }
        # Send to monitoring system
```

## Production Deployment

### 1. Environment Configuration

```python
# config.py
import os
from pydantic import BaseSettings

class Settings(BaseSettings):
    api_key: str
    tracker_key: str
    log_level: str = "INFO"
    cache_size: int = 1000
    max_connections: int = 100
    timeout: float = 30.0

    class Config:
        env_file = ".env"
        case_sensitive = False

settings = Settings()
```

### 2. Docker Configuration

```dockerfile
# Dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["python", "-m", "your_wrapper.server"]
```

### 3. Kubernetes Deployment

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-wrapper
spec:
  replicas: 3
  selector:
    matchLabels:
      app: api-wrapper
  template:
    metadata:
      labels:
        app: api-wrapper
    spec:
      containers:
      - name: api-wrapper
        image: your-wrapper:latest
        env:
        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: api-secrets
              key: api_key
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

## Maintenance & Updates

### 1. Version Management

```python
# version_compat.py
class VersionManager:
    SUPPORTED_VERSIONS = {
        'min': '1.0.0',
        'max': '2.0.0',
        'tested': ['1.0.0', '1.1.0', '1.2.0']
    }

    def check_compatibility(self, version: str) -> bool:
        # Check if version is supported
        pass

    def get_migration_guide(self, from_version: str, to_version: str) -> str:
        # Return migration instructions
        pass
```

### 2. Automated Testing

```yaml
# .github/workflows/test.yml
name: Test Suite
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.8, 3.9, 3.10, 3.11]

    steps:
    - uses: actions/checkout@v3
    - name: Set up Python ${{ matrix.python-version }}
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}

    - name: Install dependencies
      run: |
        pip install -e .[dev]

    - name: Run tests
      run: |
        pytest tests/ --cov=your_wrapper --cov-report=xml

    - name: Upload coverage
      uses: codecov/codecov-action@v3
```

### 3. Release Process

```python
# release.py
class ReleaseManager:
    def __init__(self, github_token: str):
        self.github = Github(github_token)

    def create_release(self, version: str, changelog: str):
        # Create GitHub release
        # Update package version
        # Deploy to PyPI
        pass
```

## Best Practices Summary

1. **Always maintain backward compatibility**
2. **Never break the original API interface**
3. **Implement comprehensive error handling**
4. **Use structured logging with proper sanitization**
5. **Add extensive input validation**
6. **Implement proper retry mechanisms**
7. **Cache appropriately but safely**
8. **Monitor everything**
9. **Test thoroughly across all scenarios**
10. **Document extensively**

## Common Pitfalls to Avoid

1. **Blocking the main thread** - Always use async for I/O operations
2. **Exposing secrets in logs** - Implement proper sanitization
3. **Not handling rate limits** - Implement proper backoff
4. **Ignoring memory leaks** - Proper cleanup in finally blocks
5. **Not testing error scenarios** - Test failure modes extensively
6. **Poor error messages** - Provide actionable error information
7. **Not considering thread safety** - Use proper locking mechanisms
8. **Ignoring performance** - Profile and optimize regularly

This guide provides a comprehensive framework for building enterprise-grade API wrappers. Adapt the specific implementations based on your target API's characteristics and requirements.
