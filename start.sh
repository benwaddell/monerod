#!/bin/bash
  
# turn on bash's job control
set -m

# run tor daemon
su - toranon -s /bin/bash -c "tor" &

# wait for tor
sleep 30

# run monerod
su - monero -c "/opt/monero/monerod --config-file=/etc/monero.conf --non-interactive"
