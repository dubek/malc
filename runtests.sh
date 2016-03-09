#!/bin/bash

test_one() {
  testfile="$1"
  echo -n "Compiling $testfile ... "
  rm -rf tests/tmp
  mkdir -p tests/tmp
  exe=tests/tmp/$(basename $testfile .mal)
  ./malc -v -l -c $testfile -o $exe > tests/tmp/malc.log 2>&1
  if [[ $? != 0 ]] ; then
    echo "ERROR compiling $testfile; log is in tests/tmp/malc.log"
    return 1
  fi
  echo -n "Running ... "
  $exe > tests/tmp/test_output
  if [[ $? != 0 ]] ; then
    echo "ERROR running $testfile: test output:"
    cat tests/tmp/test_output
    return 1
  fi
  sed -ne 's/^;; *EXPECTED: *//p' $testfile > tests/tmp/expected_output
  diff -q tests/tmp/expected_output tests/tmp/test_output > /dev/null
  if [[ $? != 0 ]] ; then
    echo "FAIL"
    diff -u --label expected_output tests/tmp/expected_output --label test_output tests/tmp/test_output
    return 1
  fi
  rm -rf tests/tmp
  echo "PASS"
  return 0
}

if [ -z "$1" ] ; then
  alltests="tests/*.mal"
else
  alltests=($1)
fi

tests=0
failures=0
for testfile in $alltests ; do
  tests=$((tests+1))
  test_one $testfile
  failures=$((failures+$?))
done

if [ $failures = 0 ] ; then
  echo "Success, $tests tests OK"
else
  echo "Done, $failures tests failed/errored (out of $tests tests)"
  exit 1
fi
