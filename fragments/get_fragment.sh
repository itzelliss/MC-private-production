#!/bin/bash

#########################################
#Example usage: ./get_fragments.sh 125 15
#########################################

#Arguments
MASS_H=$1
MASS_A=$2
CMSSW=/afs/cern.ch/work/s/sbaradia/public/PseudoscalarSearch_Run3/CMSSW/CMSSW_14_0_21/src/Configuration/GenProduction/python

cp ggh01_M125_Toa01a01_M10_Tomumutautau_13p6TeV_fragment.py ggh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py
cp vbfh01_M125_Toa01a01_M10_Tomumutautau_13p6TeV_fragment.py vbfh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py
cp wh01_M125_Toa01a01_M10_Tomumutautau_13p6TeV_fragment.py wh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py
cp zh01_M125_Toa01a01_M10_Tomumutautau_13p6TeV_fragment.py zh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py


sed -i "s|M10_|M${MASS_A_}|g; s|M125|M${MASS_H}|g" ggh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py
sed -i "s|M10_|M${MASS_A_}|g; s|M125|M${MASS_H}|g" vbfh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py
sed -i "s|M10_|M${MASS_A_}|g; s|M125|M${MASS_H}|g" wh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py
sed -i "s|M10_|M${MASS_A_}|g; s|M125|M${MASS_H}|g" zh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py

cp ggh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py "$CMSSW/"
cp vbfh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py "$CMSSW/"
cp wh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py "$CMSSW/"
cp zh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py "$CMSSW/"
