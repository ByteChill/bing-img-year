#!/bin/bash

# change directory to where the script resides.
BASEDIR=$(dirname $0)
cd "$BASEDIR"

bing="http://www.bing.com"
for i in {0..7}
do
    # the idx parameter determines where to start from. 0 is the current day,
    xmlURL="http://www.bing.com/HPImageArchive.aspx?format=xml&idx=${i}&n=1&mkt=zh-CN" 

    # Valid options: "_1024x768" "_1280x720" "_1366x768" "_1920x1200" "_1920x1080" "_UHD"
    picRes="_UHD"   

    # The file extension for the Bing pic
    picExt=".jpg"   

    # the XML data retrieved from xmlURL, form the fully qualified
    # URL for the pic of the day, and store it in $picURL
    data=$(curl -s $xmlURL) 

    if [ -n "$data" ]
    then
    picURL=$(cut -d '>' -f13 <<< "$data")
    picURL=$(cut -d '<' -f 1 <<< "$picURL")
    picURL=$bing$picURL$picRes$picExt   

    date=$(cut -d '>' -f9 <<< "$data")
    date=$(cut -d '<' -f1 <<< "$date")  
    year=${date:0:4}  
    month=${date:4:2}
    mkdir -p pic/${year}/${month}

    name=$(cut -d '>' -f15 <<< "$data")
    name=$(cut -d '<' -f 1 <<< "$name")
    name=$(cut -d '(' -f 1 <<< "$name") 

    len=${#name} 
       
    file="pic/${year}/${month}/$date - ${name:0:len-1}$picExt"

    if [ -f "$file" ]
    then
        filesize=$(wc -c < "$file")
        filesize=$(($filesize)) # parseInt
        actualsize="$(curl -s -L -I $picURL | awk -v IGNORECASE=1 '/^Content-Length/ { print $2 }')"
        actualsize=$(echo $actualsize | sed "s/$(printf '\r')\$//") # remove carriage return on macOS   

        if [ "$filesize" -eq "$actualsize" ]
        then
            echo "$(date) - '$file' already downloaded"
        else
            curl -s "$picURL" > "$file"
            echo "$(date) - image saved as $file"
        fi
    else
        curl -s "$picURL" > "$file"
        echo "$(date) - image saved as $file"
    fi  

    else
    echo "$(date) - connection failed"
    fi
done
