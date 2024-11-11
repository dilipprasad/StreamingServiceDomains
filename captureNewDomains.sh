\#!/bin/bash

USER=${USER:-$(whoami)}

executionScriptFolder=/home/$USER/EXECUTIONSCRIPTS/
streamingServiceDomains="$executionScriptFolder/StreamingServiceDomains"
piholeBackup=/home/$USER/backup/piholebackup

echo "Paths"
echo "executionScriptFolder: $executionScriptFolder"
echo "streamingServiceDomains:  $streamingServiceDomains"
echo "piholeBackup: $piholeBackup"

#Create Directory if missing
echo "Creating Directory if missing"
mkdir $executionScriptFolder
cd $executionScriptFolder
echo "$PWD"

echo "Clone the repo"
#Clone the repo
sudo git clone https://github.com/dilipprasad/StreamingServiceDomains.git

echo "Navigate to the directory /StreamingServiceDomains"
cd "$streamingServiceDomains"
echo "$PWD"

#Change to development branch
echo "Changing to development branch"
sudo git checkout development

#Pull if repo already exists
echo "Pull if repo already exists"
sudo git pull
echo "Git Completed"

#How to take backup of pihole database
#sudo cp /etc/pihole/pihole-FTL.db  /home/pi/backup/piholebackup/pihole-FTL_$(date +"%m-%y").db
#above is done as a cron job

#Using backup DB instead of live db
echo "Get Latest backup file of pihole database"
cd $piholeBackup
echo "$PWD"
latest_file=$(ls -lt --time=creation | grep ^- | head -n 1 | awk '{print $9}')
echo "Latest backup file: $latest_file"
fullPathofLatestFile="$piholeBackup/$latest_file"
echo "Full path of latest backup file: $fullPathofLatestFile"


echo "Navigate to the directory /StreamingServiceDomains/services"
#Navigate to the directory
cd "$streamingServiceDomains/services/"

# Set the directory path
directory="$streamingServiceDomains/services"
echo "Directory to process: $directory"

echo "Set Permissions"
sudo chmod -R 777  $directory

echo " Loop through each file in the directory for domains"
for file in "$directory"/*
do
    # Check if the file is a regular file
    if [[ -f "$file" ]]; then
        # Echo the file name
        filename=$(basename "$file")
        echo "Current file name: $filename"
        echo "Get the domains from the pihole database for : $filename"
        sudo sqlite3 "$fullPathofLatestFile"  "SELECT  DISTINCT  domain  FROM  domain_by_id  WHERE domain LIKE '%.$filename%';"  >>  "$streamingServiceDomains/services/$filename"
        sudo sqlite3 "$fullPathofLatestFile"  "SELECT  DISTINCT  domain  FROM  domain_by_id  WHERE domain LIKE '%-$filename%';"  >>  "$streamingServiceDomains/services/$filename"
	echo "Current dir: ${PWD}"
        echo "Sort the file and get only unique entries  for : $filename"
        sudo sort -u "$filename" -o "${filename}.sorted"
	sudo mv -f  "${filename}.sorted" "$filename"

    fi
done





echo "Generate wildcard version of the domains found"
# Process each file in the folder
for file in "$directory"/*; do
  # Check if it's a regular file
  if [ -f "$file" ]; then
    echo "Processing wildcard for file $file"
    # Create a temporary file for appending wildcard domains
    temp_file=$(mktemp)

    # Process each line in the file
    while IFS= read -r domain; do
      # Skip empty lines or lines starting with #
      if [[ -n "$domain" && "$domain" != "#"* ]]; then
        # Append original and wildcard domain to the temporary file
        echo "$domain" >> "$temp_file"
        echo "*.$domain" >> "$temp_file"
      fi
    done < "$file"

    # Replace the original file with the temporary file
    mv -f "$temp_file" "$file"
  fi
done
echo "completed wildcard generation"





# echo "Get the domains from the pihole database"
# sudo sqlite3 "/etc/pihole/pihole-FTL.db"  "SELECT DISTINCT domain from queries WHERE domain like '%amazon%';"  >>  /home/$USER/addtlPiholeAdlist/StreamingServiceDomains/services/primevideo
# echo "Sort the file and get only unique entries"
# sort -o /home/$USER/addtlPiholeAdlist/StreamingServiceDomains/services/primevideo -u /home$USER/addtlPiholeAdlist/StreamingServiceDomains/services/primevideo

echo "cd into StreamingServicesDomain directory "
cd $streamingServiceDomains
echo "$PWD"

echo "Provide permissions"
sudo chown $USER: $streamingServiceDomains

echo "Get the domains from the pihole database - build combinedlist file"
echo "Current dir : ${PWD}"
#Contact and get a single list
sudo cat services/* > "$streamingServiceDomains/combinedlist.txt"

echo "Current Dir: $PWD"

echo "Sort the file and get only unique entries"
#Sort the file and get only unique entries
sort -u combinedlist.txt  -o combinedlist.sorted
mv combinedlist.sorted combinedlist.txt


cd "$streamingServiceDomains"
echo "Current Dir: $PWD"
echo "Commit and push git changes"
#Commit and push git changes
sudo git add .
sudo git status
sudo git config --global user.email "dilipprasad87@gmail.com"
sudo git config --global user.name "Automated Script"
sudo git commit -m "Update Domains"
sudo git push
echo "Pushed latest domain list successfully"

echo "Sync with gravity sync"
sudo gravity-sync update

echo "end"
