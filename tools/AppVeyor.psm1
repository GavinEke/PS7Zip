Write-Host -ForegroundColor Magenta -Object "--- Start of AppVeyor.psm1 ---"

$ErrorActionPreference = 'Stop'
$ProjectRoot = $env:APPVEYOR_BUILD_FOLDER
$ProjectName = $env:APPVEYOR_PROJECT_NAME

Write-Host -ForegroundColor Yellow -Object "PowerShell Version is $($PSVersionTable.PSVersion)"
Write-Host -ForegroundColor Yellow -Object "Project Root is $ProjectRoot"
Write-Host -ForegroundColor Yellow -Object "Project Name is $ProjectName"
Write-Host -ForegroundColor Yellow -Object "AppVeyor Job ID is $env:APPVEYOR_JOB_ID"

Function Invoke-AppVeyorInstall {
    Write-Host -ForegroundColor Magenta -Object "Invoke-AppVeyorInstall"
    If ($PSVersionTable.PSVersion -ge [Version]'5.0') {
        [void]$(Install-PackageProvider Nuget -Force)
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        Install-Module -Name Pester, platyPS, PSScriptAnalyzer -SkipPublisherCheck -Force
    } Else {
        nuget install Pester -source https://www.powershellgallery.com/api/v2 -outputDirectory "$Env:ProgramFiles\WindowsPowerShell\Modules\."
        nuget install platyPS -source https://www.powershellgallery.com/api/v2 -outputDirectory "$Env:ProgramFiles\WindowsPowerShell\Modules\."
        nuget install PSScriptAnalyzer -source https://www.powershellgallery.com/api/v2 -outputDirectory "$Env:ProgramFiles\WindowsPowerShell\Modules\."
    }
}

Function Invoke-AppVeyorTest {
    [CmdletBinding()]
    param(
        [switch]$NormalTest,
        [switch]$DockerTest,
        [switch]$PSCoreTest,
        [switch]$AltInstallTest
    )
    Write-Host -ForegroundColor Magenta -Object "Invoke-AppVeyorTest"
    If ($NormalTest) {
        Write-Host -ForegroundColor Yellow -Object "Running Normal Test"

        Import-Module Pester
        Invoke-Pester @Verbose -Path "$ProjectRoot\$ProjectName\Tests" -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile" -PassThru | Export-Clixml -Path "$ProjectRoot\PesterResults_PS$PSVersion`_$Timestamp.xml"
    }

    If ($DockerTest) {
        Write-Host -ForegroundColor Yellow -Object "Running Docker Test"

        docker build -t nano -f $ProjectRoot\Docker\NanoServer.Dockerfile .
        docker run nano
    }

    If ($PSCoreTest) {
        Write-Host -ForegroundColor Yellow -Object "Running PSCore Test"

        $PSCore_MSI = "https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-beta.4/PowerShell-6.0.0-beta.4-win10-win2016-x64.msi"
        Invoke-WebRequest -Uri "$PSCore_MSI" -UseBasicParsing -OutFile "C:\PowerShell-win10-x64.msi"
        Start-Process -FilePath msiexec.exe -ArgumentList '-qn','-i C:\PowerShell-win10-x64.msi','-norestart' -wait
        $PSCore_EXE = Get-Item -Path $Env:ProgramFiles\PowerShell\*\powershell.exe
        New-Item -Type SymbolicLink -Path $Env:ProgramFiles\PowerShell\ -Name latest -Value $PSCore_EXE.DirectoryName
        & "C:\Program Files\PowerShell\latest\PowerShell.exe" -Command Invoke-Pester @Verbose -Path "$ProjectRoot\$ProjectName\Tests"
    }

    If ($AltInstallTest) {
        Write-Host -ForegroundColor Yellow -Object "Running Alternative Install Test"

        Invoke-Expression ((New-Object net.webclient).DownloadString("https://raw.githubusercontent.com/$env:APPVEYOR_ACCOUNT_NAME/$ProjectName/master/install.ps1"))
        Test-ModuleManifest -Path "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\$ProjectName\$ProjectName.psd1"
        Remove-Item -Path "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\$ProjectName" -Recurse -Force
    }
}

Write-Host -ForegroundColor Magenta -Object "--- End of AppVeyor.psm1 ---"
