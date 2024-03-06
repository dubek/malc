#!/bin/bash

# Compile the steps of the mal implementation of the mal interpreter using
# malc, and then run the tests of these steps.

set -e
MALC="$PWD/malc"
if [ ! -d external/mal ] ; then
  mkdir -p external
  git clone --depth 500 https://github.com/kanaka/mal.git external/mal
fi
cd external/mal/impls/mal

# Checkout the last mal version in which the self-hosted implementation (mal
# interpreter implemented in mal) doesn't use the `eval` function.  The
# following mal commit c1963a43aab1fd222fa7155ea3d5bf728bcc4a07 simplies the
# implementation a bit by using `eval`.  Since malc doesn't support `eval`, we
# can't use it.
git checkout 770aae175f90237055bb944249e990def8aefc76

# Note that mal doesn't have a step5 implementation
STEPS="
step0_repl
step1_read_print
step2_eval
step3_env
step4_if_fn_do
step6_file
step7_quote
step8_macros
step9_try
stepA_mal
"

for step in $STEPS ; do
  $MALC -v -c ${step}.mal
  python3 ../../runtest.py --deferrable --optional ../tests/${step}.mal -- ./${step}
done

echo ""
echo "Performance tests for malc-mal:"
echo "./stepA_mal ../tests/perf1.mal"
./stepA_mal ../tests/perf1.mal
echo "./stepA_mal ../tests/perf2.mal"
./stepA_mal ../tests/perf2.mal
echo "./stepA_mal ../tests/perf3.mal"
./stepA_mal ../tests/perf3.mal

echo ""
echo "Mal tests passed OK"
