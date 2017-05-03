#!/bin/sh

verbose=false

good=0
bad=0
nosig=0
nokey=0
other=0

say() {
	if $verbose; then
		echo "$@"
	fi
}

verify_sig() {
	if [ -z "$1" ]; then
		echo "verify: no file given"
		other=$(($other+1))
		return 1
	fi

	if ! [ -f "$1" ]; then
		echo "verify: no such file: $1"
		other=$(($other+1))
		return 1
	fi

	if ! [ -f "$1".sig ]; then
		say "verify: $1: no signature"
		nosig=$(($nosig+1))
		return 2
	fi

	gpgout=$(gpg --verify "$1".sig "$1" 2>&1)
	if echo "$gpgout" | grep -q 'Good signature from.*spender'; then
		say "verify: $i: good"
		good=$(($good+1))
	elif echo "$gpgout" | grep -q 'check signature: No public key'; then
		say "verify: $i: no key"
		nokey=$(($nokey+1))
	else
		echo "verify: $1: unknown output"
		echo "$gpgout"
	fi
}

if ! [ -z "$1" ]; then
	while ! [ -z "$1" ]; do
		verify_sig "$1"
		shift
	done
	exit
fi

for i in grsecurity_patches/*.patch; do
	verify_sig "$i"
done

echo "Results:"
echo "good:     $good"
echo "bad:      $bad"
echo "no .sig:  $nosig"
echo "no key:   $nokey"
echo "other:    $other"
