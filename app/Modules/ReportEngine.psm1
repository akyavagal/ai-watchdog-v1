function New-AIWExecutiveReport {
    param(
        [Parameter(Mandatory)] [array]$Alerts,
        [string]$OutputDirectory
    )

    $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
    $fileName = "AIWatchdog_Executive_Report_$timestamp.html"
    $filePath = Join-Path $OutputDirectory $fileName

    $criticalCount = @($Alerts | Where-Object Severity -eq "Critical").Count
    $highCount = @($Alerts | Where-Object Severity -eq "High").Count
    $mediumCount = @($Alerts | Where-Object Severity -eq "Medium").Count

    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>AI Watchdog | Executive Intelligence Report</title>
    <style>
        :root {
            --bg: #0D1117;
            --card: #161B22;
            --border: #30363D;
            --text: #C9D1D9;
            --accent: #58A6FF;
            --critical: #FF7B72;
            --high: #FFA657;
            --medium: #F2C94C;
        }
        body { font-family: 'Inter', -apple-system, sans-serif; background: var(--bg); color: var(--text); line-height: 1.6; padding: 60px; margin: 0; }
        .container { max-width: 1100px; margin: 0 auto; }
        .header { display: flex; justify-content: space-between; align-items: flex-end; border-bottom: 1px solid var(--border); padding-bottom: 30px; margin-bottom: 50px; }
        .logo-area h1 { margin: 0; font-size: 28px; letter-spacing: -1px; font-weight: 900; }
        .logo-area span { color: var(--accent); font-weight: bold; font-size: 12px; text-transform: uppercase; }
        .stats { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 50px; }
        .stat-card { background: var(--card); border: 1px solid var(--border); padding: 25px; border-radius: 12px; position: relative; overflow: hidden; }
        .stat-card::after { content: ''; position: absolute; top: 0; left: 0; width: 4px; height: 100%; background: var(--accent); }
        .stat-card.critical::after { background: var(--critical); }
        .stat-card.high::after { background: var(--high); }
        .stat-card.medium::after { background: var(--medium); }
        .stat-card .label { font-size: 11px; font-weight: 800; color: #8B949E; text-transform: uppercase; }
        .stat-card .value { font-size: 36px; font-weight: 900; display: block; margin-top: 5px; }
        table { width: 100%; border-collapse: collapse; background: var(--card); border-radius: 12px; overflow: hidden; border: 1px solid var(--border); }
        th { text-align: left; background: #21262D; padding: 15px 20px; font-size: 12px; text-transform: uppercase; letter-spacing: 1px; }
        td { padding: 15px 20px; border-top: 1px solid var(--border); font-size: 14px; }
        .sev { display: inline-block; padding: 4px 10px; border-radius: 4px; font-size: 11px; font-weight: bold; }
        .sev-Critical { background: rgba(255,123,114,0.15); color: var(--critical); border: 1px solid var(--critical); }
        .sev-High { background: rgba(255,166,87,0.15); color: var(--high); border: 1px solid var(--high); }
        .sev-Medium { background: rgba(242,201,76,0.15); color: var(--medium); border: 1px solid var(--medium); }
        .footer { margin-top: 60px; padding-top: 30px; border-top: 1px solid var(--border); color: #8B949E; font-size: 12px; display: flex; justify-content: space-between; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo-area">
                <h1>AI WATCHDOG <span>v1.0 Executive</span></h1>
            </div>
            <div style="text-align: right">
                <div style="font-weight: bold;">INTEL REPORT</div>
                <div style="color: #8B949E; font-size: 12px;">$((Get-Date).ToString("MMMM dd, yyyy HH:mm"))</div>
            </div>
        </div>

        <div class="stats">
            <div class="stat-card critical"><span class="label">Critical Threats</span><span class="value">$criticalCount</span></div>
            <div class="stat-card high"><span class="label">High Alerts</span><span class="value">$highCount</span></div>
            <div class="stat-card medium"><span class="label">Medium Alerts</span><span class="value">$mediumCount</span></div>
            <div class="stat-card"><span class="label">Total Incidents</span><span class="value">$($Alerts.Count)</span></div>
        </div>

        <h2 style="font-size: 20px; margin-bottom: 25px;">Mission Critical Findings</h2>
        <table>
            <thead>
                <tr>
                    <th>Timestamp</th>
                    <th>Source Host</th>
                    <th>Threat Level</th>
                    <th>Description</th>
                    <th>Risk Score</th>
                </tr>
            </thead>
            <tbody>
"@

    foreach ($a in $Alerts) {
        $html += "<tr><td>$($a.Timestamp)</td><td>$($a.Host)</td><td><span class='sev sev-$($a.Severity)'>$($a.Severity)</span></td><td>$($a.Description)</td><td style='font-weight:bold;'>$($a.RiskScore)</td></tr>"
    }

    $html += @"
            </tbody>
        </table>

        <div class="footer">
            <div>&copy; $(Get-Date -Format "yyyy") AI Watchdog Neural SOC. Generated for Internal Use Only.</div>
            <div>CONFIDENTIAL // TOP SECRET</div>
        </div>
    </div>
</body>
</html>
"@

    $html | Set-Content -Path $filePath -Encoding UTF8 -Force
    return [pscustomobject]@{ HtmlPath = $filePath; Success = $true }
}

Export-ModuleMember -Function New-AIWExecutiveReport
