function New-AIWDemoEvents {
    param([int]$Count = 100)
    
    $events = @()
    $baseTime = (Get-Date).AddMinutes(-$Count)
    
    $hosts = @("WKSTN-014", "WKSTN-092", "SRV-WEB-01", "SRV-DC-01", "WKSTN-055")
    $users = @("jdoe", "asmith", "bjohnson", "msott", "SYSTEM")
    $domains = @("CORP", "NT AUTHORITY")
    
    $attackerIp = "192.168.1.105"
    $targetHost = "SRV-WEB-01"
    
    $attackStartIndex = [int]($Count * 0.5)
    
    for ($i = 0; $i -lt $Count; $i++) {
        $timestamp = $baseTime.AddMinutes($i).AddSeconds((Get-Random -Minimum 1 -Maximum 59))
        
        if ($i -eq $attackStartIndex) {
            for ($f = 0; $f -lt 5; $f++) {
                $events += [pscustomobject]@{
                    TimeCreated = $timestamp.AddSeconds($f * 2).ToString("o")
                    Timestamp = $timestamp.AddSeconds($f * 2)
                    EventId = 4625
                    Computer = $targetHost
                    Host = $targetHost
                    LogName = "Security"
                    ProviderName = "Microsoft-Windows-Security-Auditing"
                    Level = "Information"
                    Message = "An account failed to log on.`r`n`r`nSubject:`r`n`tSecurity ID:`t`tNULL SID`r`n`tAccount Name:`t`t-`r`n`tAccount Domain:`t`t-`r`n`tLogon ID:`t`t0x0`r`n`r`nLogon Type:`t`t3`r`n`r`nAccount For Which Logon Failed:`r`n`tSecurity ID:`t`tNULL SID`r`n`tAccount Name:`t`tsvc_apache`r`n`tAccount Domain:`t`tCORP`r`n`r`nFailure Information:`r`n`tFailure Reason:`t`tUnknown user name or bad password.`r`n`tStatus:`t`t`t0xC000006D`r`n`tSub Status:`t`t0xC000006A`r`n`r`nNetwork Information:`r`n`tWorkstation Name:`t-`r`n`tSource Network Address:`t$attackerIp`r`n`tSource Port:`t`t49152"
                    AccountName = "svc_apache"
                    AccountDomain = "CORP"
                    IpAddress = $attackerIp
                    ProcessName = "-"
                    CommandLine = "-"
                    ServiceName = "-"
                }
            }
            $events += [pscustomobject]@{
                TimeCreated = $timestamp.AddSeconds(12).ToString("o")
                Timestamp = $timestamp.AddSeconds(12)
                EventId = 4624
                Computer = $targetHost
                Host = $targetHost
                LogName = "Security"
                ProviderName = "Microsoft-Windows-Security-Auditing"
                Level = "Information"
                Message = "An account was successfully logged on.`r`n`r`nSubject:`r`n`tSecurity ID:`t`tNULL SID`r`n`tAccount Name:`t`t-`r`n`tAccount Domain:`t`t-`r`n`tLogon ID:`t`t0x0`r`n`r`nLogon Information:`r`n`tLogon Type:`t`t3`r`n`r`nNew Logon:`r`n`tSecurity ID:`t`tCORP\svc_apache`r`n`tAccount Name:`t`tsvc_apache`r`n`tAccount Domain:`t`tCORP`r`n`tLogon ID:`t`t0x1A2B3C`r`n`r`nNetwork Information:`r`n`tWorkstation Name:`t-`r`n`tSource Network Address:`t$attackerIp`r`n`tSource Port:`t`t49153"
                AccountName = "svc_apache"
                AccountDomain = "CORP"
                IpAddress = $attackerIp
                ProcessName = "-"
                CommandLine = "-"
                ServiceName = "-"
            }
            $events += [pscustomobject]@{
                TimeCreated = $timestamp.AddSeconds(13).ToString("o")
                Timestamp = $timestamp.AddSeconds(13)
                EventId = 4672
                Computer = $targetHost
                Host = $targetHost
                LogName = "Security"
                ProviderName = "Microsoft-Windows-Security-Auditing"
                Level = "Information"
                Message = "Special privileges assigned to new logon.`r`n`r`nSubject:`r`n`tSecurity ID:`t`tCORP\svc_apache`r`n`tAccount Name:`t`tsvc_apache`r`n`tAccount Domain:`t`tCORP`r`n`tLogon ID:`t`t0x1A2B3C`r`n`r`nPrivileges:`t`tSeSecurityPrivilege`r`n`t`t`tSeBackupPrivilege`r`n`t`t`tSeRestorePrivilege`r`n`t`t`tSeTakeOwnershipPrivilege`r`n`t`t`tSeDebugPrivilege`r`n`t`t`tSeSystemEnvironmentPrivilege`r`n`t`t`tSeLoadDriverPrivilege`r`n`t`t`tSeImpersonatePrivilege"
                AccountName = "svc_apache"
                AccountDomain = "CORP"
                IpAddress = "-"
                ProcessName = "-"
                CommandLine = "-"
                ServiceName = "-"
            }
            $events += [pscustomobject]@{
                TimeCreated = $timestamp.AddSeconds(20).ToString("o")
                Timestamp = $timestamp.AddSeconds(20)
                EventId = 4688
                Computer = $targetHost
                Host = $targetHost
                LogName = "Security"
                ProviderName = "Microsoft-Windows-Security-Auditing"
                Level = "Information"
                Message = "A new process has been created.`r`n`r`nCreator Subject:`r`n`tSecurity ID:`t`tCORP\svc_apache`r`n`tAccount Name:`t`tsvc_apache`r`n`tAccount Domain:`t`tCORP`r`n`tLogon ID:`t`t0x1A2B3C`r`n`r`nTarget Subject:`r`n`tSecurity ID:`t`tNULL SID`r`n`tAccount Name:`t`t-`r`n`tAccount Domain:`t`t-`r`n`tLogon ID:`t`t0x0`r`n`r`nProcess Information:`r`n`tNew Process ID:`t`t0x1F44`r`n`tNew Process Name:`tC:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`r`n`tToken Elevation Type:`t%%1936`r`n`tMandatory Label:`t`tMandatory Label\High Mandatory Level`r`n`tCreator Process ID:`t0x8C4`r`n`tCreator Process Name:`tC:\Windows\System32\cmd.exe`r`n`tProcess Command Line:`tpowershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -EncodedCommand JABzAD0ATgBlAHcALQBPAGIAagBlAGMAdAAgAEkATwAuAE0AZQBtAG8AcgB5AFMAdAByAGUAYQBtACgAWwBDAG8AbgB2AGUAcgB0AF0AOgA6AEYAcgBvAG0AQgBhAHMAZQA2ADQAUwB0AHIAaQBuAGcAKAAiAEgA"
                AccountName = "svc_apache"
                AccountDomain = "CORP"
                IpAddress = "-"
                ProcessName = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
                CommandLine = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -EncodedCommand JABzAD0ATgBlAHcALQBPAGIAagBlAGMAdAAgAEkATwAuAE0AZQBtAG8AcgB5AFMAdAByAGUAYQBtACgAWwBDAG8AbgB2AGUAcgB0AF0AOgA6AEYAcgBvAG0AQgBhAHMAZQA2ADQAUwB0AHIAaQBuAGcAKAAiAEgA"
                ServiceName = "-"
            }
            $events += [pscustomobject]@{
                TimeCreated = $timestamp.AddSeconds(35).ToString("o")
                Timestamp = $timestamp.AddSeconds(35)
                EventId = 7045
                Computer = $targetHost
                Host = $targetHost
                LogName = "System"
                ProviderName = "Service Control Manager"
                Level = "Information"
                Message = "A service was installed in the system.`r`n`r`nService Name:  WinRM_Management`r`nService File Name:  C:\Users\Public\svchost.exe`r`nService Type:  user mode service`r`nService Start Type:  auto start`r`nService Account:  LocalSystem"
                AccountName = "LocalSystem"
                AccountDomain = "NT AUTHORITY"
                IpAddress = "-"
                ProcessName = "-"
                CommandLine = "-"
                ServiceName = "WinRM_Management"
            }
            $events += [pscustomobject]@{
                TimeCreated = $timestamp.AddSeconds(45).ToString("o")
                Timestamp = $timestamp.AddSeconds(45)
                EventId = 4698
                Computer = $targetHost
                Host = $targetHost
                LogName = "Security"
                ProviderName = "Microsoft-Windows-Security-Auditing"
                Level = "Information"
                Message = "A scheduled task was created.`r`n`r`nSubject:`r`n`tSecurity ID:`t`tCORP\svc_apache`r`n`tAccount Name:`t`tsvc_apache`r`n`tAccount Domain:`t`tCORP`r`n`tLogon ID:`t`t0x1A2B3C`r`n`r`nTask Information:`r`n`tTask Name:`t`t\Microsoft\Windows\AppID\PolicyConverter_Update`r`n`tTask Content:`t`t<?xml version=`"1.0`" encoding=`"UTF-16`"?>...<Command>C:\Users\Public\svchost.exe</Command>..."
                AccountName = "svc_apache"
                AccountDomain = "CORP"
                IpAddress = "-"
                ProcessName = "-"
                CommandLine = "-"
                ServiceName = "-"
            }
            $i += 6 # Skip to account for the injected events
        } else {
            $h = $hosts | Get-Random
            $u = $users | Get-Random
            $d = $domains | Get-Random
            $normalEvents = @(4624, 4672, 4688)
            $eId = $normalEvents | Get-Random
            
            if ($eId -eq 4624) {
                $events += [pscustomobject]@{
                    TimeCreated = $timestamp.ToString("o")
                    Timestamp = $timestamp
                    EventId = 4624
                    Computer = $h
                    Host = $h
                    LogName = "Security"
                    ProviderName = "Microsoft-Windows-Security-Auditing"
                    Level = "Information"
                    Message = "An account was successfully logged on.`r`n`r`nSubject:`r`n`tSecurity ID:`t`tNULL SID`r`n`tAccount Name:`t`t-`r`n`tAccount Domain:`t`t-`r`n`tLogon ID:`t`t0x0`r`n`r`nNew Logon:`r`n`tSecurity ID:`t`t$d\$u`r`n`tAccount Name:`t`t$u`r`n`tAccount Domain:`t`t$d`r`n`tLogon ID:`t`t0x$((Get-Random -Min 1000 -Max 9999).ToString('X'))`r`n`r`nNetwork Information:`r`n`tWorkstation Name:`t-`r`n`tSource Network Address:`t10.0.$((Get-Random -Min 1 -Max 254)).$((Get-Random -Min 1 -Max 254))`r`n`tSource Port:`t`t$((Get-Random -Min 1024 -Max 65535))"
                    AccountName = $u
                    AccountDomain = $d
                    IpAddress = "10.0.$((Get-Random -Min 1 -Max 254)).$((Get-Random -Min 1 -Max 254))"
                    ProcessName = "-"
                    CommandLine = "-"
                    ServiceName = "-"
                }
            } elseif ($eId -eq 4672) {
                $events += [pscustomobject]@{
                    TimeCreated = $timestamp.ToString("o")
                    Timestamp = $timestamp
                    EventId = 4672
                    Computer = $h
                    Host = $h
                    LogName = "Security"
                    ProviderName = "Microsoft-Windows-Security-Auditing"
                    Level = "Information"
                    Message = "Special privileges assigned to new logon.`r`n`r`nSubject:`r`n`tSecurity ID:`t`t$d\$u`r`n`tAccount Name:`t`t$u`r`n`tAccount Domain:`t`t$d`r`n`tLogon ID:`t`t0x$((Get-Random -Min 1000 -Max 9999).ToString('X'))`r`n`r`nPrivileges:`t`tSeSecurityPrivilege`r`n`t`t`tSeBackupPrivilege"
                    AccountName = $u
                    AccountDomain = $d
                    IpAddress = "-"
                    ProcessName = "-"
                    CommandLine = "-"
                    ServiceName = "-"
                }
            } elseif ($eId -eq 4688) {
                $procs = @("C:\Windows\System32\svchost.exe", "C:\Program Files\Chrome\Application\chrome.exe", "C:\Windows\explorer.exe", "C:\Windows\System32\cmd.exe", "C:\Windows\System32\notepad.exe")
                $p = $procs | Get-Random
                $events += [pscustomobject]@{
                    TimeCreated = $timestamp.ToString("o")
                    Timestamp = $timestamp
                    EventId = 4688
                    Computer = $h
                    Host = $h
                    LogName = "Security"
                    ProviderName = "Microsoft-Windows-Security-Auditing"
                    Level = "Information"
                    Message = "A new process has been created.`r`n`r`nCreator Subject:`r`n`tSecurity ID:`t`t$d\$u`r`n`tAccount Name:`t`t$u`r`n`tAccount Domain:`t`t$d`r`n`tLogon ID:`t`t0x$((Get-Random -Min 1000 -Max 9999).ToString('X'))`r`n`r`nProcess Information:`r`n`tNew Process Name:`t$p`r`n`tProcess Command Line:`t$p"
                    AccountName = $u
                    AccountDomain = $d
                    IpAddress = "-"
                    ProcessName = $p
                    CommandLine = $p
                    ServiceName = "-"
                }
            }
        }
    }
    
    return $events | Select-Object -First $Count | Sort-Object Timestamp
}

function New-AIWDemoAttackSequence {
    param([string]$Host = "SRV-WEB-01", [string]$User = "admin-svc")
    
    $baseTime = Get-Date
    $events = @()
    $attackerIp = "192.168.1.105"

    for ($f = 0; $f -lt 5; $f++) {
        $events += [pscustomobject]@{
            TimeCreated = $baseTime.AddSeconds(-60 + ($f * 2)).ToString("o")
            Timestamp = $baseTime.AddSeconds(-60 + ($f * 2))
            EventId = 4625
            Computer = $Host
            Host = $Host
            LogName = "Security"
            ProviderName = "Microsoft-Windows-Security-Auditing"
            Level = "Information"
            Message = "An account failed to log on.`r`n`r`nSubject:`r`n`tSecurity ID:`t`tNULL SID`r`n`tAccount Name:`t`t-`r`n`tAccount Domain:`t`t-`r`n`tLogon ID:`t`t0x0`r`n`r`nLogon Type:`t`t3`r`n`r`nAccount For Which Logon Failed:`r`n`tSecurity ID:`t`tNULL SID`r`n`tAccount Name:`t`t$User`r`n`tAccount Domain:`t`tCORP`r`n`r`nFailure Information:`r`n`tFailure Reason:`t`tUnknown user name or bad password.`r`n`tStatus:`t`t`t0xC000006D`r`n`tSub Status:`t`t0xC000006A`r`n`r`nNetwork Information:`r`n`tWorkstation Name:`t-`r`n`tSource Network Address:`t$attackerIp`r`n`tSource Port:`t`t49152"
            AccountName = $User
            AccountDomain = "CORP"
            IpAddress = $attackerIp
            ProcessName = "-"
            CommandLine = "-"
            ServiceName = "-"
        }
    }
    
    $events += [pscustomobject]@{
        TimeCreated = $baseTime.AddSeconds(-45).ToString("o")
        Timestamp = $baseTime.AddSeconds(-45)
        EventId = 4624
        Computer = $Host
        Host = $Host
        LogName = "Security"
        ProviderName = "Microsoft-Windows-Security-Auditing"
        Level = "Information"
        Message = "An account was successfully logged on.`r`n`r`nSubject:`r`n`tSecurity ID:`t`tNULL SID`r`n`tAccount Name:`t`t-`r`n`tAccount Domain:`t`t-`r`n`tLogon ID:`t`t0x0`r`n`r`nLogon Information:`r`n`tLogon Type:`t`t3`r`n`r`nNew Logon:`r`n`tSecurity ID:`t`tCORP\$User`r`n`tAccount Name:`t`t$User`r`n`tAccount Domain:`t`tCORP`r`n`tLogon ID:`t`t0x1A2B3C`r`n`r`nNetwork Information:`r`n`tWorkstation Name:`t-`r`n`tSource Network Address:`t$attackerIp`r`n`tSource Port:`t`t49153"
        AccountName = $User
        AccountDomain = "CORP"
        IpAddress = $attackerIp
        ProcessName = "-"
        CommandLine = "-"
        ServiceName = "-"
    }
    $events += [pscustomobject]@{
        TimeCreated = $baseTime.AddSeconds(-44).ToString("o")
        Timestamp = $baseTime.AddSeconds(-44)
        EventId = 4672
        Computer = $Host
        Host = $Host
        LogName = "Security"
        ProviderName = "Microsoft-Windows-Security-Auditing"
        Level = "Information"
        Message = "Special privileges assigned to new logon.`r`n`r`nSubject:`r`n`tSecurity ID:`t`tCORP\$User`r`n`tAccount Name:`t`t$User`r`n`tAccount Domain:`t`tCORP`r`n`tLogon ID:`t`t0x1A2B3C`r`n`r`nPrivileges:`t`tSeSecurityPrivilege`r`n`t`t`tSeBackupPrivilege`r`n`t`t`tSeRestorePrivilege`r`n`t`t`tSeTakeOwnershipPrivilege`r`n`t`t`tSeDebugPrivilege`r`n`t`t`tSeSystemEnvironmentPrivilege`r`n`t`t`tSeLoadDriverPrivilege`r`n`t`t`tSeImpersonatePrivilege"
        AccountName = $User
        AccountDomain = "CORP"
        IpAddress = "-"
        ProcessName = "-"
        CommandLine = "-"
        ServiceName = "-"
    }
    $events += [pscustomobject]@{
        TimeCreated = $baseTime.AddSeconds(-35).ToString("o")
        Timestamp = $baseTime.AddSeconds(-35)
        EventId = 4688
        Computer = $Host
        Host = $Host
        LogName = "Security"
        ProviderName = "Microsoft-Windows-Security-Auditing"
        Level = "Information"
        Message = "A new process has been created.`r`n`r`nCreator Subject:`r`n`tSecurity ID:`t`tCORP\$User`r`n`tAccount Name:`t`t$User`r`n`tAccount Domain:`t`tCORP`r`n`tLogon ID:`t`t0x1A2B3C`r`n`r`nProcess Information:`r`n`tNew Process Name:`tC:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`r`n`tProcess Command Line:`tpowershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -EncodedCommand JABzAD0ATgBlAHcALQBPAGIAagBlAGMAdAAgAEkATwAuAE0AZQBtAG8AcgB5AFMAdAByAGUAYQBtACgAWwBDAG8AbgB2AGUAcgB0AF0AOgA6AEYAcgBvAG0AQgBhAHMAZQA2ADQAUwB0AHIAaQBuAGcAKAAiAEgA"
        AccountName = $User
        AccountDomain = "CORP"
        IpAddress = "-"
        ProcessName = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
        CommandLine = "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -EncodedCommand JABzAD0ATgBlAHcALQBPAGIAagBlAGMAdAAgAEkATwAuAE0AZQBtAG8AcgB5AFMAdAByAGUAYQBtACgAWwBDAG8AbgB2AGUAcgB0AF0AOgA6AEYAcgBvAG0AQgBhAHMAZQA2ADQAUwB0AHIAaQBuAGcAKAAiAEgA"
        ServiceName = "-"
    }
    $events += [pscustomobject]@{
        TimeCreated = $baseTime.AddSeconds(-20).ToString("o")
        Timestamp = $baseTime.AddSeconds(-20)
        EventId = 7045
        Computer = $Host
        Host = $Host
        LogName = "System"
        ProviderName = "Service Control Manager"
        Level = "Information"
        Message = "A service was installed in the system.`r`n`r`nService Name:  WinRM_Management`r`nService File Name:  C:\Users\Public\svchost.exe`r`nService Type:  user mode service`r`nService Start Type:  auto start`r`nService Account:  LocalSystem"
        AccountName = "LocalSystem"
        AccountDomain = "NT AUTHORITY"
        IpAddress = "-"
        ProcessName = "-"
        CommandLine = "-"
        ServiceName = "WinRM_Management"
    }

    return $events
}

Export-ModuleMember -Function New-AIWDemoEvents, New-AIWDemoAttackSequence
