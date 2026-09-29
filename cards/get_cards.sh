#!/bin/bash

#########################################
#This script generates the cards for a given mass (MH, MA).
#It copies cards from MH125/MA10 directory and renames it to the desired mass. It also modifies the customizecards.dat and proc_card.dat files accordingly. 
#Right now copying files from MH125 for heavier higgs too (might change in future)
#Example usage: ./get_cards.sh 125 15
#############################################

if [ $# -ne 2 ]; then
    echo "Usage: ./get_cards.sh MASS_H MASS_A"
    echo "Example: ./get_cards.sh 125 15"
    exit 1
fi

#Arguments
MASS_H=$1
MASS_A=$2

mkdir -p MH${MASS_H}
cp -r MH125/MA10 MH${MASS_H}/MA${MASS_A}

cd MH${MASS_H}/MA${MASS_A}

for f in *M125*M10*; do
    new="${f/M125/M${MASS_H}}"
    new="${new/M10_/M${MASS_A}_}"
    mv "$f" "$new"
done

#Modify customizecards.dat
cat > ggh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_customizecards.dat << EOF
set param_card mass 25 ${MASS_H}
set param_card mass 36 $MASS_A
EOF

cat > wh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_customizecards.dat << EOF
set param_card mass 25 ${MASS_H}
set param_card mass 36 $MASS_A
EOF

cat > zh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_customizecards.dat << EOF
set param_card mass 25 ${MASS_H}
set param_card mass 36 $MASS_A
EOF

cat > vbfh01_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau_customizecards.dat << EOF
set param_card mass 25 ${MASS_H}
set param_card mass 36 $MASS_A
EOF

#Modify the output directory for *proc_card.dat
sed -i "s/M125/M${MASS_H}/; s/M10_/M${MASS_A}_/" *_proc_card.dat

#Ran succesfully
echo "Cards generated for MH${MASS_H}, MA${MASS_A}"
