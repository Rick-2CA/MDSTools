function Connect-MDSIPPSSession {
    <#
        .SYNOPSIS
            Connect-IPPSSession -ConnectionURI https://ps.compliance.protection.outlook.com/PowerShell-LiveId -AzureADAuthorizationEndpointUri https://login.windows.net/common
            NOTE: PSSessionOption accept object created using New-PSSessionOption
                  Please add -DelegatedOrganization para name and its value (domain name) if you want manage another tenant

        .DESCRIPTION
            This cmdlet allows you to connect to Exchange Online Protection Service
    #>
    [CmdletBinding()]
    param(
        # Connection Uri for the Remote PowerShell endpoint
        [string]$ConnectionUri = 'https://ps.compliance.protection.outlook.com/PowerShell-LiveId',

        # Azure AD Authorization endpoint Uri that can issue the OAuth2 access tokens
        [string]$AzureADAuthorizationEndpointUri = 'https://login.windows.net/common',

        # Delegated Organization Name
        [string]$DelegatedOrganization = '',

        # PowerShell session options to be used when opening the Remote PowerShell session
        [System.Management.Automation.Remoting.PSSessionOption]$PSSessionOption = $null,

        # Switch to bypass use of mailbox anchoring hint.
        [switch]$BypassMailboxAnchoring = $false
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

            $paramDictionary = New-object System.Management.Automation.RuntimeDefinedParameterDictionary
            $paramDictionary.Add('UserPrincipalName', $UserPrincipalName)
            $paramDictionary.Add('Credential', $Credential)
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
        # Cleanup old ps sessions
        $ComputerName = 'ps.compliance.protection.outlook.com'
        If ((Get-PSSession).Where{$_.ComputerName -match $ComputerName}) {
            $WarningMsg = 'A previous connection to {0} has been removed.' -f $ComputerName
            Write-Warning $WarningMsg
        }

        [string]$newUri = $null

        if (-not [string]::IsNullOrWhiteSpace($DelegatedOrganization)) {
            [UriBuilder]$uriBuilder = New-Object -TypeName UriBuilder -ArgumentList $ConnectionUri
            [string]$queryToAppend = "DelegatedOrg={0}" -f $DelegatedOrganization

            if ($null -ne $uriBuilder.Query -and $uriBuilder.Query.Length -gt 0) {
                [string]$existingQuery = $uriBuilder.Query.Substring(1)
                $uriBuilder.Query = $existingQuery + "&" + $queryToAppend
            }
            else {
                $uriBuilder.Query = $queryToAppend
            }

            $newUri = $uriBuilder.ToString()
        }
        else {
            $newUri = $ConnectionUri
        }

        $connectEXOPSSessionSplat = @{
            BypassMailboxAnchoring          = $BypassMailboxAnchoring
            PSSessionOption                 = $PSSessionOption
            ConnectionUri                   = $newUri
            AzureADAuthorizationEndpointUri = $AzureADAuthorizationEndpointUri
        }

        if ($isCloudShell -eq $false) {
            If (-not [string]::IsNullOrWhiteSpace($UserPrincipalName.Value)) {
                $connectEXOPSSessionSplat.Add('UserPrincipalName', $UserPrincipalName.Value)
            }
            If (-not [string]::IsNullOrWhiteSpace($Credential.Value)) {
                $connectEXOPSSessionSplat.Add('Credential', $Credential.Value)
            }
            Connect-EXOPSSession @connectEXOPSSessionSplat
        }
        else {
            $newExoPSSessionSplat.Add('Device', $Device.Value)
            Connect-EXOPSSession @connectEXOPSSessionSplat
        }
    }
    end {}
}
