Function Import-MDSSkypeOnPrem {
	<#
    .SYNOPSIS
	Import the Skype On-Premises PowerShell cmdlets using a MDSCredential

    .DESCRIPTION
    Import the Skype On-Premises PowerShell cmdlets using a MDSCredential

    .EXAMPLE
    Import-MDSSkypeOnPrem -MDSCredential MyCred1

	Import the Skype On-Premises cmdlets with the stored 'MyCred1' credentials.  The stored credential username should be a UPN.

    .EXAMPLE
    Import-MDSSkypeOnPrem -MDSCredential MyCred1 -Prefix OnPrem

	Import the Skype On-Premises cmdlets with the stored 'MyCred1' credentials and prefix the cmdlets.  For example Get-CsUser becomes Get-OnPremCsUser.  This allows you to load both the Skype Online cmdlets and Exchange cmdlets in the same session.

    .NOTES

	#>
	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingPlainTextForPassword','')]
	[System.Diagnostics.CodeAnalysis.SuppressMessage('PSUsePSCredentialType','')]

	[CmdletBinding(DefaultParameterSetName = 'Credential')]
	Param(
		[parameter(
            Position = 0,
            Mandatory = $true,
            ParameterSetName = 'MDSCredential'
        )]
		[String]$MDSCredential,

		[parameter(
			Position = 0,
			Mandatory = $true,
            ParameterSetName = 'Credential'
        )]
		[ValidateNotNullOrEmpty()]
		[System.Management.Automation.CredentialAttribute()]
		$Credential,

		[parameter(
			Position = 1,
			Mandatory = $false,
            ParameterSetName = 'Credential'
		)]
		[parameter(ParameterSetName = 'Credential')]
		[string]$ServerName,

        [parameter(
            Position = 2,
            Mandatory = $false,
            ParameterSetName = 'Credential'
        )]
		[parameter(ParameterSetName = 'Credential')]
		[string]$Prefix
	)

	Begin {
		$SessionName = 'Microsoft.Skype'
		If (Get-PSSession -Name $SessionName -ErrorAction SilentlyContinue) {
			Try {
				Remove-PSSession -Name $SessionName -ErrorAction Stop
				Write-Verbose "Session $($SessionName) removed"
			}
			Catch {}
		}
	}
	Process {
		Try {
			# MDSCredentials
			If ($PSBoundParameters.MDSCredential) {
				$Credential = Get-MDSCredential -Name $MDSCredential -ErrorAction Stop
			}

			# Use the configuration file if a servername was not specified
			If (-not $PSBoundParameters.ServerName) {
				$Setting = 'SkypeOnPremServer'
				Try {
					$ServerName = Get-MDSConfiguration -Setting $Setting -ErrorAction Stop
				}
				Catch {
					Throw "A server name was not specified.  Use the -ServerName parameter or configure the $Setting setting with Set-MDSConfiguration."
				}
			}

			# New-PSSession
            $SessionParameters = @{
                Name          = $SessionName
                ConnectionUri = "https://$($ServerName)/ocspowershell"
                Credential    = $Credential
                ErrorAction   = 'Stop'
            }
			$Session = New-PSSession @SessionParameters

			# Import-PSSession
			$PSSessionParameters = @{
				Session             = $Session
                AllowClobber        = $true
                DisableNameChecking = $true
                ErrorAction         = 'Stop'
			}
			If ($PSBoundParameters.Prefix) {
				$PSSessionParameters.Add("Prefix",$Prefix)
			}
			$ModuleInfo = Import-PSSession @PSSessionParameters

			# Import-Module
			$ModuleParameters = @{
                ModuleInfo          = $ModuleInfo
                DisableNameChecking = $true
                Global              = $true
                ErrorAction         = 'Stop'
            }
			If ($PSBoundParameters.Prefix) {
				$ModuleParameters.Add("Prefix",$Prefix)
			}
			Import-Module @ModuleParameters
		}
		Catch {
			Write-Error $PSItem
		}
	}
	End {}
}
