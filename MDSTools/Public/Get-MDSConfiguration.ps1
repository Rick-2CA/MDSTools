function Get-MDSConfiguration {
    <#
    .SYNOPSIS
    Set module configuration variables

    .DESCRIPTION
    Some functions in the module require variables that are unique to the environment.  This function displays the configuration variables.

    .EXAMPLE
    Get-MDSConfiguration

	List the module configuration file

    .NOTES
    Uses the 'Configuration' module by Joel Bennett (https://www.powershellgallery.com/packages/Configuration)

    #>

	[CmdletBinding()]
    param (
        [ValidateSet('ADConnectServer','SkypeOnPremServer','ErrorTest')]
        [Parameter()]
        [String]$Setting
    )

    begin {}
    process {
        Try {
            $Configuration = Import-Configuration -ErrorAction Stop

            # Return the specified setting
            If ($PSBoundParameters.Setting) {
                $ConfigSetting = $Configuration[$Setting]
                If (-not $ConfigSetting) {
                    Throw "The module configuration does not have $Setting configured.  Use 'Set-MDSConfiguration -Name $Setting -Value <string>' to configure your settings."
                }
                $ConfigSetting
            }
            # Throw an error if no settings are set
            ElseIf ($Configuration.count -eq 0) {
                Throw "Thank you for using the MDS Tools module.  Please run Set-MDSConfiguration to configure the module settings."
            }
            # Return all settings
            Else {
                $Configuration
            }
        }
        Catch {
            Write-Error $PSItem
        }
    }
    end {}
}
