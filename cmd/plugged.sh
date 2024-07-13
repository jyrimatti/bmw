#! /usr/bin/env nix-shell
#! nix-shell -i dash --pure --keep CREDENTIALS_DIRECTORY -I channel:nixos-23.05-small -p dash jq python3Packages.bimmer-connected python3Packages.setuptools
set -eu

. ./bmw_env.sh

if [ "$(python3 ./data.sh | jq -r '.is_charger_connected')" = "true" ]; then
  echo 1
else
  echo 0
fi
