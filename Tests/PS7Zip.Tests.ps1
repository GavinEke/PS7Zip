# $PSScriptRoot Fix
If (-not ($PSScriptRoot)) {
    $PSScriptRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
}

$ModuleName = 'PS7Zip'
$OSVersion = [Environment]::OSVersion.VersionString

Import-Module "$PSScriptRoot\..\$ModuleName\$ModuleName" -Verbose -Force -ErrorAction SilentlyContinue

Describe "PS7Zip Module - $OSVersion" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        It 'Should not have any PSScriptAnalyzer warnings' {
            Import-Module PSScriptAnalyzer -Force -ErrorAction SilentlyContinue
            $ScriptWarnings = Invoke-ScriptAnalyzer -Path "$PSScriptRoot\..\$ModuleName" -Recurse
            $ScriptWarnings.Length | Should BeNullOrEmpty
        }
		
		$script:manifest = $null
        It "has a valid manifest" {
            { $script:manifest = Test-ModuleManifest -Path "$PSScriptRoot\..\$ModuleName\$ModuleName.psd1" -ErrorAction Stop -WarningAction SilentlyContinue } | Should Not Throw
        }
    }
}

Describe "Compress-7Zip Function - $OSVersion" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest
        Set-Location TestDrive:

        It 'should create archive.zip in the TestDrive' {
            New-Item TestDrive:\archive -ItemType Directory
            Compress-7Zip TestDrive:\archive
            Test-Path TestDrive:\archive.zip | Should Be $True
            Remove-Item archive*
		}
		
		It 'should create a gzip archive of a single file and delete the uncompressed file' {
            New-Item TestDrive:\archive.csv -ItemType File
            New-Item TestDrive:\folder -ItemType Directory
            Compress-7Zip 'TestDrive:\archive.csv' -OutputFile 'TestDrive:\folder\files.gz' -ArchiveType GZIP -Remove
            Test-Path TestDrive:\folder\files.gz | Should Be $True
            Test-Path TestDrive:\archive.csv | Should Be $False
		}
		
		It 'should create an archive based on pipeline input' {
            New-Item TestDrive:\archive.txt -ItemType File
            Get-ChildItem TestDrive:\archive.txt | Compress-7Zip
            Test-Path TestDrive:\archive.zip | Should Be $True
            Remove-Item TestDrive:\archive.txt
        }
    }
}

Describe "Expand-7Zip Function - $OSVersion" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest
        Set-Location TestDrive:

        It 'should extract contents of archive.zip in the TestDrive' {
            Expand-7Zip TestDrive:\archive.zip
            Test-Path TestDrive:\archive.txt | Should Be $True
            Remove-Item TestDrive:\archive.txt
		}
		
		It 'should extract contents of TestDrive:\folder\files.gz into current working folder' {
            Expand-7Zip 'TestDrive:\folder\files.gz'
            Test-Path TestDrive:\archive.csv | Should Be $True
            Remove-Item TestDrive:\archive.csv
        }
    }
}

Describe "Get-7Zip Function - $OSVersion" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest
        Set-Location TestDrive:
        
        It 'should list contents of archive.zip in the TestDrive' {
            $get7ziptest1 = Get-7Zip TestDrive:\archive.zip
            Test-Path Variable:get7ziptest1 | Should Be $True
            Write-Output "$get7ziptest1"
            Remove-Item TestDrive:\archive*
		}
		
		It 'should list contents of TestDrive:\folder\files.gz' {
            $get7ziptest2 = Get-7Zip 'TestDrive:\folder\files.gz'
            Test-Path Variable:get7ziptest2 | Should Be $True
            Write-Output "$get7ziptest2"
            Remove-Item TestDrive:\folder -Recurse
        }
    }
}
