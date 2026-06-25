# Load SCT environment (if needed)
# Equivalent of: source /Users/labadmin/.bashrc
# Adjust as necessary for your Windows installation

.\venv\Scripts\Activate.ps1

# Setup data and output paths
$data_path = Join-Path $HOME "Documents\code\test_niix"
$output_path = Join-Path $HOME "Documents\code\out"

Write-Host "Data path is $data_path"
Write-Host "Output path is $output_path"

# Create dataset folders in output path
New-Item -ItemType Directory -Force -Path "$output_path\sourcedata" | Out-Null

# List of subject IDs
$ids = @("000") #For now just running on a single mri

foreach ($id in $ids) {

    Write-Host "Running $id"

    ### Organize data ###

    # Create BIDS-like folders
    $subjectDir = "$output_path\sourcedata\testing-$id"
    $sessionDir = "$subjectDir\ses-T1w"

    New-Item -ItemType Directory -Force -Path $subjectDir | Out-Null
    New-Item -ItemType Directory -Force -Path $sessionDir | Out-Null

    # Find muscle images
    $t1w_iso     = Get-ChildItem "$data_path\fl3d_vibe_iso*.nii.gz" | Select-Object -ExpandProperty FullName
    $t1w_neg200  = Get-ChildItem "$data_path\fl3d_vibe_200*.nii.gz" | Select-Object -ExpandProperty FullName
    $t1w_neg400  = Get-ChildItem "$data_path\fl3d_vibe_400*.nii.gz" | Select-Object -ExpandProperty FullName
    $t1w_neg600  = Get-ChildItem "$data_path\fl3d_vibe_600*.nii.gz" | Select-Object -ExpandProperty FullName
    $t1w_neg800  = Get-ChildItem "$data_path\fl3d_vibe_800*.nii.gz" | Select-Object -ExpandProperty FullName
    $t1w_neg1000 = Get-ChildItem "$data_path\fl3d_vibe_1000*.nii.gz" | Select-Object -ExpandProperty FullName

    # Copy JSON file
    $t1w_json = Get-ChildItem "$data_path\fl3d_vibe_iso*.json" | Select-Object -First 1

    Copy-Item `
        $t1w_json.FullName `
        "$sessionDir\test${id}_ses-T1w.json"

    # Stitch muscle images together
    & sct_image `
        -i $t1w_iso $t1w_neg200 $t1w_neg400 $t1w_neg600 $t1w_neg800 $t1w_neg1000 `
        -stitch `
        -o "$sessionDir\test${id}_ses-T1w.nii.gz"

    ### Run Segmentations ###

    $inputFile = "$sessionDir\test${id}_ses-T1w.nii.gz"

    Write-Host "outputing to $sessionDir"
    # Abdomen
    py .\scripts\mm_segment.py -i $inputFile -r abdomen -o $sessionDir

    Move-Item `
        "$sessionDir\test${id}_ses-T1w_dseg.nii.gz" `
        "$sessionDir\test${id}_ses-T1w_chunk-abdomen_dseg.nii.gz" `
        -Force

    # Pelvis
    py .\scripts\mm_segment.py -i $inputFile -r pelvis -o $sessionDir

    Move-Item `
        "$sessionDir\test${id}_ses-T1w_dseg.nii.gz" `
        "$sessionDir\test${id}_ses-T1w_chunk-pelvis_dseg.nii.gz" `
        -Force

    # Thigh
    py .\scripts\mm_segment.py -i $inputFile -r thigh -o $sessionDir

    Move-Item `
        "$sessionDir\test${id}_ses-T1w_dseg.nii.gz" `
        "$sessionDir\test${id}_ses-T1w_chunk-thigh_dseg.nii.gz" `
        -Force

    # Leg
    py .\scripts\mm_segment.py -i $inputFile -r leg -o $sessionDir

    Move-Item `
        "$sessionDir\test${id}_ses-T1w_dseg.nii.gz" `
        "$sessionDir\test${id}_ses-T1w_chunk-leg_dseg.nii.gz" `
        -Force
}