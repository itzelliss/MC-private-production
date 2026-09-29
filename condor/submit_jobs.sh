#!/bin/bash

#########################################
#Example usage: ./submit_jobs.sh 125 15 ggh01

#########################################
source ../paths.sh

if [ $# -ne 3 ]; then
    echo "Usage: ./submit_jobs.sh MASS_H MASS_A SAMPLETAG"
    echo "Example: ./submit_jobs.sh 125 15 ggh01"
    echo "SAMPLETAG must be one of: ggh01, vbfh01, wh01, zh01"
    exit 1
fi

#Arguments
MASS_H=$1
MASS_A=$2
SAMPLETAG=$3

if [[ "$SAMPLETAG" != "ggh01" && \
      "$SAMPLETAG" != "vbfh01" && \
      "$SAMPLETAG" != "wh01" && \
      "$SAMPLETAG" != "zh01" ]]; then
    echo "Error: invalid SAMPLETAG: $SAMPLETAG"
    echo "SAMPLETAG must be one of: ggh01, vbfh01, wh01, zh01"
    exit 1
fi

export MASS_H=M${MASS_H}
export MASS_A=M${MASS_A}
export SAMPLETAG="$SAMPLETAG"

echo "Submitting job:"
echo "  MASS_H                = ${MASS_H}"
echo "  MASS_A                = ${MASS_A}"
echo "  SAMPLETAG             = ${SAMPLETAG}"
echo "  RELBASE               = ${RELBASE}"
echo "  OUTBASE               = ${OUTBASE}"
echo "  MC_PRIVATE_PRODUCTION = ${MC_PRIVATE_PRODUCTION}"

condor_submit submit.sub
