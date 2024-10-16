#  docker run -p 18080-18081:18080-18081 -v /mnt/monero:/srv/monero -v monero-tor-keys:/var/lib/tor/monero -d --name monerod --pull always --restart always benwaddell/monerod

# ubuntu base image
FROM ubuntu:22.04

# ports used by monerod
EXPOSE 18080 18081

# install tor repo dependencies
RUN apt-get update \
    && apt-get install apt-transport-https wget gpg -y \
    && wget -qO- https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc \
    | gpg --dearmor | tee /usr/share/keyrings/tor-archive-keyring.gpg >/dev/null \
    && echo 'deb [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org jammy main' \
    >> /etc/apt/sources.list.d/tor.list \
    && echo 'deb-src [signed-by=/usr/share/keyrings/tor-archive-keyring.gpg] https://deb.torproject.org/torproject.org jammy main' \
    >> /etc/apt/sources.list.d/tor.list

# download and install tor and monerod
RUN apt-get update \
    && apt-get install tor deb.torproject.org-keyring bzip2 -y \
    && useradd --system monero \
    && useradd --system toranon \
    && mkdir -p /opt/monero \
    && mkdir -p /srv/monero \
    && chown -R monero:monero /srv/monero \
    && mkdir - p /var/log/monero \
    && chown -R monero:monero /var/log/monero \
    && wget -O monero.tar.bz2 https://downloads.getmonero.org/linux64 \
    && tar -xf monero.tar.bz2 \
    && mv monero-x86_64-linux-gnu-v*/* /opt/monero \
    && chown -R monero:monero /opt/monero \
    && yes | apt-get install tor -y \
    && mkdir -p /var/lib/tor/monero \
    && chown toranon:toranon /var/lib/tor/monero \
    && chmod 700 /var/lib/tor/monero

# copy config files and startup script
COPY --chown=toranon:toranon ./torrc /etc/tor/torrc
COPY monero.conf /etc/monero.conf
COPY start.sh start.sh

# run startup script
ENTRYPOINT ./start.sh
