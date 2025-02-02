#!/usr/bin/env bash

tests=(
	8bit.sh
	8to7.sh
	badenc.sh
	binary.sh
	bsd.sh
	bug32271-1.sh
	cmd-0r.sh
	cmd-R.sh
	cmd-l.sh
	command-endings.sh
	comment-n.sh)

if ! [ "$SED_PROG" ]; then
	echo "\$SED_PROG isn't set"
	exit 1
fi

for tcase in "${tests[@]}"; do
	printf "$(basename $tcase)..."
	if ./"$tcase" > /dev/null 2>/dev/null; then
		echo "[OK]"
	else
		echo "[FAIL]"
	fi
done
