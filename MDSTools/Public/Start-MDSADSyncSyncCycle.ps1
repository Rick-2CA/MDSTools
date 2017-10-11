Function Start-MDSADSyncSyncCycle {
    <#
    .SYNOPSIS
    Start an Azure AD Connect sync cycle remotely.

    .DESCRIPTION
    Start an Azure AD Connect sync cycle remotely.  The default servername can be set with Set-MDSConfiguration or a servername can be specified with the -ServerName parameter.  Credentials can be passed with MDSCredential or Credential.  The -StartSync swtich parameter is required to start a sync.

    .EXAMPLE
    Start-MDSADSyncSyncCycle -MDSCredential MyCred1 -StartSync

	Start a sync cycle using a stored MDSCredential.  Uses the MDSConfiguration file's ADConnectServer value for the target server.

    .EXAMPLE
    Start-MDSADSyncSyncCycle -Credential MyUserName -StartSync

	Start a sync cycle with a password prompt for the username MyUserName.  Uses the MDSConfiguration file's ADConnectServer value for the target server.

    .EXAMPLE
    Start-MDSADSyncSyncCycle -MDSCredential MyCred1 -ServerName MyServer -StartSync

	Start a sync cycle using a stored MDSCredential against the specified server MyServer

    .NOTES

    #>
	[CmdletBinding(DefaultParameterSetName="MDSCredential")]
	Param (
		[parameter(Position=0,ParameterSetName="MDSCredential")]
		[ValidateNotNullOrEmpty()]
		[String]$MDSCredential,

		[parameter(Position=0,ParameterSetName="Credential")]
		[ValidateNotNullOrEmpty()]
		[System.Management.Automation.CredentialAttribute()]
		$Credential,

		[parameter(Position=1, ParameterSetName="MDSCredential", Mandatory=$False)]
		[parameter(Position=1, ParameterSetName="Credential", Mandatory=$False)]
		[string]$ServerName,

		[parameter(Position=2, ParameterSetName="MDSCredential", Mandatory=$True)]
		[parameter(Position=2, ParameterSetName="Credential", Mandatory=$True)]
		[switch]$StartSync
	)
	
	Begin {}
	
	Process {
		# Capture MDS Credentials.  If no credentials were specified the current credentials are used.
		If ($PsCmdlet.ParameterSetName -eq "MDSCredential" -and -not [string]::IsNullOrEmpty($MDSCredential)) {
			Try {
				$Credential = Get-MDSCredential -Name $MDSCredential
			}
			Catch {
				$PsCmdlet.ThrowTerminatingError($PSItem)
			}
		}

		# Use the configuration file if a servername was not specified
		If (-not $ServerName) {
			$Setting = 'ADConnectServer'
			Try {$ServerName = Get-MDSConfiguration -Setting $Setting}
			Catch {
				Throw "A server name was not specified.  Use the -ServerName parameter or configure the $Setting setting with Set-MDSConfiguration."
			}
		}

		$Parameters = @{
			'ComputerName'	= $ServerName
			'ErrorAction'	= "Stop"
		}
		If ($Credential) {[void]$Parameters.Add('Credential',$Credential)}
		
		If (Invoke-Command @Parameters -ScriptBlock {Get-ADSyncConnectorRunStatus}) {
			Write-Warning "A sync cycle is already in progress."
		}
		Else {
			Try {
				# Load the module and start the sync on the AD Connect Server
				Write-Verbose "Initializing Azure AD Delta Sync..."
				Invoke-Command @Parameters -ScriptBlock {Import-Module ADSync;Start-ADSyncSyncCycle -PolicyType Delta}

				# Wait 10 seconds for the sync connector to wake up.
				Start-Sleep -Seconds 10

				# Progress Bar Variables
				$StartTime = Get-Date

				# Initial status check
				$ADSyncConnectorRunStatus = Invoke-Command @Parameters -ScriptBlock {Get-ADSyncConnectorRunStatus}

				# Monitor the status
				If ($ADSyncConnectorRunStatus.RunState) {
					Write-Verbose "Sync has started..."

					# Monitor the runstate and record the progress with a progress bar
					While($null -ne $ADSyncConnectorRunStatus.RunState) {
						$ADSyncConnectorRunStatus = Invoke-Command @Parameters -ScriptBlock {Get-ADSyncConnectorRunStatus}
						# Progress Bar Processing
						$Date = Get-Date
						$CurrTime = $Date - $StartTime
						$WrPrgParam = @{
							Activity = (
								"Last Refresh:  $($Date.ToLongTimeString())",
								"Elapsed Time: $($CurrTime -replace '\..*')",
								"Run State: $($ADSyncConnectorRunStatus.RunState)",
								"Syncing:  $($ADSyncConnectorRunStatus.ConnectorName)"
							) -join '|'
							Status = "Refreshes every 10 seconds until the sync completes.  Ctrl + C to stop monitoring."
						}
						Write-Progress @WrPrgParam
						Start-Sleep -Seconds 9
					}

					Write-Verbose "Sync completed at $($Date.ToLongTimeString())"
				}
				# The connector status only returns a value if it's running.  If it wasn't found running notify the user
				Else {
					$Message = "Get-ADSyncConnectorRunStatus could not confirm the sync started after 10 seconds."
					Throw (New-Object -TypeName System.Exception -ArgumentList $Message)
				}
			}
			Catch {$PsCmdlet.ThrowTerminatingError($PSItem)}
		}
	}
	
	End {}
}