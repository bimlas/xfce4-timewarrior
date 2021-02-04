#!/bin/bash
# XFCE GenMon widget to add and show entries of time tracker
#
# How to create GenMon widget:
#
#   * Create a new GenMon widget
#   * Set the command to `/path/to/this/file FILTER`, where FILTER is one of
#     `fzf` or `rofi`
#   * Turn off label
#   * Set the interval to 5 seconds
#
# Usage:
#
#   * Click on the text to add new entry
#   * Keep the mouse over the text to view the report of today
#   * Click on the image to start/stop tracking time with the most recent tag
#
# Requirements:
#
#   * TimeWarrior: https://timewarrior.net/
#   * XFCE desktop environment: https://xfce.org
#   * XFCE GenMon plugin: https://docs.xfce.org/panel-plugins/xfce4-genmon-plugin
#   * FZF: https://github.com/junegunn/fzf
#   * ROFI: https://github.com/davatorium/rofi

if [ ! -d "$HOME/.timewarrior" ]; then
  echo "EXECUTE 'timew' FROM COMMANDLINE FIRST!"
  exit 1
fi

is_active=`timew get dom.active`
recent_tag=`timew get dom.active.tag.1`
is_disabled=0
if [ "$recent_tag" == ""  ]; then
  recent_tag="CLICK HERE TO SPECIFY A TAG"
  is_active=0
  is_disabled=1
fi

icon="/usr/share/icons/elementary-xfce/actions/16/media-playback-start.png"
if [ $is_disabled == 0 ]; then
  click="timew start \"$recent_tag\""
fi
if [ $is_active -gt 0 ]; then
  icon="/usr/share/icons/elementary-xfce/actions/16/media-playback-stop.png"
  click="timew stop"
fi

list_tags='
  for n in $(seq $(timew get dom.tag.count)); do
    timew get "dom.tag.$n"
  done'

case "$1" in
  "fzf")
    select_tag_command="$list_tags | fzf --print-query | tail -1 | xargs --null timew start"
    txtclick="x-terminal-emulator -e /bin/bash --login -i -c '$select_tag_command'"
    ;;
  "rofi")
    txtclick="/bin/bash -c '$list_tags | rofi -dmenu | tail -1 | xargs --null timew start'"
    ;;
  *)
    echo "Unknown fuzzy filter: $1" >& 2
    exit 1
    ;;
esac

cat << __HEREDOC__
<img>$icon</img>
<txt>$recent_tag</txt>
<tool><span font-family="monospace">`timew summary today`</span></tool>
<click>$click</click>
<txtclick>$txtclick</txtclick>
__HEREDOC__
