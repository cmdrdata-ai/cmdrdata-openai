# 🏢 Enterprise-Grade Features

Drop-in replacement for the OpenAI Python SDK with automatic usage tracking and enterprise-ready infrastructure.

## 🚀 Quick Start

```bash
pip install cmdrdata-openai
```

```python
from cmdrdata_openai import TrackedOpenAI

client = TrackedOpenAI(
    api_key="your-openai-key",
    tracker_key="your-cmdrdata-key"
)

# Works exactly like the OpenAI SDK
response = client.chat.completions.create(
    model="gpt-4",
    messages=[{"role": "user", "content": "Hello!"}],
    customer_id="customer-123"  # Enables automatic usage tracking
)
```

## ✨ Key Features

### 🛡️ Production Security
- **Input validation** for all API parameters and customer data
- **Rate limiting** with configurable thresholds
- **Secure logging** that automatically redacts sensitive information
- **API key validation** for OpenAI format compliance

### 🔄 Bulletproof Reliability
- **Intelligent retry logic** with exponential backoff and jitter
- **Circuit breaker pattern** prevents cascading failures
- **Fail-safe design** - tracking never affects your OpenAI calls
- **Background processing** for zero-latency usage tracking

### ⚡ Performance Optimized
- **Connection pooling** reduces latency and improves throughput
- **Smart caching** with LRU and TTL support
- **Async/await support** for high-concurrency applications
- **Memory efficient** design prevents leaks in long-running processes

### 📊 Production Observability
- **Structured JSON logging** with request context
- **Performance metrics** for response times and success rates
- **Health checks** for monitoring and alerting
- **Distributed tracing** support for microservices

### 🔧 Developer Experience
- **100% OpenAI SDK compatibility** - no code changes required
- **Full type hints** for IDE autocomplete and static analysis
- **Comprehensive test coverage** including security and performance
- **Extensive documentation** with real-world examples

## 🎯 Usage Patterns

### Web Application Integration
```python
from flask import Flask, request
from cmdrdata_openai import TrackedOpenAI, customer_context

app = Flask(__name__)
client = TrackedOpenAI(api_key="...", tracker_key="...")

@app.route('/chat', methods=['POST'])
def chat():
    with customer_context(request.json['customer_id']):
        response = client.chat.completions.create(
            model="gpt-4",
            messages=request.json['messages']
        )
        return response.choices[0].message.content
```

### Async/High-Concurrency Applications
```python
from cmdrdata_openai import AsyncTrackedOpenAI

async def process_batch(requests):
    client = AsyncTrackedOpenAI(api_key="...", tracker_key="...")

    tasks = []
    for req in requests:
        task = client.chat.completions.create(
            model="gpt-4",
            messages=req['messages'],
            customer_id=req['customer_id']
        )
        tasks.append(task)

    return await asyncio.gather(*tasks)
```

### Enterprise Configuration
```python
from cmdrdata_openai import TrackedOpenAI
from cmdrdata_openai.logging_config import configure_logging

# Configure structured logging
configure_logging({
    'log_level': 'INFO',
    'log_format': 'structured',
    'security_mode': True
})

# Production-ready client
client = TrackedOpenAI(
    api_key=os.getenv("OPENAI_API_KEY"),
    tracker_key=os.getenv("CMDRDATA_API_KEY"),
    tracker_timeout=10.0,
    max_retries=5
)
```

## 🏗️ What Gets Tracked

Every API call automatically captures:
- **Customer ID** (for usage attribution)
- **Model used** (gpt-4, gpt-3.5-turbo, etc.)
- **Token usage** (input, output, and total tokens)
- **Request metadata** (response ID, finish reason, timestamps)
- **Performance metrics** (response time, success/failure)

## 📈 Deployment Ready

- **Container optimized** with Docker support
- **Kubernetes ready** with proper health checks
- **Thread-safe** for multi-threaded applications
- **Horizontally scalable** with stateless design
- **Zero-downtime deployments** with graceful shutdown

## 🔗 Links

- **[Documentation](https://github.com/cmdrdata-ai/cmdrdata-openai#readme)** - Complete usage guide
- **[Examples](https://github.com/cmdrdata-ai/cmdrdata-openai/tree/main/examples)** - Real-world integration patterns
- **[API Reference](https://github.com/cmdrdata-ai/cmdrdata-openai/blob/main/docs/api.md)** - Complete API documentation
- **[Get cmdrdata API Key](https://www.cmdrdata.ai)** - Sign up for usage tracking
