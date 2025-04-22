# Get Args

$ConnectionString = $args[0]
$UserName = $args[1]
$Email = $args[2]
$Password = $args[3]
$LicenseKey = $args[4]

$storageName=$args[5]
$storageShare=$args[6]
$storagePass=$args[7]

$storageDirectory = "octoha"
$LogFileLocation = "C:\log.txt"

# Log Args to File

"Begin Running Scripts" | Out-File -FilePath $LogFileLocation -append

(-join("Connection String = ", $ConnectionString)) | Out-File -FilePath $LogFileLocation -append
(-join("Username = ", $UserName)) | Out-File -FilePath $LogFileLocation -append
(-join("Email = ", $Email)) | Out-File -FilePath $LogFileLocation -append
(-join("Password = ", $Password)) | Out-File -FilePath $LogFileLocation -append
(-join("License Key = ", $LicenseKey)) | Out-File -FilePath $LogFileLocation -append

# Connect SMB file share

"Connect SMB file share" | Out-File -FilePath $LogFileLocation -append


(-join("Storage Account Name = ", $StorageName)) | Out-File -FilePath $LogFileLocation -append
(-join("Account Key = ", $storagePass)) | Out-File -FilePath $LogFileLocation -append
(-join("Storage File Share Name = ", $storageShare)) | Out-File -FilePath $LogFileLocation -append
(-join("Storage File Share Directory = ", $storageDirectory)) | Out-File -FilePath $LogFileLocation -append

# Add the Authentication for the symbolic links. You can get this from the Azure Portal.

try {
    cmdkey /add:$storageName.file.core.windows.net /user:Azure\$storageName /pass:$storagePass
}
catch {
    (-join("Error Adding Authentication = ", $_.ScriptStackTrace)) | Out-File -FilePath $LogFileLocation -append
}

# Add Octopus folder to add symbolic links

New-Item -ItemType directory -Path C:\Octopus

# Add the Symbolic Links. Do this before installing Octopus.

New-Item -ItemType SymbolicLink -Path "C:\Octopus\TaskLogs" -Target "\\$storageName.file.core.windows.net\$storageShare\$storageDirectory\TaskLogs"
New-Item -ItemType SymbolicLink -Path "C:\Octopus\Artifacts" -Target "\\$storageName.file.core.windows.net\$storageShare\$storageDirectory\Artifacts"
New-Item -ItemType SymbolicLink -Path "C:\Octopus\Packages" -Target "\\$storageName.file.core.windows.net\$storageShare\$storageDirectory\Packages"

# Install Octopus

"Install Octopus" | Out-File -FilePath $LogFileLocation -append

$url = "https://raw.githubusercontent.com/SarasaGunawardhana/Octopus-Deploy-HA-Scritps/refs/heads/main/install_octopus.ps1"

(-join("Getting File from = ", $url)) | Out-File -FilePath $LogFileLocation -append

$outpath = "$PSScriptRoot\install_octopus.ps1"

(-join("Saving File to = ", $outpath)) | Out-File -FilePath $LogFileLocation -append

$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $url -OutFile $outpath

$octoargs = @("-ExecutionPolicy", "Unrestricted", "-File", $outpath)

Start-Process "powershell.exe" -ArgumentList $octoargs -Wait -NoNewWindow

# Setup Octopus

"Setup Octopus" | Out-File -FilePath $LogFileLocation -append

$url = "https://raw.githubusercontent.com/SarasaGunawardhana/Octopus-Deploy-HA-Scritps/refs/heads/main/setup_octopus.ps1"

(-join("Getting File from = ", $url)) | Out-File -FilePath $LogFileLocation -append

$outpath = "$PSScriptRoot\setup_octopus.ps1"

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

