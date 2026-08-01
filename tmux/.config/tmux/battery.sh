#!/bin/bash

battery() {
  local batt discharging percentage charge

  if [[ $(uname) == "Linux" ]]; then
    batt=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -1)
    [[ -z "$batt" ]] && return 1
    discharging=$(grep -qi "discharging" ${batt}/status && echo "true" || echo "false")
    percentage=$(cat $batt/capacity)
  elif [[ $(uname) == "Darwin" ]]; then
    batt="$(pmset -g batt)"
    discharging="$(echo "${batt}" | grep -qi "discharging" && echo "true" || echo "false")"
    percentage="$(echo "${batt}" | grep -Eo  "[0-9]+%")" || return
  else
    return 1
  fi

  charge="${percentage%%%} / 100"

  [[ "${percentage%%%}" -lt 10 ]] && mode=" blink" || mode=""

  battery_bg=$1

  columns=$(tmux -q display -p '#{client_width}' 2> /dev/null || echo 120)

  if [[ $columns -ge 170 ]]; then
    battery_symbol_count=10
  elif [[ $columns -ge 120 ]]; then
    battery_symbol_count=8
  else
    battery_symbol_count=6
  fi

  battery_symbol_full=█
  battery_symbol_empty=░

  if [[ "$discharging" == "true" ]]; then
    printf "%s " 󰂌
  elif [[ $(uname) == "Linux" ]] && grep -qi "^charging$" ${batt}/status 2>/dev/null; then
    printf "%s " 󰂄
  else
    printf "%s " 󰁹
  fi

  palette="52 88 124 130 136 142 106 70 34 28 22"
  count=$(echo $palette | wc -w)

  eval set -- "$palette"
  palette=$(eval echo $(eval echo $(printf "\\$\{\$(expr %s \* $count / $battery_symbol_count)\} " $(seq 1 $battery_symbol_count))))

  full=$(printf %.0f $(awk "BEGIN{print $charge * $battery_symbol_count}"))
  printf '#[bg=%s]' $battery_bg
  [ $full -gt 0 ] && printf "#[fg=colour%s${mode}]$battery_symbol_full" $(echo $palette | cut -d' ' -f1-$full)
  empty=$((battery_symbol_count - full))
  [ $empty -gt 0 ] && printf "#[fg=colour%s]$battery_symbol_empty" $(echo $palette | cut -d' ' -f$((full+1))-$(($full + $empty)))
}

battery "$@"
