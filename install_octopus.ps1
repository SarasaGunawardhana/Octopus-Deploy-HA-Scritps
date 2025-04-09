$url = "https://download.octopusdeploy.com/octopus/Octopus.2025.1.10012-x64.msi"
# $url = "https://octopus.com/downloads/OctopusServer/thanks?releaseVersion=2025.1.10012&filePlatform=WindowsX64"

$outpath = "$PSScriptRoot\octopusdeploy.msi"
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $url -OutFile $outpath

$octoargs = @("/I",$outpath,"/quiet", "RUNMANAGERONEXIT=no")
Write-Output $args[0]
Write-Output $args[1]
Write-Output $args[2]
Write-Output $args[3]

Start-Process "msiexec.exe" -ArgumentList $octoargs -Wait -NoNewWindow
