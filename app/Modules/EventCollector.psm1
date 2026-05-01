function Get-AIWWindowsEvents {
    param(
        [int]$MinutesBack = 5
    )

    $startTime = (Get-Date).AddMinutes(-$MinutesBack).ToString("o")
    $events = @()
    
    # We use an XML filter to drastically improve performance and specifically target only
    # the events our Detection Engine cares about, instead of arbitrarily limiting to 100 max events.
    $query = @"
<QueryList>
  <Query Id="0" Path="Security">
    <Select Path="Security">
      *[System[TimeCreated[@SystemTime&gt;='$startTime'] and (EventID=4624 or EventID=4625 or EventID=4672 or EventID=4688 or EventID=4698 or EventID=4720)]]
    </Select>
  </Query>
  <Query Id="1" Path="System">
    <Select Path="System">
      *[System[TimeCreated[@SystemTime&gt;='$startTime'] and (EventID=7045)]]
    </Select>
  </Query>
</QueryList>
"@

    try {
        $raw = Get-WinEvent -FilterXml $query -ErrorAction SilentlyContinue
        foreach ($e in $raw) {
            $events += [pscustomobject]@{
                Timestamp = $e.TimeCreated
                Host = $env:COMPUTERNAME
                EventId = $e.Id
                Message = $e.Message
                LogName = $e.LogName
                Source = $e.ProviderName
            }
        }
    } catch {
        if ($_.Exception.Message -notmatch "(?i)unauthorized") {
            Write-Warning "Could not read Windows Event Logs using XML filter: $($_.Exception.Message)"
        }
    }

    return $events | Sort-Object Timestamp -Descending
}

function Get-AIWDemoCollectors {
    return @(
        [pscustomobject]@{ Hostname = "HOST-01"; LastHeartbeat = (Get-Date).AddMinutes(-2); Status = "Healthy"; EventsToday = 45; OSVersion = "Win10 22H2" },
        [pscustomobject]@{ Hostname = "HOST-09"; LastHeartbeat = (Get-Date).AddMinutes(-5); Status = "Warning"; EventsToday = 120; OSVersion = "Win11 23H2" },
        [pscustomobject]@{ Hostname = "HOST-12"; LastHeartbeat = (Get-Date).AddMinutes(-1); Status = "Healthy"; EventsToday = 890; OSVersion = "WinServer 2022" },
        [pscustomobject]@{ Hostname = "HOST-03"; LastHeartbeat = (Get-Date).AddMinutes(-30); Status = "Offline"; EventsToday = 0; OSVersion = "Win10 21H2" }
    )
}

Export-ModuleMember -Function Get-AIWWindowsEvents, Get-AIWDemoCollectors
