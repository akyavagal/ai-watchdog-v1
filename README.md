# AI Watchdog v1.0
> **Affordable cybersecurity for every Windows organization.**

AI Watchdog v1.0 is a polished Windows desktop application designed to turn unread Windows Event Logs into clear, actionable security incidents. Built for SMBs, schools, and IT admins, it provides a premium "Command Center" experience for threat detection.

## 🚀 Core MVP Features

- **Autonomous AI Intelligence**: Critical threats automatically trigger **Gemma-4** neural analysis for zero-touch remediation playbooks.
- **Generalized Detection Engine**: Robust N-step behavioral analysis for detecting complex, multi-stage attack chains.
- **Incremental Nitro Scans**: High-performance event processing with minimal system overhead.
- **Executive Reporting v2**: Premium, data-rich HTML reporting with modern aesthetic.
- **Fleet Management**: Unified monitoring of managed endpoints.

## 🛠️ Tech Stack

- **Frontend**: PowerShell + WPF (XAML)
- **Backend**: PowerShell Modules
- **Storage**: Local JSON (SQLite Ready)
- **UI**: Premium Cyber Dark Theme

## 📦 Getting Started

### Prerequisites
- Windows 10/11 or Windows Server 2019+
- PowerShell 5.1 (Standard on Windows)
- **Administrator Privileges** (Required for reading Security Logs)

### Installation
1. Clone or extract the `AIWatchdog` folder.
2. Open PowerShell as **Administrator**.
3. Run the application:
   ```powershell
   cd .\app
   .\Main.ps1
   ```

### Building the EXE
To compile to a standalone executable, run the build script:
```powershell
cd .\build
.\Build-EXE.ps1
```

## 🛡️ Demo Mode
Click the **"DEMO ATTACK"** button in the Incidents tab to simulate a complex, multi-stage attack involving brute force, credential theft, and persistence.

---
*© 2026 AI Watchdog Security. All rights reserved.*
