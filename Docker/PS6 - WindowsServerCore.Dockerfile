FROM microsoft/powershell:windowsservercore
ADD Docker.Tests.ps1 /Docker.Tests.ps1
CMD ["powershell.exe -File Docker.Tests.ps1"