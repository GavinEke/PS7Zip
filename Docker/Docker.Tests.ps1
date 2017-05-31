$GitHubUser = "GavinEke"
$RepoName = "PS7Zip"
$ProfileModulePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Modules"
Invoke-WebRequest -Uri "https://github.com/$GitHubUser/$RepoName/archive/master.zip" -UseBasicParsing -OutFile $RepoName.zip
Expand-Archive -Path "$RepoName.zip" -DestinationPath "$ProfileModulePath"
Invoke-Pester @Verbose -Path "$ProfileModulePath\PS7Zip-master\PS7Zip\Tests" 