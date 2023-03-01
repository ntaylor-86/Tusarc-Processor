# ----------------------------------------------------------
# Program Variables
# ----------------------------------------------------------
$BASE_DIR = ""
$TEMP_DIR = ""
$FAB_BASE_DIR = ""
$FAB_API_URL = ""
$TEAMS_WEBHOOK_URL = ""
$SEND_CHECK_IN = $true
$CHECK_IN_URL=""

# ----------------------------------------------------------
# Imports
# ----------------------------------------------------------
Import-Module -Force $PSScriptRoot\CheckIn.ps1
Import-Module -Force $PSScriptRoot\FabApi.ps1
Import-Module -Force $PSScriptRoot\TusarcProcessor.ps1
Import-Module -Force $PSScriptRoot\TusarcChecker.ps1
Import-Module -Force $PSScriptRoot\TeamsNotification.ps1

# ----------------------------------------------------------
# Sending the Check-In to HoneyBadger (optional)
# ----------------------------------------------------------
if ( $SEND_CHECK_IN ) {
    $CheckIn = [CheckIn]::new()
    $CheckIn.Url = $CHECK_IN_URL
    $CheckIn.sendCheckIn()
}

# ----------------------------------------------------------
# Only execute the script between
# the hours of 07:00 and 18:00
# ----------------------------------------------------------
$min = Get-Date '07:00'
$max = Get-Date '18:00'
$now = Get-Date

if ( $now.TimeOfDay -le $min.TimeOfDay -or $now.TimeOfDay -ge $max.TimeOfDay ) {
    Exit
}

# ----------------------------------------------------------
# Main
# ----------------------------------------------------------
$FabApi = [FabApi]::new()
$FabApi.URL = $FAB_API_URL
$latestNests = $FabApi.GetLatestNests()

foreach ($lst in $latestNests) {
    $fileName = Split-Path $lst.LstPath -Leaf
    $fileNameNoExt = $fileName.Replace(".LST", "")
    $originalFile = $($TEMP_DIR + "\" + $fileName)
    $modifiedFile = $($TEMP_DIR + "\" + $fileNameNoExt + "_MODIFIED.LST")

    Write-Host $fileName
    
    # Copy the .LST from the FAB_BASE_DIR + the path from the FAB database for the Job into the TEMP dir
    Copy-Item -Path $($FAB_BASE_DIR + "\" + $lst.LstPath)  -Destination $TEMP_DIR
    # Copy and rename the file that TUSARC5 will process
    Copy-Item -Path $originalFile -Destination $modifiedFile
    
    # Run the TUSARC5 processor on the modified file
    $TusarcProcessor = [TusarcProcessor]::new()
    $TusarcProcessor.baseDirectory = $BASE_DIR
    $TusarcProcessor.inputFile = $modifiedFile
    $TusarcProcessor.processFile()
    
    Start-Sleep -s 1 
    
    # Compare the origianl & modified file
    $TusarcChecker = [TusarcChecker]::new()
    $TusarcChecker.sourceFile = $originalFile
    $TusarcChecker.modifiedFile = $modifiedFile

    if ($TusarcChecker.ModifiedFileIsDifferent() -eq $true) {
        Write-Host "Files are different!"
        $TeamsNotification = [TeamsNotification]::new()
        $TeamsNotification.webHookUrl = $TEAMS_WEBHOOK_URL
        $TeamsNotification.lstThatHasNotBeenTusarc5 = $fileName
        $TeamsNotification.checkedBy = $lst.CheckedBy
        $TeamsNotification.sendNotification()
    }

    # Delete the .LST's from the TEMP dir
    Remove-Item -Path $originalFile
    Remove-Item -Path $modifiedFile
}

Exit
