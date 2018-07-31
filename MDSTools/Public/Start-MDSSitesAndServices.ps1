Function Start-MDSSitesAndServices {
	<#
		.SYNOPSIS
		Open Active Directory Sites and Services console

		.DESCRIPTION
		Open ctive Directory Sites and Services console as the current user, with a stored MDSCredential, or prompt for a credential

		.EXAMPLE
		Start-MDSSitesAndServices

		Open the ctive Directory Sites and Services console console as the current user

		.EXAMPLE
		Start-MDSSitesAndServices -MDSCredential MyCred1

		Open the ctive Directory Sites and Services console console with a stored MDSCredential

		.EXAMPLE
		Start-MDSSitesAndServices -Credential MyUserName

		Open the ctive Directory Sites and Services console console prompting for a password for the username MyUserName

		.NOTES

		#>

	#requires -Module ActiveDirectory

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
		[ValidateNotNullOrEmpty()]
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
			$ArgumentList = 'Start-Process -FilePath $env:SystemRoot\System32\mmc.exe -ArgumentList $env:SystemRoot\System32\dssite.msc -Verb RunAs'
			$Parameters = @{
				'ArgumentList' = $ArgumentList
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
				Start-Process PowerShell @Parameters -WindowStyle Hidden
			}
		}
		Catch {
			Write-Error $PSItem
		}
	}
	End {}
}
