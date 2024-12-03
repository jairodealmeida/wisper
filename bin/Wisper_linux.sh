#!/bin/sh
echo -ne '\033c\033]0;Wisper\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Wisper_linux.x86_64" "$@"
