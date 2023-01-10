#!/bin/sh
echo -ne '\033c\033]0;Post Apocalyptic Chess\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/paper_druid_linux.x86_64" "$@"
