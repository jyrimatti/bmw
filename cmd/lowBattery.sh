#! /usr/bin/env nix-shell
#! nix-shell --pure --keep CREDENTIALS_DIRECTORY --keep BKT_SCOPE --keep BKT_CACHE_DIR
#! nix-shell -i dash -I channel:nixos-23.05-small -p dash jq flock bkt python3Packages.bimmer-connected python3Packages.setuptools
set -eu

test "$(dash ./cmd/batteryPercentage.sh $*)" -lt 50 && echo 1 || echo 0
