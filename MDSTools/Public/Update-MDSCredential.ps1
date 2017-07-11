Function Update-MDSCredential {
	<#
    .SYNOPSIS
	Update a credential entry to the MDSCredentials file

    .DESCRIPTION
    Update a credential entry to the MDSCredentials file.  A dynamic parameter of 'Name' allows for tab completion of available credentials that may be updated.  A credential prompt will open to accept the new username and password.

    .EXAMPLE
    Update-MDSCredential -Name MyCred1

	Update a credential entry named 'MyCred1'

    .NOTES

	#>
	[cmdletbinding()]
	Param ()

    DynamicParam {
        $Options = @(
            Get-MDSCredential -ErrorAction Stop |
                    Select-Object -ExpandProperty Name
            )
        New-DynamicParam -Name Name -ValidateSet $Options -Position 0 -ParameterSetName Name
	}

	Begin {$Name = $PSBoundParameters.Name}
	
	Process {
		Try {$Hash = Get-MDSCredential -SortByName:$false -ErrorAction Stop}
        Catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }

        Try {$Credentials = Get-Credential -ErrorAction Stop}
        Catch {$PSCmdlet.ThrowTerminatingError($PSItem)}
        $Username = $Credentials.UserName
        $Password = $Credentials.Password | ConvertFrom-SecureString

        If ($Hash[$Name]) {
            Try { 
                $Hash.Remove($Name)
                $Hash.Add($Name,@($UserName,$Password))
                Write-Verbose "Updated credential record $($Name)"
            }
            Catch {
                $PSCmdlet.ThrowTerminatingError($PSItem)
            }
        }
        Else {
            $Message = "A record for {0} does not exist." -f $Object
             Write-Error -Message $Message -ErrorAction Stop -Exception ([System.Management.Automation.MethodInvocationException]::new())
             Return
        }
        
        Write-Verbose "Updating file $CredentialFilePath"
		$Hash | Export-CliXML $CredentialFilePath
	}
	
	End {}
}