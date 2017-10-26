#!/bin/sh

set -e

log() {
  echo "boostrap.sh: $@"
}

if [ ! -f ./malc ] ; then
  echo "Must run bootstrap.sh from the malc project directory."
  exit 1
fi

if [ -z "$MAL_IMPL" ] ; then
  log "\$MAL_IMPL is not set; using built-in default Mal interpreter"
  export MAL_IMPL="./mal-interpreter/ruby/run"
fi

log "Compiling mal-to-llvm.mal ..."
./malc -v -c mal-to-llvm.mal

log "Sanity check"
echo '(println "Sanity check" (+ 11 22))' > sanity-check.mal
unset MAL_IMPL
./malc -v -c sanity-check.mal
rm sanity-check.mal
result=$(./sanity-check)
rm sanity-check
if [ "$result" = "Sanity check 33" ] ; then
  log "Sanity check passed OK"
else
  log "Error in sanity check, result was '$result'"
  exit 2
fi

log "Done"
