Function Import-MDSSecurityAndCompliance {
	<#
    .SYNOPSIS
	Import the Security and Compliance PowerShell cmdlets by passing an MDSCredential, credential, or via a credential prompt when used interactively.

    .DESCRIPTION
    Import the Security and Compliance PowerShell cmdlets by passing an MDSCredential, credential, or via a credential prompt when used interactively.

    .EXAMPLE
    Import-MDSSecurityAndCompliance -MDSCredential MyCred1

	Import the EXO cmdlets with the stored 'MyCred1' credentials.  The stored credential username should be a UPN.

	.EXAMPLE
	Import-MDSSecurityAndCompliance -Credential $CredentialObject

	Import the EXO cmdlets with a credential object.

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
            ParameterSetName = 'MDSCredential'
        )]
		[parameter(ParameterSetName = 'Credential')]
		[string]$Prefix
	)

	Begin {
		$SessionName = 'Microsoft.SecurityAndCompliance'
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
			# MDSCredential
			If ($PSBoundParameters.MDSCredential) {
				$Credential = Get-MDSCredential -Name $MDSCredential -ErrorAction Stop
			}

            # New-PSSession
			$SessionParameters = @{
				Name              = $SessionName
				ConfigurationName = 'Microsoft.Exchange'
				ConnectionUri     = 'https://ps.compliance.protection.outlook.com/powershell-liveid/'
				Credential        = $Credential
				Authentication    = 'Basic'
				AllowRedirection  = $true
			}
			$Session = New-PSSession @SessionParameters

			# Import-PSSession
			$PSSessionParameters = @{
				Session             = $Session
				DisableNameChecking = $true
				ErrorAction         = 'Stop'
			}
			If ($PSBoundParameters.Prefix) {$PSSessionParameters.Add("Prefix",$Prefix)}
			$ModuleInfo = Import-PSSession @PSSessionParameters

			# Import-Module
			$ModuleParameters = @{
				ModuleInfo          = $ModuleInfo
				DisableNameChecking = $true
				Global              = $true
				ErrorAction         = 'Stop'
			}
			If ($PSBoundParameters.Prefix) {$ModuleParameters.Add("Prefix",$Prefix)}
			Import-Module @ModuleParameters
		}
		Catch {
			Write-Error $PSItem
		}
	}
	End {}
}
