#!/bin/bash

#Create Directory if missing
echo "Creating Directory if missing"
mkdir /home/$USER/addtlPiholeAdlist

echo "Navigating to Directory /home/$USER/addtlPiholeAdlist"
cd /home/$USER/addtlPiholeAdlist

echo "Clone the repo"
#Clone the repo
git clone https://github.com/dilipprasad/StreamingServiceDomains.git
echo "Navigate to the directory /StreamingServiceDomains"
cd StreamingServiceDomains/

#Change to development branch
echo "Changing to development branch"
git checkout development

#Pull if repo already exists
echo "Pull if repo already exists"
git pull

echo "Navigate to the directory /StreamingServiceDomains/services"
#Navigate to the directory
cd  /home/$USER/addtlPiholeAdlist/StreamingServiceDomains/services/

# Set the directory path
directory="/home/$USER/addtlPiholeAdlist/StreamingServiceDomains/services/"
echo "Directory to process: $directory"

#How to take backup of pihole database
#sudo cp /etc/pihole/pihole-FTL.db  /home/pi/backup/piholebackup/pihole-FTL_$(date +"%m-%y").db
#above is done as a cron job

#Using backup DB instead of live db
echo "Get Latest backup file of pihole database"
cd /home/$USER/backup/piholebackup
latest_file=$(ls -lt --time=creation | grep ^- | head -n 1 | awk '{print $9}')
echo "Latest backup file: $latest_file"
fullPathofLatestFile="/backup/piholebackup/$latest_file"
echo "Full path of latest backup file: $fullPathofLatestFile"


# Loop through each file in the directory
for file in "$directory"/*
do
    # Check if the file is a regular file
    if [[ -f "$file" ]]; then
        # Echo the file name
        filename=$(basename "$file")
        echo "Current file name: $filename"
        echo "Get the domains from the pihole database for : $filename"
        sudo sqlite3 "$fullPathofLatestFile"  "SELECT  DISTINCT  domain  FROM  domain_by_id  WHERE domain LIKE '%.$filename%';"  >>  /home/$USER/addtlPiholeAdlist/StreamingServiceDomains/services/$filename
        sudo sqlite3 "$fullPathofLatestFile"  "SELECT  DISTINCT  domain  FROM  domain_by_id  WHERE domain LIKE '%-$filename%';"  >>  /home/$USER/addtlPiholeAdlist/StreamingServiceDomains/services/$filename
        echo "Sort the file and get only unique entries  for : $filename"
        sort -o $filename -u $filename

    fi
done


# echo "Get the domains from the pihole database"
# sudo sqlite3 "/etc/pihole/pihole-FTL.db"  "SELECT DISTINCT domain from queries WHERE domain like '%amazon%';"  >>  /home/$USER/addtlPiholeAdlist/StreamingServiceDomains/services/primevideo

# echo "Sort the file and get only unique entries"
# sort -o /home/$USER/addtlPiholeAdlist/StreamingServiceDomains/services/primevideo -u /home$USER/addtlPiholeAdlist/StreamingServiceDomains/services/primevideo

echo "cd into services directory again"
cd /home/$USER/addtlPiholeAdlist/StreamingServiceDomains/services/

echo "Get the domains from the pihole database"
#Contact and get a single list
cat *.* > /home/$USER/addtlPiholeAdlist/StreamingServiceDomains/combinedlist.txt

echo "Navigate to the parent directory /StreamingServiceDomains"
cd /home/$USER/addtlPiholeAdlist/StreamingServiceDomains

echo "Current Dir: $PWD"

echo "Sort the file and get only unique entries"
#Sort the file and get only unique entries
sort -o combinedlist.txt -u combinedlist.txt

echo "Current Dir: $PWD"
echo "Commit and push git changes"
#Commit and push git changes
git add .
git status
git config --global user.email "dilipprasad87@gmail.com"
git config --global user.name "Automated Script"
git commit -m "Update Domains"
git push
echo "Pushed latest domain list successfully"

echo "Sync with gravity sync"
sudo gravity-sync update

echo "end"