FROM microsoft/powershell:nanoserver
ADD Docker.Tests.ps1 /Docker.Tests.ps1
WORKDIR C:\\Program Files\\PowerShell\\latest
CMD powershell.exe -File C:\\Docker.Tests.ps1
