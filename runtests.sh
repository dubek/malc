#!/bin/bash

for testfile in tests/*.mal ; do
  echo "Testing $testfile"
  exe=$(dirname $testfile)/$(basename $testfile .mal)
  rm -f $exe
  ./malc $testfile
  if [[ $? != 0 ]] ; then
    echo "ERROR compiling $testfile"
    exit 1
  fi
  $exe > /tmp/testoutput
  if [[ $? != 0 ]] ; then
    echo "ERROR running $testfile"
    exit 1
  fi
  diff -u <(sed -ne 's/^;; *EXPECTED: *//p' $testfile) /tmp/testoutput
  if [[ $? != 0 ]] ; then
    echo "FAIL results of $testfile are not what expected"
    exit 1
  fi
  rm -f /tmp/testoutput
done
