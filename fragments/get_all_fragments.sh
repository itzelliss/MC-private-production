#!/bin/bash

echo "=== Starting CMSSW Fragment Generation for All Mass Benchmarks ==="

# ----------------------------------------------------
# Benchmark MH = 125
# 3.6, 4-21 {step 1}, 25
# ----------------------------------------------------

MASS_H=125
MASS_A_LIST=("3.6" $(seq 4 1 21) "25")
for MASS_A in "${MASS_A_LIST[@]}"; do
    bash get_fragments.sh "$MASS_H" "$MASS_A"
done

# ----------------------------------------------------
# Benchmark MH = 250
# 3.6, 5-25 {step 5}, 50
# ----------------------------------------------------

MASS_H=250
MASS_A_LIST=("3.6" $(seq 5 5 25) "50")
for MASS_A in "${MASS_A_LIST[@]}"; do
    bash get_fragments.sh "$MASS_H" "$MASS_A"
done

# ----------------------------------------------------
# Benchmark MH = 500
# 3.6, 5-30 {step 5}, 40, 50, 100
# ----------------------------------------------------

MASS_H=500
MASS_A_LIST=("3.6" $(seq 5 5 30) "40" "50" "100")
for MASS_A in "${MASS_A_LIST[@]}"; do
    bash get_fragments.sh "$MASS_H" "$MASS_A"
done

# ----------------------------------------------------
# Benchmark MH = 750
# 3.6, 10-30 {step 5}, 40-80 {step 10}, 150
# ----------------------------------------------------

MASS_H=750
MASS_A_LIST=("3.6" $(seq 10 5 30) $(seq 40 10 80) "150")
for MASS_A in "${MASS_A_LIST[@]}"; do
    bash get_fragments.sh "$MASS_H" "$MASS_A"
done

# ----------------------------------------------------
# Benchmark MH = 1000
# 3.6, 10-30 {step 5}, 40-60 {step 10}, 80, 100, 200
# ----------------------------------------------------

MASS_H=1000
MASS_A_LIST=("3.6" $(seq 10 5 30) $(seq 40 10 60) "80" "100" "200")
for MASS_A in "${MASS_A_LIST[@]}"; do
    bash get_fragments.sh "$MASS_H" "$MASS_A"
done

echo "=== All Fragments Generated and Copied to CMSSW! ==="
