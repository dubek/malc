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

log "Done"
