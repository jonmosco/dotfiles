#!/bin/bash

battery() {
  local batt discharging percentage color status_icon level
  local batt_dirs

  if [[ $(uname) == "Linux" ]]; then
    # Glob rather than parsing ls; an unmatched glob stays literal and fails -d.
    batt_dirs=(/sys/class/power_supply/BAT*)
    batt="${batt_dirs[0]}"
    [[ -d "$batt" ]] || return 1
    discharging=$(grep -qi "discharging" "${batt}/status" && echo "true" || echo "false")
    percentage=$(<"${batt}/capacity")
  elif [[ $(uname) == "Darwin" ]]; then
    batt="$(pmset -g batt)"
    discharging="$(echo "${batt}" | grep -qi "discharging" && echo "true" || echo "false")"
    percentage="$(echo "${batt}" | grep -Eo  "[0-9]+%")" || return
  else
    return 1
  fi

  local pct="${percentage%%%}"

  # Dracula colors: green=#50fa7b orange=#ffb86c red=#ff5555
  if [[ $pct -le 20 ]]; then
    color="203"
  elif [[ $pct -le 50 ]]; then
    color="215"
  else
    color="84"
  fi

  # Status icon
  if [[ "$discharging" == "true" ]]; then
    status_icon="󰂌"
  elif [[ $(uname) == "Linux" ]] && grep -qi "^charging$" "${batt}/status" 2>/dev/null; then
    status_icon="󰂄"
  else
    status_icon="󰁹"
  fi

  # Charge level icon (unicode block elements)
  if   [[ $pct -ge 95 ]]; then level="█"
  elif [[ $pct -ge 80 ]]; then level="▇"
  elif [[ $pct -ge 65 ]]; then level="▆"
  elif [[ $pct -ge 50 ]]; then level="▅"
  elif [[ $pct -ge 35 ]]; then level="▄"
  elif [[ $pct -ge 20 ]]; then level="▃"
  elif [[ $pct -ge 5  ]]; then level="▂"
  else                         level="▁"
  fi

  printf "#[fg=colour%s]%s %s %s%%" "$color" "$status_icon" "$level" "$pct"
}

battery "$@"
