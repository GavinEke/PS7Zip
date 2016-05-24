# This script will invoke pester tests
# It should invoke on PowerShell v3 and later
# We serialize XML results and pull them in appveyor.yml

#If Finalize is specified, we collect XML output, upload tests, and indicate build errors
param(
    [switch]$Test,
    [switch]$Finalize,
    [switch]$Deploy,
    [string]$ProjectRoot = $ENV:APPVEYOR_BUILD_FOLDER
)

#Initialize some variables, move to the project root
$Timestamp = Get-Date -uformat "%Y%m%d-%H%M%S"
$PSVersion = $PSVersionTable.PSVersion.Major
$TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"

$Address = "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)"
Set-Location $ProjectRoot

$Verbose = @{}
If ($env:APPVEYOR_REPO_BRANCH -and $env:APPVEYOR_REPO_BRANCH -notlike "master") {
    $Verbose.add("Verbose",$True)
}

#Run a test with the current version of PowerShell, upload results
If ($Test) {
    "`n`tSTATUS: Testing with PowerShell $PSVersion`n"

    Import-Module Pester
    Invoke-Pester @Verbose -Path "$ProjectRoot\PS7Zip\Tests" -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile" -PassThru | Export-Clixml -Path "$ProjectRoot\PesterResults_PS$PSVersion`_$Timestamp.xml"
    
    Import-Module PSScriptAnalyzer
    $saResults = Invoke-ScriptAnalyzer -Path "$ProjectRoot\PS7Zip" -Severity @('Error', 'Warning') -Recurse -Verbose:$false
    If ($saResults) {
        $saResults | Format-Table  
        Write-Error -Message 'One or more Script Analyzer errors/warnings where found. Build cannot continue!'        
    }

    If ($env:APPVEYOR_JOB_ID) {
        (New-Object 'System.Net.WebClient').UploadFile( $Address, "$ProjectRoot\$TestFile" )
    }
}

#If finalize is specified, display errors and fail build if we ran into any
If ($Finalize) {
    #Show status...
        $AllFiles = Get-ChildItem -Path $ProjectRoot\PesterResults*.xml | Select -ExpandProperty FullName
        "`n`tSTATUS: Finalizing results`n"
        "COLLATING FILES:`n$($AllFiles | Out-String)"

    #What failed?
        $Results = @( Get-ChildItem -Path "$ProjectRoot\PesterResults_PS*.xml" | Import-Clixml )

        $FailedCount = $Results |
            Select -ExpandProperty FailedCount |
            Measure-Object -Sum |
            Select -ExpandProperty Sum

        If ($FailedCount -gt 0) {

            $FailedItems = $Results |
                Select -ExpandProperty TestResult |
                Where {$_.Passed -notlike $True}

            "FAILED TESTS SUMMARY:`n"
            $FailedItems | ForEach-Object {
                $Item = $_
                [pscustomobject]@{
                    Describe = $Item.Describe
                    Context = $Item.Context
                    Name = "It $($Item.Name)"
                    Result = $Item.Result
                }
            } |
                Sort Describe, Context, Name, Result |
                Format-List

            throw "$FailedCount tests failed."
        }
}

#Run a test with the current version of PowerShell, upload results
If ($Deploy) {
    Import-Module $ProjectRoot\PS7Zip -Force -ErrorAction SilentlyContinue
    [Version]$PS7ZipGalleryVersion = Find-Package PS7Zip | Select-Object -ExpandProperty Version
    [Version]$PS7ZipLocalVersion = Get-Module PS7Zip | Select-Object -ExpandProperty Version
    If (($PS7ZipLocalVersion.Major -gt $PS7ZipGalleryVersion.Major) -or ($PS7ZipLocalVersion.Minor -gt $PS7ZipGalleryVersion.Minor)) {
        Write-Output "Deploying new version to the PowerShell Gallery"
        Publish-Module -Path "$ProjectRoot\PS7Zip" -NuGetApiKey "$env:my_apikey"
    }
}
