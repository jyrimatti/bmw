#!/bin/sh

export BMW_VIN="$(cat "${CREDENTIALS_DIRECTORY:-.}/.bmw-vin")"
export BMW_USERNAME="$(cat "${CREDENTIALS_DIRECTORY:-.}/.bmw-user")"
export BMW_PASSWORD="$(cat "${CREDENTIALS_DIRECTORY:-.}/.bmw-pass")"
