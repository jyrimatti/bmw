#! /usr/bin/env nix-shell
#! nix-shell -i dash --pure --keep CREDENTIALS_DIRECTORY -I channel:nixos-23.05-small -p dash jq flock python3Packages.bimmer-connected python3Packages.setuptools
set -eu

. ./bmw_env.sh
BMW_ACCESS_TOKEN="$(dash ./bmw_login.sh)"
export BMW_ACCESS_TOKEN

if [ "$(python3 ./data.sh fuel_and_battery | jq -r '.is_charger_connected')" = "true" ]; then
  echo 1
else
  echo 0
fi
