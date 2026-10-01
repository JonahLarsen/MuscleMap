# Base folder containing subject folders
$BASE = "C:\Users\jsl94\Documents\local_svo\MRI Scans\Unmeasured Scans"

# Output directory for NIfTI and JSON
$OUT = "C:\Users\jsl94\Documents\code\output_dcm2nifty_for_svo"

# Create output directory if needed
New-Item -ItemType Directory -Force -Path $OUT | Out-Null

Write-Host "Starting conversion..."

# Loop through each subject folder
Get-ChildItem -Path $BASE -Directory -Filter "JOHNSON_SVO_*" | ForEach-Object {

    $SUBJECT = $_.FullName
    $SUBNAME = $_.Name

    Write-Host ""
    Write-Host "Subject: $SUBNAME"

    # Create subject output folder
    $SUBJECT_OUT = Join-Path $OUT "sub-$SUBNAME"
    New-Item -ItemType Directory -Force -Path $SUBJECT_OUT | Out-Null

    # Find the Johnson FootCalf folder
    $FOOT_DIR = Get-ChildItem -Path $SUBJECT -Directory |
        Where-Object { $_.Name -eq "Johnson FootCalf" } |
        Select-Object -First 1

    if (-not $FOOT_DIR) {
        Write-Warning "Johnson FootCalf folder not found for $SUBNAME"
        return
    }

    Write-Host "  Found: $($FOOT_DIR.FullName)"

    # Find each MR fl3d_vibe series folder
    Get-ChildItem -Path $FOOT_DIR.FullName -Directory |
        Where-Object { $_.Name -like "MR fl3d_vibe_*" } |
        ForEach-Object {

            $SERIES = $_.FullName
            $SERNAME = $_.Name

            Write-Host "    Converting $SERNAME..."

            py -m dcm2niix `
                -z y `
                -f "$SERNAME" `
                -o "$SUBJECT_OUT" `
                "$SERIES"

            if ($LASTEXITCODE -ne 0) {
                Write-Warning "    Conversion failed for $SERNAME"
            }
            else {
                Write-Host "    Finished $SERNAME"
            }
        }
}

Write-Host ""
Write-Host "Finished converting all subjects."