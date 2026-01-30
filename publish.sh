#!/usr/bin/env bash

# Build script for Flutter web app production deployment
# This script builds the Flutter web app with Supabase credentials
# provided via --dart-define. This script expects a .env file in the project
# root containing SUPABASE_URL and SUPABASE_ANON_KEY.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$ROOT_DIR/.env" ]; then
  echo "ERROR: .env file not found in project root ($ROOT_DIR/.env)."
  echo "Create one with SUPABASE_URL and SUPABASE_ANON_KEY before running this script."
  exit 1
fi

# shellcheck source=/dev/null
set -o allexport
source "$ROOT_DIR/.env"
set +o allexport

if [ -z "${SUPABASE_URL:-}" ] || [ -z "${SUPABASE_ANON_KEY:-}" ] ; then
  echo "ERROR: SUPABASE_URL or SUPABASE_ANON_KEY missing in .env."
  exit 1
fi

cd "$ROOT_DIR"

echo "Building Flutter web app for production..."
echo "Using SUPABASE_URL: ${SUPABASE_URL}"

flutter build web \
  --release \
  --dart-define="SUPABASE_URL=$SUPABASE_URL" \
  --dart-define="SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY"

# Create zip (optional backup)
( cd "$ROOT_DIR/build/web" && zip -r -q "$ROOT_DIR/build/aplle-web-deploy.zip" . -x "*.DS_Store" )
echo ""
echo "✅ Build complete. To go live: git push origin main"
