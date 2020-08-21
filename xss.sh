#!/bin/bash
filename=$1
while read line; do

# Grep URLs
cat $1 | waybackurls >> 1
cat $1 | gau >> 1
cat $1 | hakrawler -depth 50 -plain >> 1
gospider -S $1  -c 20 -d 0 --other-source  >> 2

# Clean the URLs
awk -F// '{print $2}' 2 | cut -d "'" -f 1 >> 1
sort -u 1 >> 3.txt
rm 1
rm 2

# Brutforce Parameter
cat 3.txt | while read url;do hide=$(curl -s -L $url | egrep -o "('|\")hidden('|\") name=('|\")[a-z_0-9-]*"|sed -e 's/\"hidden\"/[Found]/g' -e 's,'name=\"','"$url"/?',g'); echo -e "\033[32m$url""\033[34m\n$hide";done | grep Found | awk '{print $NF}' >> 4.txt
sed -i'.bak' 's/$/=/' 4.txt

# Merge files
cat 3.txt >> urls.txt
cat 4.txt >> urls.txt
rm 3.txt
rm 4.txt

# Run xss Scanner
cat urls.txt | grep '=' | qsreplace hack\" -a | while read url;do target=$(curl -s -l $url | egrep -o '(hack"|hack\\")'); echo -e "Target:\e[1;33m $url\e[0m" "$target" "\n-------"; done | sed 's/hack"/[Xss Possible] Reflection Found/g'

done < $filename
