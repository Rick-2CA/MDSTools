Function Start-MDSWebBrowser {
    <#
	.SYNOPSIS
	Opens a web browser as the current user or as the user of the credentials provided

	.DESCRIPTION
	Opens a web browser as the current user or as the user of the credentials provided.  Defaults to Internet Explorer.

    .EXAMPLE
    Start-MDSWebBrowswer -MDSCredential $MDSCredentialName

    .EXAMPLE
    Start-MDSWebBrowswer -Credential -Browser Chrome

    .NOTES

    #>

    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSAvoidUsingPlainTextForPassword', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUsePSCredentialType', '')]

    [CmdletBinding(
		SupportsShouldProcess,
		DefaultParameterSetName="MDSCredential"
	)]
	Param(
		[parameter(Position=0,ParameterSetName="MDSCredential")]
		[String]$MDSCredential,

		[parameter(Position=0,ParameterSetName="Credential")]
		[ValidateNotNullOrEmpty()]
		[System.Management.Automation.CredentialAttribute()]
        $Credential,

        [parameter(Position=1,ParameterSetName="MDSCredential")]
        [parameter(Position=1,ParameterSetName="Credential")]
        [ValidateSet('IE','Chrome')]
        [string]$Browser='IE'
	)

	Begin {}
	Process {
        $ProcessPath = Switch ($Browser) {
            IE      {'C:\Program Files\Internet Explorer\iexplore.exe'}
            Chrome  {'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe'}
            Default {}
        }
		# Variable for storing parameters
		$Parameters = @{}

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
			Write-Verbose "Opening $($Browser) for the current user."
			Return Start-Process $ProcessPath
		}

		# Add credentials to parameter list
		If ($null -ne $Credential) {
			$Parameters.Add("Credential",$Credential)
		}

		# For use in Confirm & WhatIf
		$ShouldProcessTarget = "Username:  {0}, Browser:  {1}" -f $Credential.UserName,$Browser

		# Execute Explorer
		If ($PSCmdlet.ShouldProcess($ShouldProcessTarget,$MyInvocation.MyCommand)) {
			Try {
				Write-Verbose "Opening $($Browser) for $($Credential.UserName)."
				Start-Process $ProcessPath @Parameters -LoadUserProfile
			}
			Catch {
				$PsCmdlet.ThrowTerminatingError($PSItem)
			}
		}
	}

	End {}
}
