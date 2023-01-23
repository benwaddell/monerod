#  docker run -p 18080-18081:18080-18081 -v /mnt/monero:/srv/monero -v monero-tor-keys:/var/lib/tor/monero -d --name monerod --pull always --restart always benwaddell/monerod

# centos base image
FROM centos:7

# ports used by monerod
EXPOSE 18080 18081

# copy repo file for tor repo
COPY tor.repo /etc/yum.repos.d/tor.repo

# download and install tor and monerod
RUN yum install bzip2 epel-release -y \
    && useradd --system monero \
    && useradd --system toranon \
    && mkdir -p /opt/monero \
    && mkdir -p /srv/monero \
    && chown -R monero:monero /srv/monero \
    && mkdir - p /var/log/monero \
    && chown -R monero:monero /var/log/monero \
    && curl -Lo monero.tar.bz2 https://downloads.getmonero.org/linux64 \
    && tar -xf monero.tar.bz2 \
    && mv monero-x86_64-linux-gnu-v*/* /opt/monero \
    && chown -R monero:monero /opt/monero \
    && yes | yum install tor -y \
    && mkdir -p /var/lib/tor/monero \
    && chown toranon:toranon /var/lib/tor/monero \
    && chmod 700 /var/lib/tor/monero

# copy config files and startup script
COPY --chown=toranon:toranon ./torrc /etc/tor/torrc
COPY monero.conf /etc/monero.conf
COPY start.sh start.sh

# run startup script
ENTRYPOINT ./start.sh
