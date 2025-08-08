# OpenAI API Methods That Should Be Tracked

## Methods that consume tokens and should be tracked:

### Chat Completions
- `client.chat.completions.create()` - Main chat API ✅ Already tracked

### Completions (Legacy)
- `client.completions.create()` - Legacy completions API ✅ Already tracked

### Embeddings
- `client.embeddings.create()` - Create embeddings (consumes tokens)

### Images
- `client.images.generate()` - Generate images (DALL-E)
- `client.images.edit()` - Edit images
- `client.images.create_variation()` - Create image variations

### Audio
- `client.audio.transcriptions.create()` - Whisper transcription
- `client.audio.translations.create()` - Whisper translation
- `client.audio.speech.create()` - TTS (Text-to-Speech)

### Fine-tuning
- `client.fine_tuning.jobs.create()` - Create fine-tuning job (uses tokens for training)

### Moderations
- `client.moderations.create()` - Content moderation (free but worth tracking)

### Assistants API (Beta)
- `client.beta.assistants.create()` - Create assistant
- `client.beta.threads.create()` - Create thread
- `client.beta.threads.messages.create()` - Create message
- `client.beta.threads.runs.create()` - Create run (consumes tokens)
- `client.beta.threads.runs.create_and_poll()` - Create and poll run

## Methods that DON'T need tracking (no token consumption):

### List/Get operations
- `client.models.list()`
- `client.models.retrieve()`
- `client.files.list()`
- `client.files.retrieve()`
- `client.fine_tuning.jobs.list()`
- `client.fine_tuning.jobs.retrieve()`

### Delete operations
- `client.files.delete()`
- `client.fine_tuning.jobs.cancel()`

### File uploads (storage, not tokens)
- `client.files.create()`
