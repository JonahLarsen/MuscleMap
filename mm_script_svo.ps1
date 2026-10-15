# Load SCT environment (if needed)
# Equivalent of: source /Users/labadmin/.bashrc
# Adjust as necessary for your Windows installation

.\venv\Scripts\Activate.ps1

# Setup data and output paths
$data_path = Join-Path $HOME "Documents\code\output_dcm2nifty_for_svo"
$output_path = Join-Path $HOME "Documents\code\MM-out-for-svo-sept24"

Write-Host "Data path is $data_path"
Write-Host "Output path is $output_path"

# Create dataset folders in output path
New-Item -ItemType Directory -Force -Path "$output_path\sourcedata" | Out-Null

# List of subject IDs
$ids = @("002_311", "003", "004", "004(2)", "005", "006", "007", "008", "009", "010", "011", "012", "013", "014", "015", "016")

foreach ($id in $ids) {

    Write-Host "Running $id"

    ### Organize data ###

    # Create BIDS-like folders
    $subjectDir = "$output_path\sourcedata\Johnson_SVO_MM_$id"
    $sessionDir = "$subjectDir\ses-T1w"

    New-Item -ItemType Directory -Force -Path $subjectDir | Out-Null
    New-Item -ItemType Directory -Force -Path $sessionDir | Out-Null

    # Find muscle images
    $t1w_F0     = Get-ChildItem "$data_path\sub-JOHNSON_SVO_${id}*\MR_fl3d_vibe_F0_W*.nii.gz" | Select-Object -ExpandProperty FullName
    $t1w_F50  = Get-ChildItem "$data_path\sub-JOHNSON_SVO_${id}*\MR_fl3d_vibe_F50_W*.nii.gz" | Select-Object -ExpandProperty FullName
    $t1w_F100  = Get-ChildItem "$data_path\sub-JOHNSON_SVO_${id}*\MR_fl3d_vibe_F100_W*.nii.gz" | Select-Object -ExpandProperty FullName
    $t1w_F150  = Get-ChildItem "$data_path\sub-JOHNSON_SVO_${id}*\MR_fl3d_vibe_F150_W*.nii.gz" | Select-Object -ExpandProperty FullName
    $t1w_F200  = Get-ChildItem "$data_path\sub-JOHNSON_SVO_${id}*\MR_fl3d_vibe_F200_W*.nii.gz" | Select-Object -ExpandProperty FullName
    $t1w_F250 = Get-ChildItem "$data_path\sub-JOHNSON_SVO_${id}*\MR_fl3d_vibe_F250_W*.nii.gz" | Select-Object -ExpandProperty FullName
    $t1w_F300 = Get-ChildItem "$data_path\sub-JOHNSON_SVO_${id}*\MR_fl3d_vibe_F300_W*.nii.gz" | Select-Object -ExpandProperty FullName
    $t1w_F350 = Get-ChildItem "$data_path\sub-JOHNSON_SVO_${id}*\MR_fl3d_vibe_F350_W*.nii.gz" | Select-Object -ExpandProperty FullName

    # Copy JSON file
    $t1w_json = Get-ChildItem "$data_path\sub-Johnson_${id}*\fl3d_vibe_F0_W*.json" | Select-Object -First 1
    
    Copy-Item `
        $t1w_json.FullName `
        "$sessionDir\Johnson_SVO_MM_${id}_ses-T1w.json"


    & sct_image `
        -i $t1w_F100 `
        -stitch `
        -o "$sessionDir\Johnson_SVO_${id}_ses-T1w-testing.nii.gz"

    # Stitch muscle images together
    # & sct_image `
    #     -i $t1w_F0 $t1w_F50 $t1w_F100 $t1w_F150 $t1w_F200 $t1w_F250 $t1w_F300 $t1w_F350 `
    #     -stitch `
    #     -o "$sessionDir\Johnson_SVO_${id}_ses-T1w.nii.gz"

    ### Run Segmentations ###

    $inputFile = "$sessionDir\Johnson_SVO_${id}_ses-T1w.nii.gz"

    Write-Host "outputing to $sessionDir"
    # Abdomen
    # py .\scripts\mm_segment.py -i $inputFile -r abdomen -o $sessionDir

    # Move-Item `
    #     "$sessionDir\Johnson_BACH_${id}_ses-T1w_dseg.nii.gz" `
    #     "$sessionDir\Johnson_BACH_${id}_ses-T1w_chunk-abdomen_dseg.nii.gz" `
    #     -Force

    # # Pelvis
    # py .\scripts\mm_segment.py -i $inputFile -r pelvis -o $sessionDir

    # Move-Item `
    #     "$sessionDir\Johnson_BACH_${id}_ses-T1w_dseg.nii.gz" `
    #     "$sessionDir\Johnson_BACH_${id}_ses-T1w_chunk-pelvis_dseg.nii.gz" `
    #     -Force

    # # Thigh
    # py .\scripts\mm_segment.py -i $inputFile -r thigh -o $sessionDir

    # Move-Item `
    #     "$sessionDir\Johnson_BACH_${id}_ses-T1w_dseg.nii.gz" `
    #     "$sessionDir\Johnson_BACH_${id}_ses-T1w_chunk-thigh_dseg.nii.gz" `
    #     -Force

    # Leg
    py .\scripts\mm_segment.py -i $inputFile -r leg -o $sessionDir

    # Move-Item `
    #     "$sessionDir\Johnson_SVO_${id}_ses-T1w_dseg.nii.gz" `
    #     "$sessionDir\Johnson_SVO_${id}_ses-T1w_chunk-leg_dseg.nii.gz" `
    #     -Force
}