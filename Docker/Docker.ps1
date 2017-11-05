$GitHubUser = "GavinEke"
$RepoName = "PS7Zip"
$ProfileModulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules"
Invoke-WebRequest -Uri "https://github.com/$GitHubUser/$RepoName/archive/master.zip" -UseBasicParsing -OutFile "C:\$RepoName.zip"
Expand-Archive -Path "C:\$RepoName.zip" -DestinationPath "$ProfileModulePath"
Install-PackageProvider -Name NuGet -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name Pester, PSScriptAnalyzer -SkipPublisherCheck -Force
Invoke-Pester -Path "$ProfileModulePath\$RepoName-master\Tests" -EnableExit
