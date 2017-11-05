Install-PackageProvider -Name NuGet -Force
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name Pester, PSScriptAnalyzer -SkipPublisherCheck -Force
Invoke-Pester -Path ".\Tests" -OutputFormat NUnitXml -OutputFile ".\TestResults_PSCoreTest.xml" -PassThru | Export-Clixml -Path ".\PesterResults_PSCoreTest.xml"