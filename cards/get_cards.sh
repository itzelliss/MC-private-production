#!/bin/bash

#########################################
#This script generates the cards for a given mass. 
#It copies the M10 directory and renames it to the desired mass. It also modifies the customizecards.dat and proc_card.dat files accordingly. 

#Example usage: ./get_cards.sh 10 125
#############################################


#Arguments
MASS=$1
HMASS=$2

cd H${HMASS}

cp -r M10 M${MASS}

cd M${MASS}

for f in *M10*; do mv "$f" "${f/M10/M${MASS}}"; done

#Modify customizecards.dat
cat > ggh01_M${HMASS}_Toa01a01_M${MASS}_Tomumutautau_customizecards.dat << EOF
set param_card mass 25 $HMASS
set param_card mass 36 $MASS
EOF

#Modify the output directory for *proc_card.dat
sed -i "s/M10/M${MASS}/" ggh01_M${HMASS}_Toa01a01_M${MASS}_Tomumutautau_proc_card.dat

#Ran succesfully
echo "Cards generated for H${HMASS} -> M${MASS}"