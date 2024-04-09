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

