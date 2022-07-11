#!/usr/bin/env bash

iv=$(openssl rand -hex 12)
payload=$(echo "{\"id\":\"$iv\",\"method\":\"close_wallet\",\"params\":{\"name\":null}}")
payload=$(.venv/bin/python ./scripts/python/encrypt.py "$1" "$iv" "$payload")
unset password
read body_enc nonce < <(echo $(curl -s --user grin:$(cat ~/.grin/test/.owner_api_secret) -d '{"jsonrpc":"2.0", "id":"'"$iv"'","method":"encrypted_request_v3","params":{"nonce":"'"$iv"'","body_enc":"'"$payload"'"}}' -o - http://127.0.0.1:13420/v3/owner | jq -r '.result.Ok.body_enc, .result.Ok.nonce'))
unset payload
result=$(.venv/bin/python ./scripts/python/decrypt.py $1 $nonce $body_enc)
if $(echo $result | jq 'has("error")')
then
    echo $result | jq .error.message
else
    echo "Wallet closed"
fi
