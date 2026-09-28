#!/bin/bash

#########################################
#Example usage: ./submit_jobs.sh 125 15 ggh01

#########################################

#Arguments
MASS_H=$1
MASS_A=$2
SAMPLETAG=$3

export MASS_H=M${MASS_H}
export MASS_A=M${MASS_A}
export SAMPLETAG="$SAMPLETAG"

condor_submit submit.sub
