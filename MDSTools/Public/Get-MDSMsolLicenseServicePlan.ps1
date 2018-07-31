function Get-MDSMsolLicenseServicePlan {
	<#
    .SYNOPSIS
	Enables service plans from MSOnline licenses applied to users.

    .DESCRIPTION
    Will enable one or more service plans from a user's MSOnline account or specific MSOnline license on an account.

    .EXAMPLE
    Get-MDSMsolLicenseServicePlan -UserPrincipalName user@domain.com

	List all service plans from all licenses for a single user

    .EXAMPLE
	Get-MDSMsolLicenseServicePlan -UserPrincipalName user@domain.com -ServicePlan Teams1,YAMMER_ENTERPRISE

	List specific service plans for all licenses for a single user

	.EXAMPLE
	Get-MDSMsolLicenseServicePlan -UserPrincipalName user@domain.com -ServicePlan Sway -AccountSkuID tenantname:ENTERPRISEPACK,tenantname:PROJECTESSENTIALS

	List specific service plans for a single user who have an EnterprisePack and/or ProjectEssentials license assigned

	.EXAMPLE
	Get-MsolUser -All | Get-MDSMsolLicenseServicePlan -ServicePlan Teams1

	Utilize Pipeline support with objects that have a UserPrincipalName property with any combination of parameters shown in previous examples.  Also accepts the Licenses property captured by Get-MsolUser.

    .NOTES
	Written by Rick A, April 2017

    #>
	    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory=$True,
            ValueFromPipeline=$True,
			ValueFromPipelineByPropertyName=$True
        )]
		[string[]]$UserPrincipalName,

		[Parameter(
            Mandatory=$False,
            ValueFromPipelineByPropertyName=$True
        )]
		[object[]]$Licenses,

        [Parameter(Mandatory=$False)]
		[string[]]$ServicePlan,

		[Parameter(Mandatory=$False)]
		[string[]]$AccountSkuID
    )

    begin {}
    process {
		ForEach ($UPN in $UserPrincipalName) {
			# Get the licenses and confirm the UserPrincipalName exists
			If (-not $Licenses) {
				Try {
					Write-Verbose ("{0}:  Licenses not provided.  Querying MSOnline for licenses." -f $UPN )
					[array]$Licenses = (Get-MsolUser -UserPrincipalName $UPN -ErrorAction Stop).Licenses
				}
				Catch {
					$PSCmdlet.ThrowTerminatingError($PSItem)
				}
			}

			# Confirm any license was found
			If ($Licenses.count -eq 0) {
				Write-Verbose ("{0}:  User not licensed." -f $UPN )
				Continue
			}

			# If present target only the licenses specified
			If ($AccountSkuID) {
				[array]$Licenses = $Licenses | Where-Object {$AccountSkuID -contains $_.AccountSkuID}
				# Validate there are licenses to process
				If ($Null -eq $Licenses) {
					Write-Verbose ("{0}:  No licenses match the specified AccountSkuID(s)." -f $UPN )
					$Licenses = $Null
					Continue
				}
			}

			# Flatten the license details for the user only if the license contains a
			# provided service plan.
			[array]$LicenseCollection = ForEach ($License in $Licenses) {
				ForEach ($Status in $License.ServiceStatus) {
                    [PSCustomObject] @{
                        UserPrincipalName   = $UPN
                        ServiceName			= $Status.ServicePlan.ServiceName
                        ProvisioningStatus	= $Status.ProvisioningStatus
                        AccountSkuID		= $License.AccountSkuID
                    }
				}
			} # End license collection

            If ($AccountSkuID) {
                $LicenseCollection = $LicenseCollection | Where-Object {$AccountSkuID -contains $_.AccountSkuID}
            }

            If ($ServicePlan) {
                $LicenseCollection = $LicenseCollection | Where-Object {$ServicePlan -contains $_.ServiceName}
            }

			[PSCustomObject] @{
				PSTypeName			= 'MDSTools.MDSMsolLicenseServicePlan'
				UserPrincipalName 	= $UPN
				LicenseCollection 	= $LicenseCollection
				Licenses			= $Licenses
			}

			$Licenses = $LicenseCollection = $Null
		} # End ForEach
	} # End Process
    end {}
} # End Function
