FROM microsoft/nanoserver
ADD Docker.ps1 /Docker.ps1
CMD ["powershell.exe", "-File C:\\Docker.ps1"]
