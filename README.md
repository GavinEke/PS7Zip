[![AppVeyor Status](https://ci.appveyor.com/api/projects/status/github/GavinEke/PS7Zip)](https://ci.appveyor.com/project/GavinEke/ps7zip)

# PS7Zip

Powershell module that allows you to work with compressed archives (PS 3.0+). Online Help Files - http://gavineke.com/PS7Zip/

## Supported Systems

| Operating System Version   | Core 6 Beta        | WMF 5.1            | WMF 5.0            | WMF 4.0            | WMF 3.0            | WMF 2.0 |
|----------------------------|--------------------|--------------------|--------------------|--------------------|--------------------|---------|
| Windows Nano Server        |                    | :heavy_check_mark: | N/A                | N/A                | N/A                | N/A     |
| Windows Server 2016        | :heavy_check_mark: | :heavy_check_mark: | N/A                | N/A                | N/A                | N/A     |
| Windows 10                 | :heavy_check_mark: | :heavy_check_mark: | :x:                | N/A                | N/A                | N/A     |
| Windows Server 2012 R2     |                    | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | N/A                | N/A     |
| Windows 8.1                |                    | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | N/A                | N/A     |
| Windows Server 2008 R2 SP1 |                    | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :x:     |
| Windows 7 SP1              |                    | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :heavy_check_mark: | :x:     |

Systems without a green tick or red cross have not be tested for compatibility and as such are unsupported.

## Installing

Download and Install from the PowerShellGallery (Recommended)

    Install-Module -Name PS7Zip

Alternatively run the following command from PowerShell

    iex ((new-object net.webclient).DownloadString('https://raw.githubusercontent.com/GavinEke/PS7Zip/master/install.ps1'))

## Contribute

Please submit an issue on GitHub or if you know how to fix it please submit a pull request.

## Notes

Parts of this module use the 7-Zip program.  
7-Zip is licensed under the GNU LGPL license.  
www.7-zip.org
