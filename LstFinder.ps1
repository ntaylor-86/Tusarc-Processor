class LstFinder
{
    [string] $baseDirectory

    [array] returnNewLsts()
    {
        $t = (Get-Date).AddHours(-1)
        $files = Get-ChildItem -Path $this.baseDirectory -Filter *.lst -Recurse -OutBuffer 1000 | where {$_.LastWriteTime -gt $t}
        return $files
    }
}