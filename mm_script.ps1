# Load SCT environment (if needed)
# Equivalent of: source /Users/labadmin/.bashrc
# Adjust as necessary for your Windows installation

.\venv\Scripts\Activate.ps1

# Setup data and output paths
$data_path = Join-Path $HOME "Documents\MuscleMap\Bach_raw_dataset"
$output_path = Join-Path $HOME "Documents\MuscleMap\Bach_dataset"

Write-Host "Data path is $data_path"
Write-Host "Output path is $output_path"

# Create dataset folders in output path
New-Item -ItemType Directory -Force -Path "$output_path\sourcedata" | Out-Null

# List of subject IDs
$ids = @("009")

foreach ($id in $ids) {

    Write-Host "Running $id"

    ### Organize data ###

    # Create BIDS-like folders
    $subjectDir = "$output_path\sourcedata\Johnson_Bach_Bach$id"
    $sessionDir = "$subjectDir\ses-T1w"

    New-Item -ItemType Directory -Force -Path $subjectDir | Out-Null
    New-Item -ItemType Directory -Force -Path $sessionDir | Out-Null

    # Find muscle images
    $t1w_iso     = Get-ChildItem "$data_path\Johnson_Bach_Bach$id\fl3d_vibe_iso_W_*.nii.gz" | Select-Object -ExpandProperty FullName
    $t1w_neg200  = Get-ChildItem "$data_path\Johnson_Bach_Bach$id\fl3d_vibe_200_W_*.nii.gz" | Select-Object -ExpandProperty FullName
    $t1w_neg400  = Get-ChildItem "$data_path\Johnson_Bach_Bach$id\fl3d_vibe_400_W_*.nii.gz" | Select-Object -ExpandProperty FullName
    $t1w_neg600  = Get-ChildItem "$data_path\Johnson_Bach_Bach$id\fl3d_vibe_600_W_*.nii.gz" | Select-Object -ExpandProperty FullName
    $t1w_neg800  = Get-ChildItem "$data_path\Johnson_Bach_Bach$id\fl3d_vibe_800_W_*.nii.gz" | Select-Object -ExpandProperty FullName
    $t1w_neg1000 = Get-ChildItem "$data_path\Johnson_Bach_Bach$id\fl3d_vibe_1000_W_*.nii.gz" | Select-Object -ExpandProperty FullName

    # Copy JSON file
    $t1w_json = Get-ChildItem "$data_path\Johnson_Bach_Bach$id\fl3d_vibe_iso_W_*.json" | Select-Object -First 1

    Copy-Item `
        $t1w_json.FullName `
        "$sessionDir\Johnson_Bach_Bach${id}_ses-T1w.json"

    # Stitch muscle images together
    & sct_image `
        -i $t1w_iso $t1w_neg200 $t1w_neg400 $t1w_neg600 $t1w_neg800 $t1w_neg1000 `
        -stitch `
        -o "$sessionDir\Johnson_Bach_Bach${id}_ses-T1w.nii.gz"

    ### Run Segmentations ###

    # Activate MuscleMap environment
    conda activate MuscleMap

    $inputFile = "$sessionDir\Johnson_Bach_Bach${id}_ses-T1w.nii.gz"

    # Abdomen
    mm_segment -i $inputFile -r abdomen -o $sessionDir

    Move-Item `
        "$sessionDir\Johnson_Bach_Bach${id}_ses-T1w_dseg.nii.gz" `
        "$sessionDir\Johnson_Bach_Bach${id}_ses-T1w_chunk-abdomen_dseg.nii.gz" `
        -Force

    # Pelvis
    mm_segment -i $inputFile -r pelvis -o $sessionDir

    Move-Item `
        "$sessionDir\Johnson_Bach_Bach${id}_ses-T1w_dseg.nii.gz" `
        "$sessionDir\Johnson_Bach_Bach${id}_ses-T1w_chunk-pelvis_dseg.nii.gz" `
        -Force

    # Thigh
    mm_segment -i $inputFile -r thigh -o $sessionDir

    Move-Item `
        "$sessionDir\Johnson_Bach_Bach${id}_ses-T1w_dseg.nii.gz" `
        "$sessionDir\Johnson_Bach_Bach${id}_ses-T1w_chunk-thigh_dseg.nii.gz" `
        -Force

    # Leg
    mm_segment -i $inputFile -r leg -o $sessionDir

    Move-Item `
        "$sessionDir\Johnson_Bach_Bach${id}_ses-T1w_dseg.nii.gz" `
        "$sessionDir\Johnson_Bach_Bach${id}_ses-T1w_chunk-leg_dseg.nii.gz" `
        -Force
}