FROM microsoft/powershell:windowsservercore
ADD Docker.Tests.ps1 /Docker.Tests.ps1
CMD . C:\\Docker.Tests.ps1
