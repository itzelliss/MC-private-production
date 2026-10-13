#!/bin/bash                                                                                                                                                          

PROD_MODES="ggh01 vbfh01 wh01 zh01"

for MASS_H in 125 250 500 750 1000; do

    if [ "$MASS_H" -eq 125 ]; then
	MASS_A_LIST=("3.6" $(seq 4 1 21) "25")
    elif [ "$MASS_H" -eq 250 ]; then
        MASS_A_LIST=("3.6" $(seq 5 5 25) "50")
    elif [ "$MASS_H" -eq 500 ]; then
        MASS_A_LIST=("3.6" $(seq 5 5 30) "40" "50" "100")
    elif [ "$MASS_H" -eq 750 ]; then
        MASS_A_LIST=("3.6" $(seq 10 5 30) $(seq 40 10 80) "150")
    elif [ "$MASS_H" -eq 1000 ]; then
        MASS_A_LIST=("3.6" $(seq 10 5 30) $(seq 40 10 60) "80" "100" "200")
    fi

    for MASS_A in "${MASS_A_LIST[@]}"; do

        CARDS=/afs/cern.ch/work/s/sbaradia/public/PseudoscalarSearch_Run3/MCProduction/MC-private-production/cards/MH"${MASS_H}"/MA"${MASS_A}"
        if [ ! -d "$CARDS" ]; then
            echo "Skipping: No cards found at $CARDS"
            continue
        fi

        for PROD in $PROD_MODES; do

            ./submit_condor_gridpack_generation.sh \
              "${PROD}_M${MASS_H}_Toa01a01_M${MASS_A}_Tomumutautau" \
              "$CARDS" \
              "$PWD" \
              el8_amd64_gcc12 \
              CMSSW_14_0_21

        done
    done
done
