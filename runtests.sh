#!/bin/bash

test_one() {
  testfile="$1"
  echo "Testing $testfile"
  rm -rf tests/tmp
  mkdir -p tests/tmp
  exe=tests/tmp/$(basename $testfile .mal)
  ./malc $testfile $exe
  if [[ $? != 0 ]] ; then
    echo "ERROR compiling $testfile"
    exit 1
  fi
  $exe > tests/tmp/test_output
  if [[ $? != 0 ]] ; then
    echo "ERROR running $testfile: test output:"
    cat tests/tmp/test_output
    exit 1
  fi
  sed -ne 's/^;; *EXPECTED: *//p' $testfile > tests/tmp/expected_output
  diff -u tests/tmp/expected_output tests/tmp/test_output
  if [[ $? != 0 ]] ; then
    echo "FAIL results of $testfile are not what expected"
    exit 1
  fi
  rm -rf tests/tmp
  echo "  ... PASS"
}

if [ -z "$1" ] ; then
  for testfile in tests/*.mal ; do
    time test_one $testfile
  done
else
  time test_one $1
fi

echo "Success"
