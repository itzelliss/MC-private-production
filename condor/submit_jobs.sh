#!/bin/bash

#########################################
#Example usage: ./submit_jobs.sh 5

#########################################

#Arguments
MASS=$1

mkdir -p logs/M${MASS}

export MASS=M${MASS}

condor_submit submit.sub