#!/usr/bin/env bash
set -euo pipefail

DEST="${HOME}/.claude/plugins/cmux-claude-code"
REPO="https://github.com/tslateman/cmux-claude-code.git"
PLUGINS_JSON="${HOME}/.claude/plugins/installed_plugins.json"

if [ -d "$DEST" ]; then
  git -C "$DEST" fetch origin
  git -C "$DEST" reset --hard origin/main
  echo "cmux-claude-code updated."
else
  mkdir -p "$(dirname "$DEST")"
  git clone "$REPO" "$DEST"
  echo "cmux-claude-code installed to $DEST"
fi

# Register plugin
mkdir -p "$(dirname "$PLUGINS_JSON")"
if [ ! -f "$PLUGINS_JSON" ]; then
  echo '{"version":2,"plugins":{}}' >"$PLUGINS_JSON"
fi

VERSION=$(jq -r '.version // "0.0.0"' "$DEST/.claude-plugin/plugin.json" 2>/dev/null || echo "0.0.0")
NOW=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")
SHA=$(git -C "$DEST" rev-parse HEAD 2>/dev/null || echo "")

if command -v jq &>/dev/null; then
  jq --arg path "$DEST" --arg ver "$VERSION" --arg now "$NOW" --arg sha "$SHA" \
    '.plugins["cmux-claude-code@local"] = [{
      scope: "user",
      installPath: $path,
      version: $ver,
      installedAt: $now,
      lastUpdated: $now,
      gitCommitSha: $sha
    }]' "$PLUGINS_JSON" >"$PLUGINS_JSON.tmp" &&
    mv "$PLUGINS_JSON.tmp" "$PLUGINS_JSON"
  echo "cmux-claude-code registered."
else
  echo "jq required for plugin registration. Install with: brew install jq"
  exit 1
fi

# Enable plugin in settings.json
SETTINGS_JSON="${HOME}/.claude/settings.json"
if [ -f "$SETTINGS_JSON" ]; then
  if jq -e '.enabledPlugins' "$SETTINGS_JSON" >/dev/null 2>&1; then
    jq '.enabledPlugins["cmux-claude-code@local"] = true' "$SETTINGS_JSON" >"$SETTINGS_JSON.tmp" &&
      mv "$SETTINGS_JSON.tmp" "$SETTINGS_JSON"
  else
    jq '.enabledPlugins = {"cmux-claude-code@local": true}' "$SETTINGS_JSON" >"$SETTINGS_JSON.tmp" &&
      mv "$SETTINGS_JSON.tmp" "$SETTINGS_JSON"
  fi
fi

echo "Restart Claude to load."
