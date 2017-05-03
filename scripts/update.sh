#!/bin/sh

autocommit=true
autopush=true
dopush=false

commit_to_git() {
	if $autocommit; then
		git commit -s -m"Add $i"
		dopush=true
	else
		echo "Skip commit of $i"
	fi
}

push_repo() {
	remote=`git remote -v | grep 'git@github.com:kdave.*push' | awk '{print $1}'`
	ref=`git symbolic-ref HEAD 2> /dev/null` || exit 1
	branch=${ref#refs/heads/}
	if $autopush; then
		git push $remote $branch
	else
		echo "Skip pushing $branch to $remote"
	fi
}

add_new() {
	for i in $(git status --porcelain); do
		case "$i" in
			A)
				echo "Error: index not clean, check git status"
				exit 1
				;;
			grsecurity_patches/*.patch)
				echo "Grsec patch: $i"
				git add "$i" "$i.sig"
				commit_to_git "$i"
				;;
			pax_patches/*.patch)
				echo "PaX patch: $i"
				git add "$i"
				commit_to_git "$i"
				;;
			*) #echo "IGNORED: $i"
				: ;;
		esac
	done
}

###############

./getgrsec.sh
./getpax.sh
add_new

if $dopush; then
	push_repo
else
	echo "Nothing new to push"
fi

echo
for p in $(tail pax_patches/paxlog.txt); do
	lastpax=$p
	[ -f pax_patches/$p ] && continue
echo "PaX patch not in git:   $p"
done

echo "Last PaX:               $p"
