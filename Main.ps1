# ----------------------------------------------------------
# Imports
# ----------------------------------------------------------
Import-Module -Force $PSScriptRoot\FabApi.ps1
Import-Module -Force $PSScriptRoot\TusarcProcessor.ps1
Import-Module -Force $PSScriptRoot\TusarcChecker.ps1
Import-Module -Force $PSScriptRoot\TeamsNotification.ps1

# ----------------------------------------------------------
# Program Variables
# ----------------------------------------------------------
$BASE_DIR = "C:\laragon\www\Tusarc-Processor"
$TEMP_DIR = "C:\laragon\www\Tusarc-Processor\TEMP"
$FAB_BASE_DIR = "\\gci-trumpf\Archiv"
$FAB_API_URL = "http://fab-api.gci.local/api/programmed-nests"
$TEAMS_WEBHOOK_URL = "https://rbcducentis.webhook.office.com/webhookb2/dbeffb7f-afef-49bd-a1ee-1142f77c035b@be25322c-847f-46c3-a099-1b03657ef136/IncomingWebhook/c39973ba441f4f70a66083e047adee31/26992479-89dc-46bc-99c7-8f0cd5c4c1b9"


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
        $TeamsNotification.sendNotification()
    }

    # Delete the .LST's from the TEMP dir
    Remove-Item -Path $originalFile
    Remove-Item -Path $modifiedFile
}

Exit
