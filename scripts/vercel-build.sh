#!/usr/bin/env bash
set -euo pipefail

if ! command -v flutter >/dev/null 2>&1; then
  git clone https://github.com/flutter/flutter.git --depth 1 -b stable "$HOME/flutter"
  export PATH="$HOME/flutter/bin:$PATH"
fi

flutter config --enable-web
flutter pub get

build_args=(web --release --base-href /)
if [[ -n "${SUPABASE_URL:-}" ]]; then
  build_args+=(--dart-define=SUPABASE_URL="$SUPABASE_URL")
fi
if [[ -n "${SUPABASE_ANON_KEY:-}" ]]; then
  build_args+=(--dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY")
fi

flutter build "${build_args[@]}"
