Function Test-MDSADAuthentication {
	<#
    .SYNOPSIS
	Validate Active Directory credentials

    .DESCRIPTION
    Validate Active Directory credentials

    .EXAMPLE
    Test-MDSADAuthentication -Credential MyUserName

	Prompt for credentials for username MyUserName and validate the credentials with Active Directory

    .EXAMPLE
    Test-MDSADAuthentication -Credential MyUserName -DomainController MyDC01

	Prompt for credentials for username MyUserName and validate the credentials with Active Directory on a specified domain controller

	.NOTES
	The Confirm parameter is prompted by default due to the chance of locking out accounts.

	#>

	#requires -Module ActiveDirectory

	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingPlainTextForPassword', '')]
	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUsePSCredentialType', '')]

	[CmdletBinding(
		SupportsShouldProcess=$True,
		ConfirmImpact='High'
	)]

    Param(
		[parameter(Position=0,Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		[System.Management.Automation.CredentialAttribute()]
		$Credential,

		[parameter(Position=1)]
		$DomainController
	)

	Try {
		If ($null -ne $PSBoundParameters.DomainController) {
			$DomainControllerDN = Get-ADDomainController $DomainController -ErrorAction Stop |
				Select-Object -ExpandProperty ComputerObjectDN
			$LDAPPath = "LDAP://{0}" -f $DomainControllerDN
		}

		If ($PSCmdlet.ShouldProcess($Credential.UserName,$MyInvocation.MyCommand)) {
			$null -ne (New-Object DirectoryServices.DirectoryEntry "$($LDAPPath)",$Credential.UserName,$Credential.GetNetworkCredential().Password).psbase.name
		}
	}
	Catch {
		Write-Error $PSItem
	}
}
