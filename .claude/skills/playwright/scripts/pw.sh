#!/usr/bin/env bash
# pw.sh — run playwright-cli the same way on every machine and cloud session.
#
# Resolves two things upstream leaves to the machine:
#   1. The CLI: global `playwright-cli`, else the local/global Playwright
#      package via `npx --no-install playwright cli`. Never installs anything.
#   2. The browser, for `open` only: upstream defaults to branded Chrome.
#      Cloud containers have no Chrome and ship a Chromium build that may not
#      match the Playwright version, so when Chrome is absent and no browser
#      flag was given, a config pointing at an installed Chromium is added.
#
# Overrides: PW_EXECUTABLE=/path/to/chrome  PW_CONFIG=/path/to/config.json
# Usage: pw.sh [-s=session] <command> [args...]   (same as playwright-cli)
set -euo pipefail

if command -v playwright-cli >/dev/null 2>&1; then
  CLI=(playwright-cli)
elif npx --no-install playwright --version >/dev/null 2>&1; then
  CLI=(npx --no-install playwright cli)
else
  echo "pw.sh: no Playwright found. Ask the user before installing: npm install -g @playwright/cli@latest" >&2
  exit 127
fi

cmd=""
for a in "$@"; do case "$a" in -*) ;; *) cmd="$a"; break ;; esac; done

needs_browser=1
for a in "$@"; do
  case "$a" in --config=*|--browser=*|--profile=*|--cdp=*|--extension*|--device=*) needs_browser=0 ;; esac
done

find_chromium() {
  [ -n "${PW_EXECUTABLE:-}" ] && { echo "$PW_EXECUTABLE"; return; }
  for c in /opt/google/chrome/chrome "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
           "/c/Program Files/Google/Chrome/Application/chrome.exe"; do
    [ -x "$c" ] && return 1          # branded Chrome present: upstream default works
  done
  for c in /opt/pw-browsers/chromium "${PLAYWRIGHT_BROWSERS_PATH:-$HOME/.cache/ms-playwright}"/chromium-*/chrome-linux*/chrome \
           "$(command -v chromium 2>/dev/null)" "$(command -v chromium-browser 2>/dev/null)"; do
    [ -n "$c" ] && [ -x "$c" ] && { echo "$c"; return; }
  done
  return 1
}

extra=()
if [ "$cmd" = "open" ] && [ "$needs_browser" = 1 ]; then
  if [ -n "${PW_CONFIG:-}" ]; then
    extra=(--config="$PW_CONFIG")
  elif exe=$(find_chromium); then
    cfg="${TMPDIR:-/tmp}/playwright-cli-config.json"
    printf '{"browser":{"browserName":"chromium","launchOptions":{"executablePath":"%s","headless":true}}}\n' "$exe" > "$cfg"
    extra=(--config="$cfg")
  fi
fi

exec "${CLI[@]}" "$@" "${extra[@]}"
