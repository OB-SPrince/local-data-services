# Testing external API access

## Anthropic Claude

```bash
❯ curl https://api.anthropic.com/v1/complete \
     --header "x-api-key: ${ANTHROPIC_API_KEY}" \
     --header "anthropic-version: 2023-06-01" \
     --header "content-type: application/json" \
     --data \
'{
    "model": "claude-2.1",
    "max_tokens_to_sample": 1024,
    "prompt": "\n\nHuman: Hello, Claude\n\nAssistant:"
}'
```

## Mistral AI

Chat Completions:

```bash
curl --location "https://api.mistral.ai/v1/chat/completions" \
     --header 'Content-Type: application/json' \
     --header 'Accept: application/json' \
     --header "Authorization: Bearer $MISTRAL_API_KEY" \
     --data '{
    "model": "mistral-large-latest",
    "messages": [{"role": "user", "content": "Who is the most renowned French painter?"}]
  }'
```

Embeddings:

```bash
curl --location "https://api.mistral.ai/v1/embeddings" \
     --header 'Content-Type: application/json' \
     --header 'Accept: application/json' \
     --header "Authorization: Bearer $MISTRAL_API_KEY" \
     --data '{
    "model": "mistral-embed",
    "input": ["Embed this sentence.", "As well as this one."]
  }'
```

## Groq

Chat Completions:

```bash
curl -X POST "https://api.groq.com/openai/v1/chat/completions" \
     -H "Authorization: Bearer $GROQ_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"messages": [{"role": "user", "content": "Explain the importance of low latency LLMs"}], "model": "mixtral-8x7b-32768"}'
```

## OpenAI

Chat Completions:

```bash
curl https://api.openai.com/v1/chat/completions   -H "Content-Type: application/json"   -H "Authorization: Bearer $OPENAI_API_KEY"   -d '{
    "model": "gpt-3.5-turbo",
    "messages": [
      {
        "role": "system",
        "content": "You are a poetic assistant, skilled in explaining complex programming concepts with creative flair."
      },
      {
        "role": "user",
        "content": "Compose a poem that explains the concept of recursion in programming."
      }
    ]
  }'
```

Embeddings:

```bash
curl https://api.openai.com/v1/embeddings   -H "Authorization: Bearer $OPENAI_API_KEY"   -H "Content-Type: application/json"   -d '{
    "input": "The food was delicious and the waiter...",
    "model": "text-embedding-ada-002"
  }'
```

Images:

```bash
curl https://api.openai.com/v1/images/generations   -H "Content-Type: application/json"   -H "Authorization: Bearer $OPENAI_API_KEY"   -d '{
    "prompt": "A cute baby sea otter",
    "n": 2,
    "size": "1024x1024"
  }'
```
