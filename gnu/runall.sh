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
	comment-n.sh
	compile-tests.sh
	convert-number.sh
	dc.sh
	distrib.sh
	eval.sh
	execute-tests.sh
	in-place-hyphen.sh
	in-place-suffix-backup.sh
	inplace-hold.sh
	mac-mf.sh
	madding.sh
	mb-bad-delim.sh
	mb-charclass-non-utf8.sh)

if ! [ "$SED_PROG" ]; then
	echo "\$SED_PROG isn't set"
	exit 1
fi

logfile="${LOG_FILE:-/dev/null}"
truncate -s 0 "$logfile" 2>/dev/null

for tcase in "${tests[@]}"; do
	printf "$(basename $tcase)..."
	printf "\n==== starting %s ====\n" "$(basename $tcase)" >> "$logfile"
	if timeout -s INT -k 1 10 ./"$tcase" >> "$logfile" 2>>"$logfile"; then
		echo "[OK]"
	else
		if [ "$?" = 77 ]; then
			echo "[SKIP]"
		else
			echo "[FAIL]"
		fi
	fi
done
