# Dokploy Deployment

This setup runs:

- `antigravity` (private service, internal port `8080`)
- `litellm` (public service, OpenAI-compatible API on port `4000`)

Cursor should connect to LiteLLM, not directly to antigravity.

## 1) Prepare environment

```bash
cp deploy/dokploy/.env.example deploy/dokploy/.env
```

Edit `deploy/dokploy/.env` and set:

- `LITELLM_MASTER_KEY` to a strong random secret
- `ANTIGRAVITY_WEBUI_PASSWORD` to protect WebUI

## 2) Deploy in Dokploy

Use Compose deployment with:

- Compose file: `deploy/dokploy/docker-compose.yml`
- Environment file: `deploy/dokploy/.env`

Expose only LiteLLM (`4000`) publicly. Keep antigravity private/internal.

## 3) Link Google account(s) after deploy

Open antigravity WebUI through your private/internal route and add accounts.

For remote/headless setup, use manual OAuth completion:

1. Start OAuth from WebUI Accounts page.
2. Open the generated Google auth URL in your local browser.
3. After redirect to `http://localhost:51121/...`, copy the full callback URL.
4. Paste it in WebUI manual callback input.

## 4) Cursor configuration

In Cursor > API Keys:

- OpenAI API Key: set to your `LITELLM_MASTER_KEY`
- Override OpenAI Base URL: `https://<your-litellm-domain>/v1`

Do not point Cursor to antigravity `:8080`.

## 5) Model names in Cursor

- `ag-sonnet`
- `ag-opus`
- `ag-gemini-3.1-pro-high`
- `ag-gemini-3.1-pro-low`
