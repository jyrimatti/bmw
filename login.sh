#! /usr/bin/env nix-shell
#! nix-shell -i python --pure --keep BMW_VIN --keep BMW_USERNAME --keep BMW_PASSWORD --keep CREDENTIALS_DIRECTORY -I channel:nixos-23.05-small -p python3Packages.bimmer-connected python3Packages.setuptools

import sys
import os
import asyncio
from bimmer_connected.account import MyBMWAccount
from bimmer_connected.api.regions import Regions
from bimmer_connected.api.client import MyBMWClientConfiguration
from bimmer_connected.api.authentication import MyBMWAuthentication

USERNAME=os.environ.get('BMW_USERNAME')
PASSWORD=os.environ.get('BMW_PASSWORD')

REFRESH_TOKEN = None

if len(sys.argv) > 1:
    REFRESH_TOKEN=sys.argv[1]

config = MyBMWClientConfiguration(MyBMWAuthentication(USERNAME, PASSWORD, Regions.REST_OF_WORLD, None, None, REFRESH_TOKEN))
account = MyBMWAccount(USERNAME, PASSWORD, Regions.REST_OF_WORLD, config)
asyncio.run(account.get_vehicles())

print('{' +
    '"refresh_token": "' + account.config.authentication.refresh_token + '", ' +
    '"access_token": "' + account.config.authentication.access_token + '", ' +
    '"expires_at": "' + account.config.authentication.expires_at.isoformat() + '"' +
'}')
