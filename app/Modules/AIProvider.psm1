function Invoke-AIWIncidentAnalysis {
    param(
        $Incident,
        $ApiEndpoint = "http://localhost:11434",
        $AIModel = "gemma4:e2b",
        $EnableTurboMode = $false
    )

    try {
        $normalizedEndpoint = $ApiEndpoint.TrimEnd("/")
        
        # 1. OPTIMIZED PROMPT
        $eventIds = ($Incident.Events | ForEach-Object { $_.EventId }) -join ","
        $eventsBrief = ""
        if ($Incident.Events) {
            $eventsBrief = ($Incident.Events | Select-Object -First 5 | ForEach-Object { "ID $($_.EventId): $($_.Message.Substring(0, [math]::Min(150, $_.Message.Length)))" }) -join "`n"
        }

        $prompt = @"
Analyze this security incident and respond ONLY with valid JSON.
Incident: $($Incident.Description)
Severity: $($Incident.Severity)
Host: $($Incident.Host)
EventIDs: $eventIds
Logs:
$eventsBrief

Schema:
{
  "summary": "2 sentence executive overview",
  "severity": "Critical|High|Medium|Low",
  "insights": ["technical finding 1", "technical finding 2", "technical finding 3"],
  "mitigation_playbook": ["action 1", "action 2", "action 3"],
  "confidence": 0-100
}
"@

        $threads = 8; if ($EnableTurboMode) { $threads = 16 }
        $gpus = 0; if ($EnableTurboMode) { $gpus = 1 }

        $jsonBody = @{
            model = $AIModel
            prompt = $prompt
            stream = $false
            format = "json"
            options = @{
                temperature = 0.1
                num_predict = 500
                num_thread  = $threads
                num_gpu     = $gpus
                stop        = @('```', '}')
            }
        } | ConvertTo-Json -Compress

        $response = Invoke-RestMethod -Uri "$normalizedEndpoint/api/generate" -Method Post -ContentType "application/json" -Body $jsonBody -TimeoutSec 120
        
        if ($response -and $response.response) {
            $rawResponse = [string]$response.response.Trim()
            
            # Robust Extraction
            if ($rawResponse -match '(?s)(\{.*)') {
                $jsonStr = $matches[1].Trim()
                if ($jsonStr -notmatch '\}$') { $jsonStr += '}' }
                
                try {
                    return $jsonStr | ConvertFrom-Json
                } catch {
                    # Manual Regex Fallback if JSON is still broken
                    $summary = if ($jsonStr -match '"summary"\s*:\s*"([^"]+)"') { $matches[1] } else { "AI analyzed incident on $($Incident.Host)" }
                    $severity = if ($jsonStr -match '"severity"\s*:\s*"([^"]+)"') { $matches[1] } else { $Incident.Severity }
                    return [pscustomobject]@{
                        summary = $summary
                        severity = $severity
                        insights = @("Complexity high; manual review recommended", "Source: $($Incident.Host)")
                        mitigation_playbook = @("Isolate Host", "Check logs")
                        confidence = 50
                    }
                }
            }
        }
        throw "Empty or invalid response from AI"
    } catch {
        return [pscustomobject]@{
            summary            = "Neural analysis offline. Service or model error."
            severity           = "Error"
            insights           = @("Error: $($_.Exception.Message)", "Check Ollama status")
            mitigation_playbook = @("Verify Ollama API", "Run: ollama list")
            confidence         = 0
        }
    }
}

Export-ModuleMember -Function Invoke-AIWIncidentAnalysis
