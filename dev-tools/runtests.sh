#!/bin/bash
#
# Test wrapper for Octave tests.
#
# This exists because Octave's runtests() does not return an error status, so
# you can't detect within octave whether your tests have failed.
#
# This must be run from the root of the repo.

test_dir="$1"

tempfile=$(mktemp /tmp/octave-chrono-tests-XXXXXXXX)
if [[ "$test_dir" == "" ]]; then
  octave --path="$PWD/inst" --eval="runtests" &>$tempfile
else
  octave --path="$PWD/inst" --eval="addpath('$test_dir'); runtests $test_dir" &>$tempfile
fi

cat $tempfile

if grep FAIL $tempfile &>/dev/null; then
  echo Some tests FAILED!
  exit 1
else
  echo All tests passed.
  exit 0
fi
