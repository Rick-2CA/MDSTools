Function Get-MDSExchServerFromLDAP {
	<#
	.SYNOPSIS
		Gets a list of Exchange Servers registered in LDAP.

	.DESCRIPTION
		Gets a list of Exchange Servers registered in LDAP.  Can return Exchange Servers of a particular
		role and/or return a single random server.

	.PARAMETER Role
		Returns a list of servers with a specific role installed.  Valid arguments include
		'Mailbox','ClientAccess','UnifiedMessaging','HubTransport','EdgeTransport'

	.PARAMETER Random
		Returns a single random server from the list.  May be used with or without -Role

	.EXAMPLE
		Get-ExchangeServerFromLDAP

		Returns all Exchange Servers in LDAP

	.EXAMPLE
	   Get-ExchangeServerFromLDAP -Role ClientAccess

		Returns all Client Access Servers in LDAP

	.EXAMPLE
		Get-ExchangeServerFromLDAP -Role HubTransport -Random

		Returns a random Hub Transport Server in LDAP

	.NOTES
		Name: Get-ExchangeServerFromLDAP
		Author: Rick A
		Based on source:  http://mikepfeiffer.net/2010/04/find-exchange-servers-in-the-local-active-directory-site-using-powershell/
	#>

	[cmdletbinding()]
	param(
		[parameter()]
		[ValidateSet('Mailbox','ClientAccess','UnifiedMessaging','HubTransport','EdgeTransport',ignorecase=$True)]
		[string]$Role,
		[parameter()]
		[switch]$Random
	)
	
	Begin {
		If ($Role) {
			Switch ($Role) {
				Mailbox				{$ServerRoleInteger = 2;continue}
				ClientAccess		{$ServerRoleInteger = 4;continue}
				UnifiedMessaging	{$ServerRoleInteger = 16;continue}
				HubTransport		{$ServerRoleInteger = 32;continue}
				EdgeTransport		{$ServerRoleInteger = 64;continue}
			}
		}
		
		$RoleAbbreviation = @{
			2  = "MB"
			4  = "CAS"
			16 = "UM"
			32 = "HT"
			64 = "ET"
		}
	}

	Process {
		$configNC=([ADSI]"LDAP://RootDse").configurationNamingContext
		$search = new-object DirectoryServices.DirectorySearcher([ADSI]"LDAP://$configNC")
		$objectClass = "objectClass=msExchExchangeServer"
		$version = "versionNumber>=1937801568"
		$search.Filter = "(&($objectClass)($version))"
		$search.PageSize = 1000
		[void] $search.PropertiesToLoad.AddRange(("name","msexchcurrentserverroles","networkaddress"))
		$ServerList = $search.FindAll() | %{
			$ServerRoles = $_.Properties.msexchcurrentserverroles[0]
			$RolesHumanReadable = ($RoleAbbreviation.keys | ?{$_ -band $ServerRoles} | %{$RoleAbbreviation.Get_Item($_)}) -join ","
			New-Object PSObject -Property @{
				Name = $_.Properties.name[0]
				FQDN = $_.Properties.networkaddress |
					%{if ($_ -match "ncacn_ip_tcp") {$_.split(":")[1]}}
				msexchcurrentserverroles = $_.Properties.msexchcurrentserverroles[0]
				Roles = $RolesHumanReadable
			}
		} | Sort Name | Select Name,FQDN,msexchcurrentserverroles,Roles

		If ($ServerRoleInteger) {
			$Output = $ServerList | Where({($_.msexchcurrentserverroles -band $ServerRoleInteger) -eq $ServerRoleInteger})
		}
		Else {$Output = $ServerList}
		
		If ($Random) {$Output | Select Name,FQDN,Roles | Get-Random}
		Else {$Output | Select Name,FQDN,Roles}
	}
}

<#
### Test the function
$Count = 0
Do {
	$ExchServer = Get-ExchangeServerFromLDAP -Role HubTransport -Random
	$TestConnection = $False
	Try {$TestConnection = Test-Connection $ExchServer.FQDN -Count 1 -ErrorAction Stop}
	Catch {}
	If ($Count -le 2) {$ExchServer.fqdn;$Count++;$TestConnection = $False}
}
Until ($TestConnection -ne $False)

### Use Case

Do {
	$ExchServer = Get-ExchangeServerFromLDAP -Role HubTransport -Random
	$TestConnection = $False
	Try {$TestConnection = Test-Connection $ExchServer.FQDN -Count 1 -ErrorAction Stop}	
	Catch {}

}
Until ($TestConnection -ne $False)
$ExchServer

#>