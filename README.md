# AI Watchdog v1.0
> **Affordable cybersecurity for every Windows organization.**

AI Watchdog v1.0 is a polished Windows desktop application designed to turn unread Windows Event Logs into clear, actionable security incidents. Built for SMBs, schools, and IT admins, it provides a premium "Command Center" experience for threat detection.

## 🚀 Core MVP Features

- 🔐 Fully local, privacy-first AI inference
- ⚡ Real-time event monitoring (Simulated)
- 🧠 Multi-stage threat detection (behavioral patterns - Simulated)
- 📊 Human-readable intelligence outputs
- 🧪 Built-in attack simulation for demonstration purpose
- 💻 Runs on standard hardware (no enterprise infra required)

## 🛠️ Tech Stack

- **Frontend**: PowerShell + WPF (XAML)
- **Backend**: PowerShell Modules
- **Storage**: Local JSON
- **UI**: Premium Cyber Dark Theme

## 📦 Getting Started

### Prerequisites
- Windows 10/11 or Windows Server 2019+
- PowerShell 5.1 (Standard on Windows)
- Administrator Privileges
- Ollama (for running local AI models)

### 🤖 Local AI Setup (Ollama + Gemma4)

AI Watchdog uses a local Gemma4 model via Ollama for private, on-device inference.

#### 1. Install Ollama (Windows)

Download and install Ollama from:
https://ollama.com/download

or

Run the following command in **PowerShell** to install Ollama:

```powershell
**irm https://ollama.com/install.ps1 | iex**

After installation, verify:


```powershell
ollama --version

> ⚠️ This installs Ollama locally on your system. No data is sent externally by AI Watchdog during inference.

### 🤖 Install Gemma Model

After installing Ollama, pull a Gemma model:

```powershell
ollama pull gemma4:e2b

ollama run gemma4:e2b
<img width="980" height="678" alt="image" src="https://github.com/user-attachments/assets/6d22cce3-4f13-47f3-9966-e8d82353c6d7" />

### 🔌 Ollama Service Requirement

AI Watchdog connects to a locally running Ollama instance.

Ensure Ollama is running at:
http://localhost:11434/

<img width="318" height="191" alt="image" src="https://github.com/user-attachments/assets/d16cf2e0-a018-4dca-a385-caa6b12c5cd2" />

By default, Ollama starts automatically after installation.  
You can verify it is running by executing:

```powershell
ollama list

<img width="535" height="331" alt="image" src="https://github.com/user-attachments/assets/38099632-1b98-477a-a456-3dfb8dd8a3c9" />


### Installation
1. Clone or extract the `AIWatchdog` folder.
2. Open PowerShell as **Administrator**.
3. Run the application:
   ```powershell
   cd .\app
   .\Main.ps1
   ```
<img width="585" height="115" alt="image" src="https://github.com/user-attachments/assets/28e61407-f373-4e75-aa79-877c088463ad" />

## 🛡️ Demo Mode
Click the **"Run Simulation"** button in the Incidents tab to simulate an attack involving brute force, credential theft, and persistence.

<img width="1299" height="311" alt="image" src="https://github.com/user-attachments/assets/7931699e-4009-46f4-a33a-24cd8d27857b" />

---
*© 2026 AI Watchdog Security. All rights reserved.*
