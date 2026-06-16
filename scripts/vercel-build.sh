#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
  export PATH="$HOME/flutter/bin:$PATH"
fi

: "${SUPABASE_URL:?Set SUPABASE_URL in Vercel Environment Variables}"
: "${SUPABASE_ANON_KEY:?Set SUPABASE_ANON_KEY in Vercel Environment Variables}"

flutter config --enable-web
flutter pub get
flutter build web --release --base-href / \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
