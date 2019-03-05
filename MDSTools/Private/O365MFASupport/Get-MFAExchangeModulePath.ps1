Function Get-MFAExchangeModulePath {
    <#
    .SYNOPSIS
    Returns the MFA Exchange Module directory path or an error on how to install the module

    .DESCRIPTION
    Returns the MFA Exchange Module directory path or an error on how to install the module

    .EXAMPLE
    Get-MFAExchangeModulePath

    .NOTES
    Supports Connect-MDSOffice365.ps1

    #>

    [OutputType('System.String')]
    [CmdletBinding()]
    param ()

	begin {}
	process	{
        Try {
            $getChildItemSplat = @{
                Path        = "$Env:LOCALAPPDATA\Apps\2.0\*\Microsoft.Exchange.Management.ExoPowershellModule.manifest"
                Recurse     = $true
                ErrorAction = 'SilentlyContinue'
                Verbose     = $false
            }
            $MFAExchangeModule = Get-ChildItem @getChildItemSplat | Select-Object -ExpandProperty DirectoryName

            If ($null -eq $MFAExchangeModule) {
                Throw "The Exchange Online MFA Module was not found!
https://docs.microsoft.com/en-us/powershell/exchange/exchange-online/connect-to-exchange-online-powershell/mfa-connect-to-exchange-online-powershell?view=exchange-ps"
            }

            $MFAExchangeModule
        }
        Catch {
            Write-Error $PSItem
        }
    }
	end {}
}
