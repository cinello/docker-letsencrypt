FROM nginx:stable

COPY backports.list /etc/apt/sources.list.d/backports.list

RUN apt-get update && apt-get install -y git wget cron bc

RUN mkdir -p /letsencrypt/challenges/.well-known/acme-challenge
RUN apt-get install certbot -y -t stretch-backports && apt-get autoclean && apt-get autoremove --purge
RUN echo "OK" > /letsencrypt/challenges/.well-known/acme-challenge/health

# Install kubectl
RUN wget -O /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/`wget -q -O - https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl

# Add our nginx config for routing through to the challenge results
RUN rm /etc/nginx/conf.d/*.conf
ADD nginx/nginx.conf /etc/nginx/
ADD nginx/letsencrypt.conf /etc/nginx/conf.d/

# Add some helper scripts for getting and saving scripts later
ADD fetch_certs.sh /letsencrypt/
ADD save_certs.sh /letsencrypt/
ADD recreate_pods.sh /letsencrypt/
ADD refresh_certs.sh /letsencrypt/
ADD start.sh /letsencrypt/

ADD nginx/letsencrypt.conf /etc/nginx/snippets/letsencrypt.conf

RUN ln -s /root/.local/share/letsencrypt/bin/letsencrypt /usr/local/bin/letsencrypt

WORKDIR /letsencrypt

ENTRYPOINT ./start.sh
