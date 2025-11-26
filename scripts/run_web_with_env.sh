#!/usr/bin/env bash

# Simple helper script to run the Flutter web app with Supabase credentials
# provided via --dart-define. This script expects a .env file in the project
# root containing SUPABASE_URL and SUPABASE_ANON_KEY. The .env file itself
# is NOT committed to git.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

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

flutter run -d chrome \
  --web-hostname=localhost \
  --web-port=8080 \
  --dart-define="SUPABASE_URL=$SUPABASE_URL" \
  --dart-define="SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY"


