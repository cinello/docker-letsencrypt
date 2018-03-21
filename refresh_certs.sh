#!/bin/bash
set -e

if [ -e "/tmp/.letsencrypt-lock" ]
then
    echo "Nope, not gonna touch that."
    exit 1
fi

touch /tmp/.letsencrypt-lock

echo "$(date) Fetching certs..."
/letsencrypt/fetch_certs.sh
if [ -f /tmp/.letsencrypt-status ]; then
  UPDATED=$(cat /tmp/.letsencrypt-status)
  rm /tmp/.letsencrypt-status
fi

if [ "${UPDATED}" = "UPDATED" ];then
    echo "$(date) Saving certs..."
    /letsencrypt/save_certs.sh

    echo "$(date) Recreating pods..."
    /letsencrypt/recreate_pods.sh
else
    echo "$(date) The certificate han not been updated"
fi

rm /tmp/.letsencrypt-lock
