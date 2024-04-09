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

```bash
curl -X POST "https://api.groq.com/openai/v1/chat/completions" \
     -H "Authorization: Bearer $GROQ_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"messages": [{"role": "user", "content": "Explain the importance of low latency LLMs"}], "model": "mixtral-8x7b-32768"}'
```
