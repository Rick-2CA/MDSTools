Function Import-MDSExchOnline {
	<#
    .SYNOPSIS
	Import the Exchange Online PowerShell cmdlets by passing an MDSCredential, credential, or via a credential prompt when used interactively.

    .DESCRIPTION
    Import the Exchange Online PowerShell cmdlets by passing an MDSCredential, credential, or via a credential prompt when used interactively.

    .EXAMPLE
    Import-MDSExchOnline -MDSCredential MyCred1

	Import the EXO cmdlets with the stored 'MyCred1' credentials.  The stored credential username should be a UPN.

    .EXAMPLE
    Import-MDSExchOnline -MDSCredential MyCred1 -Prefix O365

	Import the EXO cmdlets with the stored 'MyCred1' credentials and prefix the cmdlets.  For example Get-Mailbox becomes Get-O365Mailbox.  This allows you to load both the EXO cmdlets and Exchange cmdlets in the same session.

	.EXAMPLE
	Import-MDSExchOnline -Credential $CredentialObject

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
		$SessionName = 'Microsoft.Exchange.Online'
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
				ConnectionUri     = 'https://outlook.office365.com/powershell-liveid/'
				Credential        = $Credential
				Authentication    = 'Basic'
			}
			$Session = New-PSSession @SessionParameters

			# Import-PSSession
			$PSSessionParameters = @{
				Session             = $Session
				DisableNameChecking = $true
				Global              = $true
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



