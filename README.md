# letsencrypt-kubernetes

A docker image suitable for requesting new certificates from letsencrypt,
and storing them in a secret on kubernetes.

Available on docker hub as [ployst/letsencrypt](https://hub.docker.com/r/ployst/letsencrypt)

## Purpose

To provide an application that owns certificate requesting and storing.

- To serve acme requests to letsencrypt (given that you direct them to this
   container)
- To regularly (monthly) ask for new certificates.
- To store those new certificates in a secret on kubernetes.

## Useful commands

### Generate a new set of certs

Once this container is running you can generate new certificates using:

```bash
kubectl exec -it <pod> -- bash -c 'EMAIL=fred@fred.com DOMAINS=example.com foo.example.com ./fetch_certs.sh'
```

### Save the set of certificates as a secret

```bash
kubectl exec -it <pod> -- bash -c 'DOMAINS=example.com foo.example.com ./save_certs.sh'
```

### Refresh the certificates

```bash
kubectl exec -it <pod> -- bash -c 'EMAIL=fred@fred.com DOMAINS=example.com foo.example.com SECRET_NAME=foo DEPLOYMENTS=bar ./refresh_certs.sh'
```

## Environment variables:

- EMAIL
  - the email address to obtain certificates on behalf of.
- DOMAINS
  - a space separated list of domains to obtain a certificate for.
- LETSENCRYPT_ENDPOINT
  - If set, will be used to populate the /etc/letsencrypt/cli.ini file with
    the given server value. For testing use
    https://acme-staging.api.letsencrypt.org/directory
- DEPLOYMENTS
  - a space separated list of deployments whose pods should be refreshed after a certificate save
- SECRET_NAME
  - the name to save the secrets under
- NAMESPACE
  - the namespace under which the secrets should be available
- TYPE
  - the type of the secrets (default is Opaque)
- CRON_FREQUENCY
  - the 5-part frequency of the cron job. Default is a random time in the range `0-59 0-23 1-27 * *`
- SSL_VERIFY_URL
  - the update job will verify this service to be sure the certificate has been updated correctly. If the certificate has not been updated, and still will expire within ```${SSL_VERIFY_DAYS}``` days, a mail will be sent to ```${EMAIL_TO}``` recipients.
    This variable has the "hostname:port" format.
- SSL_VERIFY_DAYS
  - the number of days to check before the certificate will expire,  when the update job will check ```${SSL_VERIFY_URL}``` service.
    If not specified, the default value is 5 days.
- EMAIL_HOST
  - hostname of the mail server used to send the mail
- EMAIL_PORT
  - port of the mail server used to send the mail
- EMAIL_USERNAME
  - username used to login on then server
- EMAIL_PASSWORD
  - password used to login on then server
- EMAIL_FROM
  - email used to populate the FROM header of the message
- EMAIL_TO
  - a list of recipients to send the mail to, separated by comma
