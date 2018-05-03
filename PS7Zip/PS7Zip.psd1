<#
    Parts of this module use the 7-Zip program.
    7-Zip is licensed under the GNU LGPL license.
    www.7-zip.org
#>

@{

# Script module or binary module file associated with this manifest.
RootModule = 'PS7Zip.psm1'

# Version number of this module.
ModuleVersion = '2.2.0'

# ID used to uniquely identify this module
GUID = '46cd1d63-7d41-4cfa-9a69-c950d224b291'

# Author of this module
Author = 'Gavin Eke'

# Company or vendor of this module
# CompanyName = 'Unknown'

# Copyright statement for this module
Copyright = '(c) 2017 Gavin Eke. All rights reserved.'

# Description of the functionality provided by this module
Description = 'Powershell module that allows you to work with compressed archives'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '3.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
# RequiredModules = @()

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module
FunctionsToExport = 'Get-7Zip','Compress-7Zip','Expand-7Zip'

# Cmdlets to export from this module
CmdletsToExport = ''

# Variables to export from this module
VariablesToExport = ''

# Aliases to export from this module
AliasesToExport = ''

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('7-Zip','7zip','Archive','Compress','Extract','Zip','7z','gz','gzip','bzip2','tar')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/GavinEke/PS7Zip/blob/master/LICENCE.md'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/GavinEke/PS7Zip'

        # A URL to an icon representing this module.
        # IconUri = ''

        # ReleaseNotes of this module
        ReleaseNotes = 'Update 7-Zip Binary to 18.05'

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}
