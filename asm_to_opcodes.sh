#!/usr/bin/env bash

set -euo pipefail

mkdir -p opcodes

for asm in asm/*.asm; do
    base=$(basename "${asm%.asm}")
    tmp=$(mktemp)

    awk '
      /^[[:space:]]*[0-9A-Fa-f]+:/ {
          sub(/^[[:space:]]*[0-9A-Fa-f]+:[[:space:]]+([0-9A-Fa-f]{2}[[:space:]]+)+/, "")
          if ($1 != "") {
              print tolower($1)
              ++c
              if (c == 1000) exit        # stop after 1 000 *opcodes*
          }
      }
    ' "$asm" > "$tmp"

    lines=$(wc -l < "$tmp")
    if (( lines == 1000 )); then
        mv "$tmp" "opcodes/$base.txt"
        echo "$base.txt  (1 000 opcodes)"
    else
        rm -f "$tmp"
        echo "skipped $base.asm  (only $lines opcodes)"
    fi
done

