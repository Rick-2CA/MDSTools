function Set-MDSConfiguration {
    <#
    .SYNOPSIS
    Set module configuration variables

    .DESCRIPTION
    Some functions in the module require variables that are unique to the environment.  This function allows for the setting of those variables.  Supported variables may be tab completed with the name parameter.  Those variables include:
        ADConnectServer (Start-MDSADSyncSyncCycle)
        SkypeOnPremServer (Import-MDSSkypeOnPrem)

    .PARAMETER Name
    Valid values:  ADConnectServer, SkypeOnPremServer

    .PARAMETER Value
    String value for the variable specified in the name parameter

    .EXAMPLE
    Set-MDSConfiguration -Name ADConnectServer -Value AADConnect.contoso.com

    .NOTES
    Uses the 'Configuration' module by Joel Bennett (https://www.powershellgallery.com/packages/Configuration)

    #>
	[cmdletbinding()]
    param(
        [ValidateSet("ADConnectServer","SkypeOnPremServer")]
        [Parameter(Mandatory)]
        [String]$Name,

        [Parameter(Mandatory)]
        [String]$Value
    )
    begin {}
    process {
        $Configuration = Import-Configuration
        If ($null -ne $Configuration) {
            If ($Configuration[$Name]) {
                Write-Verbose 'Removing old value'
                $Configuration.Remove($Name)
            }

            Write-Verbose 'Adding old value'
            $Configuration.Add($Name,$Value)
            Get-Module MDSTools | Export-Configuration $Configuration -Scope Enterprise
        }
        Else {
            Write-Verbose "Exporting new value"
            $FirstEntry = @{$Name = $Value}
            Get-Module MDSTools | Export-Configuration $FirstEntry -Scope Enterprise
        }
    }
    end {}
}