#!/bin/sh

export BMW_VIN="$(cat "${CREDENTIALS_DIRECTORY:-.}/.bmw-vin")"
export BMW_USERNAME="$(cat "${CREDENTIALS_DIRECTORY:-.}/.bmw-user")"
export BMW_PASSWORD="$(cat "${CREDENTIALS_DIRECTORY:-.}/.bmw-pass")"

export BKT_CACHE_DIR="${XDG_RUNTIME_DIR:-/tmp}/bmw"