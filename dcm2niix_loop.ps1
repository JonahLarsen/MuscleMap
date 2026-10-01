# Base folder containing raw DICOMs
$BASE = "D:\Ballet Sharing"

# Output directory for NIfTI and JSON
$OUT = "C:\Users\jsl94\Documents\code\output\Ballet Sharing"

# Create output directory if needed
New-Item -ItemType Directory -Force -Path $OUT | Out-Null

Write-Host "Starting conversion..."

# Loop through each subject folder
Get-ChildItem -Path $BASE -Directory -Filter "Johnson*" | ForEach-Object {

    $SUBJECT = $_.FullName
    $SUBNAME = $_.Name

    Write-Host ""
    Write-Host "Subject: $SUBNAME"

    # Create subject output folder
    $SUBJECT_OUT = Join-Path $OUT "sub-$SUBNAME"
    New-Item -ItemType Directory -Force -Path $SUBJECT_OUT | Out-Null

    # Find the Johnson_foot folder
    $FOOT_DIR = Get-ChildItem -Path $SUBJECT -Directory |
        Where-Object { $_.Name -like "Johnson_foot*" } |
        Select-Object -First 1

    if (-not $FOOT_DIR) {
        Write-Warning "Johnson_foot folder not found for $SUBNAME"
        return
    }

    Write-Host "  Found: $($FOOT_DIR.FullName)"

    # Convert each series folder
    Get-ChildItem -Path $FOOT_DIR.FullName -Directory | ForEach-Object {

        $SERIES = $_.FullName
        $SERNAME = $_.Name

        Write-Host "    Converting $SERNAME..."

        py -m dcm2niix `
            -z y `
            -f "$SERNAME" `
            -o "$SUBJECT_OUT" `
            "$SERIES"
    }
}

Write-Host ""
Write-Host "Finished converting all subjects."