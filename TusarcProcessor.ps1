class TusarcProcessor
{
    [string] $baseDirectory

    [string] $inputFile

    [void] processFile()
    {
        Start-Process -FilePath $($this.baseDirectory + "\TUSARC5.exe") -ArgumentList $($this.inputFile) -NoNewWindow -Wait
    }
}