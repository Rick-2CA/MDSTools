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
	[cmdletbinding(DefaultParameterSetName="MDSCredential")]
    Param(
		[parameter(Position=0,ParameterSetName="MDSCredential")]
		[String]$MDSCredential,

		[parameter(Position=0,ParameterSetName="Credential")]
		[ValidateNotNullOrEmpty()]
		[System.Management.Automation.CredentialAttribute()]
		$Credential
    )
	
#requires -Module GroupPolicy

	Begin {}
	
	Process {
		$ArgumentList = 'Start-Process -FilePath $env:SystemRoot\System32\mmc.exe -ArgumentList $env:SystemRoot\System32\gpmc.msc -Verb RunAs'
		$Parameters = @{
			'ArgumentList' = $ArgumentList
		}		
		
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
			Write-Verbose "Opening Group Policy Management Console for the current user."
			Return Start-Process gpmc.msc
		}

		# Add credentials to parameter list
		If ($null -ne $Credential) {
			$Parameters.Add("Credential",$Credential)
		}
		
		Write-Verbose "Opening Group Policy Management Console for $($Credential.UserName)."
		Start-Process PowerShell @Parameters -WindowStyle Hidden
	}
	End {}
}