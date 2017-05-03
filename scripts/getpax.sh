#!/bin/sh

RL=256k

[ -d pax_patches ] && cd pax_patches

if ! [ -z "$1" ]; then
	wget -nc "https://grsecurity.net/~paxguy1/$1"
	exit
fi


wget -c -O - "https://grsecurity.net/~paxguy1" |
	perl -p -e 's/href=/\n/g' |
	grep 'pax-linux-.*\.patch' |
	sed -e 's/"//g' |
	sed -e 's/>.*$//' |
	tee paxlog.txt |
	tail -n 1 |
while read URL
do
	echo ${URL}
	wget --limit-rate=$RL -nc "https://grsecurity.net/~paxguy1/${URL}"
done
