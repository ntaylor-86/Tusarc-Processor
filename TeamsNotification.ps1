class TeamsNotification
{
    [string] $webHookUrl
    
    [string] $lstThatHasNotBeenTusarc5

    [string] $checkedBy
    
    [void] sendNotification()
    {
        $lstName = $this.lstThatHasNotBeenTusarc5
        $checkedByUser = $this.checkedBy

        $jsonText = @"
        {
            "type": "message",
            "attachments": [
                {
                    "contentType": "application/vnd.microsoft.card.adaptive",
                    "content": {
                        "type": "AdaptiveCard",
                        "`$schema": "http://adaptivecards.io/schemas/adaptive-card.json",
                        "version": "1.5",
                        "body": [
                            {
                                "type": "TextBlock",
                                "text": "Nest found without TUSARC5 applied, ${lstName}",
                                "wrap": true,
                                "weight": "Bolder"
                            },
                            {
                                "type": "Image",
                                "url": "https://media.giphy.com/media/mz6aYifIzDqOuZSvEd/giphy.gif",
                                "size": "Medium"
                            },
                            {
                                "type": "FactSet",
                                "facts": [
                                    {
                                        "title": "Nest name",
                                        "value": "${lstName}"
                                    },
                                    {
                                        "title": "Check by",
                                        "value": "${checkedByUser}"
                                    }
                                ]
                            },
                            {
                                "type": "TextBlock",
                                "text": "This nest will have to be re-nc'd with the TUSARC5 post processor.",
                                "wrap": true
                            },
                            {
                                "type": "TextBlock",
                                "text": "Sent from the [Tusarc-Processor](https://github.com/ntaylor-86/Tusarc-Processor) running on `GCI-TRUMPF`.",
                                "wrap": true,
                                "size": "Small"
                            }
                        ]
                    }
                }
            ]
        }
"@
        
        Invoke-RestMethod -Method Post -Uri $this.webHookUrl -Body $jsonText -ContentType "application/json"
    }
}