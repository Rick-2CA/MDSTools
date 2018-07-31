Function Add-MDSCredential {
	<#
    .SYNOPSIS
	Add a credential entry to the MDSCredentials file

    .DESCRIPTION
    Add a credential entry to the MDSCredentials file.  Supply the name of the entry and be prompted for a username and password.

    .EXAMPLE
    Add-MDSCredential -Name MyCred1

	Create a credential entry named 'MyCred1'

	.EXAMPLE
    Add-MDSCredential -Name MyCred1 -UserName 'ASmith'

	Create a credential entry named 'MyCred1'

    .NOTES

	#>
	[cmdletbinding()]
	Param (
		[parameter(Position=0, Mandatory=$True)]
		[ValidateNotNullOrEmpty()]
		[string]$Name,

		[Parameter()]
		[string]$UserName
	)

	Begin {
		Try {
			$Hash = Get-MDSCredential -SortByName:$false -ErrorAction Stop
		}
		Catch {
			$PSCmdlet.ThrowTerminatingError($PSItem)
		}
		If (-not $Hash) {$Hash = @{}}
	}
	Process {
		Try {
			$getCredentialSplat = @{
				Message 	= "Credentials will be stored as $Name in the MDSTools credential store"
				ErrorAction = 'Stop'
			}
			If ($null -ne $PSBoundParameters.UserName) {
				$getCredentialSplat.Add('UserName',$UserName)
			}
			$Credentials = Get-Credential @getCredentialSplat
			$Username = $Credentials.UserName
			$Password = $Credentials.Password | ConvertFrom-SecureString

			$Hash.Add($PSBoundParameters.Name,@($UserName,$Password))
			$Username = $Password = $null
			Write-Verbose "Added credential record $($Name)"
			$Hash | Export-CliXML $CredentialFilePath
		}
		Catch [System.Management.Automation.MethodInvocationException] {
			$Message = "A record for {0} already exists.  Use Update-MDSCredential to edit a record." -f $Name
			Write-Error -Message $Message -ErrorAction Stop -Exception ([System.Management.Automation.MethodInvocationException]::new())
		}
		Catch {
			Write-Error $PSItem
		}
	}
	End {}
}
