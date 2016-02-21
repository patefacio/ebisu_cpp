#!/bin/bash
DART=$(readlink -f `which dart`)
DARTPATH=$(dirname $DART)
ANALYZER=$DARTPATH/dartanalyzer
$ANALYZER codegen/**.dart lib/**.dart test/**.dart

