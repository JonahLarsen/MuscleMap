#Base folder containing raw DICOMS
BASE='/Users/labadmin/Docuemnts/MuscleMap/MRI_Scans/Johnson_SVO'

OUT='/Users/labadmin...'

mkdir -p "$OUT"

echo "Starting conversion..."

#Loop through each subject folder (e,g,, Johnson_Ball_41)
for SUBJECT in "$BASE"; do 
