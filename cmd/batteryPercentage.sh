#! /usr/bin/env nix-shell
#! nix-shell --pure --keep CREDENTIALS_DIRECTORY --keep BKT_SCOPE --keep BKT_CACHE_DIR
#! nix-shell -i dash -I channel:nixos-23.05-small -p dash jq flock bkt python3Packages.bimmer-connected python3Packages.setuptools
set -eu

. ./bmw_env.sh
BMW_ACCESS_TOKEN="$(dash ./bmw_login.sh)"
export BMW_ACCESS_TOKEN

bkt --discard-failures --ttl "60s" --stale "50s" -- python3 ./data.sh fuel_and_battery | jq -r '.remaining_battery_percent'
