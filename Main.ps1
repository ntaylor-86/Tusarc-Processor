# ----------------------------------------------------------
# Imports
# ----------------------------------------------------------
Import-Module -Force $PSScriptRoot\FabApi.ps1
Import-Module -Force $PSScriptRoot\TusarcProcessor.ps1
Import-Module -Force $PSScriptRoot\FileDiffer.ps1
Import-Module -Force $PSScriptRoot\TeamsNotification.ps1

# ----------------------------------------------------------
# Program Variables
# ----------------------------------------------------------
$FAB_BASE_DIR = ""
$FAB_API_URL = ""
$TEAMS_WEBHOOK_URL = ""


# ----------------------------------------------------------
# Main
# ----------------------------------------------------------
$FabApi = [FabApi]::new()
$FabApi.URI = $FAB_API_URL
$latestNests = $FabApi.GetLatestNests()

foreach ($lst in $latestNests) {
    $fileName = Split-Path $lst.LstPath -Leaf
    $fileNameNoExt = $fileName.Replace(".LST", "")
    $originalFile = $($PWD.Path + "\TEMP\" + $fileName)
    $modifiedFile = $($PWD.Path + "\TEMP\" + $fileNameNoExt + "_MODIFIED.LST")

    Write-Host $fileName
    
    # Copy the .LST from the FAB_BASE_DIR + the path from the FAB database for the Job
    Copy-Item -Path $($FAB_BASE_DIR + "\" + $lst.LstPath)  -Destination $($PWD.Path + "\TEMP")
    # Copy and rename the file
    Copy-Item -Path $originalFile -Destination $modifiedFile
    
    # Run the TUSARC5 processor on the modified file
    $TusarcProcessor = [TusarcProcessor]::new()
    $TusarcProcessor.inputFile = $modifiedFile
    $TusarcProcessor.processFile()
    
    Start-Sleep -s 3
    
    # Compare the origianl & modified file
    $FileDiffer = [FileDiffer]::new()
    $FileDiffer.sourceFile = $originalFile
    $FileDiffer.modifiedFile = $modifiedFile
    
    if ($FileDiffer.FilesAreDifferent() -eq $false) {
        Remove-Item -Path $originalFile
        Remove-Item -Path $modifiedFile
        Continue
    }
    
    Write-Host "Files are different!"
    
    $TeamsNotification = [TeamsNotification]::new()
    $TeamsNotification.webHookUrl = $TEAMS_WEBHOOK_URL
    $TeamsNotification.lstThatHasNotBeenTusarc5 = $fileName
    $TeamsNotification.sendNotification()
}

Exit
