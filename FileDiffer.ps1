class FileDiffer
{
    [string] $sourceFile

    [string] $modifiedFile
    
    [bool] FilesAreDifferent()
    {
        if ( Compare-Object -ReferenceObject $(Get-Content $this.sourceFile) -DifferenceObject $(Get-Content $this.modifiedFile)) {
            return $true
        }
        
        return $false
    }
}