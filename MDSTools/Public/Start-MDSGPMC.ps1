Function Start-MDSGPMC {
	<#
		.SYNOPSIS
		Open the Group Policy Management Console

		.DESCRIPTION
		Open the Group Policy Management Console as the current user, with a stored MDSCredential, or prompt for a credential

		.EXAMPLE
		Start-MDSGPMC

		Open the GPMC console as the current user

		.EXAMPLE
		Start-MDSGPMC -MDSCredential MyCred1

		Open the GPMC console with a stored MDSCredential

		.EXAMPLE
		Start-MDSGPMC -Credential MyUserName

		Open the GPMC console prompting for a password for the username MyUserName

		.NOTES

	#>

	#requires -Module GroupPolicy

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
			$ArgumentList = 'Start-Process -FilePath $env:SystemRoot\System32\mmc.exe -ArgumentList $env:SystemRoot\System32\gpmc.msc -Verb RunAs'
            $Parameters = @{
                ArgumentList = $ArgumentList
                ErrorAction  = 'Stop'
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
