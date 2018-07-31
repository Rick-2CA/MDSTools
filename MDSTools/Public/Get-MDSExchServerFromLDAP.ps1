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
		Get-MDSExchServerFromLDAP

		Returns all Exchange Servers in LDAP

	.EXAMPLE
	   Get-MDSExchServerFromLDAP -Role ClientAccess

		Returns all Client Access Servers in LDAP

	.EXAMPLE
		Get-MDSExchServerFromLDAP -Role HubTransport -Random

		Returns a random Hub Transport Server in LDAP

	.NOTES
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
		Try {
			$configNC = ([ADSI]"LDAP://RootDse").configurationNamingContext
			$search = New-Object DirectoryServices.DirectorySearcher([ADSI]"LDAP://$configNC")
			$objectClass = "objectClass=msExchExchangeServer"
			$version = "versionNumber>=1937801568"
			$search.Filter = "(&($objectClass)($version))"
			$search.PageSize = 1000
			[void] $search.PropertiesToLoad.AddRange(("name","msexchcurrentserverroles","networkaddress"))
			$ServerList = $search.FindAll() | ForEach-Object{
				$ServerRoles = $_.Properties.msexchcurrentserverroles[0]
				$RolesHumanReadable = (
					$RoleAbbreviation.keys |
						Where-Object {$_ -band $ServerRoles} |
						ForEach-Object{$RoleAbbreviation.Get_Item($_)}
				) -join ","
				New-Object PSObject -Property @{
					Name = $_.Properties.name[0]
					FQDN = $_.Properties.networkaddress |
					ForEach-Object{if ($_ -match "ncacn_ip_tcp") {$_.split(":")[1]}}
					msexchcurrentserverroles = $_.Properties.msexchcurrentserverroles[0]
					Roles = $RolesHumanReadable
				}
			} | Sort-Object Name | Select-Object Name,FQDN,msexchcurrentserverroles,Roles

			If ($ServerRoleInteger) {
				$Output = $ServerList | Where-Object {($_.msexchcurrentserverroles -band $ServerRoleInteger) -eq $ServerRoleInteger}
			}
			Else {$Output = $ServerList}

			If ($Random) {$Output | Select-Object Name,FQDN,Roles | Get-Random}
			Else {$Output | Select-Object Name,FQDN,Roles}
		}
		Catch {
			Write-Error $PSItem
		}
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
