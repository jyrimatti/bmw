#! /usr/bin/env nix-shell
#! nix-shell -i python --pure --keep BMW_VIN --keep BMW_USERNAME --keep BMW_PASSWORD --keep CREDENTIALS_DIRECTORY -I channel:nixos-23.05-small -p python3Packages.bimmer-connected python3Packages.setuptools

import sys
import os
import asyncio
from bimmer_connected.account import MyBMWAccount
from bimmer_connected.api.regions import Regions
from bimmer_connected.api.client import MyBMWClientConfiguration
from bimmer_connected.api.authentication import MyBMWAuthentication

VIN=os.environ.get('BMW_VIN')
ACCESS_TOKEN = os.environ.get('BMW_ACCESS_TOKEN')

command = sys.argv[1]

config = MyBMWClientConfiguration(MyBMWAuthentication('', '', Regions.REST_OF_WORLD, ACCESS_TOKEN, None, None))
account = MyBMWAccount('', '', Regions.REST_OF_WORLD, config)
asyncio.run(account.get_vehicles())
vehicle = account.get_vehicle(VIN)

if command == 'fuel_and_battery':
    status=vehicle.fuel_and_battery.charging_status
    conn=vehicle.fuel_and_battery.is_charger_connected
    perc=vehicle.fuel_and_battery.remaining_battery_percent
    print('{' +
        '"charging_status": "' + status.value + '", ' +
        '"is_charger_connected": ' + str(conn).lower() + ", " +
        '"remaining_battery_percent": ' + str(perc) +
    '}')
elif command == 'trigger_charge_start':
    result = asyncio.run(vehicle.remote_services.trigger_charge_start())
    print(result.state.value)
elif command == 'trigger_charge_stop':
    result = asyncio.run(vehicle.remote_services.trigger_charge_stop())
    print(result.state.value)
else:
    print('Error: Unknown command ' + command)
    sys.exit(1)