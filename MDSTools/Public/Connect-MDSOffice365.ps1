function Connect-MDSOffice365 {
    <#
	.NOTES
		===========================================================================
		Created on:   	2/4/2019 10:42 PM
		Created by:   	Bradley Wyatt
		E-Mail:			Brad@TheLazyAdministrator.com
		GitHub:			https://github.com/bwya77
		Website:		https://www.thelazyadministrator.com
		Organization: 	Porcaro Stolarek Mete Partners; The Lazy Administrator
		Filename:     	Connect-Office365.ps1
		Version: 		2.0.0

		Contributors:   /u/Sheppard_Ra

        Changelog:
            2.0.0
                - Script repurposed for use in MDSTools module
			1.0.5
				- Updated comment based help
			1.0.4
				- Host title will add a service or services you are connected to. If unable to connect it will not display connection status until connection is valid
		===========================================================================

    .SYNOPSIS
        Connect to Office 365 Services

    .DESCRIPTION
        Connect to different Office 365 Services using PowerShell function. Supports MFA.

    .PARAMETER MFA
        Description: Specifies MFA requirement to sign into Office 365 services. If set to $True it will use the Microsoft Exchange Online PowerShell Module to sign into Exchange & Compliance Center using MFA. Other modules support MFA without needing another external module.

        Warning - the Microsoft Exchange Online PowerShell Module has flaws.  It'll close all open sessions.

    .PARAMETER Service
		Description: Specify service to connect to (Exchange, AzureAD, MSOnline, Teams, SecurityandCompliance, SharePoint, SkypeForBusiness)

    .EXAMPLE
		Description: Connect to SharePoint Online
        C:\PS> Connect-Office365 -SharePoint

    .EXAMPLE
		Description: Connect to Exchange Online and Azure AD V1 (MSOnline)
        C:\PS> Connect-Office365 -Service Exchange, MSOnline

    .EXAMPLE
		Description: Connect to Exchange Online and Azure AD V2 using Multi-Factor Authentication
        C:\PS> Connect-Office365 -Service Exchange, MSOnline -MFA

	.EXAMPLE
		Description: Connect to Teams and Skype for Business
        C:\PS> Connect-Office365 -Service Teams, SkypeForBusiness

	.EXAMPLE
		Description: Connect to SharePoint Online
		 C:\PS> Connect-Office365 -Service SharePoint -SharePointOrganizationName bwya77 -MFA

    .LINK
        Online version:  https://www.thelazyadministrator.com/2019/02/05/powershell-function-to-connect-to-all-office-365-services

    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingPlainTextForPassword', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUsePSCredentialType', '')]

    [OutputType()]
    [CmdletBinding(DefaultParameterSetName = 'Credential')]
    Param (
        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateSet('AzureAD', 'Exchange', 'MSOnline', 'SecurityAndCompliance', 'SharePoint', 'SkypeForBusiness', 'Teams')]
        [string[]]$Service,

        [Parameter(Mandatory = $False, Position = 2)]
        [Alias('SPOrgName')]
        [string]$SharePointOrganizationName,

        [Parameter(Mandatory = $False, Position = 3, ParameterSetName = 'MDSCredential')]
        [String]$MDSCredential,

        [Parameter(Mandatory = $False, Position = 3, ParameterSetName = 'Credential')]
        [ValidateNotNullOrEmpty()]
        [PSCredential]$Credential,

        [Parameter(Mandatory = $False, Position = 4)]
        [Switch]$MFA,

        [Parameter(Mandatory = $False, Position = 5)]
        [switch]$Prefix
    )

    begin {
        If ($PSBoundParameters.ContainsKey('MDSCredential')) {
            $Credential = Get-MDSCredential -Name $MDSCredential -ErrorAction Stop
        }
    }
    process {
        ForEach ($Item in $PSBoundParameters.Service) {
            Write-Verbose "Attempting connection to $Item"
            Switch ($Item) {
                AzureAD {
                    $ModuleName = 'AzureAD'
                    If (-not (Test-MDSModuleExist -Name $ModuleName -Item $Item)) {
                        continue
                    }
                    Else {
                        Try {
                            If ($True -eq $MFA) {
                                Connect-AzureAD -ErrorAction Stop
                            }
                            Else {
                                Connect-AzureAD -Credential $Credential -ErrorAction Stop
                            }
                        }
                        Catch {
                            Write-Error $PSItem
                            continue
                        }
                    }
                    continue
                }

                Exchange {
                    If ($True -eq $MFA) {
                        Try {    
                            $connectEXOPSSessionSplat = @{
                                ErrorAction = 'Stop'
                                Verbose     = $False
                            }
                            If ($null -ne $Credential) {
                                $connectEXOPSSessionSplat.Add('UserPrincipalName', $Credential.UserName)
                            }
                            Connect-MDSEXOPSSession @connectEXOPSSessionSplat
                        }
                        Catch {
                            Write-Error $PSItem
                            continue
                        }
                    }
                    Else {
                        Try {
                            $importMDSExchOnlineSplat = @{
                                Credential  = $Credential
                                ErrorAction = 'Stop'
                            }
                            If ($PSBoundParameters.ContainsKey($Prefix)) {
                                $importMDSExchOnlineSplat.Add('Prefix', $True)
                            }
                            Import-MDSExchOnline @importMDSExchOnlineSplat
                        }
                        Catch {
                            Write-Error $PSItem
                            continue
                        }
                    }
                    continue
                }

                MSOnline {
                    $ModuleName = 'MSOnline'
                    If (-not (Test-MDSModuleExist -Name $ModuleName -Item $Item)) {
                        continue
                    }
                    Else {
                        Try {
                            Write-Verbose "Connecting to MSOnline"
                            If ($True -eq $MFA) {
                                Connect-MsolService -ErrorAction Stop
                            }
                            Else {
                                Connect-MsolService -Credential $Credential -ErrorAction Stop
                            }
                        }
                        Catch {
                            Write-Error $PSItem
                            continue
                        }
                    }
                    continue
                }

                SecurityAndCompliance {
                    If ($MFA -eq $True) {
                        Try {
                            $connectIPPSSessionSplat = @{
                                ErrorAction = 'Stop'
                                Verbose     = $False
                            }

                            If ($null -ne $Credential) {
                                $connectIPPSSessionSplat.Add('UserPrincipalName', $Credential.UserName)
                            }
                            Connect-MDSIPPSSession @connectIPPSSessionSplat
                        }
                        Catch {
                            Write-Error $PSItem
                            continue
                        }
                    }
                    Else {
                        Try {
                            $importMDSSecurityAndCompliance = @{
                                Credential  = $Credential
                                ErrorAction = 'Stop'
                            }
                            If ($PSBoundParameters.ContainsKey($Prefix)) {
                                $importMDSSecurityAndCompliance.Add('Prefix', $True)
                            }
                            Import-MDSSecurityAndCompliance @importMDSSecurityAndCompliance
                        }
                        Catch {
                            Write-Error $PSItem
                            continue
                        }
                    }
                    continue
                }

                SharePoint {
                    $ModuleName = 'Microsoft.Online.SharePoint.PowerShell'
                    If (-not (Test-MDSModuleExist -Name $ModuleName -Item $Item)) {
                        continue
                    }
                    Else {
                        If (-not ($PSBoundParameters.ContainsKey('SharePointOrganizationName'))) {
                            Write-Error 'Please provide a valid SharePoint organization name with the -SharePointOrganizationName parameter.'
                            continue
                        }

                        Try {
                            $SharePointURL = "https://{0}-admin.sharepoint.com" -f $SharePointOrganizationName
                            $connectSPOServiceSplat = @{
                                Url         = $SharePointURL
                                ErrorAction = 'Stop'
                            }
                            Write-Verbose "Connecting to SharePoint at $SharePointURL"
                            If ($True -eq $MFA) {
                                Connect-SPOService @connectSPOServiceSplat
                            }
                            Else {
                                Connect-SPOService @connectSPOServiceSplat -Credential $Credential
                            }
                        }
                        Catch {
                            Write-Error $PSItem
                            continue
                        }
                    }
                    continue
                }

                SkypeForBusiness {
                    Write-Verbose "Connecting to SkypeForBusiness"
                    $ModuleName = 'SkypeOnlineConnector'
                    If (-not (Test-MDSModuleExist -Name $ModuleName -Item $Item)) {
                        continue
                    }
                    Else {
                        Try {
                            If ($True -eq $MFA) {
                                $CSSession = New-CsOnlineSession -ErrorAction Stop
                            }
                            Else {
                                $CSSession = New-CsOnlineSession -Credential $Credential -ErrorAction Stop
                            }
                            Import-PSSession $CSSession -AllowClobber -ErrorAction Stop
                        }
                        Catch {
                            Write-Error $PSItem
                            continue
                        }
                    }
                    continue
                }

                Teams {
                    $ModuleName = 'MicrosoftTeams'
                    If (-not (Test-MDSModuleExist -Name $ModuleName -Item $Item)) {
                        continue
                    }
                    Else {
                        Try {
                            Write-Verbose "Connecting to Teams"
                            If ($MFA -eq $True) {
                                Connect-MicrosoftTeams -ErrorAction Stop
                            }
                            Else {
                                Connect-MicrosoftTeams -Credential $Credential -ErrorAction Stop
                            }
                        }
                        Catch {
                            Write-Error $PSItem
                            continue
                        }
                    }
                    continue
                }

                Default {
                    Write-Verbose "Default triggered for item $Item"
                }
            }
        }
    }
    end {}
}
