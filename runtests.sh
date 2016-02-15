#!/bin/bash

test_one() {
  testfile="$1"
  echo -n "Compiling $testfile ... "
  rm -rf tests/tmp
  mkdir -p tests/tmp
  exe=tests/tmp/$(basename $testfile .mal)
  ./malc -l $testfile $exe > tests/tmp/malc.log
  if [[ $? != 0 ]] ; then
    echo "ERROR compiling $testfile"
    exit 1
  fi
  echo -n "Running ... "
  $exe > tests/tmp/test_output
  if [[ $? != 0 ]] ; then
    echo "ERROR running $testfile: test output:"
    cat tests/tmp/test_output
    exit 1
  fi
  sed -ne 's/^;; *EXPECTED: *//p' $testfile > tests/tmp/expected_output
  diff -q tests/tmp/expected_output tests/tmp/test_output > /dev/null
  if [[ $? != 0 ]] ; then
    echo "FAIL"
    diff -u --label expected_output tests/tmp/expected_output --label test_output tests/tmp/test_output
    exit 1
  fi
  rm -rf tests/tmp
  echo "PASS"
}

if [ -z "$1" ] ; then
  for testfile in tests/*.mal ; do
    test_one $testfile
  done
else
  test_one $1
fi

echo "Success"
