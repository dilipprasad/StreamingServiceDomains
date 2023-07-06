#!/bin/bash

#Create Directory if missing
echo "Creating Directory if missing"
mkdir /home/pi/addtlPiholeAdlist

echo "Navigating to Directory /home/pi/addtlPiholeAdlist"
cd /home/pi/addtlPiholeAdlist

echo "Clone the repo"
#Clone the repo
git clone https://github.com/dilipprasad/StreamingServiceDomains.git
echo "Navigate to the directory /StreamingServiceDomains"
cd StreamingServiceDomains/

#Pull if repo already exists
echo "Pull if repo already exists"
git pull

echo "Navigate to the directory /StreamingServiceDomains/services"
#Navigate to the directory
cd /home/pi/addtlPiholeAdlist/StreamingServiceDomains/services/

# Set the directory path
directory="/home/pi/addtlPiholeAdlist/StreamingServiceDomains/services/"
echo "Directory to process: $directory"


# Loop through each file in the directory
for file in "$directory"/*
do
    # Check if the file is a regular file
    if [[ -f "$file" ]]; then
        # Echo the file name
        echo "Current file: $file"
        echo "Get the domains from the pihole database for : $file"
        sudo sqlite3 "/etc/pihole/pihole-FTL.db"  "SELECT DISTINCT domain from queries WHERE domain like '%$file%';"  >>  /home/pi/addtlPiholeAdlist/StreamingServiceDomains/services/$file
        echo "Sort the file and get only unique entries  for : $file"
        sort -o $file -u $file

    fi
done


# echo "Get the domains from the pihole database"
# sudo sqlite3 "/etc/pihole/pihole-FTL.db"  "SELECT DISTINCT domain from queries WHERE domain like '%amazon%';"  >>  /home/pi/addtlPiholeAdlist/StreamingServiceDomains/services/primevideo

# echo "Sort the file and get only unique entries"
# sort -o /home/pi/addtlPiholeAdlist/StreamingServiceDomains/services/primevideo -u /home/pi/addtlPiholeAdlist/StreamingServiceDomains/services/primevideo


echo "Get the domains from the pihole database"
#Contact and get a single list
cat ./* > ../combinedlist.txt

echo "Navigate to the parent directory /StreamingServiceDomains"
cd /home/pi/addtlPiholeAdlist/StreamingServiceDomains

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