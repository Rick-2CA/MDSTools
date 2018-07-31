Function Start-MDSADUC {
	<#
		.SYNOPSIS
		Open the Active Directory Users and Computers console

		.DESCRIPTION
		Open the Active Directory Users and Computers console as the current user, with a stored MDSCredential, or prompt for a credential

		.EXAMPLE
		Start-MDSADUC

		Open the ADUC console as the current user

		.EXAMPLE
		Start-MDSADUC -MDSCredential MyCred1

		Open the ADUC console with a stored MDSCredential

		.EXAMPLE
		Start-MDSADUC -Credential MyUserName

		Open the ADUC console prompting for a password for the username MyUserName

		.NOTES

	#>
	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingPlainTextForPassword','')]
	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUsePSCredentialType','')]

	#requires -Module ActiveDirectory

	[CmdletBinding(
		SupportsShouldProcess,
		DefaultParameterSetName='MDSCredential'
	)]
    Param(
		[parameter(Position=0,ParameterSetName='MDSCredential')]
		[String]$MDSCredential,

		[parameter(Position=0,ParameterSetName='Credential')]
		[ValidateNotNullOrEmpty()]
		[System.Management.Automation.CredentialAttribute()]
		$Credential
    )

	Begin {}
	Process {
		Try {
			$ArgumentList = 'Start-Process -FilePath $env:SystemRoot\System32\mmc.exe -ArgumentList $env:SystemRoot\System32\dsa.msc -Verb RunAs'
			$Parameters = @{
				ArgumentList = $ArgumentList
				ErrorAction  = 'Stop'
			}

			# Capture MDS Credentials
			If ($PsCmdlet.ParameterSetName -eq 'MDSCredential' -and -not [string]::IsNullOrEmpty($MDSCredential)) {
				$Credential = Get-MDSCredential -Name $MDSCredential
			}

			# Add credentials to parameter list
			If ($null -ne $Credential) {
				$Parameters.Add('Credential',$Credential)
			}

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
