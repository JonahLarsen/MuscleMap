#!/bin/bash

# Base folder containing raw DICOMs
BASE="/Users/labadmin/Documents/MuscleMap/bball_raw_dcm_dataset"

# Output directory for NIfTI and JSON
OUT="/Users/labadmin/Documents/MuscleMap/bball_raw_dataset"

mkdir -p "$OUT"

echo "Starting conversion..."

# Loop through each subject folder (e.g., Johnson_Ball_41)
for SUBJECT in "$BASE"/Johnson*; do
    [ -d "$SUBJECT" ] || continue
    SUBNAME=$(basename "$SUBJECT")

    echo "📁 Subject: $SUBNAME"

    # Output folder for this subject (flat file list)
    SUBJECT_OUT="$OUT/sub-$SUBNAME"
    mkdir -p "$SUBJECT_OUT"

    # Locate the baseline folder
    BASELINE_DIR=$(find "$SUBJECT" -maxdepth 1 -type d -name "*Baseline*")

    if [ -z "$BASELINE_DIR" ]; then
        echo "  ⚠️ Baseline folder NOT found for $SUBNAME"
        continue
    fi

    echo "  ✅ Baseline folder: $BASELINE_DIR"

    # Loop through all series folders inside the baseline
    for SERIES in "$BASELINE_DIR"/*; do
        [ -d "$SERIES" ] || continue
        SERNAME=$(basename "$SERIES")

        echo "    ➜ Converting series: $SERNAME"

        # Output directly into the subject folder (no subdirectories)
        dcm2niix -z y -f %p -o "$SUBJECT_OUT" "$SERIES"
    done
done

echo "✅ Finished converting all subjects."
