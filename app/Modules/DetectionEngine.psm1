function Invoke-AIWDetections {
    param(
        [Parameter(Mandatory)] [array]$Events,
        [Parameter(Mandatory)] [array]$Rules
    )

    $alerts = @()
    if (@($Events).Count -eq 0 -or @($Rules).Count -eq 0) { return @() }

    # Group by host for targeted analysis
    $byHost = $Events | Group-Object Host

    foreach ($group in $byHost) {
        $hostName = $group.Name
        $hEvents = $group.Group | Sort-Object Timestamp

        foreach ($rule in $Rules) {
            if ($rule.Type -eq "Single") {
                $cond = $rule.Condition
                $detectedEvents = @($hEvents | Where-Object { 
                    $match = ($_.EventId -eq $cond.EventId)
                    if ($match -and $cond.MessageRegex) {
                        $regexMatches = $true
                        foreach ($rgx in $cond.MessageRegex) {
                            if ($_.Message -notmatch $rgx) { $regexMatches = $false; break }
                        }
                        $match = $regexMatches
                    }
                    $match
                })
                foreach ($m in $detectedEvents) {
                    $alerts += [pscustomobject]@{
                        AlertId = [guid]::NewGuid().ToString()
                        Timestamp = $m.Timestamp
                        Host = $hostName
                        Severity = $rule.Severity
                        Description = $rule.Description
                        RiskScore = $rule.RiskScore
                        MitreTags = $rule.MitreTags
                        Events = @($m)
                    }
                }
            } elseif ($rule.Type -eq "Sequence") {
                $seq = $rule.Sequence
                $matchedSequenceEvents = New-Object 'System.Collections.Generic.List[PSObject]'
                $currentTimeLimit = [DateTime]::MinValue
                $allStepsMatched = $true

                foreach ($step in $seq) {
                    $stepEvents = @($hEvents | Where-Object { $_.EventId -eq $step.EventId -and $_.Timestamp -ge $currentTimeLimit })
                    if ($stepEvents.Count -ge $step.MinCount) {
                        foreach ($e in $stepEvents) { $matchedSequenceEvents.Add($e) }
                        $currentTimeLimit = $stepEvents[-1].Timestamp
                    } else {
                        $allStepsMatched = $false
                        break
                    }
                }

                if ($allStepsMatched) {
                    $alerts += [pscustomobject]@{
                        AlertId = [guid]::NewGuid().ToString()
                        Timestamp = $matchedSequenceEvents[-1].Timestamp
                        Host = $hostName
                        Severity = $rule.Severity
                        Description = $rule.Description
                        RiskScore = $rule.RiskScore
                        MitreTags = $rule.MitreTags
                        Events = $matchedSequenceEvents.ToArray()
                    }
                }
            }
        }
    }

    return $alerts | Sort-Object Timestamp -Descending
}

Export-ModuleMember -Function Invoke-AIWDetections
