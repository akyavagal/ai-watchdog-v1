function Initialize-AIWDataStore {
    param(
        [Parameter(Mandatory)] [string]$RootPath
    )

    $dataPath = Join-Path $RootPath "data"
    $reportsPath = Join-Path $RootPath "reports"
    $settingsPath = Join-Path $dataPath "settings.json"
    $eventsPath = Join-Path $dataPath "mock-events.json"
    $rulesPath = Join-Path $dataPath "rules.json"

    if (-not (Test-Path $dataPath)) { New-Item -ItemType Directory -Path $dataPath | Out-Null }
    if (-not (Test-Path $reportsPath)) { New-Item -ItemType Directory -Path $reportsPath | Out-Null }

    if (-not (Test-Path $settingsPath)) {
        $defaultSettings = @{
            ScanIntervalSeconds = 30
            RetentionDays = 14
            AlertThreshold = 5
            Theme = "Dark"
            EnableAIMode = $true
            ApiEndpoint = "http://localhost:11434"
            AIProvider = "Ollama"
            AIModel = "gemma4:e4b"
            UseLiveEventCollection = $true
        }
        $defaultSettings | ConvertTo-Json -Depth 8 | Set-Content -Path $settingsPath -Encoding UTF8 -Force
    }

    if (-not (Test-Path $rulesPath)) {
        $defaultRules = @(
            @{
                RuleId = "R001"
                Name = "Brute Force Success"
                Description = "Brute force success suspected (Multiple failed logins followed by success)"
                Severity = "Critical"
                RiskScore = 95
                MitreTags = "T1110.001 (Brute Force)"
                Type = "Sequence"
                Sequence = @(
                    @{ EventId = 4625; MinCount = 5 },
                    @{ EventId = 4624; MinCount = 1 }
                )
            },
            @{
                RuleId = "R002"
                Name = "Suspicious Encoded PowerShell"
                Description = "Suspicious Encoded PowerShell execution detected"
                Severity = "High"
                RiskScore = 85
                MitreTags = "T1059.001 (Command and Scripting Interpreter)"
                Type = "Single"
                Condition = @{
                    EventId = 4688
                    MessageRegex = @("(?i)powershell", "(?i)(-enc|-encodedcommand)")
                }
            },
            @{
                RuleId = "R003"
                Name = "Service Persistence"
                Description = "New system service installed (Potential Persistence)"
                Severity = "Medium"
                RiskScore = 60
                MitreTags = "T1543.003 (Create or Modify System Process)"
                Type = "Single"
                Condition = @{
                    EventId = 7045
                }
            },
            @{
                RuleId = "R004"
                Name = "Scheduled Task Persistence"
                Description = "New scheduled task created (Potential Persistence)"
                Severity = "High"
                RiskScore = 75
                MitreTags = "T1053.005 (Scheduled Task/Job)"
                Type = "Single"
                Condition = @{
                    EventId = 4698
                }
            },
            @{
                RuleId = "R005"
                Name = "New Admin Account"
                Description = "New local administrator account created"
                Severity = "Critical"
                RiskScore = 90
                MitreTags = "T1136.001 (Create Account: Local Account)"
                Type = "Sequence"
                Sequence = @(
                    @{ EventId = 4720; MinCount = 1 },
                    @{ EventId = 4732; MinCount = 1 }
                )
            },
            @{
                RuleId = "R006"
                Name = "Account Lockout Attack"
                Description = "Multiple account lockouts detected (Denial of Service risk)"
                Severity = "Medium"
                RiskScore = 50
                MitreTags = "T1531 (Account Access Removal)"
                Type = "Sequence"
                Sequence = @(
                    @{ EventId = 4740; MinCount = 3 }
                )
            }
        )
        $defaultRules | ConvertTo-Json -Depth 5 | Set-Content -Path $rulesPath -Encoding UTF8 -Force
    }

    return @{
        DataPath = $dataPath
        ReportsPath = $reportsPath
        SettingsPath = $settingsPath
        EventsPath = $eventsPath
        RulesPath = $rulesPath
    }
}

function Get-AIWSettings {
    param([Parameter(Mandatory)] [string]$SettingsPath)
    if (-not (Test-Path $SettingsPath)) {
        throw "Settings file not found at $SettingsPath"
    }
    $json = Get-Content $SettingsPath -Raw | ConvertFrom-Json
    $hash = New-Object hashtable
    foreach ($prop in $json.psobject.Properties) { $hash[$prop.Name] = $prop.Value }
    return $hash
}

function Save-AIWSettings {
    param(
        [Parameter(Mandatory)] [string]$SettingsPath,
        [Parameter(Mandatory)] [hashtable]$Settings
    )
    $Settings | ConvertTo-Json -Depth 8 | Set-Content -Path $SettingsPath -Encoding UTF8 -Force
}

function Get-AIWMockEvents {
    param([Parameter(Mandatory)] [string]$EventsPath)
    if (-not (Test-Path $EventsPath)) { return @() }
    return Get-Content $EventsPath -Raw | ConvertFrom-Json
}

function Save-AIWMockEvents {
    param(
        [Parameter(Mandatory)] [string]$EventsPath,
        [Parameter(Mandatory)] [array]$Events
    )
    $Events | ConvertTo-Json -Depth 10 | Set-Content -Path $EventsPath -Encoding UTF8 -Force
}

function Get-AIWRules {
    param([Parameter(Mandatory)] [string]$RulesPath)
    if (-not (Test-Path $RulesPath)) { return @() }
    return Get-Content $RulesPath -Raw | ConvertFrom-Json
}

Export-ModuleMember -Function *
