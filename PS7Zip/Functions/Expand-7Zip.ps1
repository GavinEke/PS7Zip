<#
.SYNOPSIS
Extract contents of a compressed archive file
.DESCRIPTION
Use Expand-7Zip to extract the contents of an archive.
.EXAMPLE
Expand-7Zip archive.zip

Extract contents of archive.zip in the current working folder

.EXAMPLE
Expand-7Zip archive.zip -DestinationPath c:\archive

Extract contents of archive.zip in the c:\archive folder

.EXAMPLE
Expand-7Zip "c:\folder\files.gz"

Extract contents of c:\folder\files.gz into current working folder

.PARAMETER FullName
The full path of the compressed archive file.
.PARAMETER DestinationPath
The output directory.
.PARAMETER Remove
If $True this will remove the compressed version of the file only leaving the uncompressed contents.
.LINK
http://gavineke.com/PS7Zip/Expand-7Zip
#>
Function Expand-7Zip {
    [CmdletBinding(HelpUri='http://gavineke.com/PS7Zip/Expand-7Zip')]
    Param(
        [Parameter(Mandatory=$True,Position=0,ValueFromPipelineByPropertyName=$True)]
        [ValidateScript({$_ | Test-Path -PathType Leaf})]
        [System.IO.FileInfo]$FullName,

        [Parameter()]
        [Alias('Destination')]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationPath,

        [Parameter()]
        [switch]$Remove
	)
	
	Begin {}
	
    Process {
        Write-Verbose -Message 'Extracting contents of compressed archive file'
        If ($DestinationPath) {
            & "$7zaBinary" x -o"$DestinationPath" "$FullName"
        } Else {
            & "$7zaBinary" x "$FullName"
        }

        If ($Remove) {
			Write-Verbose -Message 'Removing compressed archive file'
			Remove-Item -Path "$FullName" -Force
        }
	}
	
	End {}
	
}
