#!/bin/bash

# Create a master log file
VAL_LOG="validation_summary.log"
echo "=== GRIDPACK VALIDATION RUN: $(date) ===" > "$VAL_LOG"
echo "------------------------------------------------" >> "$VAL_LOG"

# Loop over all gridpacks in the current directory
for gp in *.tar.xz; do
    # Skip if no matching files are found
    [ -e "$gp" ] || continue
    
    # Get the base name without extensions
    gp_name=$(basename "$gp" .tar.xz)
    echo "Processing: $gp_name..."
    echo "Processing: $gp_name" >> "$VAL_LOG"
    
    # 1. Create a clean sandbox directory and move into it
    mkdir -p "test_$gp_name"
    cd "test_$gp_name" || exit
    
    # 2. Extract the gridpack
    tar -xf "../$gp" 2>> "../$VAL_LOG"
    
    # 3. Read the internal physical masses from the param_card
    # Check standard paths and fall back to a dynamic search if needed
    PARAM_CARD="./process/madevent/Cards/param_card.dat"
    if [ ! -f "$PARAM_CARD" ]; then
        PARAM_CARD=$(find . -name "param_card.dat" | head -n 1)
    fi

    if [ -f "$PARAM_CARD" ]; then
        # Extracts mass values matching PDG IDs 25 (h) and 36 (a)
        # Adjust '25' or '36' below if your custom model uses different PDG codes!
        ACTUAL_MH=$(grep -i -E "^\s*25\s" "$PARAM_CARD" | awk '{print $2}')
        ACTUAL_MA=$(grep -i -E "^\s*36\s" "$PARAM_CARD" | awk '{print $2}')
        
        echo "   -> Internal MH compiled: ${ACTUAL_MH:-Unknown}"
        echo "   -> Internal MA compiled: ${ACTUAL_MA:-Unknown}"
        echo "   [MASS DETAILS] Internal MH=$ACTUAL_MH, MA=$ACTUAL_MA" >> "../$VAL_LOG"
    else
        echo "   -> [WARN] param_card.dat not found. Could not verify internal masses."
        echo "   [WARN] Could not locate internal param_card.dat" >> "../$VAL_LOG"
    fi
    
    # 4. Check if runcmsgrid.sh actually exists (catches empty/broken builds)
    if [ ! -f "./runcmsgrid.sh" ]; then
        echo "   -> [FAIL] runcmsgrid.sh missing!"
        echo "   [FAIL] runcmsgrid.sh missing (Gridpack build was broken)" >> "../$VAL_LOG"
        echo "------------------------------------------------" >> "../$VAL_LOG"
        cd .. && rm -rf "test_$gp_name"
        continue
    fi
    
    # 5. Attempt to run a test generation of 10 events
    echo "   -> Running 10 test events..."
    ./runcmsgrid.sh 10 1234 1 > test_run.log 2>&1
    
    # 6. Check script exit code AND verification files to ensure physics run completed
    if [ $? -eq 0 ] && { [ -f "cmsgrid_final.lhe" ] || [ -f "events.lhe" ]; }; then
        echo "   -> [SUCCESS] Passed event generation test!"
        echo "   [SUCCESS] Passed event generation test" >> "../$VAL_LOG"
        
        # Clean up successful test directories to save cluster disk space
        cd .. && rm -rf "test_$gp_name"
    else
        echo "   -> [FAIL] Event generation crashed!"
        echo "   [FAIL] Event generation failed. Keeping directory for debugging." >> "../$VAL_LOG"
        cd ..
    fi
    
    echo "------------------------------------------------" >> "$VAL_LOG"
    echo "Done with $gp_name"
    echo "----------------------------------------"
done

echo "=== VALIDATION COMPLETE ==="
echo "Check '$VAL_LOG' to verify your physical parameters and test results."
