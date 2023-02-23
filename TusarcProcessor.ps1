class TusarcProcessor
{
    [string] $inputFile

    [void] processFile()
    {
        Start-Process -FilePath $($PWD.Path + "\TUSARC5.exe") -ArgumentList $($this.inputFile) -NoNewWindow
    }
}