#!/bin/sh

set -e

cd perf

rm -rf tmp
mkdir -p tmp

echo "Compiling perf1.mal ..."
../malc -l -c perf1.mal -o tmp/perf1
echo "Running perf1 ..."
tmp/perf1
echo ""

echo "Compiling perf2.mal ..."
../malc -l -c perf2.mal -o tmp/perf2
echo "Running perf2 ..."
tmp/perf2
echo ""

echo "Compiling perf3.mal ..."
../malc -l -c perf3.mal -o tmp/perf3
echo "Running perf3 ..."
tmp/perf3
echo ""

rm -rf tmp
