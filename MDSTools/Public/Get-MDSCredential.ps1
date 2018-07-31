Function Get-MDSCredential {
	<#
    .SYNOPSIS
	Get a stored credential or list all stored credentials.

    .DESCRIPTION
    Get a stored credential or list all stored credentials.  A dynamic parameter of 'Name' allows for tab completion of available credentials.

    .EXAMPLE
    Get-MDSCredential -Name MyCred1

	Get a stored credential

	.EXAMPLE
    Invoke-Command -ComputerName Computer01 -Credential (Get-MDSCredential -Name MyCred1) -ScriptBlock {Get-Service}

	Use a stored credential to populate another cmdlet's credential parameter

	.EXAMPLE
    Get-MDSCredential -ListAvailable

	Disable a single service plan for a single user

	.EXAMPLE
    Get-MDSCredential -SortByName

	Disable a single service plan for a single user

    .NOTES

	#>
	[cmdletbinding(DefaultParameterSetName='Default',PositionalBinding=$False)]
	Param (
		[parameter(ParameterSetName='Default')]
		[switch]$ListAvailable,

		[parameter(ParameterSetName='Sort')]
		[switch]$SortByName
	)

	DynamicParam {
		# Execute a Test-Path to avoid dynamic parameter creation errors
		If ((Test-Path $CredentialFilePath) -eq $True) {
			$Options = @(
				Import-CliXML $CredentialFilePath -ErrorAction Stop |
						Select-Object -ExpandProperty Keys | Sort-Object
			)
			New-DynamicParam -Name 'Name' -ValidateSet $Options -Position 0 -ParameterSetName 'Name'
		}
	}

	Begin {}
	Process {
		Try {
			If ((Test-Path $CredentialFilePath) -eq $False) {
				Write-Warning "Please use 'Add-MDSCredential' to populate your credential store.  The store file will be saved in $CredentialFilePath."
				Return
			}

			$CredentialFile = Import-CliXML $CredentialFilePath -ErrorAction Stop

			# Credential object output
			If ($PSBoundParameters.Name) {
				$Name = $PSBoundParameters.Name
				If ($CredentialFile[$Name]) {
					Write-Verbose "MDSCredential `'$Name`' found in store $CredentialFilePath"
					$MDSCredentialEntry = $CredentialFile[$Name]
				}
				Else {
					Throw "MDSCredential not found for $($Name)"
				}

				New-Object -TypeName System.Management.Automation.PsCredential -ArgumentList $MDSCredentialEntry[0],($MDSCredentialEntry[1] | ConvertTo-SecureString)
			}
			# Array output for human consumption
			ElseIf ($PSCmdlet.ParameterSetName -eq 'Default' -or $SortByName -eq $True) {
				$CredentialFile.GetEnumerator() | Sort-Object Name
			}
			# Hash output for Add/Remove functions
			Else {
				$CredentialFile
			}
		}
		Catch {
			Write-Error $PSItem
		}
	}
	End {}
}
