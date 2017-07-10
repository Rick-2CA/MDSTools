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
		$ArgumentList = 'Start-Process -FilePath $env:SystemRoot\System32\mmc.exe -ArgumentList $env:SystemRoot\System32\dsa.msc -Verb RunAs'
		$Parameters = @{
			'ArgumentList' = $ArgumentList
		}		
		
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
			Write-Verbose "Opening AD Users & Computers for the current user."
			Return Start-Process dsa.msc
		}

		# Add credentials to parameter list
		If ($null -ne $Credential) {
			$Parameters.Add("Credential",$Credential)
		}
		
		Write-Verbose "Opening AD Users & Computers for $($Credential.UserName)."
		Start-Process PowerShell @Parameters -WindowStyle Hidden
	}
	
	End{}
}