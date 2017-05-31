FROM microsoft/windowsservercore
ADD Docker.Tests.ps1 /Docker.Tests.ps1
CMD ["powershell.exe", "-File C:\Docker.Tests.ps1"
