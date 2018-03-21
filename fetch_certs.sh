#!/bin/bash

EMAIL=${EMAIL}
DOMAINS=(${DOMAINS})

if [ -z "${DOMAINS}" ]; then
    echo "ERROR: Domain list is empty or unset"
    exit 1
fi

if [ -z "${EMAIL}" ]; then
    echo "ERROR: Email is empty string or unset"
    exit 1
fi

CERT_LOCATION='/etc/letsencrypt/live'

DOMAIN=${DOMAINS[0]}

DAYS=15
TIME=$((60 * 60 * 24 * ${DAYS}))

MUST_UPGRADE="n"
if [ ! -f ${CERT_LOCATION}/${DOMAIN}/fullchain.pem ] || ! openssl x509 -noout -checkend ${TIME} -in ${CERT_LOCATION}/${DOMAIN}/fullchain.pem >/dev/null; then
    MUST_UPGRADE="y"
fi

if [ "${MUST_UPGRADE}" = "y" ]; then
    domain_args=""
    for i in "${DOMAINS[@]}"
    do
    domain_args="${domain_args} -d $i"
    # do whatever on $i
    done

    certbot certonly \
        --renew-by-default --agree-tos --email ${EMAIL} \
        --max-log-backups 0 \
        --webroot -w /letsencrypt/challenges/ \
        ${domain_args}

    echo "UPDATED" > /tmp/.letsencrypt-status
    exit 0
fi

echo "SKIPPED" > /tmp/.letsencrypt-status
exit 0
