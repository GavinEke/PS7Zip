FROM microsoft/nanoserver
ADD PS7Zip.Tests.ps1 /PS7Zip.Tests.ps1
CMD ["powershell.exe", "-File C:\\PS7Zip.Tests.ps1"]
