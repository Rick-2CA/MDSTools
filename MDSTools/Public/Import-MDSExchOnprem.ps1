Function Import-MDSExchOnprem {
	<#
    .SYNOPSIS
	Import the Exchange On-Premises PowerShell cmdlets using a MDSCredential

    .DESCRIPTION
    Import the Exchange On-Premises PowerShell cmdlets using a MDSCredential

    .EXAMPLE
    Import-MDSExchOnprem -MDSCredential MyCred1 -ExchangeServer MyServerName

	Import the Exchange On-Premises cmdlets with the stored 'MyCred1' credentials

    .EXAMPLE
    Import-MDSExchOnprem -MDSCredential MyCred1 -ExchangeServer MyServerName -ViewEntireForest

	Import the Exchange On-Premises cmdlets with the stored 'MyCred1' credentials and set the session's ADServerSettings to allow viewing the entire forest

    .EXAMPLE
    Import-MDSExchOnprem -MDSCredential MyCred1 -ExchangeServer MyServerName -Prefix OnPrem

	Import the EXO cmdlets with the stored 'MyCred1' credentials and prefix the cmdlets.  For example Get-Mailbox becomes Get-OnPremMailbox.  This allows you to load both the EXO cmdlets and Exchange cmdlets in the same session.

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

		[Parameter(
			Position = 1,
			Mandatory = $false,
			ParameterSetName = 'MDSCredential'
		)]
		[parameter(ParameterSetName = 'Credential')]
		[string]$ExchangeServer,

        [parameter(
            Position = 2,
            ParameterSetName = 'MDSCredential'
        )]
		[parameter(ParameterSetName = 'Credential')]
		[string]$Prefix,

		[parameter(
            Position = 3,
            ParameterSetName = 'MDSCredential'
        )]
		[parameter(ParameterSetName = 'Credential')]
		[switch]$ViewEntireForest
	)

	Begin {
		$SessionName = 'Microsoft.Exchange'
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

			# Exchange Server Query
			If (-not $PSBoundParameters.ExchangeServer) {
				$ExchangeServer = Get-MDSExchServerFromLDAP -Random -ErrorAction Stop | Select-Object -Expand FQDN
			}

			# New-PSSession
            $SessionParameters = @{
                Name              = $SessionName
                ConfigurationName = 'Microsoft.Exchange'
                ConnectionUri     = "http://$($ExchangeServer)/Powershell/?SerializationLevel=Full"
                Credential        = $Credential
                Authentication    = 'Kerberos'
            }
			$Session = New-PSSession @SessionParameters -ErrorAction Stop

			# Import-PSSession
            $PSSessionParameters = @{
                Session             = $Session
                AllowClobber        = $true
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

			# Set-ADServerSettings to view the entire forest
			If ($PSBoundParameters.ViewEntireForest) {
				$ADServerSettings = Get-Command "Set-$($Prefix)ADServerSettings"
				If ($ADServerSettings) {
					& $ADServerSettings -ViewEntireForest $True
				}
			}
		}
		Catch {
			Write-Error $PSItem
		}
	}
	End {}
}
