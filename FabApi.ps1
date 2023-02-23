class FabApi
{
    [string] $URL
    
    [array] GetLatestNests()
    {
        $response = Invoke-RestMethod -Uri $this.URL
        
        return $response.data
    }
}