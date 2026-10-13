#!/bin/bash

#########################################
#Example usage: ./get_fragments.sh 125 15
#########################################

#Argument
source ../paths.sh
if [ $# -ne 2 ]; then
    echo "Usage: ./get_fragments.sh MASS_H MASS_A"
    echo "Example: ./get_fragments.sh 125 15"
    exit 1
fi

MASS_H=$1
MASS_A=$2

#Handle baseline template point directly 
if [ "$MASS_H" = "125" ] && [ "$MASS_A" = "10" ]; then
    cp ggh01_M125_Toa01a01_M10_Tomumutautau_13p6TeV_fragment.py "${RELBASE}/CMSSW_14_0_21/src/Configuration/GenProduction/python"
    cp vbfh01_M125_Toa01a01_M10_Tomumutautau_13p6TeV_fragment.py "${RELBASE}/CMSSW_14_0_21/src/Configuration/GenProduction/python"
    cp wh01_M125_Toa01a01_M10_Tomumutautau_13p6TeV_fragment.py "${RELBASE}/CMSSW_14_0_21/src/Configuration/GenProduction/python"
    cp zh01_M125_Toa01a01_M10_Tomumutautau_13p6TeV_fragment.py "${RELBASE}/CMSSW_14_0_21/src/Configuration/GenProduction/python"
    exit 0
fi

cp ggh01_M125_Toa01a01_M10_Tomumutautau_13p6TeV_fragment.py ggh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py
cp vbfh01_M125_Toa01a01_M10_Tomumutautau_13p6TeV_fragment.py vbfh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py
cp wh01_M125_Toa01a01_M10_Tomumutautau_13p6TeV_fragment.py wh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py
cp zh01_M125_Toa01a01_M10_Tomumutautau_13p6TeV_fragment.py zh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py


sed -i "s|M10_|M${MASS_A}_|g; s|M125|M${MASS_H}|g" ggh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py
sed -i "s|M10_|M${MASS_A}_|g; s|M125|M${MASS_H}|g" vbfh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py
sed -i "s|M10_|M${MASS_A}_|g; s|M125|M${MASS_H}|g" wh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py
sed -i "s|M10_|M${MASS_A}_|g; s|M125|M${MASS_H}|g" zh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py

cp ggh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py "${RELBASE}/CMSSW_14_0_21/src/Configuration/GenProduction/python"
cp vbfh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py "${RELBASE}/CMSSW_14_0_21/src/Configuration/GenProduction/python"
cp wh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py "${RELBASE}/CMSSW_14_0_21/src/Configuration/GenProduction/python"
cp zh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_13p6TeV_fragment.py "${RELBASE}/CMSSW_14_0_21/src/Configuration/GenProduction/python"

