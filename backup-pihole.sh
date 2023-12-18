#Command to Backup pihole db - THIS ADDED AS A CRON JOB

#$(date +"%d-%m-%y") - This will give the date in the format 23-12-20
#$(date +"%m-%y") - This will give the date in the format 12-20
#Replace the same for - so 1 file per month to save space
sudo rsync -ah --progress /etc/pihole/pihole-FTL.db  /home/$USER/backup/piholebackup/pihole-FTL_$(date +"%m-%y").db.backup >> /home/$USER/Logs/piholedbbackup/pihole-FTL_$(date +"%m-%y").log

#Old approach
# sudo sqlite3 /etc/pihole/pihole-FTL.db ".backup /home/$USER/backup/piholebackup/pihole-FTL_$(date +"%m-%y").db.backup" 
# sudo sudo sqlite3 /etc/pihole/gravity.db ".backup /home/$USER/backup/piholebackup/pihole-gravity_$(date +"%m-%y").db.backup" 



#Create index
sudo sqlite3 "/home/$USER/backup/piholebackup/pihole-FTL_$(date +"%m-%y").db.backup"  "CREATE INDEX idx_domain ON domain_by_id (domain);"


