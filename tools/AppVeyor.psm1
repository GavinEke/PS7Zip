$ErrorActionPreference = 'Stop'
$ProjectRoot = $env:APPVEYOR_BUILD_FOLDER
$ProjectName = $env:APPVEYOR_PROJECT_NAME

Write-Host -ForegroundColor Yellow -Object "PowerShell Version is $($PSVersionTable.PSVersion)"

Function Invoke-AppVeyorInstall {
    If ($PSVersionTable.PSVersion -ge [Version]'5.0') {
        [void]$(Install-PackageProvider Nuget -Force)
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        Install-Module -Name Pester, platyPS, PSScriptAnalyzer -SkipPublisherCheck -Force
    } Else {
        nuget install Pester -source https://www.powershellgallery.com/api/v2 -outputDirectory "$Env:ProgramFiles\WindowsPowerShell\Modules\."
        nuget install platyPS -source https://www.powershellgallery.com/api/v2 -outputDirectory "$Env:ProgramFiles\WindowsPowerShell\Modules\."
        nuget install PSScriptAnalyzer -source https://www.powershellgallery.com/api/v2 -outputDirectory "$Env:ProgramFiles\WindowsPowerShell\Modules\."
    }
    
    Write-Host -ForegroundColor Yellow -Object "Pester version is $(Get-Module -Name Pester -ListAvailable | Select-Object -ExpandProperty Version)"
    Write-Host -ForegroundColor Yellow -Object "platyPS version is $(Get-Module -Name platyPS -ListAvailable | Select-Object -ExpandProperty Version)"
    Write-Host -ForegroundColor Yellow -Object "PSScriptAnalyzer version is $(Get-Module -Name PSScriptAnalyzer -ListAvailable | Select-Object -ExpandProperty Version)"
}

Function Invoke-AppVeyorTest {
    [CmdletBinding()]
    param(
        [switch]$NormalTest,
        [switch]$DockerTest,
        [switch]$PSCoreTest,
        [switch]$AltInstallTest
    )
    If ($NormalTest) {
        Write-Host -ForegroundColor Yellow -Object "Running Normal Test"

        Import-Module Pester
        Invoke-Pester @Verbose -Path "$ProjectRoot\$ProjectName\Tests" -OutputFormat NUnitXml -OutputFile "$ProjectRoot\TestResults_NormalTest.xml" -PassThru | Export-Clixml -Path "$ProjectRoot\PesterResults_NormalTest.xml"
    }

    If ($DockerTest) {
        Write-Host -ForegroundColor Yellow -Object "Running Docker Test"

        Set-Location "$ProjectRoot\Docker"
        docker build -t nano -f NanoServer.Dockerfile .
        docker run nano
        Set-Location "$ProjectRoot"
    }

    If ($PSCoreTest) {
        Write-Host -ForegroundColor Yellow -Object "Running PSCore Test"

        $PSCore_MSI = "https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-beta.4/PowerShell-6.0.0-beta.4-win10-win2016-x64.msi"
        Invoke-WebRequest -Uri "$PSCore_MSI" -UseBasicParsing -OutFile "C:\PowerShell-win10-x64.msi"
        Start-Process -FilePath msiexec.exe -ArgumentList '-qn','-i C:\PowerShell-win10-x64.msi','-norestart' -wait
        $PSCore_EXE = Get-Item -Path $Env:ProgramFiles\PowerShell\*\powershell.exe
        New-Item -Type SymbolicLink -Path $Env:ProgramFiles\PowerShell\ -Name latest -Value $PSCore_EXE.DirectoryName
        & "C:\Program Files\PowerShell\latest\PowerShell.exe" -Command Invoke-Pester @Verbose -Path "$ProjectRoot\$ProjectName\Tests -OutputFormat NUnitXml -OutputFile "$ProjectRoot\TestResults_PSCoreTest.xml" -PassThru | Export-Clixml -Path "$ProjectRoot\PesterResults_PSCoreTest.xml""
    }

    If ($AltInstallTest) {
        Write-Host -ForegroundColor Yellow -Object "Running Alternative Install Test"

        Invoke-Expression ((New-Object net.webclient).DownloadString("https://raw.githubusercontent.com/$env:APPVEYOR_ACCOUNT_NAME/$ProjectName/master/install.ps1"))
        Test-ModuleManifest -Path "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\$ProjectName\$ProjectName.psd1"
        Remove-Item -Path "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\$ProjectName" -Recurse -Force
    }
}

Function Invoke-AppVeyorBuild {
    Import-Module -Path "$ProjectRoot\$ProjectName" -Force -ErrorAction SilentlyContinue
    New-MarkdownHelp -Module $ProjectName -OutputFolder "$ProjectRoot\$ProjectName\docs"
}

Function Invoke-AppVeyorDeploy {
    [CmdletBinding()]
    param(
        [switch]$DeployToGallery,
        [switch]$DeployToArtifacts
    )
    Update-ModuleManifest -Path "$ProjectRoot\$ProjectName\$ProjectName.psd1" -ModuleVersion "$env:APPVEYOR_BUILD_VERSION"
    Import-Module -Path "$ProjectRoot\$ProjectName" -Force -ErrorAction SilentlyContinue
    
    If ($DeployToGallery) {
        Write-Host -ForegroundColor Yellow -Object "Deploying to PSGallery"
        If ($PSVersionTable.PSVersion.Major -ge 5) {
            [Version]$GalleryVersion = Find-Package $ProjectName -ErrorAction Stop | Select-Object -ExpandProperty Version
            [Version]$LocalVersion = Get-Module $ProjectName -ErrorAction Stop | Select-Object -ExpandProperty Version

            If (($LocalVersion.Major -gt $GalleryVersion.Major) -or ($LocalVersion.Minor -gt $GalleryVersion.Minor)) {
                Write-Host -ForegroundColor Yellow -Object "Deploying $LocalVersion to the PowerShell Gallery"
                Publish-Module -Path "$ProjectRoot\PS7Zip" -NuGetApiKey "$env:NuGetApiKey"
            }
        }
    }
    
    If ($DeployToArtifacts) {
        Write-Host -ForegroundColor Yellow -Object "Deploying to AppVeyor Artifacts"
        Compress-Archive -Path "$ProjectRoot\$ProjectName" -DestinationPath "$ProjectRoot\$ProjectName-$LocalVersion.zip"
        Push-AppveyorArtifact "$ProjectRoot\$ProjectName-$LocalVersion.zip"
    }
}
