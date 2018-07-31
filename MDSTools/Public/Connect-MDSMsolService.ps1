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
	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingPlainTextForPassword','')]
	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUsePSCredentialType','')]

	[CmdletBinding(DefaultParameterSetName='MDSCredential')]
	Param (
		[parameter(Position=0,ParameterSetName='MDSCredential')]
		[ValidateNotNullOrEmpty()]
		[String]$MDSCredential,

		[parameter(Position=0,ParameterSetName='Credential')]
		[ValidateNotNullOrEmpty()]
		[System.Management.Automation.CredentialAttribute()]
		$Credential,

		[parameter(Position=0,ParameterSetName='CurrentCredential')]
		[switch]$CurrentCredential
	)

	Begin {}
	Process {
		Try {
			$Parameters = @{
				ErrorAction = 'Stop'
			}

			Switch ($PSCmdlet.ParameterSetName) {
				'Credential' {
					$Parameters.Add('Credential',$Credential)
					Write-Verbose "Connect-MDSMsolService using credential $($Credential.Username)"
					Continue
				}
				'CurrentCredential' {
					$Parameters.Add('CurrentCredential',$true)
					Write-Verbose "Connect-MDSMsolService using current credential"
					Continue
				}
				'MDSCredential' {
					If ($PSBoundParameters.MDSCredential) {
						$Credential = Get-MDSCredential -Name $MDSCredential -ErrorAction Stop
						$Parameters.Add('Credential',$Credential)
						Write-Verbose "Connect-MDSMsolService using credential $($Credential.Username)"
					}
					Continue
				}
				Default {}
			}

			Connect-MsolService @Parameters
		}
		Catch {
			Write-Error $PSItem
		}
	}
	End {}
}
