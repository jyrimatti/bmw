#! /usr/bin/env nix-shell
#! nix-shell -i dash --pure --keep CREDENTIALS_DIRECTORY -I channel:nixos-23.05-small -p dash jq flock python3Packages.bimmer-connected python3Packages.setuptools
set -eu

getset="${1:-}"
value="${4:-}"
if [ "$value" = "true" ] || [ "$value" = "1" ]; then
  value="1";
else
  value="0";
fi

. ./bmw_env.sh
BMW_ACCESS_TOKEN="$(dash ./bmw_login.sh)"
export BMW_ACCESS_TOKEN

if [ "$getset" = "Set" ]; then
  if [ "$value" = "1" ]; then
    res="$(python3 ./data.sh trigger_charge_start)"
  else
    res="$(python3 ./data.sh trigger_charge_stop)"
  fi
  if [ "$res" = "EXECUTED" ]; then
    echo 1
  else
    echo 0
  fi
else
  if [ "$(python3 ./data.sh fuel_and_battery | jq -r '.charging_status')" = "CHARGING" ]; then
    echo 1
  else
    echo 0
  fi
fi
