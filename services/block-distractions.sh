#
#!/bin/bash
# block-distractions.sh
echo 'blocking distractions...'
export PATH="$PATH:/usr/sbin:/usr/local/bin/"
pihole restartdns
sqlite3 /etc/pihole/gravity.db "update adlist set enabled = true where id = 5;"
