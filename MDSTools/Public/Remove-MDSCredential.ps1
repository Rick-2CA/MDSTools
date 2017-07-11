Function Remove-MDSCredential {
	<#
    .SYNOPSIS
	Remove a credential entry to the MDSCredentials file

    .DESCRIPTION
    Remove a credential entry to the MDSCredentials file.  Supply the name of the entry and be prompted for a username and password.

    .EXAMPLE
    Remove-MDSCredential -Name MyCred1

	Remove a credential entry named 'MyCred1'

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
        # Get a hash table of the credential store
		Try {$Hash = Get-MDSCredential -SortByName:$false -ErrorAction Stop}
        Catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }

        # Confirm the removal name exists and remove it from the ash
        Try {
            If ($Hash[$Name]) {
                $Hash.Remove($Name)
                Write-Verbose "Removed credential record $($Name)"
            }
            Else {
                $Message = "A record for {0} does not exist." -f $Name
                Write-Error -Message $Message -ErrorAction Stop -Exception ([System.Management.Automation.MethodInvocationException]::new())
                Continue
            }
            
        }
        Catch {
            Write-Error $PSItem
            Continue
        }

		# Update the store file
        Write-Verbose "Updating file $CredentialFilePath"
		$Hash | Export-CliXML $CredentialFilePath
	}
	
	End {}
}