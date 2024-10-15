#! /usr/bin/env nix-shell
#! nix-shell -i dash --pure --keep CREDENTIALS_DIRECTORY --keep XDG_RUNTIME_DIR -I channel:nixos-23.05-small -p dash jq flock bkt python3Packages.bimmer-connected python3Packages.setuptools
set -eu

test "$(dash ./cmd/batteryPercentage.sh $*)" -lt 50 && echo 1 || echo 0
