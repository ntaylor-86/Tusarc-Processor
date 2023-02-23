# ----------------------------------------------------------
# Imports
# ----------------------------------------------------------
Import-Module -Force $PSScriptRoot\LstFinder.ps1
Import-Module -Force $PSScriptRoot\TusarcProcessor.ps1
Import-Module -Force $PSScriptRoot\FileDiffer.ps1

# ----------------------------------------------------------
# Program Variables
# ----------------------------------------------------------
$LstDirectory = ""  # The root directory to where your .LST's are

# ----------------------------------------------------------
# Main
# ----------------------------------------------------------
$LstFinder = [LstFinder]::new()
$LstFinder.baseDirectory = $LstDirectory

$filesToProcess = $LstFinder.returnNewLsts()

foreach ($lst in $filesToProcess) {
    $fileName = Split-Path $lst.FullName -Leaf
    $fileNameNoExt = $fileName.Replace(".LST", "")
    $originalFile = $($PWD.Path + "\TEMP\" + $fileName)
    $modifiedFile = $($PWD.Path + "\TEMP\" + $fileNameNoExt + "_MODIFIED.LST")
    
    Write-Host $fileName

    # Copy .LST from the $LstDirectory to the TEMP directory
    Copy-Item -Path $lst.FullName -Destination $($PWD.Path + "\TEMP")
    # Copy and rename the file
    Copy-Item -Path $originalFile -Destination $modifiedFile
    
    # Run the TUSARC5 processor on the modified file
    $TusarcProcessor = [TusarcProcessor]::new()
    $TusarcProcessor.inputFile = $modifiedFile
    $TusarcProcessor.processFile()
    
    Start-Sleep -s 1 
    
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
}

Exit