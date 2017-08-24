#Requires -Version 3
$GitHubUser = 'GavinEke'
$RepoName = 'PS7Zip'
$ProfileModulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules"
If (!(Test-Path $ProfileModulePath)) {
    Net-Item -ItemType Directory -Path $ProfileModulePath
}
(New-Object System.Net.WebClient).DownloadFile("https://github.com/$GitHubUser/$RepoName/archive/master.zip", "$env:TEMP\$RepoName.zip")
Unblock-File -Path "$env:TEMP\$RepoName.zip"
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory("$env:TEMP\$RepoName.zip", "$env:TEMP")
Move-Item -Path "$env:TEMP\$RepoName-master\$RepoName" -Destination "$ProfileModulePath"
Remove-Item "$env:TEMP\$RepoName*" -Recurse -ErrorAction SilentlyContinue
