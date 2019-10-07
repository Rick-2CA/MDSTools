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
	[CmdletBinding(SupportsShouldProcess)]
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
            $Hash = Get-MDSCredential -SortByName:$false -ErrorAction Stop

            If ($Hash[$PSBoundParameters.Name]) {
                $Credentials = Get-Credential -Credential $Hash[$PSBoundParameters.Name][0] -ErrorAction Stop
                $Username = $Credentials.UserName
                $Password = $Credentials.Password | ConvertFrom-SecureString

                $ShouldProcessChange = 'Update MDS Credential entry'
                If ($PSCmdlet.ShouldProcess($PSBoundParameters.Name, $ShouldProcessChange)) {
                   $Hash.Remove($PSBoundParameters.Name)
                   $Hash.Add($PSBoundParameters.Name,@($UserName,$Password))
                   $Hash | Export-CliXML $CredentialFilePath
                   Write-Verbose "Updated credential record $($PSBoundParameters.Name)"
                }
            }
            Else {
                $Message = "A record for {0} does not exist." -f $PSBoundParameters.Name
                Write-Error -Message $Message -ErrorAction Stop -Exception ([System.Management.Automation.MethodInvocationException]::new())
            }
        }
        Catch {
            Write-Error $PSItem
        }
	}

	End {}
}
