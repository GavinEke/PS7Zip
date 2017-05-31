FROM microsoft/powershell:windowsservercore
ADD Docker.Tests.ps1 /Docker.Tests.ps1
CMD ["C:\\Program Files\\PowerShell\\latest\\PowerShell.exe", "-File C:\\Docker.Tests.ps1"]
