# Get Args

$ConnectionString = $args[3]
$UserName = $args[4]
$Email = $args[5]
$Password = $args[6]
$LicenseKey = $args[7]

$LogFileLocation = "C:\log.txt"

# Log Args to File

"Begin Running Scripts" | Out-File -FilePath $LogFileLocation -append

(-join("Connection String = ", $ConnectionString)) | Out-File -FilePath $LogFileLocation -append
(-join("Username = ", $UserName)) | Out-File -FilePath $LogFileLocation -append
(-join("Email = ", $Email)) | Out-File -FilePath $LogFileLocation -append
(-join("Password = ", $Password)) | Out-File -FilePath $LogFileLocation -append
(-join("License Key = ", $LicenseKey)) | Out-File -FilePath $LogFileLocation -append

# Install Octopus

"Install Octopus" | Out-File -FilePath $LogFileLocation -append

$url = "https://raw.githubusercontent.com/SarasaGunawardhana/Octopus-Deploy-HA-Scritps/refs/heads/main/install_octopus.ps1"

(-join("Getting File from = ", $url)) | Out-File -FilePath $LogFileLocation -append

$outpath = "$PSScriptRoot\02_installoctopus.ps1"

(-join("Saving File to = ", $outpath)) | Out-File -FilePath $LogFileLocation -append

$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $url -OutFile $outpath

$octoargs = @("-ExecutionPolicy", "Unrestricted", "-File", $outpath)

Start-Process "powershell.exe" -ArgumentList $octoargs -Wait -NoNewWindow

# Setup Octopus

"Setup Octopus" | Out-File -FilePath $LogFileLocation -append

$url = "https://raw.githubusercontent.com/SarasaGunawardhana/Octopus-Deploy-HA-Scritps/refs/heads/main/setup_octopus.ps1"

(-join("Getting File from = ", $url)) | Out-File -FilePath $LogFileLocation -append

$outpath = "$PSScriptRoot\03_setupOctopus_VM1.ps1"

(-join("Saving File to = ", $outpath)) | Out-File -FilePath $LogFileLocation -append

$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $url -OutFile $outpath

$octoargs = @("-ExecutionPolicy", "Unrestricted", "-File", $outpath, """$ConnectionString""", "$UserName", "$Email", "$Password", """$LicenseKey""")

Start-Process "powershell.exe" -ArgumentList $octoargs -Wait -NoNewWindow

# Add Firewall Rules

New-NetFirewallRule -DisplayName "Allow Outbound Port 80" -Direction Outbound -LocalPort 80 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow Outbound Port 443" -Direction Outbound -LocalPort 80 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow Inbound Port 80" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Allow Inbound Port 443" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow
