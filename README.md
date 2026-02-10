# Windows Temp Cleaner

A lightweight Windows utility to safely remove temporary files and free up disk space.

This tool is designed for **local and personal use** and focuses on simplicity, transparency, and safety.

---

## ✨ Features

- Clean **User TEMP** folder
- Clean **Windows TEMP** folder (admin)
- Optional **Prefetch** cleanup
- Clear **Recycle Bin**
- Simple Windows GUI
- No background services
- No telemetry
- No registry modification
- No internet access

---

## 📦 Files Included

- `WinTempCleaner.exe` – Prebuilt executable (PowerShell-based)
- `WinTempCleaner.ps1` – Full source code (readable and auditable)
- `cleaner.ico` – Application icon

---

## ⚠️ Important Security Notice (PLEASE READ)

This application is built using **PowerShell and packaged as an EXE**.

Because of this, **some antivirus engines may flag the executable as suspicious or malicious**.  
This is a **false positive** caused by heuristic and machine-learning detection.

### Why this happens
- PowerShell-based executables are commonly abused by malware
- This tool requires **Administrator privileges**
- It deletes files recursively from temporary locations

### What this tool does NOT do
- ❌ No data collection
- ❌ No network communication
- ❌ No persistence (startup, scheduled tasks, services)
- ❌ No registry changes
- ❌ No hidden behavior

You are encouraged to:
- Review the source code (`WinTempCleaner.ps1`)
- Run the script directly instead of the EXE if preferred
- Use this tool only if you understand what it does

---

## 🛡 Antivirus Detections (False Positives)

Some antivirus products may detect the EXE as:
- `Trojan`
- `AI.Malicious`
- `SusGen`

These detections are **heuristic-based**, not signature-based.

If you are concerned:
- Run the `.ps1` script directly
- Build the EXE yourself from source
- Add a local exclusion if you trust the tool

---

## ▶ How to Use

### Option 1: Run EXE
1. Right-click `WinTempCleaner.exe`
2. Select **Run as administrator**
3. Choose items to clean
4. Click **Start Cleaning**

5. ## Option 2: Run PowerShell Script (Direct from GitHub)

You can run the script directly without downloading files manually.

> This command applies only to the current PowerShell session and does not permanently change system execution policy.

```powershell
irm https://raw.githubusercontent.com/F3aarLeSS/WinTempCleaner/main/WinTempCleaner.ps1 | iex
