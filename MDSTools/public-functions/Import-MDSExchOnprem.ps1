Function Import-MDSExchOnprem {
	<#
    .SYNOPSIS
	Import the Exchange On-Premises PowerShell cmdlets using a MDSCredential

    .DESCRIPTION
    Import the Exchange On-Premises PowerShell cmdlets using a MDSCredential

    .EXAMPLE
    Import-MDSExchOnprem -MDSCredential MyCred1 -ExchangeServer MyServerName

	Import the Exchange On-Premises cmdlets with the stored 'MyCred1' credentials

    .EXAMPLE
    Import-MDSExchOnprem -MDSCredential MyCred1 -ExchangeServer MyServerName -ViewEntireForest

	Import the Exchange On-Premises cmdlets with the stored 'MyCred1' credentials and set the session's ADServerSettings to allow viewing the entire forest

    .EXAMPLE
    Import-MDSExchOnprem -MDSCredential MyCred1 -ExchangeServer MyServerName -Prefix OnPrem

	Import the EXO cmdlets with the stored 'MyCred1' credentials and prefix the cmdlets.  For example Get-Mailbox becomes Get-OnPremMailbox.  This allows you to load both the EXO cmdlets and Exchange cmdlets in the same session.

    .NOTES

	#>
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory)]
		[string]$MDSCredential,

		[Parameter(Mandatory)]
		[string]$ExchangeServer,

		[string]$Prefix,
		
		[switch]$ViewEntireForest
	)
	
	Begin {
		$SessionName = 'Microsoft.Exchange'
		Write-Verbose $SessionName
		If (Get-PSSession -Name $SessionName -ErrorAction SilentlyContinue) {
			Try {
				Remove-PSSession $SessionName -ErrorAction Stop
				Write-Verbose "Session $($SessionName) removed"
			}
			Catch {}
		}
	}
	
	Process {
		# Credentials
		If ($MDSCredential) {
			Try {$Credential = Get-MDSCredential -Name $MDSCredential -ErrorAction Stop}
			Catch {
				Write-Error $_
				Return $Null
			}
		}
		Else {
			Try {$Credential = Get-Credential -ErrorAction Stop}
			Catch {
				Write-Error $_
				Return $Null
			}
		}
		
		# Exchange Server Query
		If (-not $ExchangeServer) {
			Try {$ExchangeServer = Get-MDSExchServerFromLDAP -Random -ErrorAction Stop | Select -Expand FQDN}
			Catch {
				Write-Error $_
				Return $Null
			}
		}
		
		# New-PSSession
		$SessionParameters = @{
			'Name'					= $SessionName 
			'ConfigurationName'		= 'Microsoft.Exchange'
			'ConnectionUri'			= "http://$($ExchangeServer)/Powershell/?SerializationLevel=Full"
			'Credential'			= $Credential
			'Authentication'		= 'Kerberos'
		}
		Try {$Session = New-PSSession @SessionParameters -ErrorAction Stop}
		Catch {
			Write-Error $_
			Return $Null
		}

		# Import-PSSession
		$PSSessionParameters = @{
			'Session'	= $Session
			
		}
		If ($Prefix) {$PSSessionParameters.Add("Prefix",$Prefix)}
		Try {$ModuleInfo = Import-PSSession @PSSessionParameters -AllowClobber -DisableNameChecking -ErrorAction Stop}
		#Try {Import-PSSession @PSSessionParameters -AllowClobber -DisableNameChecking -ErrorAction Stop}
		Catch {
			Write-Error $_
			Return $Null
		}
		
		# Import-Module
		$ModuleParameters = @{
			'ModuleInfo'	= $ModuleInfo
			
		}
		If ($Prefix) {$ModuleParameters.Add("Prefix",$Prefix)}
		Try {Import-Module @ModuleParameters -DisableNameChecking -Global -ErrorAction Stop}
		Catch {
			Write-Error $_
			Return $Null
		}
		
		# Set-ADServerSettings to view the entire forest
		If ($ViewEntireForest) {
			$ADServerSettings = Get-Command "Set-$($Prefix)ADServerSettings"
			If ($ADServerSettings) {
				& $ADServerSettings -ViewEntireForest $True
			}
		}
	}
	
	End {}
}