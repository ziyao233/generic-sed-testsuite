#!/bin/sh
# Test execution less-common cases

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

#
# 'D' when pattern-space has no newline (act like 'd')
#
echo a | "$SED_PROG" 1D > out1 || fail=1
compare_ /dev/null out1 || fail=1

#
# s///e with a command that returns zero output
#
printf "\n" > exp2 || framework_failure_
echo "" | "$SED_PROG" '1etrue' > out2 || fail=1
compare_ exp2 out2 || fail=1


#
# plain 'e' with a command that returns non-delimted output
#
printf "a\n" > exp3 || framework_failure_
echo "printf a" | "$SED_PROG" '1e' > out3 || fail=1
compare_ exp3 out3 || fail=1

#
# plain 'e' with a command that returns delimted '\n' output
# (implementation note: the delimiter is first chomp'd)
printf "a\n" > exp4 || framework_failure_
echo "echo a" | "$SED_PROG" '1e' > out4 || fail=1
compare_ exp4 out4 || fail=1

#
# e with a command that returns delimted '\0' output
#
printf "b\0" > exp5 || framework_failure_
# This input file contains the shell command to be excuted:
printf 'cat exp5' > in5 || framework_failure_
"$SED_PROG" -z '1e' <in5 > out5 || fail=1
compare_ exp5 out5 || fail=1

if [ "$fail" ]; then
    od -tx1c exp5
    od -tx1c out5
fi

#
# 'P' command, with and without '\n' in the pattern space
#
echo a > in6 || framework_failure_
printf "%s\n" a b | "$SED_PROG" -n 'N;P' > out6 || fail=1
compare_ in6 out6 || fail=1

printf "%s\n" a | "$SED_PROG" -n 'P' > out7 || fail=1
compare_ in6 out7 || fail=1

#
# 'q' and other commands with big numbers (2**256 + 1, 2 ** 256 + 2)
#
big1=115792089237316195423570985008687907853269984665640564039457584007913129639937
big2=115792089237316195423570985008687907853269984665640564039457584007913129639938
printf '%s\n' a b >in7a || framework_failure_
"$SED_PROG" ${big1}q in7a >out7a1 || fail=1
compare_ in7a out7a1 || fail=1
"$SED_PROG" -n 1,${big1}p in7a >out7a2 || fail=1
compare_ in7a out7a2 || fail=1
"$SED_PROG" ${big1},${big2}d in7a >out7a3 || fail=1
compare_ in7a out7a3 || fail=1

#
# 'Q' with exit code
#
echo a > in7 || framework_failure_
returns_ 42 "$SED_PROG" '1Q42' in7 || fail=1

#
# 'r' without a filename (silently ignored)
#
echo c > in8 || framework_failure_
"$SED_PROG" 'rfoo.bar' in8 > out8 || fail=1
compare_ in8 out8 || fail=1

#
# 'W' without a filename (silently ignored)
#
echo d > in9 || framework_failure_
"$SED_PROG" 'Wfoo1' in9 > out9 || fail=1
compare_ in9 out9 || fail=1

#
# 'W', with and without '\n' in pattern space
#

# pattern-space with '\n', only 'a' should be written
printf "%s\n" a b > in10 || framework_failure_
echo a > a || framework_failure_
"$SED_PROG" 'N;Ww1.txt' in10 > out10 || fail=1
compare_ a w1.txt || fail=1
compare_ in10 out10 || fail=1

# pattern-space without '\n', entire pattern-space ('a') should be written
"$SED_PROG" 'Ww2.txt' a > out11 || fail=1
compare_ a out11 || fail=1
compare_ a w2.txt || fail=1


#
# 'T' command
#

# Unsuccessful substitute, 'T' jumps to 'skip'.
echo a | "$SED_PROG" -n 's/X/Y/ ; Tskip ; Q42 ; :skip' || fail=1

# Successful substitute, 'T' does not jumps to 'skip', sed exits with code 42.
echo a | returns_ 42 "$SED_PROG" -n 's/a/Y/ ; Tskip ; Q42 ; :skip' || fail=1


#
# 'F' command
#
echo a > in12 || framework_failure_
printf "%s\n" in12 a > exp12 || framework_failure_
"$SED_PROG" F in12 > out12 || fail=1
compare_ exp12 out12 || fail=1

# 'F' with multiple files
echo b > in13 || framework_failure_
echo c > in14 || framework_failure_
printf "%s\n" in12 a in13 b in14 c > exp14 || framework_failure_
"$SED_PROG" F in12 in13 in14 > out14 || fail=1
compare_ exp14 out14 || fail=1

# 'F' with stdin
printf "%s\n" - a > exp15 || framework_failure_
"$SED_PROG" F < in12 > out15 || fail=1
compare_ exp15 out15 || fail=1


Exit $fail
