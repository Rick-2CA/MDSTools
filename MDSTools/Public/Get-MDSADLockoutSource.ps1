Function Get-MDSADLockoutSource {
    <#
    .SYNOPSIS
    Query Active Directory for the lockout source for the most recently lockout event

    .DESCRIPTION
    Query Active Directory for the lockout source for the most recently lockout event.  If a server is listed the query will be for the last lockout event on that specific server.

    .EXAMPLE
    Get-MDSADLockoutSource -SamAccountName $SamAccountName

    Query a single user's lockout source
    .EXAMPLE
    Get-MDSADLockoutSource -SamAccountName SamAccountName1,SamAccountName2

    Query multiple users at a time.  Also accepts SamAccountNames via the pipeline
    .EXAMPLE
    Get-MDSADLockoutSource -SamAccountName $SamAccountName -Server Server.domain.com

    Accepts a specific server to query assuming the metadata time is the event time for that server
    .NOTES
    Written by Rick A., December 2017

    #>
    [CmdletBinding(DefaultParameterSetName)]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingPlainTextForPassword','')]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUsePSCredentialType','')]

    param(
        [Parameter(
            Mandatory                       = $true,
            Position                        = 0,
            ValueFromPipeline               = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$SamAccountName,

        [Parameter(Position=1)]
        [string]$Server,

        [Parameter(Position=2,ParameterSetName="MDSCredential")]
        [ValidateNotNullOrEmpty()]
        [String]$MDSCredential,

        [Parameter(Position=2,ParameterSetName="Credential")]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
    )

	begin {}
	process	{
        Try {
            # MDSCredential
			If ($PSBoundParameters.MDSCredential) {
				$Credential = Get-MDSCredential -Name $MDSCredential -ErrorAction Stop
			}

            If ($null -eq $PSBoundParameters.Server) {
                $Server = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().PdcRoleOwner.Name
                $VerboseString = 'No server specified.  Using PDCEmulator: {0}.' -f $Server
                Write-Verbose $VerboseString
            }
        }
        Catch {
            $PsCmdlet.ThrowTerminatingError($PSItem)
        }

        ForEach ($Name in $SamAccountName) {
            Try {
                $Events = $Account = $SID = $null

                Try {
                    $Account = New-Object Security.Principal.NTAccount $Name
                    $SID = $Account.Translate([Security.Principal.Securityidentifier]).Value
                }
                Catch {
                    $ThrowString = 'Cannot find object with samaccountname: {0}' -f $SamAccountName
                    Throw $ThrowString
                }

                # Lockout:  'Microsoft-Windows-Security-Auditing', ID 4740
                # Failure Event:  'Microsoft-Windows-Security-Auditing',ID 4771
                $FilterHashtable = @{
                    LogName         = 'Security'
                    ID              = 4740
                    ProviderName    = 'Microsoft-Windows-Security-Auditing'
                    Data            = $Name
                }
                $getWinEventSplat = @{
                    ComputerName    = $Server
                    FilterHashtable = $FilterHashtable
                    ErrorAction     = 'Stop'
                    Verbose         = $False
                }
                If ($Credential) {
                    [void]$getWinEventSplat.Add('Credential',$Credential)
                }

                [array]$Events = Get-WinEvent @getWinEventSplat

                Write-Verbose 'Parsing returned events...'
                ForEach ($Event in $Events) {
                    If($Event | Where-Object {$_.Properties[2].Value -match $SID}) {
                        [PSCustomObject] @{
                            AccountName     = $Name
                            EventComputer   = $Event.Properties[4].Value
                            LockoutTime     = $Event.TimeCreated
                            LockoutSource   = $Event.Properties[1].Value
                        }
                    }
                }
            }
            Catch {
                Write-Error $PSItem
            }
        }
    }
	end {}
}
