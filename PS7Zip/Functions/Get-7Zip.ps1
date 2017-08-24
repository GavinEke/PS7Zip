<#
.SYNOPSIS
List contents of a compressed archive file
.DESCRIPTION
Use Get-7Zip to list the contents of an archive.
.EXAMPLE
Get-7Zip archive.zip

List contents of archive.zip in the current working folder

.EXAMPLE
Get-7Zip "c:\folder\files.gz"

List contents of c:\folder\files.gz

.PARAMETER FullName
The full path of the compressed archive file.
.LINK
http://gavineke.com/PS7Zip/Get-7Zip
#>
Function Get-7Zip {
    [CmdletBinding(HelpUri='http://gavineke.com/PS7Zip/Get-7Zip')]
    Param(
        [Parameter(Mandatory=$True,Position=1,ValueFromPipelineByPropertyName=$True)]
        [ValidateScript({Test-Path $_})]
        [string]$FullName
	)
	
	Begin {}
	
    Process {
        Write-Verbose -Message 'Getting contents of archive file'
        & "$7zaBinary" l "$FullName"
	}
	
	End {}
	
}
