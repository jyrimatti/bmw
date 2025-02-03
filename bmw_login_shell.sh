#! /usr/bin/env nix-shell
#! nix-shell -i dash --pure --keep CREDENTIALS_DIRECTORY -I channel:nixos-23.05-small -p dash jq flock libuuid coreutils openssl
set -eu

# from: https://bimmer-connected.readthedocs.io/
# but doesn't currently work

OAUTH_PATH="/eadrax-ucs/v1/presentation/oauth/config"
APP_VERSION="3.11.1(29513)"

#NORTH_AMERICA: na
#CHINA: cn
#REST_OF_WORLD: row
region="${1:-row}"

case "$region" in
    row)
        SERVER="cocoapi.bmwgroup.com"
        APIKEY="4f1c85a3-758f-a37d-bbb6-f8704494acfa"
        ;;
    na)
        SERVER="cocoapi.bmwgroup.us"
        APIKEY="31e102f5-6f7e-7ef3-9044-ddce63891362"
        ;;
    cn)
        SERVER="myprofile.bmw.com.cn"
        ;;
esac

useragent() {
    echo "android(TQ2A.230405.003.B2);bmw;$APP_VERSION;$region"
}

generate_token() {
    openssl rand -hex "$(($1/2))"
}

generate_uuid() {
    uuidgen
}

fetch_oauth_settings() {
    sessionid="$1"
    correlation_id="$(generate_uuid)"
    ret="$(curl --no-progress-meter -H "ocp-apim-subscription-key: $APIKEY"\
                                    -H "bmw-session-id: $sessionid"\
                                    -H "x-identity-provider: gcdm"\
                                    -H "x-correlation-id: $correlation_id"\
                                    -H "bmw-correlation-id: $correlation_id"\
                                    -H "x-user-agent: $(useragent "$region")"\
                                    "https://${SERVER}${OAUTH_PATH}")"
    echo "$ret" >&2
    echo "$ret"
}

login() {
    sessionid="$(generate_uuid)"
    fetch_oauth_settings "$sessionid" \
        | jq -r '[.tokenEndpoint, .clientId, .clientSecret, .returnUrl, (.scopes | join(" "))] | @tsv'\
        | {
            read -r tokenEndpoint clientId clientSecret returnUrl scopes
            
            code_verifier="$(generate_token 86)"
            code_challenge="$(echo "$code_verifier" | sha256sum | cut -d' ' -f1 | basenc --base64url --wrap 0 | head -c-1)"

            state="$(generate_token 22)"
            nonce="login_nonce" #"$(generate_token 22)"

            authUrl="$(echo "$tokenEndpoint" | sed 's/token/authenticate/')"
            resp="$(curl --no-progress-meter --fail-with-body\
                --data-urlencode "response_type=code"\
                --data-urlencode "client_id=$clientId"\
                --data-urlencode "scope=$scopes"\
                --data-urlencode "redirect_uri=$returnUrl"\
                --data-urlencode "state=$state"\
                --data-urlencode "nonce=$nonce"\
                --data-urlencode "code_challenge=$code_challenge"\
                --data-urlencode "code_challenge_method=S256"\
                --data-urlencode "grant_type=authorization_code"\
                --data-urlencode "username=$BMW_USERNAME"\
                --data-urlencode "password=$BMW_PASSWORD"\
                "$authUrl")"
            authorization="$(echo "$resp" | jq -r '.redirect_to' | sed 's/.*authorization=\([^&]*\).*/\1/')"

            url="$(curl -v --no-progress-meter --fail-with-body -o /dev/stderr -w "%{url_effective}"\
                --data-urlencode "response_type=code"\
                --data-urlencode "client_id=$clientId"\
                --data-urlencode "scope=$scopes"\
                --data-urlencode "redirect_uri=$returnUrl"\
                --data-urlencode "state=$state"\
                --data-urlencode "nonce=$nonce"\
                --data-urlencode "code_challenge=$code_challenge"\
                --data-urlencode "code_challenge_method=S256"\
                --data-urlencode "authorization=$authorization"\
                -H "user-agent: Dart/3.0 (dart:io)"\
                -H "x-user-agent: $(useragent)"\
                "$authUrl?interaction-id=$(generate_uuid)&client-version=$(useragent)")"
            code="$(echo "$url" | sed 's/.*code=\([^&]*\).*/\1/')"

            resp3="$(curl -v --no-progress-meter --fail-with-body\
                --basic -u "$clientId:$clientSecret"\
                --data-urlencode "code=$code"\
                --data-urlencode "code_verifier=$code_verifier"\
                --data-urlencode "redirect_uri=$returnUrl"\
                --data-urlencode "grant_type=authorization_code"\
                "$tokenEndpoint")"
            echo "$resp3"\
                | jq -r '[.refresh_token, .access_token, .expires_in] | @tsv'\
                | {
                    read -r refresh_token access_token expires_in
                    jq '{refresh_token: $refresh_token, access_token: $access_token, expires_at: $expires_at}'\
                        --arg refresh_token "$refresh_token"\
                        --arg access_token "$access_token"\
                        --arg expires_at="$(date -d "+$expires_in seconds" +%s)"
                }
        }
}

DIR="${XDG_RUNTIME_DIR:-/tmp}/bmw"
test -e "$DIR" || mkdir -p "$DIR"

refresh_token_file="$DIR/refresh_token"
access_token_file="$DIR/access_token"
expires_at_file="$DIR/expires_at"

if [ -f "$refresh_token_file" ]; then
    refresh_token="$(cat "$refresh_token_file")"
fi

get_access_token() {
    if [ ! -f "$expires_at_file" ] || [ "$(date -d "$(cat "$expires_at_file")" +%s)" -lt "$(date +%s)" ]; then
        echo ""
    elif [ -f "$access_token_file" ]; then
        cat "$access_token_file"
    else
        echo ""
    fi
}

if [ -z "${get_access_token:-}" ]; then
    (
        flock 8
        if [ -z "${refresh_token:-}" ] || [ -z "${get_access_token:-}" ]; then
            . ./bmw_env.sh

            res="$(login)"
            echo "$res"\
                | jq -r "[.refresh_token, .access_token, .expires_at] | @tsv"\
                | {
                    read -r rt at ex;
                    echo "$rt" > "$refresh_token_file"
                    echo "$at" > "$access_token_file"
                    echo "$ex" > "$expires_at_file"
                }
        fi
    ) 8> "$DIR/lock"
fi

cat "$access_token_file"
