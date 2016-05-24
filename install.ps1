$projecturl = "https://github.com/GavinEke/PS7Zip/archive/master.zip"
$tmpzip = "$env:TEMP\PS7Zip.zip"
$profilemodules = "$env:USERPROFILE\Documents\WindowsPowerShell\modules"
Remove-Item $tmpzip
(New-Object System.Net.WebClient).DownloadFile($projecturl, $tmpzip)
Unblock-File -Path $tmpzip
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($tmpzip, $profilemodules)
