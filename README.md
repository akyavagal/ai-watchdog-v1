# 🛡️ AI Watchdog v1.0


**AI Watchdog: A Local-First Cybersecurity Assistant Powered by Gemma 4
Bringing real-time, private cybersecurity intelligence to every organization — regardless of size or resources.**

> **Affordable cybersecurity for every Windows organization.**
---
<img width="379" height="369" alt="image" src="https://github.com/user-attachments/assets/ccbd0f1b-c3f8-4692-8d37-f2db50121109" />


## 🚀 Core MVP Features

- 🔐 Fully local, privacy-first AI inference  
- ⚡ Real-time event monitoring *(simulated)*  
- 🧠 Multi-stage threat detection *(behavioral patterns - simulated)*  
- 📊 Human-readable intelligence outputs  
- 🧪 Built-in attack simulation for demonstration purposes  
- 💻 Runs on standard hardware *(no enterprise infrastructure required)*  

---

## 🛠️ Tech Stack

- **Frontend**: PowerShell + WPF (XAML)  
- **Backend**: PowerShell Modules  
- **Storage**: Local JSON  
- **UI**: Premium Cyber Dark Theme  

---

## 📦 Getting Started

### ✅ Prerequisites

- Windows 10/11 or Windows Server 2019+  
- PowerShell 5.1 (pre-installed on Windows)  
- Administrator privileges  
- Ollama (for running local AI models)  

---

## 🤖 Local AI Setup (Ollama + Gemma)

AI Watchdog uses a local **Gemma model** via Ollama for private, on-device inference.

### 1️⃣ Install Ollama (Windows)

Download from:  
👉 https://ollama.com/download  

Or install using PowerShell:

```powershell
irm https://ollama.com/install.ps1 | iex
```

Verify installation:

```powershell
ollama --version
```

> ⚠️ Ollama runs locally. AI Watchdog does **not** send any data externally during inference.

---

## 🤖 Install Gemma Model

Pull and run the model:

```powershell
ollama pull gemma4:e2b
ollama run gemma4:e2b
```

![Gemma Model Running](https://github.com/user-attachments/assets/6d22cce3-4f13-47f3-9966-e8d82353c6d7)

---

## 🔌 Ollama Service Requirement

AI Watchdog connects to a locally running Ollama instance.

Default endpoint:

```
http://localhost:11434/
```

![Ollama Service](https://github.com/user-attachments/assets/d16cf2e0-a018-4dca-a385-caa6b12c5cd2)

---

## ⚙️ Installation

1. Clone the repository:

```bash
git clone https://github.com/your-username/AIWatchdog.git
```

2. Open PowerShell as **Administrator**

3. Navigate to the app directory and run:

```powershell
cd .\AIWatchdog\app
.\Main.ps1
```

![App Launch](https://github.com/user-attachments/assets/28e61407-f373-4e75-aa79-877c088463ad)

---

## 🛡️ Demo Mode

Click **"Run Simulation"** in the *Incidents* tab to simulate:

- Brute force attacks  
- Credential theft  
- Persistence mechanisms  

![Simulation Demo](https://github.com/user-attachments/assets/7931699e-4009-46f4-a33a-24cd8d27857b)

---

## 📌 Notes

- Designed for **local-first security**
- No cloud dependency required  
- Ideal for:
  - Small and Medium Businesses (SMBs)
  - Educational institutions  
  - IT administrators  

---
## 🤖 Development Approach

AI Watchdog was developed using an AI-assisted workflow leveraging:

- Google Gemini 3 Flash  
- Google Antigravity (Version: 1.23.2) 

This approach accelerated prototyping, UI iteration, and system design while maintaining full control over architecture and implementation.


## 🧯 Troubleshooting

### ❌ Script execution is disabled

If you see:
> *"running scripts is disabled on this system"*

Run PowerShell as **Administrator** and execute:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
```

Then run the app again:

```powershell
.\Main.ps1
```

### ❌ Ollama not detected

Ensure Ollama is running:

```powershell
ollama list
```

If not, restart Ollama or your system.

---

## 📄 License

© 2026 AI Watchdog Labs. All rights reserved.
