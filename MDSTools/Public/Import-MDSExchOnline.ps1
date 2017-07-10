Function Import-MDSExchOnline {
	<#
    .SYNOPSIS
	Import the Exchange Online PowerShell cmdlets using a MDSCredential

    .DESCRIPTION
    Import the Exchange Online PowerShell cmdlets using a MDSCredential

    .EXAMPLE
    Import-MDSExchOnline -MDSCredential MyCred1

	Import the EXO cmdlets with the stored 'MyCred1' credentials.  The stored credential username should be a UPN.

    .EXAMPLE
    Import-MDSExchOnline -MDSCredential MyCred1 -Prefix O365

	Import the EXO cmdlets with the stored 'MyCred1' credentials and prefix the cmdlets.  For example Get-Mailbox becomes Get-O365Mailbox.  This allows you to load both the EXO cmdlets and Exchange cmdlets in the same session.

    .NOTES

	#>
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory)]
		[string]$MDSCredential,
		
		[string]$Prefix
	)

	Begin {
		$SessionName = 'Microsoft.Exchange.Online'
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
		
		# New-PSSession
		$SessionParameters = @{
			'Name'					= $SessionName
			'ConfigurationName'		= 'Microsoft.Exchange'
			'ConnectionUri'			= 'https://outlook.office365.com/powershell-liveid/'
			'Credential'			= $Credential
			'Authentication'		= 'Basic'
		}
		Try {$Session = New-PSSession @SessionParameters -AllowRedirection -ErrorAction Stop}
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
		Catch {
			Write-Error $_
			Return $Null
		}
		
		# Import-Module
		$ModuleParameters = @{
			'ModuleInfo'	= $ModuleInfo	
		}
		If ($Prefix) {$ModuleParameters.Add("Prefix",$Prefix)}
		Try {
			Import-Module @ModuleParameters -DisableNameChecking -Global -ErrorAction Stop
			#Remove-PSSession $Session
		}
		Catch {
			Write-Error $_
			Return $Null
		}
	}
	
	End {}
}



