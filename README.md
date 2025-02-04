# generic-sed-testsuite

A collection of tests for sed command.

I've worked on some sed and awk bugs of busybox and found its testsuite is too
small and it's quite hard to make sure a change doesn't break anything. Thus
there's the collection.

## Contained tests

- [GNU sed](https://www.gnu.org/software/sed/manual/sed.html) (PARTIAL)

## How to Run

Generally, enter a directory and run `./runall.sh`. There're some options
available through environment variables:

- `$SED_PROG`: Sed program to test.
- `$LOG_FILE`: File to write testing logs (mostly, information of failures)
- `$STRICT_ERROR_CHECK`: Don't skip tests for detection of invalid usages.
  busybox sed does a bad job in finding out invalid commands, etc.

### Notes

- GNU suite contains an enormous number of charset-related tests and there're
  some tests depend on specific locale. Compile `gnu/get-mb-cur-max.c` and put
  the executable at `gnu/get-mb-cur-max` to get them running.
