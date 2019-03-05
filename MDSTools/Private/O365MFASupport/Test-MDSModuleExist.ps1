Function Test-MDSModuleExist {
    <#
    .SYNOPSIS
    Test function to support Connect-Office365

    .DESCRIPTION
    Test function to support Connect-Office365

    .EXAMPLE
    Test-MDSModuleExist -Name $ModuleName -Item $ItemName

    .NOTES
    Cleans up some code in Connect-Office365

    #>

    [OutputType('System.Boolean')]
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$Item
    )

    begin {}
    process {
        $getModuleSplat = @{
            Name          = $Name
            ListAvailable = $True
            ErrorAction   = 'SilentlyContinue'
            Verbose       = $False
        }
        If ($null -eq (Get-Module @getModuleSplat)) {
            Write-Error "The $Name module must be present to connect to $Item."
            $False
        }
        else {
            $True
        }
    }
    end {}
}
