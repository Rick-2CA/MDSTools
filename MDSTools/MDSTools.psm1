$moduleRoot = Split-Path -Path $MyInvocation.MyCommand.Path

# Create aliases
Write-Verbose "Creating Aliases"
New-Alias -Name Start-MDSEMC -Value Start-MDSExchMgmtConsole -Force
New-Alias -Name Import-MDSEXO -Value Import-MDSExchOnline -Force

# Import everything in the functions folders
Write-Verbose "Importing Functions"
$privateFunctions = Get-ChildItem "$moduleRoot\Private\*.ps1" | Where-Object { -not ($_.FullName.Contains(".Tests.")) }
$privateFunctions | ForEach-Object {Write-Verbose "Private Function: $($_.FullName)"; . ([scriptblock]::Create([io.file]::ReadAllText($PSItem)))}

$publicFunctions = Get-ChildItem "$moduleRoot\Public\*.ps1" | Where-Object { -not ($_.FullName.Contains(".Tests.")) }
$publicFunctions | ForEach-Object {Write-Verbose "Public Function: $($_.FullName)"; . ([scriptblock]::Create([io.file]::ReadAllText($PSItem)))}

# Create Variables
Write-Verbose "Creating Variables"
New-Variable CredentialFileName -Value 'MDSCredentials.xml' -Option ReadOnly -Scope Script
New-Variable CredentialFilePath -Value (Get-MDSCredentialPath -FileName $CredentialFileName) -Option ReadOnly -Scope Script

Try {
    $null = Get-MDSConfiguration
}
Catch {
    $ConfigurationFilePath = Get-MDSConfigurationPath -FileName Configuration.psd1
     Write-Host "Thank you for using MDS Tools. You must configure your module settings to avoid this warning when importing the module. Use 'Get-Help Set-MDSConfiguration' to see configuration settings and 'Set-MDSConfiguration' to set them.  The store file will be saved in $ConfigurationFilePath." -ForegroundColor Black -BackgroundColor Yellow
}

# Export module members
Write-Verbose 'Export module members'
$ExportModule = @{
    Alias = @('Start-MDSEMC','Import-MDSEXO')
    Function = @($publicFunctions.BaseName)
    Variable = @()
}
Export-ModuleMember @ExportModule

# Register Argument Completers - Version 5+
If ($PSVersionTable.PSVersion.Major -ge 5) {
    # Allows the MDSCredential parameter to auto-complete with the names of each Get-MDSCredential entry
    # across any command that has MDSCredential as a parameter
    Register-ArgumentCompleter -ParameterName MDSCredential -ScriptBlock {(Get-MDSCredential).Name}
}
