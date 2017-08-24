$ErrorActionPreference = 'Stop'
$BeginTime = Get-Date
$ProjectRoot = "$env:APPVEYOR_BUILD_FOLDER"
$ProjectName = "$env:APPVEYOR_PROJECT_NAME"

Write-Host -ForegroundColor Yellow -Object "PowerShell Version is $($PSVersionTable.PSVersion)"

Function Invoke-AppVeyorInstall {
    If ($PSVersionTable.PSVersion -ge [Version]'5.0') {
        If (Get-PackageProvider NuGet) {
            Write-Host -ForegroundColor Yellow -Object "[$($(Get-Date) - $BeginTime)] Installing Nuget"
            Install-PackageProvider -Name NuGet -Force
        }
        
        Write-Host -ForegroundColor Yellow -Object "[$($(Get-Date) - $BeginTime)] Marking PSGallery as trusted"
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
        
        Write-Host -ForegroundColor Yellow -Object "[$($(Get-Date) - $BeginTime)] Installing prereq modules"
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
    Param(
        [switch]$NormalTest,
        [switch]$DockerTest,
        [switch]$PSCoreTest,
        [switch]$AltInstallTest
    )
    If ($NormalTest) {
        Write-Host -ForegroundColor Yellow -Object "[$($(Get-Date) - $BeginTime)] Running Normal Test"

        Import-Module Pester
        Invoke-Pester @Verbose -Path "$ProjectRoot\Tests" -OutputFormat NUnitXml -OutputFile "$ProjectRoot\TestResults_NormalTest.xml" -PassThru | Export-Clixml -Path "$ProjectRoot\PesterResults_NormalTest.xml"
    }

    If ($DockerTest) {
		Write-Host -ForegroundColor Yellow -Object "[$($(Get-Date) - $BeginTime)] Running Docker Test"

        Set-Location "$ProjectRoot\Docker"
        docker build -t nano -f NanoServer.Dockerfile .
        docker run nano
        Set-Location "$ProjectRoot"
    }

    If ($PSCoreTest) {
        Write-Host -ForegroundColor Yellow -Object "[$($(Get-Date) - $BeginTime)] Running PSCore Test"

        $PSCore_MSI = "https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-beta.5/PowerShell-6.0.0-beta.5-win10-win2016-x64.msi"
        Invoke-WebRequest -Uri "$PSCore_MSI" -UseBasicParsing -OutFile "C:\PowerShell-win10-x64.msi"
        Start-Process -FilePath msiexec.exe -ArgumentList '-qn','-i C:\PowerShell-win10-x64.msi','-norestart' -wait
        $PSCore_EXE = Get-Item -Path $Env:ProgramFiles\PowerShell\*\powershell.exe
        New-Item -Type SymbolicLink -Path $Env:ProgramFiles\PowerShell\ -Name latest -Value $PSCore_EXE.DirectoryName
        & "C:\Program Files\PowerShell\latest\PowerShell.exe" -Command Invoke-Pester @Verbose -Path "$ProjectRoot\Tests -OutputFormat NUnitXml -OutputFile "$ProjectRoot\TestResults_PSCoreTest.xml" -PassThru | Export-Clixml -Path "$ProjectRoot\PesterResults_PSCoreTest.xml""
    }

    If ($AltInstallTest) {
        Write-Host -ForegroundColor Yellow -Object "[$($(Get-Date) - $BeginTime)] Running Alternative Install Test"

        Invoke-Expression ((New-Object net.webclient).DownloadString("https://raw.githubusercontent.com/$env:APPVEYOR_ACCOUNT_NAME/$ProjectName/master/install.ps1"))
        Test-ModuleManifest -Path "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\$ProjectName\$ProjectName.psd1"
        Remove-Item -Path "$env:USERPROFILE\Documents\WindowsPowerShell\Modules\$ProjectName" -Recurse -Force
    }
}

Function Update-AppVeyorTestResults {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True)]
        [ValidateScript({Test-Path $_ })]
        [string] $TestFile
    )
    Write-Host -ForegroundColor Yellow -Object "[$($(Get-Date) - $BeginTime)] Uploading Test Results to AppVeyor"
    Try {
        (New-Object 'System.Net.WebClient').UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", $TestFile)
    } Catch {
        Write-Warning "Failed to push test file."
    }
}

Function Invoke-AppVeyorBuildDocs {
    Write-Host -ForegroundColor Yellow -Object "[$($(Get-Date) - $BeginTime)] Creating Help Files"
    Import-Module "$ProjectRoot\$ProjectName" -Global -Force -ErrorAction SilentlyContinue
    New-MarkdownHelp -Module $ProjectName -OutputFolder "$ProjectRoot\$ProjectName\docs"
}

Function Invoke-AppVeyorDeploy {
    [CmdletBinding()]
    Param(
        [switch]$DeployToGallery,
        [switch]$DeployToArtifacts
    )
    Update-ModuleManifest -Path "$ProjectRoot\$ProjectName\$ProjectName.psd1" -ModuleVersion "$env:APPVEYOR_BUILD_VERSION"
    Import-Module "$ProjectRoot\$ProjectName" -Force -ErrorAction SilentlyContinue
    
    If ($DeployToGallery) {
        Write-Host -ForegroundColor Yellow -Object "[$($(Get-Date) - $BeginTime)] Deploying to PSGallery"
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
        Write-Host -ForegroundColor Yellow -Object "[$($(Get-Date) - $BeginTime)] Deploying to AppVeyor Artifacts"
        Compress-Archive -Path "$ProjectRoot\$ProjectName" -DestinationPath "$ProjectRoot\$ProjectName-$env:APPVEYOR_BUILD_VERSION.zip"
        Push-AppveyorArtifact "$ProjectRoot\$ProjectName-$env:APPVEYOR_BUILD_VERSION.zip"
    }
}

Function Invoke-AppveyorFinish {
    Write-Host -ForegroundColor Yellow -Object "[$($(Get-Date) - $BeginTime)] Finalizing AppVeyor"
    $AllFiles = Get-ChildItem -Path $ProjectRoot\PesterResults*.xml | Select -ExpandProperty FullName

    $Results = @( Get-ChildItem -Path "$ProjectRoot\PesterResults_PS*.xml" | Import-Clixml )

    $FailedCount = $Results |
        Select -ExpandProperty FailedCount |
        Measure-Object -Sum |
        Select -ExpandProperty Sum

    If ($FailedCount -gt 0) {

        $FailedItems = $Results |
            Select -ExpandProperty TestResult |
            Where {$_.Passed -notlike $True}

        Write-Host -ForegroundColor Yellow -Object "Failed Tests"
        $FailedItems | ForEach-Object {
            $Item = $_
            [pscustomobject]@{
                Describe = $Item.Describe
                Context = $Item.Context
                Name = "It $($Item.Name)"
                Result = $Item.Result
            }
        } | Sort Describe, Context, Name, Result | Format-List

        throw "$FailedCount tests failed."
    }
}

Function Write-VersionRequirements {
    Save-Module -Name VersionAnalyzerRules -Path C:\ -Force
    
    $VersionRequirements = Invoke-ScriptAnalyzer -Path "$ProjectRoot\$ProjectName" -Recurse -CustomRulePath "C:\VersionAnalyzerRules" -ErrorAction SilentlyContinue
    
    If ($VersionRequirements) {
        If ($VersionRequirements.RuleName.Contains('Test-OS10Command')) {
            $RequiredOS = 'Windows 10/Windows Server 2016'
        } ElseIf ($VersionRequirements.RuleName.Contains('Test-OS62Command')) {
            $RequiredOS = 'Windows 8.1/Windows Server 2012 R2'
        } Else {
            $RequiredOS = 'Windows 7/Windows Server 2008 R2'
        }

        If ($VersionRequirements.RuleName.Contains('Test-PowerShellv5Command')) {
            $RequiredWMF = 'WMF 5'
        } ElseIf ($VersionRequirements.RuleName.Contains('Test-PowerShellv4Command')) {
            $RequiredWMF = 'WMF 4'
        } ElseIf ($VersionRequirements.RuleName.Contains('Test-PowerShellv3Command')) {
            $RequiredWMF = 'WMF 3'
        } Else {
            $RequiredWMF = 'WMF 2'
        }
    } Else {
        $RequiredOS = 'Windows 7/Windows Server 2008 R2'
        $RequiredWMF = 'WMF 2'
    }

    Write-Host -Object " "
    Write-Host -Object "The Required OS Version is: " -NoNewline -ForegroundColor Yellow
    Write-Host -Object "$RequiredOS" -ForegroundColor Green
    Write-Host -Object "The Required WMF Version is: " -NoNewline -ForegroundColor Yellow
    Write-Host -Object "$RequiredWMF" -ForegroundColor Green
    Write-Host -Object " "
}
