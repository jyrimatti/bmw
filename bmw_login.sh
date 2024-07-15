#! /usr/bin/env nix-shell
#! nix-shell -i dash --pure --keep BMW_USERNAME --keep BMW_PASSWORD --keep CREDENTIALS_DIRECTORY -I channel:nixos-23.05-small -p dash jq flock python3Packages.bimmer-connected python3Packages.setuptools
set -eu

DIR="${XDG_RUNTIME_DIR:-/tmp}/bmw"
test -e "$DIR" || mkdir -p "$DIR"

refresh_token_file="$DIR/refresh_token"
access_token_file="$DIR/access_token"
expires_at_file="$DIR/expires_at"

if [ -f "$refresh_token_file" ]; then
    refresh_token="$(cat "$refresh_token_file")"
fi

get_access_token() {
    if [ ! -f "$expires_at_file" ] || [ "$(date --utc -d "$(cat "$expires_at_file")" +%s)" -lt "$(date +%s)" ]; then
        echo ""
    elif [ -f "$access_token_file" ]; then
        cat "$access_token_file"
    else
        echo ""
    fi
}

at="$(get_access_token)"
if [ -z "${at:-}" ]; then
    (
        flock 8
        at="$(get_access_token)"
        if [ -z "${refresh_token:-}" ] || [ -z "${at:-}" ]; then
            res="$(python3 ./login.sh "${refresh_token:-}")"
            echo "$res"\
                | jq -r "[.refresh_token, .access_token, .expires_at] | @tsv"\
                | {
                    read -r rt at ex
                    echo "$rt" > "$refresh_token_file"
                    echo "$at" > "$access_token_file"
                    echo "$ex" > "$expires_at_file"
                }
        fi
    ) 8> "$DIR/lock"
fi

cat "$access_token_file"
