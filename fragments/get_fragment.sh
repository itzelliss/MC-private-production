#!/bin/bash

#########################################
#Example usage: ./get_fragments.sh 5

#########################################

#Arguments
MASS=$1

cp ggh01_M125_Toa01a01_M10_Tomumutautau_13p6TeV_fragment.py ggh01_M125_Toa01a01_M${MASS}_Tomumutautau_13p6TeV_fragment.py 

sed -i "s|M10|M${MASS}|g" ggh01_M125_Toa01a01_M${MASS}_Tomumutautau_13p6TeV_fragment.py 

cp ggh01_M125_Toa01a01_M${MASS}_Tomumutautau_13p6TeV_fragment.py ../../CMSSW_14_0_21/src/Configuration/GenProduction/python/