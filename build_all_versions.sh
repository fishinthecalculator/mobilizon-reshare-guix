#!/usr/bin/env bash
set -euo pipefail

declare -a versions=("0.1.0"
                     "0.2.0"
                     "0.2.2"
                     "0.2.3"
                     "0.3.0"
                     "0.3.1")

for v in "${versions[@]}"; do
    guix build -L ./modules "mobilizon-reshare@${v}"
done
