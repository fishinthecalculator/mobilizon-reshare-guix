#!/usr/bin/env bash

set -eo pipefail

declare -a versions=("0.1.0"
                     "0.2.0"
                     # 0.2.2 (and 0.2.3 as well) is the first release where the Guix dependencies
                     # versions are actually compatible with pyproject.toml constraints. Because of that
                     # the way the package it's built is kind of hacky and a near world rebuild for Guix.
                     # 
                     # While the packages are supposed to be buildable, we avoid building them in CI to
                     # avoid incurring in Github's timout limitations
                     "0.3.0"
                     "0.3.1"
                     "0.3.2")

for v in "${versions[@]}"; do
   if [[ "$1" = "--pack" ]]; then
      guix pack -L ./modules -f docker --save-provenance "--root=docker-image-${v}.tar.gz" --entry-point=bin/mobilizon-reshare "mobilizon-reshare@${v}"
   else
      guix build -L ./modules "mobilizon-reshare@${v}"
   fi
done
