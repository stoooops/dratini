#!/bin/bash

NAME=${1:-cert}

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

CRT_FILE=${SCRIPT_DIR}/${NAME}.crt
KEY_FILE=${SCRIPT_DIR}/${NAME}.key

if [ -f ${CRT_FILE} ]; then
    echo "Error: ${CRT_FILE} exists"
    exit 1
fi

if [ -f ${KEY_FILE} ]; then
    echo "Error: ${KEY_FILE} exists"
    exit 1
fi

openssl req -x509 \
    -out ${CRT_FILE} \
    -keyout ${KEY_FILE} \
    -newkey rsa:2048 \
    -nodes -sha256 \
    -subj '/CN=localhost' \
    -extensions EXT \
    -config <( \
        printf "[dn]\nCN=localhost\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:localhost\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")

echo "Visit chrome://flags/#allow-insecure-localhost"
