#!/bin/bash
#
# unblock-distractions.sh
#
echo 'unblocking distractions...'
export PATH="$PATH:/usr/sbin:/usr/local/bin/"
sudo sqlite3 /etc/pihole/gravity.db "update adlist set enabled = false where id = 85;"
pihole restartdns


echo "Sync with gravity sync"
sudo gravity-sync update

echo "end"
