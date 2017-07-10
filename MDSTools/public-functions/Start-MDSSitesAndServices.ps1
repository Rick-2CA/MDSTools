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
	[cmdletbinding(DefaultParameterSetName="MDSCredential")]
    Param(
		[parameter(Position=0,ParameterSetName="MDSCredential")]
		[String]$MDSCredential,

		[parameter(Position=0,ParameterSetName="Credential")]
		[ValidateNotNullOrEmpty()]
		[System.Management.Automation.CredentialAttribute()]
		$Credential
    )
	
#requires -Module ActiveDirectory

	Begin {}
	
	Process {
		$ArgumentList = 'Start-Process -FilePath $env:SystemRoot\System32\mmc.exe -ArgumentList $env:SystemRoot\System32\dssite.msc -Verb RunAs'
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
			Write-Verbose "Opening AD Sites & Services for the current user."
			Return Start-Process dssite.msc
		}

		# Add credentials to parameter list
		If ($null -ne $Credential) {
			$Parameters.Add("Credential",$Credential)
		}
		
		Write-Verbose "Opening Opening AD Sites & Services for $($Credential.UserName)."
		Start-Process PowerShell @Parameters -WindowStyle Hidden
	}
	End {}
}