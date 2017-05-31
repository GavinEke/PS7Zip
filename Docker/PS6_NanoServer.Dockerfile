FROM microsoft/powershell:nanoserver
ADD Docker.Tests.ps1 /Docker.Tests.ps1
CMD ["%PSCORE%", "-File C:\\Docker.Tests.ps1"]
