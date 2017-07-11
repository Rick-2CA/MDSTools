Function Add-MDSCredential {
	<#
    .SYNOPSIS
	Add a credential entry to the MDSCredentials file

    .DESCRIPTION
    Add a credential entry to the MDSCredentials file.  Supply the name of the entry and be prompted for a username and password.

    .EXAMPLE
    Add-MDSCredential -Name MyCred1

	Create a credential entry named 'MyCred1'

    .NOTES

	#>
	[cmdletbinding()]
	Param (
		[parameter(Position=0, Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		[string]$Name
	)

	Begin {
		$Hash = Get-MDSCredential -SortByName:$false
		If (-not $Hash) {$Hash = @{}}
	}
	
	Process {
			Try {$Credentials = Get-Credential -ErrorAction Stop}
			Catch {$PSCmdlet.ThrowTerminatingError($PSItem)}
			$Username = $Credentials.UserName
			$Password = $Credentials.Password | ConvertFrom-SecureString

            Try {
                $Hash.Add($Name,@($UserName,$Password))
				$Username = $Password = $null
                Write-Verbose "Added credential record $($Name)"
            }
            Catch [System.Management.Automation.MethodInvocationException] {
                $Message = "A record for {0} already exists.  Use Update-MDSCredential to edit a record." -f $Name
                Write-Error -Message $Message -ErrorAction Stop -Exception ([System.Management.Automation.MethodInvocationException]::new())
            }
            Catch {
                $PSCmdlet.ThrowTerminatingError($PSItem)
                Return
            }
		
		Write-Verbose "Updating file $CredentialFilePath"
		$Hash | Export-CliXML $CredentialFilePath
		
	}
	
	End {}
}