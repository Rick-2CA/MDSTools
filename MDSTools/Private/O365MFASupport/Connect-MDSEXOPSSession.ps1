function Connect-MDSEXOPSSession {
    <#
        .SYNOPSIS
            To connect in other Office 365 offerings, use the following settings:
             - Office 365 operated by 21Vianet: -ConnectionURI https://partner.outlook.cn/PowerShell-LiveID -AzureADAuthorizationEndpointUri https://login.chinacloudapi.cn/common
             - Office 365 Germany: -ConnectionURI https://outlook.office.de/PowerShell-LiveID -AzureADAuthorizationEndpointUri https://login.microsoftonline.de/common
        
            - PSSessionOption accept object created using New-PSSessionOption

            - EnableEXOTelemetry To collect telemetry on Exchange cmdlets. Default value is False.

            - TelemetryFilePath Telemetry records will be written to this file. Default value is %TMP%\EXOCmdletTelemetry\EXOCmdletTelemetry-yyyymmdd-hhmmss.csv

            - DoLogErrorMessage Switch to enable/disable error message logging in telemetry file. Default value is True.

        .DESCRIPTION
            This PowerShell module allows you to connect to Exchange Online service
        .LINK
            https://go.microsoft.com/fwlink/p/?linkid=837645
    #>
    [CmdletBinding()]
    param(
        # Connection Uri for the Remote PowerShell endpoint
        [string] $ConnectionUri = 'https://outlook.office365.com/PowerShell-LiveId',

        # Azure AD Authorization endpoint Uri that can issue the OAuth2 access tokens
        [string] $AzureADAuthorizationEndpointUri = 'https://login.windows.net/common',

        # PowerShell session options to be used when opening the Remote PowerShell session
        [System.Management.Automation.Remoting.PSSessionOption] $PSSessionOption = $null,

        # Switch to bypass use of mailbox anchoring hint.
        [switch] $BypassMailboxAnchoring = $false
    )
    DynamicParam {
        if (($isCloudShell = IsCloudShellEnvironment) -eq $false) {
            $attributes = New-Object System.Management.Automation.ParameterAttribute
            $attributes.Mandatory = $false

            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($attributes)

            # User Principal Name or email address of the user
            $UserPrincipalName = New-Object System.Management.Automation.RuntimeDefinedParameter('UserPrincipalName', [string], $attributeCollection)
            $UserPrincipalName.Value = ''

            # User Credential to Logon
            $Credential = New-Object System.Management.Automation.RuntimeDefinedParameter('Credential', [System.Management.Automation.PSCredential], $attributeCollection)
            $Credential.Value = $null
            
            # Switch to collect telemetry on command execution. 
            $EnableEXOTelemetry = New-Object System.Management.Automation.RuntimeDefinedParameter('EnableEXOTelemetry', [switch], $attributeCollection)
            $EnableEXOTelemetry.Value = $false
            
            # Where to store EXO command telemetry data. By default telemetry is stored in 
            # %TMP%/EXOTelemetry/EXOCmdletTelemetry-yyyymmdd-hhmmss.csv.
            $TelemetryFilePath = New-Object System.Management.Automation.RuntimeDefinedParameter('TelemetryFilePath', [string], $attributeCollection)
            $TelemetryFilePath.Value = ''
            
            # Switch to Disable error message logging in telemetry file.
            $DoLogErrorMessage = New-Object System.Management.Automation.RuntimeDefinedParameter('DoLogErrorMessage', [switch], $attributeCollection)
            $DoLogErrorMessage.Value = $true
            
            $paramDictionary = New-object System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add('UserPrincipalName', $UserPrincipalName)
            $paramDictionary.Add('Credential', $Credential)
            $paramDictionary.Add('EnableEXOTelemetry', $EnableEXOTelemetry)
            $paramDictionary.Add('TelemetryFilePath', $TelemetryFilePath)
            $paramDictionary.Add('DoLogErrorMessage', $DoLogErrorMessage)
            return $paramDictionary
        }
        else {
            $attributes = New-Object System.Management.Automation.ParameterAttribute
            $attributes.Mandatory = $false

            $attributeCollection = New-Object System.Collections.ObjectModel.Collection[System.Attribute]
            $attributeCollection.Add($attributes)

            # Switch to MSI auth 
            $Device = New-Object System.Management.Automation.RuntimeDefinedParameter('Device', [switch], $attributeCollection)
            $Device.Value = $false

            $paramDictionary = New-object System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add('Device', $Device)
            return $paramDictionary
        }
    }
    begin {
        $MFAExchangeModulePath = Get-MFAExchangeModulePath -ErrorAction Stop
        . "$MFAExchangeModulePath\CreateExoPSSession.ps1"
    }
    process {
        # Validate parameters
        if (-not (Test-Uri $ConnectionUri)) {
            throw "Invalid ConnectionUri parameter '$ConnectionUri'"
        }
        if (-not (Test-Uri $AzureADAuthorizationEndpointUri)) {
            throw "Invalid AzureADAuthorizationEndpointUri parameter '$AzureADAuthorizationEndpointUri'"
        }

        # Keep track of error count at beginning.
        $errorCountAtStart = $global:Error.Count
        
        try {
            # Cleanup old ps sessions
            $ComputerName = 'outlook.office365.com'
            If ((Get-PSSession).Where{$_.ComputerName -match $ComputerName}) {
                $WarningMsg = 'A previous connection to {0} has been removed.' -f $ComputerName
                Write-Warning $WarningMsg
            }

            $MFAExchangeModulePath = Get-MFAExchangeModulePath -ErrorAction Stop
            $ExoPowershellModule = "Microsoft.Exchange.Management.ExoPowershellModule.dll"
            $ModulePath = [System.IO.Path]::Combine($MFAExchangeModulePath, $ExoPowershellModule)

            $global:ConnectionUri = $ConnectionUri
            $global:AzureADAuthorizationEndpointUri = $AzureADAuthorizationEndpointUri
            $global:PSSessionOption = $PSSessionOption
            $global:BypassMailboxAnchoring = $BypassMailboxAnchoring

            if ($isCloudShell -eq $false) {
                $global:UserPrincipalName = $UserPrincipalName.Value
                $global:Credential = $Credential.Value
            }
            else {
                $global:Device = $Device.Value
            }

            Import-Module $ModulePath
            
            $newExoPSSessionSplat = @{
                BypassMailboxAnchoring          = $BypassMailboxAnchoring
                PSSessionOption                 = $PSSessionOption
                ConnectionUri                   = $ConnectionUri
                AzureADAuthorizationEndpointUri = $AzureADAuthorizationEndpointUri
            }

            if ($isCloudShell -eq $false) {
                $newExoPSSessionSplat.Add('UserPrincipalName', $UserPrincipalName.Value)
                $newExoPSSessionSplat.Add('Credential', $Credential.Value)
                $PSSession = New-ExoPSSession @newExoPSSessionSplat
            }
            else {
                $newExoPSSessionSplat.Add('Device', $Device.Value)
                $PSSession = New-ExoPSSession @newExoPSSessionSplat
            }

            if ($null -ne $PSSession) {
                $PSSessionModuleInfo = Import-PSSession $PSSession -AllowClobber
                UpdateImplicitRemotingHandler

                # If we are configured to collect telemetry, add telemetry wrappers. 
                if ($EnableEXOTelemetry.Value -eq $true) {
                    $addEXOClientTelemetryWrapperSplat = @{
                        TelemetryFilePath   = $TelemetryFilePath.Value
                        DoLogErrorMessage   = $DoLogErrorMessage.Value
                        PSSessionModuleName = $PSSessionModuleInfo.Name
                        Organization        = (Get-OrgNameFromUPN -UPN $UserPrincipalName.Value)
                    }
                    $TelemetryFilePath.Value = Add-EXOClientTelemetryWrapper @addEXOClientTelemetryWrapperSplat
                }
            }
        }
        catch {
            throw $_
        }
        Finally {
            # If telemetry is enabled, log errors generated from this cmdlet also. 
            if ($EnableEXOTelemetry.Value -eq $true) {
                $errorCountAtProcessEnd = $global:Error.Count 

                # If we have any errors during this cmdlet execution, log it. 
                if ($errorCountAtProcessEnd -gt $errorCountAtStart) {
                    if (!$TelemetryFilePath.Value) {
                        $TelemetryFilePath.Value = New-EXOClientTelemetryFilePath
                    }

                    # Log errors which are encountered during Connect-EXOPSSession execution. 
                    Write-Warning("Writing Connect-EXOPSSession errors to " + $TelemetryFilePath.Value)
                    
                    $pushEXOTelemetryRecordSplat = @{
                        CommandName            = 'Connect-EXOPSSession'
                        ScriptName             = $global:ExPSTelemetryScriptName
                        OrganizationName       = $global:ExPSTelemetryOrganization
                        ScriptExecutionGuid    = $global:ExPSTelemetryScriptExecutionGuid
                        TelemetryFilePath      = $TelemetryFilePath.Value
                        ErrorObject            = $global:Error
                        ErrorRecordsToConsider = ($errorCountAtProcessEnd - $errorCountAtStart)
                    }
                    Push-EXOTelemetryRecord @pushEXOTelemetryRecordSplat 
                }
            }
        }
    }
    end {}
}
