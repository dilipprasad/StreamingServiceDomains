#Create Directory if missing
mkdir /home/pi/addtlPiholeAdlist
cd /home/pi/addtlPiholeAdlist

#Clone the repo
git clone https://github.com/dilipprasad/StreamingServiceDomains.git
cd StreamingServiceDomains/

#Pull if repo already exists
git pull

#Navigate to the directory
cd /home/pi/addtlPiholeAdlist/StreamingServiceDomains/services/

sudo sqlite3 "/etc/pihole/pihole-FTL.db"  "SELECT DISTINCT domain from queries WHERE domain like '%amazon%';"  >>  /home/pi/addtlPiholeAdlist/StreamingServiceDomains/services/primevideo

sort -o /home/pi/addtlPiholeAdlist/StreamingServiceDomains/services/primevideo -u /home/pi/addtlPiholeAdlist/StreamingServiceDomains/services/primevideo

cd /home/pi/addtlPiholeAdlist/StreamingServiceDomains

cat ./* > ../combinedlist.txt

cd ..

git add .

git commit -m "Update Domains"

git push