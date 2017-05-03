#!/bin/sh

RL=256k

[ -d grsecurity_patches ] && cd grsecurity_patches

wget -c -O - "https://grsecurity.net/test.php" |
	grep grsecurity- |
	perl -p -e 's/href=/\n/g' |
	awk '/\.patch/ {print $1}' |
	egrep -v "\.sig|iptables" |
	grep -v "restrict" |
	sed -e 's/"//g' |
	sed -e 's/>.*$//' |
while read URL
do
	echo ${URL}
	wget --limit-rate=$RL -nc "http://grsecurity.net/${URL}"
	wget --limit-rate=$RL -nc "http://grsecurity.net/${URL}".sig

	gpg --verify ${URL}.sig ${URL}
done
#mv changelog-test.txt changelog-test.txt.old
#wget -c http://grsecurity.net/changelog-test.txt
