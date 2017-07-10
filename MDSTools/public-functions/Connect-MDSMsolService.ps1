Function Connect-MDSMsolService {
	<#
    .SYNOPSIS
	Connect to MS Online (Office 365)

    .DESCRIPTION
    Connect to MS Online (Office 365) using an MDSCredential entry, prompt for credentials, or use the currently logged on user credentials.

    .EXAMPLE
    Connect-MDSMsolService -MDSCredential MyCred1

	Connect to MS Online with the MyCred1 credentials created with Add-MDSCredential.

    .EXAMPLE
	Connect-MDSMsolService -Credential MyUserName@domain.com

	Connect to MS Online by prompted for a password for the user MyUserName@domain.com.

	.EXAMPLE
	Connect-MDSMsolService -CurrentCredential

	Connect to MS Online using the currently logged on credentials.  Simply does Connect-MsolService -CurrentCredential.

    .NOTES

	#>
	[cmdletbinding(DefaultParameterSetName="MDSCredential")]
	Param (
		[parameter(Position=0,ParameterSetName="MDSCredential")]
		[String]$MDSCredential,

		[parameter(Position=0,ParameterSetName="Credential")]
		[ValidateNotNullOrEmpty()]
		[System.Management.Automation.CredentialAttribute()]
		$Credential,

		[parameter(Position=0,ParameterSetName="CurrentCredential")]
		[switch]$CurrentCredential
	)
	
	Begin {}
	
	Process {
		# $MDSCredential is allowed to be null to allow the cmdlet to be called without parameters resulting
		# in a prompt for credentials.  $Credential has validation and handles the credential prompt ahead
		# of Connect-MsolService being called.

		If ($PsCmdlet.ParameterSetName -eq "MDSCredential" -and -not [string]::IsNullOrEmpty($MDSCredential)) {
			Try {$Credential = Get-MDSCredential -Name $MDSCredential -ErrorAction Stop}
			Catch {
				$PsCmdlet.ThrowTerminatingError($PSItem)
			}
		}

		# If Credentials were found execute Connect-MsolService with parameters
		If (-not [string]::IsNullOrEmpty($Credential)) {
			$Parameters = @{'Credential' = $Credential}
			Write-Verbose "Connecting to MS Online as $($Credential.UserName)."
			Connect-MsolService @Parameters
			Return
		}
		
		# Use current recredentials
		If ($PsCmdlet.ParameterSetName -eq "CurrentCredential") {
			Write-Verbose "Connecting to MS Online with the currently logged on user."
			Connect-MsolService -CurrentCredential
			Return
		}

		# No parameters results in Connect-MsolService prompting for credentials.
		Connect-MsolService
	}
	
	End {}
}