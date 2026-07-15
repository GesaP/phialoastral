#!/bin/bash
# Deploy script for preview environment
set -euo pipefail

echo "=== Deploying to Cloudflare Workers (Preview) ==="
echo ""

# Check required environment variables
if [ -z "${CLOUDFLARE_API_TOKEN:-}" ]; then
    echo "❌ Error: CLOUDFLARE_API_TOKEN is required"
    exit 1
fi

if [ -z "${CLOUDFLARE_ACCOUNT_ID:-}" ]; then
    echo "❌ Error: CLOUDFLARE_ACCOUNT_ID is required"
    exit 1
fi

# Set environment
export CLOUDFLARE_ACCOUNT_ID
export CLOUDFLARE_API_TOKEN
export NODE_ENV=preview

cd /workspace/workers

# Deploy to preview
echo "→ Deploying to preview environment..."
npx wrangler deploy --env preview

# Get deployment URL
echo ""
echo "→ Getting deployment URL..."
WORKER_URL="https://phialo-design-preview.lovebird.workers.dev"

# Check if site is accessible
echo "→ Verifying deployment..."
if curl -s -o /dev/null -w "%{http_code}" "$WORKER_URL" | grep -q "200"; then
    echo "✓ Preview site is accessible at: $WORKER_URL"
else
    echo "⚠️  Warning: Preview site returned non-200 status code"
fi

# Show worker info
echo ""
echo "→ Worker information:"
npx wrangler deployments list --name phialo-design-preview --env preview 2>/dev/null | head -10 || echo "Unable to list deployments"

echo ""
echo "✓ Preview deployment completed!"
echo "🌐 Preview URL: $WORKER_URL"