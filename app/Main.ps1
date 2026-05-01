# AI Watchdog v1.0 - Main Control Logic
# FINAL STABLE RELEASE (Optimized & Simplified)

$ErrorActionPreference = "Continue"
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# --- Environment & Paths ---
$script:appPath = $PSScriptRoot
$script:rootPath = Split-Path -Parent $script:appPath
$script:modulePath = Join-Path $script:appPath "Modules"
$script:dataPath = Join-Path $script:rootPath "data"
$script:reportsPath = Join-Path $script:rootPath "reports"

# --- Radar Animation Logic ---
function Start-Radar {
    if ($script:ui.RadarGrid) {
        $script:ui.RadarGrid.Visibility = "Visible"
        $anim = New-Object System.Windows.Media.Animation.DoubleAnimation
        $anim.From = 0
        $anim.To = 360
        $anim.Duration = New-Object System.Windows.Duration([TimeSpan]::FromSeconds(2))
        $anim.RepeatBehavior = [System.Windows.Media.Animation.RepeatBehavior]::Forever
        $script:ui.RadarRotate.BeginAnimation([System.Windows.Media.RotateTransform]::AngleProperty, $anim)
    }
}
function Stop-Radar {
    if ($script:ui.RadarGrid) {
        $script:ui.RadarGrid.Visibility = "Collapsed"
        $script:ui.RadarRotate.BeginAnimation([System.Windows.Media.RotateTransform]::AngleProperty, $null)
    }
}


# Ensure directories exist
@($script:dataPath, $script:reportsPath) | ForEach-Object { if (-not (Test-Path $_)) { New-Item -ItemType Directory -Path $_ -Force } }

# Global Typewriter State
$script:TypewriterSegments = New-Object 'System.Collections.Generic.List[PSObject]'
$script:CurrentSegmentIndex = 0
$script:CurrentCharIndex = 0
$script:CurrentRun = $null

# Import Modules
Get-ChildItem $script:modulePath -Filter *.psm1 | ForEach-Object { Import-Module $_.FullName -Force }

# Initialize State
$store = Initialize-AIWDataStore -RootPath $script:rootPath
$global:AIW_Config = Get-AIWSettings -SettingsPath $store.SettingsPath
$global:AIW_Rules = Get-AIWRules -RulesPath $store.RulesPath

$global:AllEvents = New-Object 'System.Collections.Generic.List[PSObject]'
$global:AllAlerts = New-Object 'System.Collections.Generic.List[PSObject]'
$global:AIDecisions = 0
$global:Collectors = [array](Get-AIWDemoCollectors)

# Initial Seeding
$script:LastScanTime = [DateTime]::Now.AddHours(-1)
$seedEvents = New-AIWDemoEvents -Count 10
foreach ($e in $seedEvents) { $global:AllEvents.Add($e) }
$seedAlerts = Invoke-AIWDetections -Events (@($global:AllEvents)) -Rules (@($global:AIW_Rules))
foreach ($a in $seedAlerts) { $global:AllAlerts.Insert(0, $a) }
$script:LastScanTime = [DateTime]::Now

# --- Async Engine ---
$script:AsyncJobs = New-Object 'System.Collections.Generic.Dictionary[string,PSObject]'

function Invoke-WpfAsync {
    param([scriptblock]$ScriptBlock, [PSObject]$Arguments, [scriptblock]$OnComplete, [string]$JobId)
    $ps = [powershell]::Create().AddScript($ScriptBlock)
    if ($Arguments) { 
        if ($Arguments -is [hashtable]) { [void]$ps.AddParameters($Arguments) }
        else { foreach ($prop in $Arguments.psobject.Properties) { [void]$ps.AddParameter($prop.Name, $prop.Value) } }
    }
    $id = if ($JobId) { $JobId } else { [guid]::NewGuid().ToString() }
    $script:AsyncJobs[$id] = [pscustomobject]@{ PS = $ps; Handle = $ps.BeginInvoke(); Callback = $OnComplete }
}

# --- Core Functions ---
function Update-AIIntelligence {
    param([Parameter(Mandatory)] $Incident)
    
    # Cancel Previous Job
    if ($script:currentJobId) {
        $oldJob = $script:AsyncJobs[$script:currentJobId]
        if ($oldJob) {
            try { $oldJob.PS.Stop() } catch {}
            $oldJob.PS.Dispose()
            [void]$script:AsyncJobs.Remove($script:currentJobId)
        }
    }
    $script:currentJobId = [guid]::NewGuid().ToString()

    $script:analysisStartTime = [DateTime]::Now
    $script:currentAnalysisPhase = 0
    if ($script:ui.AnalysisProgressBar) { $script:ui.AnalysisProgressBar.Visibility = "Visible" }
    Start-Radar
    
    # Reset Console
    if ($script:ui.ConsoleParagraph) { $script:ui.ConsoleParagraph.Inlines.Clear() }
    $script:TypewriterSegments.Clear()
    $script:CurrentSegmentIndex = 0
    $script:CurrentCharIndex = 0
    $script:CurrentRun = $null

    # 1. Add Analysis Segment
    $script:TypewriterSegments.Add([pscustomobject]@{Text = "[ SYSTEM ] "; Color = "#58A6FF" })
    $script:TypewriterSegments.Add([pscustomobject]@{Text = "PERFORMING SECURE LOCAL AI ANALYSIS...`n"; Color = "#00FF41" })
    
    $script:TypewriterTimer.Start()
    
    Invoke-WpfAsync -ScriptBlock {
        param($Incident, $Config, $ModulePath)
        try {
            Import-Module $ModulePath -Force
            $res = Invoke-AIWIncidentAnalysis -Incident $Incident -ApiEndpoint $Config.ApiEndpoint -AIModel $Config.AIModel
            return [pscustomobject]@{ Success = $true; Data = $res }
        }
        catch { return [pscustomobject]@{ Success = $false; Error = $_.Exception.Message } }
    } -Arguments @{Incident = $Incident; Config = $global:AIW_Config; ModulePath = (Join-Path $script:modulePath "AIProvider.psm1") } -JobId $script:currentJobId -OnComplete {
        param($Result, $ErrorRecord)
        
        # Only process if this is still the active job
        if ($script:currentJobId -and ($script:AsyncJobs.Keys -notcontains $script:currentJobId)) { return }
        
        $jobResult = if ($Result -is [array]) { $Result[0] } else { $Result }

        if ($jobResult -and $jobResult.Success) {
            $analysis = $jobResult.Data
            $global:AIDecisions++; Update-KPIs
            $insights = $(if ($analysis.insights) { ($analysis.insights | ForEach-Object { " >> $_" }) -join "`n" } else { " >> No specific insights" })
            $playbook = $(if ($analysis.mitigation_playbook) { ($analysis.mitigation_playbook | ForEach-Object { " >> $_" }) -join "`n" } else { " >> Manual investigation required" })
            
            $elapsed = ([DateTime]::Now - $script:analysisStartTime).TotalSeconds
            
            # Add Response Segments
            $script:TypewriterSegments.Add([pscustomobject]@{Text = "`n`n[ THREAT INTELLIGENCE SUMMARY ]`n"; Color = "#58A6FF" })
            $script:TypewriterSegments.Add([pscustomobject]@{Text = "SEVERITY: $($analysis.severity) | CONFIDENCE: $($analysis.confidence)% | ANALYSIS TIME: $($elapsed.ToString('F2'))s`n`n"; Color = "#00FF41" })
            $script:TypewriterSegments.Add([pscustomobject]@{Text = "EXECUTIVE ANALYSIS:`n"; Color = "#58A6FF" })
            $script:TypewriterSegments.Add([pscustomobject]@{Text = "$($analysis.summary)`n`n"; Color = "#00FF41" })
            $script:TypewriterSegments.Add([pscustomobject]@{Text = "KEY TEAM INSIGHTS:`n"; Color = "#58A6FF" })
            $script:TypewriterSegments.Add([pscustomobject]@{Text = "$insights`n`n"; Color = "#00FF41" })
            $script:TypewriterSegments.Add([pscustomobject]@{Text = "RECOMMENDED CONTAINMENT PLAYBOOK:`n"; Color = "#58A6FF" })
            $script:TypewriterSegments.Add([pscustomobject]@{Text = "$playbook"; Color = "#00FF41" })
        }
        else {
            $err = if ($jobResult) { $jobResult.Error } elseif ($ErrorRecord) { $ErrorRecord.Exception.Message } else { "Unknown Background Error" }
            $script:TypewriterSegments.Add([pscustomobject]@{Text = "`n`n[ ALERT ] NEURAL CORE ERROR`n"; Color = "#FF7B72" })
            $script:TypewriterSegments.Add([pscustomobject]@{Text = "ANALYSIS FAILED: $err`n"; Color = "#C9D1D9" })
        }
        
        if (-not $script:TypewriterTimer.IsEnabled) { $script:TypewriterTimer.Start() }
        if ($script:ui.AnalysisProgressBar) { $script:ui.AnalysisProgressBar.Visibility = "Collapsed" }
        if ($script:ui.AnalysisStatusText) { $script:ui.AnalysisStatusText.Text = "SYSTEM READY" }
        Stop-Radar
    }
}

function Update-KPIs {
    $ui = $script:ui
    $today = (Get-Date).Date
    $todaysAlerts = @($global:AllAlerts) | Where-Object { $_.Timestamp -ge $today }
    if ($ui.KpiEventsToday) { $ui.KpiEventsToday.Text = [string]@($global:AllEvents).Count }
    if ($ui.KpiCriticalAlerts) { $ui.KpiCriticalAlerts.Text = [string]@($todaysAlerts | Where-Object Severity -eq "Critical").Count }
    if ($ui.KpiHighAlerts) { $ui.KpiHighAlerts.Text = [string]@($todaysAlerts | Where-Object Severity -eq "High").Count }
    if ($ui.KpiAIDecisions) { $ui.KpiAIDecisions.Text = [string]$global:AIDecisions }
    if ($ui.KpiHostsMonitored) { $ui.KpiHostsMonitored.Text = [string]@($global:Collectors).Count }
    $maxRisk = 0; if (@($global:AllAlerts).Count -gt 0) { $maxRisk = (@($global:AllAlerts) | Measure-Object RiskScore -Maximum).Maximum }
    if ($ui.KpiRiskScore) { $ui.KpiRiskScore.Text = [string]$maxRisk }
}

function Update-Grids {
    $gridAlerts = @($global:AllAlerts) | Select-Object AlertId,
    @{Name = "Time"; Expression = { $_.Timestamp.ToString("HH:mm:ss") } }, 
    @{Name = "EventID"; Expression = { ($_.Events | Select-Object -First 1).EventId } }, 
    Severity, Host, Description, RiskScore
    if ($script:ui.IncidentsGrid) { $script:ui.IncidentsGrid.ItemsSource = $gridAlerts }
    if ($script:ui.CollectorsGrid) { $script:ui.CollectorsGrid.ItemsSource = $global:Collectors }
}

function Update-SystemStats {
    try {
        $cpu = (Get-Counter '\Processor(_Total)\% Processor Time' -ErrorAction SilentlyContinue).CounterSamples[0].CookedValue
        $mem = Get-CimInstance Win32_OperatingSystem
        if ($script:ui.CpuMeter) { $script:ui.CpuMeter.Value = $cpu; $script:ui.CpuText.Text = "$([int]$cpu)%" }
        if ($script:ui.RamMeter) { 
            $pct = (($mem.TotalVisibleMemorySize - $mem.FreePhysicalMemory) / $mem.TotalVisibleMemorySize) * 100
            $script:ui.RamMeter.Value = $pct; $script:ui.RamText.Text = "$([math]::Round(($mem.TotalVisibleMemorySize - $mem.FreePhysicalMemory)/1MB, 2)) GB"
        }
        $aiProcs = Get-Process | Where-Object { $_.ProcessName -like "*ollama*" } | Select-Object ProcessName, Id, CPU
        if ($script:ui.MonitorGrid) { $script:ui.MonitorGrid.ItemsSource = $aiProcs }
        
        if ($script:ui.AnalysisStatusText) {
            $ts = Get-Date -Format "HH:mm:ss"
            if ($script:ui.AnalysisProgressBar.Visibility -eq "Collapsed") {
                $script:ui.AnalysisStatusText.Text = "SYSTEM READY | LAST PULSE: $ts"
            }
        }
    }
    catch {}
}

function Show-Page {
    param([string]$PageName)
    $titleMap = @{
        "DashboardView"  = "Security Operations Center"
        "IncidentsView"  = "Incident Response Center"
        "CollectorsView" = "Endpoint Management"
        "MonitorView"    = "Neural Core Monitoring"
        "ReportsView"    = "Intelligence Reports"
        "SettingsView"   = "System Configuration"
    }
    if ($script:ui.PageSubtitle) { $script:ui.PageSubtitle.Text = $titleMap[$PageName] }
    $pages = @("DashboardView", "IncidentsView", "CollectorsView", "MonitorView", "ReportsView", "SettingsView")
    foreach ($p in $pages) { 
        if ($script:ui.$p) { 
            $script:ui.$p.Visibility = $(if ($p -eq $PageName) { "Visible" } else { "Collapsed" }) 
        } 
    }
}

# --- UI Initialization ---
[xml]$xaml = Get-Content (Join-Path $appPath "UI\MainWindow.xaml") -Raw
$window = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))

$script:ui = New-Object System.Collections.Hashtable
$xaml.SelectNodes("//*[@Name or @*[local-name()='Name']]") | ForEach-Object {
    $name = $_.Name; if (-not $name) { $name = $_.Attributes['x:Name'].Value }
    if (-not $name) { foreach ($attr in $_.Attributes) { if ($attr.LocalName -eq "Name") { $name = $attr.Value; break } } }
    $element = $window.FindName($name); if ($element) { $script:ui[$name] = $element }
}

# Fix Logo
if ($script:ui.LogoImage) {
    $logoPath = Join-Path $appPath "logo.png"
    if (Test-Path $logoPath) { $script:ui.LogoImage.Source = New-Object System.Windows.Media.Imaging.BitmapImage(New-Object System.Uri($logoPath)) }
}

# Hydrate Settings
if ($script:ui.ScanIntervalInput) { $script:ui.ScanIntervalInput.Text = [string]$global:AIW_Config['ScanIntervalSeconds'] }
if ($script:ui.ApiEndpointInput) { $script:ui.ApiEndpointInput.Text = [string]$global:AIW_Config['ApiEndpoint'] }
if ($script:ui.AiModelInput) { $script:ui.AiModelInput.Text = [string]$global:AIW_Config['AIModel'] }

# --- Handlers ---
if ($script:ui.NavList) {
    $script:ui.NavList.add_SelectionChanged({
            $item = $script:ui.NavList.SelectedItem
            if ($item) {
                $view = switch ($item.Content) { "SECURITY OPERATIONS CENTER" { "DashboardView" } "INCIDENTS" { "IncidentsView" } "COLLECTORS" { "CollectorsView" } "MONITOR" { "MonitorView" } "REPORTS" { "ReportsView" } "SETTINGS" { "SettingsView" } default { "DashboardView" } }
                Show-Page -PageName $view
            }
        })
}

if ($script:ui.IncidentsGrid) {
    $script:ui.IncidentsGrid.add_SelectionChanged({
            $selected = $script:ui.IncidentsGrid.SelectedItem
            if ($selected) {
                if ($script:ui.RawEventsGrid -and $selected.Events) { $script:ui.RawEventsGrid.ItemsSource = $selected.Events }
                Update-AIIntelligence -Incident $selected
            }
        })
}

if ($script:ui.GenerateHtmlReportButton) {
    $script:ui.GenerateHtmlReportButton.add_Click({
            $script:ui.ReportStatusText.Text = "Status: Generating report..."
            try {
                $reportData = New-AIWExecutiveReport -Alerts $global:AllAlerts -OutputDirectory $script:reportsPath
                $script:ui.ReportStatusText.Text = "Status: Saved to $($reportData.HtmlPath)"
                Start-Process $reportData.HtmlPath
            }
            catch { $script:ui.ReportStatusText.Text = "Status: Error - $($_.Exception.Message)" }
        })
}

if ($script:ui.GenerateDemoAttackButton) {
    $script:ui.GenerateDemoAttackButton.add_Click({
            if ($script:ui.ConsoleParagraph) { $script:ui.ConsoleParagraph.Inlines.Clear() }
            $script:ui.ConsoleParagraph.Inlines.Add("[ ALERT ] SIMULATING INJECTION ATTACK...")
            $demo = New-AIWDemoAttackSequence -Host "HOST-7" -User "admin-svc"
            foreach ($e in $demo) { $global:AllEvents.Add($e) }
            $alerts = Invoke-AIWDetections -Events (@($demo)) -Rules (@($global:AIW_Rules))
            foreach ($a in $alerts) { 
                $global:AllAlerts.Insert(0, $a)
                Update-AIIntelligence -Incident $a
            }
            Update-KPIs; Update-Grids
        })
}

if ($script:ui.SaveSettingsButton) {
    $script:ui.SaveSettingsButton.add_Click({
            $global:AIW_Config['ScanIntervalSeconds'] = [int]$script:ui.ScanIntervalInput.Text
            $global:AIW_Config['AIModel'] = [string]$script:ui.AiModelInput.Text
            Save-AIWSettings -SettingsPath $store.SettingsPath -Settings $global:AIW_Config
            [System.Windows.MessageBox]::Show("Config Saved")
        })
}

# --- Timers ---
$script:AsyncPollTimer = New-Object System.Windows.Threading.DispatcherTimer
$script:AsyncPollTimer.Interval = [TimeSpan]::FromMilliseconds(200)
$script:AsyncPollTimer.add_Tick({
        foreach ($id in [array]($script:AsyncJobs.Keys)) {
            $job = $script:AsyncJobs[$id]
            if ($job.Handle.IsCompleted) {
                $res = $job.PS.EndInvoke($job.Handle); if ($job.Callback) { & $job.Callback $res ($job.PS.Streams.Error | Select-Object -First 1) }
                $job.PS.Dispose(); [void]$script:AsyncJobs.Remove($id)
            }
        }
        if ($script:ui.AnalysisProgressBar.Visibility -eq "Visible") {
            $elapsed = ([DateTime]::Now - $script:analysisStartTime).TotalSeconds
            $statusText = $(switch ($elapsed) { { $_ -lt 5 } { "Extracting Forensic Telemetry" } { $_ -lt 12 } { "Packaging Logs for Gemma-4" } { $_ -lt 25 } { "Transmitting to Neural Core" } default { "Gemma-4: Analyzing Threat" } })
            $script:ui.AnalysisStatusText.Text = "[ $($elapsed.ToString('F1'))s ] $statusText..."
        }
    })
$script:AsyncPollTimer.Start()

$script:TypewriterTimer = New-Object System.Windows.Threading.DispatcherTimer
$script:TypewriterTimer.Interval = [TimeSpan]::FromMilliseconds(10)
$script:TypewriterTimer.add_Tick({
        $charsPerTick = 25
        for ($i = 0; $i -lt $charsPerTick; $i++) {
            if ($script:CurrentSegmentIndex -ge $script:TypewriterSegments.Count) {
                $script:TypewriterTimer.Stop()
                return
            }

            $seg = $script:TypewriterSegments[$script:CurrentSegmentIndex]
        
            # Start new Run if needed
            if ($script:CurrentCharIndex -eq 0) {
                $script:CurrentRun = New-Object System.Windows.Documents.Run
                $script:CurrentRun.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString($seg.Color)
                $script:ui.ConsoleParagraph.Inlines.Add($script:CurrentRun)
            }

            # Type Character
            $script:CurrentRun.Text += $seg.Text[$script:CurrentCharIndex]
            $script:CurrentCharIndex++

            # End of segment?
            if ($script:CurrentCharIndex -ge $seg.Text.Length) {
                $script:CurrentSegmentIndex++
                $script:CurrentCharIndex = 0
                $script:CurrentRun = $null
            }
        
            $script:ui.AISummaryConsole.ScrollToEnd()
        }
    })

$heartbeat = New-Object System.Windows.Threading.DispatcherTimer
$heartbeat.Interval = [TimeSpan]::FromSeconds(1)
$heartbeat.add_Tick({ Update-SystemStats })
$heartbeat.Start()

$script:MonitorTimer = New-Object System.Windows.Threading.DispatcherTimer
$script:MonitorTimer.Interval = [TimeSpan]::FromSeconds($global:AIW_Config['ScanIntervalSeconds'])
$script:MonitorTimer.add_Tick({
        try {
            $minutesBack = [math]::Ceiling(([DateTime]::Now - $script:LastScanTime).TotalMinutes + 1)
            $newEvents = Get-AIWWindowsEvents -MinutesBack $minutesBack | Where-Object { $_.Timestamp -gt $script:LastScanTime }
            if ($newEvents) {
                $script:LastScanTime = [DateTime]::Now
                foreach ($e in $newEvents) { $global:AllEvents.Add($e) }
                $newAlerts = Invoke-AIWDetections -Events (@($newEvents)) -Rules (@($global:AIW_Rules))
                foreach ($a in $newAlerts) { 
                    $global:AllAlerts.Insert(0, $a)
                    if ($a.Severity -eq "Critical") { Update-AIIntelligence -Incident $a }
                }
                Update-KPIs; Update-Grids
            }
        }
        catch {}
    })
$script:MonitorTimer.Start()

Update-KPIs; Update-Grids; Update-SystemStats; Show-Page -PageName "DashboardView"
$window.ShowDialog() | Out-Null
