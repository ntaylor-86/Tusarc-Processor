class FabApi
{
    # [string] $URI = "http://fab-api.gci.local/api/programmed-nests"
    [string] $URI
    
    [array] GetLatestNests()
    {
        $response = Invoke-RestMethod -Uri $this.URI
        
        return $response.data
    }
}