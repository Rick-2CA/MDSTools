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
	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingPlainTextForPassword','')]
	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUsePSCredentialType','')]

	[CmdletBinding(
		SupportsShouldProcess,
		DefaultParameterSetName='MDSCredential'
	)]
    Param(
		[parameter(
			Position=0,
			ParameterSetName='MDSCredential'
		)]
		[String]$MDSCredential,

		[parameter(
			Position=0,
			ParameterSetName='Credential'
		)]
		[ValidateNotNullOrEmpty()]
		[System.Management.Automation.CredentialAttribute()]
		$Credential
    )

	Begin {}
	Process {
		Try {
			$Parameters = @{
				ErrorAction = 'Stop'
			}

			# MDSCredential
			If ($PSBoundParameters.MDSCredential) {
				$Credential = Get-MDSCredential -Name $MDSCredential -ErrorAction Stop
			}

			# Add credentials to parameter list
			If ($null -ne $Credential) {
				$Parameters.Add('Credential',$Credential)
			}

			$ShouldProcessTarget = $Credential.UserName
			If ($PSCmdlet.ShouldProcess($ShouldProcessTarget,$MyInvocation.MyCommand)) {
				Start-Process PowerShell @Parameters
			}
		}
		Catch {
			Write-Error $PSItem
		}
	}
	End {}
}
