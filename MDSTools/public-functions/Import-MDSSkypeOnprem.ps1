Function Import-MDSSkypeOnPrem {
	<#
    .SYNOPSIS
	Import the Skype On-Premises PowerShell cmdlets using a MDSCredential

    .DESCRIPTION
    Import the Skype On-Premises PowerShell cmdlets using a MDSCredential

    .EXAMPLE
    Import-MDSSkypeOnPrem -MDSCredential MyCred1

	Import the Skype On-Premises cmdlets with the stored 'MyCred1' credentials.  The stored credential username should be a UPN.

    .EXAMPLE
    Import-MDSSkypeOnPrem -MDSCredential MyCred1 -Prefix OnPrem

	Import the Skype On-Premises cmdlets with the stored 'MyCred1' credentials and prefix the cmdlets.  For example Get-CsUser becomes Get-OnPremCsUser.  This allows you to load both the Skype Online cmdlets and Exchange cmdlets in the same session.

    .NOTES

	#>
	[CmdletBinding()]
	Param(
		[Parameter(Mandatory)]
		[string]$MDSCredential,

		[Parameter(Mandatory)]
		[string]$ServerName,

		[string]$Prefix
	)
	
	Begin {
		$SessionName = 'Microsoft.Skype'
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

		# Use the configuration file if a servername was not specified
		If (-not $ServerName) {
			$ServerName = Get-MDSConfiguration -Setting SkypeOnPremServer
		}
		
		# New-PSSession
		$SessionParameters = @{
			'Name'					= $SessionName 
			'ConnectionUri'			= "https://$($ServerName)/ocspowershell"
			'Credential'			= $Credential
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
	}
	
	End {}
}