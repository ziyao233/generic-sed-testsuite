#!/bin/sh
# Test -i/--inplace with backup suffixes

# Copyright (C) 2016-2024 Free Software Foundation, Inc.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
. "${srcdir=.}/init.sh"

# create multiple uniquely-named input files
# (the content does not matter for the first few)
touch a b c d e || framework_failure_
echo z > z || framework_failure_
printf "1\nz\n" >> exp-z || framework_failure_


# TODO: misleading error: the problem is the target filename of rename(2),
#       not the source filename.
cat <<\EOF >exp-err-rename || framework_failure_
sed: cannot rename ./e to ./e./e./e: No such file or directory
EOF


# simple backup suffix
"$SED_PROG" -i.bak = a || fail=1
test -e a.bak || fail=1

# backup suffix with explicit wildcard
"$SED_PROG" -i'*.foo' = b || fail=1
test -e b.foo || fail=1

"$SED_PROG" -i'==*==' = c || fail=1
test -e ==c== || fail=1

# abuse the suffix-name resolver
"$SED_PROG" -i'*=*' = d || fail=1
test -e d=d || fail=1

# This fails (as expected, with the backup name resolving './e./e./e').
# TODO: improve error message;
#       document why exit code is 4.
"$SED_PROG" -i'***' = ./e 2>err-rename && fail=1
# compare_ exp-err-rename err-rename || fail=1

# backup filename resolving to the same as the input filename,
# silently ignored, backup not created (in execute.c:closedown() ).
"$SED_PROG" -i'*' = z || fail=1
# ensure the input file was modified in-place
compare_ exp-z z || fail=1


Exit $fail
