class TeamsNotification
{
    [string] $webHookUrl
    
    [string] $lstThatHasNotBeenTusarc5
    
    [void] sendNotification()
    {
        $lstName = $this.lstThatHasNotBeenTusarc5

        $jsonText = @"
        {
            "@context": "https://schema.org/extensions",
            "@type": "MessageCard",
            "summary": "Nest found without TUSARC5 applied!",
            "themeColor": "a78bfa",
            "title": "Nest found without TUSARC5 applied, ${lstName}",
            "sections": [{
                "activityImage": "https://media.giphy.com/media/mz6aYifIzDqOuZSvEd/giphy.gif",
                "facts": [{
                    "name": "Nest name",
                    "value": "${lstName}"
                }],
                "text": "This nest will have to be re-nc'd with the TUSARC5 post processor."
            }]
        }
"@
        
        Invoke-RestMethod -Method Post -Uri $this.webHookUrl -Body $jsonText -ContentType "application/json"
    }
}