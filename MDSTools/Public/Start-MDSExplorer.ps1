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
	[CmdletBinding(
		SupportsShouldProcess,
		DefaultParameterSetName="MDSCredential"
	)]
	Param(
		[parameter(Position=0,ParameterSetName="MDSCredential")]
		[String]$MDSCredential,

		[parameter(Position=0,ParameterSetName="Credential")]
		[ValidateNotNullOrEmpty()]
		[System.Management.Automation.CredentialAttribute()]
		$Credential,

		[parameter(Position=1, ParameterSetName="MDSCredential")]
		[parameter(Position=1, ParameterSetName="Credential")]
		[string]$Path='Documents'
	)
	
	Begin {}
	Process {
		# Variable for storing parameters
		$Parameters = @{}
		
		# Capture MDS Credentials
		If ($PsCmdlet.ParameterSetName -eq "MDSCredential" -and -not [string]::IsNullOrEmpty($MDSCredential)) {
			Try {
				$Credential = Get-MDSCredential -Name $MDSCredential
			}
			Catch {
				$PsCmdlet.ThrowTerminatingError($PSItem)
			}
		}
		ElseIf ($PsCmdlet.ParameterSetName -eq "MDSCredential" -and [string]::IsNullOrEmpty($MDSCredential)) {
			Write-Verbose "Opening Explorer for the current user."
			Return Start-Process Explorer
		}

		# Add credentials to parameter list
		If ($null -ne $Credential) {
			$Parameters.Add("Credential",$Credential)
		}
		
		If (-not ([string]::IsNullOrEmpty($Path))) {
			$Parameters.Add("ArgumentList",$Path)
		}

		# For use in Confirm & WhatIf
		$ShouldProcessTarget = "Username:  {0}, Path:  {1}" -f $Credential.UserName,$Path

		# Execute Explorer
		If ($PSCmdlet.ShouldProcess($ShouldProcessTarget,$MyInvocation.MyCommand)) {
			Try {
				Write-Verbose "Opening Explorer for $($Credential.UserName)."
				Start-Process Explorer @Parameters -LoadUserProfile
			}
			Catch {
				$PsCmdlet.ThrowTerminatingError($PSItem)
			}
		}
	}
	
	End {}
}