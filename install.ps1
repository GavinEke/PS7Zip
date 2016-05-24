$projecturl = "https://github.com/GavinEke/PS7Zip/archive/master.zip"
$tmpfolder = "$env:TEMP"
$tmpzip = "$tmpfolder\PS7Zip.zip"
$profilemodules = "$env:USERPROFILE\Documents\WindowsPowerShell\modules"
(New-Object System.Net.WebClient).DownloadFile($projecturl, $tmpzip)
Unblock-File -Path $tmpzip
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($tmpzip, $env:TEMP)
Move-Item -Path "$tmpfolder\PS7Zip-master\PS7Zip" -Destination "$profilemodules"
Remove-Item "$tmpzip\PS7Zip*" -Recurse -ErrorAction SilentlyContinue
