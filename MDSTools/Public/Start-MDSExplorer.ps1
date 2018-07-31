Function Start-MDSExplorer {
	<#
		.SYNOPSIS
		Open Windows Explorer

		.DESCRIPTION
		Open Windows Explorer as the current user, with a stored MDSCredential, or prompt for a credential.

		This function has had mixed success.  Sometimes the window simply doesn't open.  It often won't open to the path specified.

		.EXAMPLE
		Start-MDSExplorer

		Open the Windows Explorer console as the current user

		.EXAMPLE
		Start-MDSExplorer -MDSCredential MyCred1 -Path C:\Temp

		Open the Windows Explorer console with a stored MDSCredential to the C:\Temp folder.

		.EXAMPLE
		Start-MDSExplorer -Credential MyUserName

		Open the Windows Explorer console prompting for a password for the username MyUserName

		.NOTES

	#>
	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingPlainTextForPassword','')]
	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUsePSCredentialType','')]

	[CmdletBinding(
		SupportsShouldProcess,
		DefaultParameterSetName='MDSCredential'
	)]
	Param(
		[parameter(Position=0,ParameterSetName='MDSCredential')]
		[ValidateNotNullOrEmpty()]
		[String]$MDSCredential,

		[parameter(Position=0,ParameterSetName='Credential')]
		[ValidateNotNullOrEmpty()]
		[System.Management.Automation.CredentialAttribute()]
		$Credential,

		[parameter(Position=1, ParameterSetName='MDSCredential')]
		[parameter(Position=1, ParameterSetName='Credential')]
		[string]$Path='Documents'
	)

	Begin {}
	Process {
		Try {
			# Variable for storing parameters
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

			# Add path to parameter list
			If (-not ([string]::IsNullOrEmpty($Path))) {
				$Parameters.Add('ArgumentList',$Path)
			}

			# For use in ShouldProcess
			$ShouldProcessTarget = "{0} with path {1}" -f $Credential.UserName,$Path

			# Execute Explorer
			If ($PSCmdlet.ShouldProcess($ShouldProcessTarget,$MyInvocation.MyCommand)) {
				Start-Process Explorer @Parameters -LoadUserProfile
			}
		}
		Catch {
			Write-Error $PSItem
		}
	}
	End {}
}
