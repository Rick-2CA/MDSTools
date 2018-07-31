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
	[CmdletBinding(
		SupportsShouldProcess=$True,
		ConfirmImpact='High'
	)]
	Param ()

    DynamicParam {
        $Options = @(
        Get-MDSCredential -ErrorAction Stop |
                Select-Object -ExpandProperty Name
        )
        New-DynamicParam -Name Name -ValidateSet $Options -Position 0 -ParameterSetName Name
	}

	Begin {}
	Process {
        Try {
            # Get a hash table of the credential store
            $Hash = Get-MDSCredential -SortByName:$false -ErrorAction Stop

            $Name = $PSBoundParameters.Name
            # Confirm the removal name exists and remove it from the ash
            If ($Hash[$Name]) {
                If ($PSCmdlet.ShouldProcess($Name,"Remove credential record")) {
                    $Hash.Remove($Name)
                    Write-Verbose "Removed credential record $($Name)"
                }
            }
            Else {
                $Message = "A record for {0} does not exist." -f $Name
                Write-Error -Message $Message -ErrorAction Stop -Exception ([System.Management.Automation.MethodInvocationException]::new())
                Continue
            }

            # Update the store file
            Write-Verbose "Updating file $CredentialFilePath"
            $Hash | Export-CliXML $CredentialFilePath
        }
        Catch {
            Write-Error $PSItem
        }
	}
	End {}
}
