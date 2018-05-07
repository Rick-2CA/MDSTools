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
    [CmdletBinding(DefaultParameterSetName='None')]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingPlainTextForPassword', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUsePSCredentialType', '')]

    param(
        [Parameter(
            Mandatory                       = $true,
            Position                        = 0,
            ValueFromPipeline               = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Parameter(ParameterSetName="MDSCredential")]
        [Parameter(ParameterSetName="Credential")]
        [Parameter(ParameterSetName="None")]
        [ValidateNotNullOrEmpty()]
        [string[]]$SamAccountName,

        [Parameter(Position=1,ParameterSetName="MDSCredential")]
        [Parameter(Position=1,ParameterSetName="Credential")]
        [Parameter(Position=1,ParameterSetName="None")]
        [string]$Server,

        [parameter(Position=2,ParameterSetName="MDSCredential")]
        [ValidateNotNullOrEmpty()]
        [String]$MDSCredential,

        [parameter(Position=2,ParameterSetName="Credential")]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.CredentialAttribute()]
        $Credential
    )
    #requires -Module ActiveDirectory
	begin {}
	process	{
        # MDSCredentials
        If ($PsCmdlet.ParameterSetName -eq "MDSCredential" -and -not [string]::IsNullOrEmpty($MDSCredential)) {
            Try {
                $Credential = Get-MDSCredential -Name $MDSCredential
            }
            Catch {
                $PsCmdlet.ThrowTerminatingError($PSItem)
            }
        }

        Try {
            If ($null -eq $PSBoundParameters.Server) {
                $PDCEmulator = Get-ADDomain -ErrorAction Stop | Select-Object -Expand PDCEmulator
                $VerboseString = 'No server specified.  Using the PDCEmulator {0}.' -f $PDCEmulator
                Write-Verbose $VerboseString
            }
        }
        Catch {
            $PsCmdlet.ThrowTerminatingError($PSItem)
        }

        ForEach ($Name in $SamAccountName) {
            Try {
                $Events = $ADUser = $null

                If ($null -eq $PSBoundParameters.Server) {
                    $Server = $PDCEmulator
                }

                $VerboseString = 'Performing AD query for {0}.' -f $Name
                Write-Verbose $VerboseString
                $getADUserSplat = @{
                    Filter      = {SamAccountName -eq $Name}
                    Properties  = 'AccountLockoutTime'
                    Server      = $Server
                    ErrorAction = 'Stop'
                }
                $ADUser = Get-ADUser @getADUserSplat

                If ($null -eq $ADUser) {
                    $ErrorString = 'Cannot find object with samaccountname: {0}' -f $SamAccountName
                    Write-Error $ErrorString
                    continue
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
                If ($Credential) {[void]$getWinEventSplat.Add('Credential',$Credential)}
                Try {[array]$Events = Get-WinEvent @getWinEventSplat}
                Catch {
                    Write-Error $PSItem
                    Continue
                }

                If ($null -eq $Events) {continue}

                Write-Verbose 'Parsing returned events'
                ForEach ($Event in $Events) {
                    If($Event | Where-Object {$_.Properties[2].Value -match $ADUser.SID.Value}) {
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
