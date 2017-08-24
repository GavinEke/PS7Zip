# $PSScriptRoot Fix
If (!($PSScriptRoot)) {
    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}

$PSVersion = $PSVersionTable.PSVersion.ToString()

Import-Module $PSScriptRoot\..\PS7Zip -Verbose -Force -ErrorAction SilentlyContinue

Describe "PS7Zip Module PS$PSVersion" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest
        It 'should load all functions' {
            $Commands = @( Get-Command -CommandType Function -Module PS7Zip | Select-Object -ExpandProperty Name)
            $Commands.count | Should be 3
            $Commands -contains "Compress-7Zip" | Should be $True
            $Commands -contains "Expand-7Zip"   | Should be $True
            $Commands -contains "Get-7Zip"      | Should be $True
        }
        It 'Should not have any PSScriptAnalyzer warnings' {
            If (Get-Module PSScriptAnalyzer) {
                Import-Module PSScriptAnalyzer -Force -ErrorAction SilentlyContinue
                $ScriptWarnings = @(Invoke-ScriptAnalyzer -Path "$PSScriptRoot\.." -Severity @('Error', 'Warning') -Recurse -Verbose:$false)
            } Else {
                $ScriptWarnings = ""
            }
            $ScriptWarnings.Length | Should be 0
        }
        $script:manifest = $null
        It "has a valid manifest" {
            {
                $script:manifest = Test-ModuleManifest -Path "$PSScriptRoot\..\PS7Zip.psd1" -ErrorAction Stop -WarningAction SilentlyContinue
            } | Should Not Throw
        }
        It "has a valid name in the manifest" {
            $script:manifest.Name | Should Be PS7Zip
        }
        It "has a valid guid in the manifest" {
            $script:manifest.Guid | Should Be '46cd1d63-7d41-4cfa-9a69-c950d224b291'
        }
        It "has a valid version in the manifest" {
            $script:manifest.Version -as [Version] | Should Not BeNullOrEmpty
        }
    }
}
 
Describe "Compress-7Zip Function PS$PSVersion" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest
        It 'should create archive.zip in the current working folder' {
            New-Item archive -ItemType Directory
            Compress-7Zip .\archive
            Test-Path .\archive.zip | Should Be $True
            Remove-Item archive*
        }
        It 'should create a gzip archive of a single file and delete the uncompressed file' {
            New-Item archive.csv -ItemType File
            New-Item folder -ItemType Directory
            Compress-7Zip "archive.csv" -OutputFile ".\folder\files.gz" -ArchiveType GZIP -Remove $True
            Test-Path .\folder\files.gz | Should Be $True
            Test-Path .\archive.csv | Should Be $False
        }
        It 'should create an archive based on pipeline input' {
            New-Item archive.txt -ItemType File
            Get-ChildItem archive.txt | Compress-7Zip
            Test-Path .\archive.zip | Should Be $True
            Remove-Item archive.txt
        }
    }
}

Describe "Expand-7Zip Function PS$PSVersion" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest
        It 'should extract contents of archive.zip in the current working folder' {
            Expand-7Zip archive.zip
            Test-Path .\archive.txt | Should Be $True
            Remove-Item archive.txt
        }
        It 'should extract contents of .\folder\files.gz into current working folder' {
            Expand-7Zip ".\folder\files.gz"
            Test-Path .\archive.csv | Should Be $True
            Remove-Item archive.csv
        }
    }
}

Describe "Get-7Zip Function PS$PSVersion" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest
        It 'should list contents of archive.zip in the current working folder' {
            $get7ziptest1 = Get-7Zip archive.zip
            Test-Path Variable:get7ziptest1 | Should Be $True
            Write-Output "$get7ziptest1"
            Remove-Item archive*
        }
        It 'should list contents of .\folder\files.gz' {
            $get7ziptest2 = Get-7Zip ".\folder\files.gz"
            Test-Path Variable:get7ziptest2 | Should Be $True
            Write-Output "$get7ziptest2"
            Remove-Item folder -Recurse
        }
    }
}
