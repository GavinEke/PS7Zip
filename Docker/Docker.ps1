$GitHubUser = "GavinEke"
$RepoName = "PS7Zip"
$ProfileModulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules"
Invoke-WebRequest -Uri "https://github.com/$GitHubUser/$RepoName/archive/master.zip" -UseBasicParsing -OutFile "C:\$RepoName.zip"
Expand-Archive -Path "C:\$RepoName.zip" -DestinationPath "$ProfileModulePath"
Invoke-Pester -Path "$ProfileModulePath\$RepoName-master\Tests" -EnableExit
