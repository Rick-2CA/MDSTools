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
        New-DynamicParam -Name Name -Type Array -ValidateSet $Options -Position 0 -ParameterSetName Name
	}

	Begin {$Name = $PSBoundParameters.Name}
	
	Process {
		Try {$Hash = Get-MDSCredential -SortByName:$false -ErrorAction Stop}
        Catch {
            $PSCmdlet.ThrowTerminatingError($PSItem)
        }

        # If you enable support for mulitple items change Update $Object & $Name below
        ForEach ($Object in $Name) {
            Try {
                If ($Hash[$Object]) {
                    $Hash.Remove($Object)
                    Write-Verbose "Removed credential record $($Object)"
                }
                Else {
                    $Message = "A record for {0} does not exist." -f $Object
                    Write-Error -Message $Message -ErrorAction Stop -Exception ([System.Management.Automation.MethodInvocationException]::new())
                    Continue
                }
                
            }
            Catch {
                Write-Error $PSItem
                Continue
            }
        }
		
		$Hash | Export-CliXML $CredentialFileName
	}
	
	End {}
}