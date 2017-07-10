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

	#>
	[cmdletbinding()]
    param(
		[parameter(Position=0,ParameterSetName="Credential", Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		[System.Management.Automation.CredentialAttribute()]
		$Credential,

		[parameter(position=1)]
		$DomainController
	)

#requires -Module ActiveDirectory

	If ($DomainController) {
		Try {$DomainControllerDN = Get-ADDomainController $DomainController -ErrorAction Stop |
				Select-Object -ExpandProperty ComputerObjectDN}
		Catch  {
			$PSCmdlet.ThrowTerminatingError($PSItem)
		}
		$LDAPPath = "LDAP://$($DomainControllerDN)"
	}

    (New-Object DirectoryServices.DirectoryEntry "$($LDAPPath)",$NetworkCredential.UserName,$Credential.GetNetworkCredential()).psbase.name -ne $null
}

<# 

$cred = Get-Credential #Read credentials
$username = $cred.username
$password = $cred.GetNetworkCredential().password
  
$Credential = Get-Credential
$Domain = $Credential.GetNetworkCredential().Domain 
[System.Reflection.Assembly]::LoadWithPartialName("System.DirectoryServices.AccountManagement") 
$principalContext = New-Object System.DirectoryServices.AccountManagement.PrincipalContext(
    [System.DirectoryServices.AccountManagement.ContextType]::Domain, $Domain
) 
$networkCredential = $Credential.GetNetworkCredential() 
$principalContext.ValidateCredentials( 
    $networkCredential.UserName, $networkCredential.Password 
)
#>