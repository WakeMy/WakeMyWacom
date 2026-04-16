#!/bin/bash
# WakeMyWacom – core script logic
# Source-available for transparency

USER_UID=$(id -u)
STATE_DIR="$HOME/.wakemywacom"
STATE_FILE="$STATE_DIR/state"

TIME_SAVED_PER_FIX=90

mkdir -p "$STATE_DIR"

# Initialize state if missing
if [ ! -f "$STATE_FILE" ]; then
  echo "fixes=0" > "$STATE_FILE"
fi

# Load state
source "$STATE_FILE"
fixes=${fixes:-0}

# Restart Wacom services (best-effort)
launchctl kickstart -k gui/$USER_UID/com.wacom.IOManager 2>/dev/null
launchctl kickstart -k gui/$USER_UID/com.wacom.DisplayHelper 2>/dev/null
launchctl kickstart -k gui/$USER_UID/com.wacom.DataStoreMgr 2>/dev/null

killall WacomTabletDriver 2>/dev/null
killall WacomTouchDriver 2>/dev/null

open -a "WacomTabletDriver" 2>/dev/null

# Update counter
fixes=$((fixes + 1))
echo "fixes=$fixes" > "$STATE_FILE"

total_minutes=$(((fixes * TIME_SAVED_PER_FIX) / 60))

# Milestone notifications (human-rounded)
case "$fixes" in
  50)
    osascript <<EOF
display notification "50 fixes.
Less stopping, more doing." with title "WakeMyWacom"
EOF
    ;;
  500)
    osascript <<EOF
display notification "500 fixes.
At this point, rebooting would feel weird." with title "WakeMyWacom"
EOF
    ;;
  1000)
    osascript <<EOF
display notification "1 000 fixes.
That’s a lot of interrupted flow, quietly restored." with title "WakeMyWacom"
EOF
    ;;
  2500)
    osascript <<EOF
display notification "The Wacom thing really *is* a thing, huh.
Thanks for sticking with WakeMyWacom." with title "WakeMyWacom — Milestone!"
EOF
    ;;
  5000)
    osascript <<EOF
display notification "That’s an epic amount of wacombing.
Thanks for using WakeMyWacom." with title "WakeMyWacom — Milestone!"
EOF
    ;;
  10000)
    osascript <<EOF
display notification "That’s some legendary pen mileage.
Thanks for using WakeMyWacom." with title "WakeMyWacom — Milestone!"
EOF
    ;;
esac
