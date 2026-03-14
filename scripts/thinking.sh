#!/bin/bash
# Reset sidebar to "Thinking" state when user submits a prompt
source "$(dirname "$0")/cmux-common.sh"
cmux_available || exit 0

cmux_run set-status state "Thinking" --color "#4a9eff" || true
cmux_run clear-status tool || true
cmux_run clear-progress || true

# Reset progress counter for this surface
echo 0 > "/tmp/cmux-progress-$(cmux_surface_id)"
