#!/bin/bash
set -e

if [ -e "/tmp/.letsencrypt-lock" ]; then
    OLDPID=$(cat /tmp/.letsencrypt-lock)
    if ps -p $OLDPID > /dev/null; then
        echo "Nope, not gonna touch that."
        exit 1
    fi
    rm -f /tmp/.letsencrypt-lock
fi

touch /tmp/.letsencrypt-lock
echo $BASHPID > /tmp/.letsencrypt-lock

echo "$(date) Fetching certs..."
/letsencrypt/fetch_certs.sh
if [ -f /tmp/.letsencrypt-status ]; then
  UPDATED=$(cat /tmp/.letsencrypt-status)
  rm /tmp/.letsencrypt-status
fi

if [ "${UPDATED}" = "UPDATED" ]; then
    echo "$(date) Saving certs..."
    /letsencrypt/save_certs.sh

    echo "$(date) Recreating pods..."
    /letsencrypt/recreate_pods.sh
else
    echo "$(date) The certificate han not been updated"
fi

rm /tmp/.letsencrypt-lock

if [ "${SSL_VERIFY_URL}" != "" ]; then
    NAMESPACE=${NAMESPACE:-default}
    SSL_VERIFY_DAYS=${SSL_VERIFY_DAYS:-5}
    TIME=$((60 * 60 * 24 * ${SSL_VERIFY_DAYS}))
    if ! true | openssl s_client -connect ${SSL_VERIFY_URL} 2>/dev/null | \
                openssl x509 -noout -checkend ${TIME} > /dev/null 2>&1; then

        EMAIL_TO_PARAMS=""
        IFS=',' read -ra ADDR <<< "$EMAIL_TO"
        for address in "${ADDR[@]}"; do
            address="$(echo -e "${address}" | sed -e 's/^[[:space:]]*//')"
            address="$(echo -e "${address}" | sed -e 's/[[:space:]]*$//')"
            EMAIL_TO_PARAMS="${EMAIL_TO_PARAMS} --to \"${address}\""
        done

        gomailer ${EMAIL_TO_PARAMS} \
            --subject "[Cinello ${NAMESPACE} SSL] Expiring certificate on proxy server" \
            --body "WARING! The SSL certificate on ${NAMESPACE} proxy server will expire in 5 days or less.\nPlease check it."
    fi
fi