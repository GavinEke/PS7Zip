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
            $ScriptWarnings | Should BeNullOrEmpty
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

        It 'should create archive.zip in the current working folder' {
            New-Item archive -ItemType Directory
            Compress-7Zip archive
            Test-Path archive.zip | Should Be $True
            Remove-Item archive*
        }
		
        It 'should create a gzip archive of a single file and delete the uncompressed file' {
            New-Item archive.csv -ItemType File
            New-Item folder -ItemType Directory
            Compress-7Zip 'archive.csv' -OutputFile 'folder\files.gz' -ArchiveType GZIP -Remove
            Test-Path folder\files.gz | Should Be $True
            Test-Path archive.csv | Should Be $False
        }
		
        It 'should create an archive based on pipeline input' {
            New-Item archive.txt -ItemType File
            Get-ChildItem archive.txt | Compress-7Zip
            Test-Path archive.zip | Should Be $True
            Remove-Item archive.txt
        }
    }
}

Describe "Expand-7Zip Function - $OSVersion" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        It 'should extract contents of archive.zip in the current working folder' {
            Expand-7Zip archive.zip
            Test-Path archive.txt | Should Be $True
            Remove-Item archive.txt
        }

        It 'should extract contents of archive.zip in c:\archive' {
            Expand-7Zip archive.zip -DestinationPath c:\archive
            Test-Path "c:\archive\archive.txt" | Should Be $True
            Remove-Item archive.txt
        }
		
        It 'should extract contents of folder\files.gz into the current working folder' {
            Expand-7Zip 'folder\files.gz'
            Test-Path archive.csv | Should Be $True
            Remove-Item archive.csv
        }
    }
}

Describe "Get-7Zip Function - $OSVersion" {
    Context 'Strict mode' {
        Set-StrictMode -Version latest

        It 'should list contents of archive.zip in the TestDrive' {
            $get7ziptest1 = Get-7Zip archive.zip
            Test-Path Variable:get7ziptest1 | Should Be $True
            Write-Output "$get7ziptest1"
            Remove-Item archive*
        }
		
        It 'should list contents of folder\files.gz' {
            $get7ziptest2 = Get-7Zip 'folder\files.gz'
            Test-Path Variable:get7ziptest2 | Should Be $True
            Write-Output "$get7ziptest2"
            Remove-Item folder -Recurse
        }
    }
}
