#!/bin/bash
#
# unblock-distractions.sh
#
echo 'unblocking distractions...'
export PATH="$PATH:/usr/sbin:/usr/local/bin/"
sqlite3 /etc/pihole/gravity.db "update adlist set enabled = false where id = 85;"
pihole restartdns