Function Start-MDSPowerShell {
	<#
		.SYNOPSIS
		Open PowerShell

		.DESCRIPTION
		Open PowerShell as the current user, with a stored MDSCredential, or prompt for a credential

		.EXAMPLE
		Start-MDSPowerShell

		Open the PowerShell console as the current user

		.EXAMPLE
		Start-MDSPowerShell -MDSCredential MyCred1

		Open the PowerShell console with a stored MDSCredential

		.EXAMPLE
		Start-MDSPowerShell -Credential MyUserName

		Open the PowerShell console prompting for a password for the username MyUserName

		.NOTES

	#>
	[cmdletbinding(DefaultParameterSetName="MDSCredential")]
    Param(
		[parameter(Position=0,ParameterSetName="MDSCredential")]
		[String]$MDSCredential,

		[parameter(Position=0,ParameterSetName="Credential")]
		[ValidateNotNullOrEmpty()]
		[System.Management.Automation.CredentialAttribute()]
		$Credential
    )
	
	Begin {}
	
	Process {
		$Parameters = @{}		
		
		# If $MDSCredential is defined lookup the credentials
		If ($PsCmdlet.ParameterSetName -eq "MDSCredential" -and -not [string]::IsNullOrEmpty($MDSCredential)) {
			Try {
				$Credential = Get-MDSCredential -Name $MDSCredential
			}
			Catch {
				$PsCmdlet.ThrowTerminatingError($PSItem)
			}
		}
		# If $MDSCredential is not defined run the process as the current user
		ElseIf ($PsCmdlet.ParameterSetName -eq "MDSCredential" -and [string]::IsNullOrEmpty($MDSCredential)) {
			Write-Verbose "Opening PowerShell for the current user."
			Return Start-Process PowerShell
		}

		# Add credentials to parameter list
		If ($null -ne $Credential) {
			$Parameters.Add("Credential",$Credential)
		}
		
		Write-Verbose "Opening PowerShell for $($Credential.UserName)."
		Start-Process PowerShell @Parameters
	}
	End {}
}