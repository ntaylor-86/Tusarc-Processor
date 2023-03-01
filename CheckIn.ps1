class CheckIn
{
    [string] $Url

    [void] sendCheckIn()
    {
        Invoke-RestMethod -Method Get -Uri $this.Url
    }
}