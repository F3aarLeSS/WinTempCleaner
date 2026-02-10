# ================================
# LOAD ASSEMBLIES
# ================================
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)

# ================================
# ADMIN CHECK
# ================================
function Test-IsAdmin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
    [System.Windows.Forms.MessageBox]::Show(
        "Please run this application as Administrator.",
        "Permission Required",
        "OK",
        "Error"
    )
    exit
}

# ================================
# SAFE CLEAN FUNCTION
# ================================
function Safe-CleanFolder {
    param($Path)
    if (Test-Path $Path) {
        Get-ChildItem $Path -Force -ErrorAction SilentlyContinue |
            Where-Object { -not $_.Attributes.ToString().Contains("ReparsePoint") } |
            Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# ================================
# FORM
# ================================
$form = New-Object System.Windows.Forms.Form
$form.Text = "Windows Temp Cleaner"
$form.Size = New-Object System.Drawing.Size(500, 380)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.AutoScaleMode = 'Dpi'
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)

# ================================
# ICON
# ================================
$exeDir = [AppDomain]::CurrentDomain.BaseDirectory
$iconPath = Join-Path $exeDir "cleaner.ico"
if (Test-Path $iconPath) {
    $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
}

# ================================
# TITLE
# ================================
$title = New-Object System.Windows.Forms.Label
$title.Text = "Windows Temp Cleaner"
$title.Font = New-Object System.Drawing.Font(
    "Segoe UI", 14, [System.Drawing.FontStyle]::Bold
)
$title.AutoSize = $true
$title.Location = '150,15'
[void]$form.Controls.Add($title)

# ================================
# GROUP BOX
# ================================
$group = New-Object System.Windows.Forms.GroupBox
$group.Text = "Select items to clean"
$group.Size = '440,140'
$group.Location = '25,55'
[void]$form.Controls.Add($group)

$cbUserTemp = New-Object System.Windows.Forms.CheckBox
$cbUserTemp.Text = "User Temp"
$cbUserTemp.Checked = $true
$cbUserTemp.Location = '15,30'
[void]$group.Controls.Add($cbUserTemp)

$cbWinTemp = New-Object System.Windows.Forms.CheckBox
$cbWinTemp.Text = "Windows Temp"
$cbWinTemp.Checked = $true
$cbWinTemp.Location = '15,55'
[void]$group.Controls.Add($cbWinTemp)

$cbPrefetch = New-Object System.Windows.Forms.CheckBox
$cbPrefetch.Text = "Prefetch Files"
$cbPrefetch.Location = '15,80'
[void]$group.Controls.Add($cbPrefetch)

$cbRecycle = New-Object System.Windows.Forms.CheckBox
$cbRecycle.Text = "Recycle Bin"
$cbRecycle.Checked = $true
$cbRecycle.Location = '250,30'
[void]$group.Controls.Add($cbRecycle)

# ================================
# STATUS + PROGRESS
# ================================
$status = New-Object System.Windows.Forms.Label
$status.Text = "Ready"
$status.Location = '25,210'
[void]$form.Controls.Add($status)

$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Location = '25,235'
$progress.Size = '440,20'
$progress.Style = 'Blocks'
[void]$form.Controls.Add($progress)

# ================================
# BUTTONS
# ================================
$aboutBtn = New-Object System.Windows.Forms.Button
$aboutBtn.Text = "About"
$aboutBtn.Size = '90,32'

$startBtn = New-Object System.Windows.Forms.Button
$startBtn.Text = "Start Cleaning"
$startBtn.Size = '140,32'
$startBtn.Font = New-Object System.Drawing.Font(
    "Segoe UI", 9, [System.Drawing.FontStyle]::Bold
)

$exitBtn = New-Object System.Windows.Forms.Button
$exitBtn.Text = "Exit"
$exitBtn.Size = '90,32'

$btnPanel = New-Object System.Windows.Forms.TableLayoutPanel
$btnPanel.RowCount = 1
$btnPanel.ColumnCount = 3
$btnPanel.Size = '440,40'
$btnPanel.Location = '25,280'

[void]$btnPanel.ColumnStyles.Add(
    (New-Object System.Windows.Forms.ColumnStyle(
        [System.Windows.Forms.SizeType]::Percent, 33)))
[void]$btnPanel.ColumnStyles.Add(
    (New-Object System.Windows.Forms.ColumnStyle(
        [System.Windows.Forms.SizeType]::Percent, 34)))
[void]$btnPanel.ColumnStyles.Add(
    (New-Object System.Windows.Forms.ColumnStyle(
        [System.Windows.Forms.SizeType]::Percent, 33)))

$aboutBtn.Anchor = 'None'
$startBtn.Anchor = 'None'
$exitBtn.Anchor = 'None'

[void]$btnPanel.Controls.Add($aboutBtn, 0, 0)
[void]$btnPanel.Controls.Add($startBtn, 1, 0)
[void]$btnPanel.Controls.Add($exitBtn, 2, 0)
[void]$form.Controls.Add($btnPanel)

# ================================
# EVENTS
# ================================
$exitBtn.Add_Click({ $form.Close() })

$aboutBtn.Add_Click({
    $githubUrl = "https://github.com/F3aarLeSS/WinTempCleaner"   # CHANGE THIS

    $msg = "Windows Temp Cleaner v1.1`n`n" +
           "Author: Navajyoti Bayan`n`n" +
           "This tool removes temporary files only.`n" +
           "No telemetry. No persistence.`n`n" +
           "GitHub:`n$githubUrl`n`n" +
           "Click OK to open GitHub page."

    if ([System.Windows.Forms.MessageBox]::Show(
        $msg,
        "About",
        "OKCancel",
        "Information"
    ) -eq "OK") {
        Start-Process $githubUrl
    }
})

# ================================
# START CLEANING
# ================================
$startBtn.Add_Click({

    if (-not ($cbUserTemp.Checked -or $cbWinTemp.Checked -or
              $cbPrefetch.Checked -or $cbRecycle.Checked)) {
        [System.Windows.Forms.MessageBox]::Show(
            "Please select at least one item to clean.",
            "Warning"
        )
        return
    }

    if ([System.Windows.Forms.MessageBox]::Show(
        "Selected temporary files will be deleted.`nContinue?",
        "Confirm",
        "YesNo",
        "Question"
    ) -ne "Yes") { return }

    $startBtn.Enabled = $false
    $status.Text = "Cleaning..."
    $progress.Style = 'Marquee'
    $form.Refresh()

    if ($cbUserTemp.Checked)  { Safe-CleanFolder $env:TEMP }
    if ($cbWinTemp.Checked)   { Safe-CleanFolder "C:\Windows\Temp" }
    if ($cbPrefetch.Checked)  { Safe-CleanFolder "C:\Windows\Prefetch" }
    if ($cbRecycle.Checked)   { Clear-RecycleBin -Force -ErrorAction SilentlyContinue }

    $progress.Style = 'Blocks'
    $progress.Value = 100
    $status.Text = "Completed"
    $startBtn.Enabled = $true

    [System.Windows.Forms.MessageBox]::Show(
        "Cleanup completed successfully.",
        "Done",
        "OK",
        "Information"
    )
})

# ================================
# RUN
# ================================
[void]$form.ShowDialog()
