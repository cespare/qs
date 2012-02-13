#!/bin/bash

# Initial version. Probably will rewrite in Ruby because I want to parse the return json (to get the url and
# put it in the clipboard with xclip) and because I want to put the image in an account (so I need to use
# OAuth).

TEMP='/tmp/qs-screenshot.png'

fail() {
  echo "Error: $1."
  exit 1
}

[[ `uname -o` = "GNU/Linux" ]] || fail "Linux-only"
hash scrot 2>&- || fail "requires scrot (sudo apt-get install scrot)"
hash xclip 2>&- || fail "requires xclip (sudo apt-get install xclip)"
hash curl 2>&- || fail "requires curl (sudo apt-get install curl)"
hash xdg-open 2>&- || fail "requires xdg-open (sudo apt-get install xdg-utils)"
hash ruby 2>&- || fail "requires ruby (sudo apt-get install ruby)"
[[ -z $IMGUR_API_KEY ]] && fail '$IMGUR_API_KEY needs to be set (to your Imgur developer API key).'


scrot -bs $TEMP
xdg-open $TEMP

read -p "Upload this screenshot to imgur? [yN] " -n 1
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && exit 1
url=$(curl -F "image=@$TEMP" -F "key=$IMGUR_API_KEY" http://api.imgur.com/2/upload.json | ruby -pe '$_.match /"original":"([^"]*)",/; $_ = $1.gsub("\\", "")')
echo -n $url | xclip
echo "Image uploaded to imgur (this url is in your clipboard as well):"
echo $url
