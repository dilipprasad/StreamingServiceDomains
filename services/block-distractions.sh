#!/bin/bash
#
# block-distractions.sh
#
echo 'blocking distractions...'
export PATH="$PATH:/usr/sbin:/usr/local/bin/"
sqlite3 /etc/pihole/gravity.db "update adlist set enabled = true where id = 85;"
pihole restartdns