#!/bin/bash
  
# turn on bash's job control
set -m

# run tor daemon
su - toranon -s /bin/bash -c "tor" &

# wait for tor
sleep 30

# update monero.conf with onion address
sed -i "s/!HOSTNAME!/$(cat /var/lib/tor/monero/hostname)/g" /etc/monero.conf

# run monerod
su - monero -c "/opt/monero/monerod --config-file=/etc/monero.conf --non-interactive"
