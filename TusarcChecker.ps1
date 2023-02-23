class TusarcChecker
{
    [string] $sourceFile

    [string] $modifiedFile
    
    # ----------------------------------------------------------
    # Function: ModifiedFileIsDifferent
    # 
    # If the modified files is different, it means
    # that the TUSARC5 program has not been
    # run on the source file.
    # 
    # To determine this we run a diff check on the
    # two files comparing the contents and also
    # count the number of lines in each file.
    # 
    # If the file contents are different and the
    # modified file line count is larger, TUSARC5
    # was not run on the source file.
    # ----------------------------------------------------------
    [bool] ModifiedFileIsDifferent()
    {
        # Compare the contents of the two files
        $filesAreDifferent = $false
        if ( Compare-Object -ReferenceObject $(Get-Content $this.sourceFile) -DifferenceObject $(Get-Content $this.modifiedFile)) {
            $filesAreDifferent = $true
        }

        # Compare the line count of the two files
        $sourceFileLineCount = Get-Content -Path $this.sourceFile | Measure-Object -Line
        $modifiedFileLineCount = Get-Content -Path $this.modifiedFile | Measure-Object -Line
        
        if ( $modifiedFileLineCount.Lines -gt $sourceFileLineCount.Lines ) {
            $modifiedLineCountLarger = $true
        } else {
            $modifiedLineCountLarger = $false
        }
        
        if ( $filesAreDifferent -eq $true -and $modifiedLineCountLarger -eq $true ) {
            return $true
        }
        
        return $false
    }
}