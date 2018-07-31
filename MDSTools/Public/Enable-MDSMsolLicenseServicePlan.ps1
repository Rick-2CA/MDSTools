function Enable-MDSMsolLicenseServicePlan {
	<#
    .SYNOPSIS
	Enables service plans from MSOnline licenses applied to users.

    .DESCRIPTION
    Will enable one or more service plans from a user's MSOnline account or specific MSOnline license on an account.

    .EXAMPLE
    Enable-MDSMsolLicenseServicePlan -UserPrincipalName user@domain.com -ServicePlan Teams1

	Enable a single service plan for a single user

    .EXAMPLE
	Enable-MDSMsolLicenseServicePlan -UserPrincipalName user@domain.com -ServicePlan Teams1,YAMMER_ENTERPRISE

	Enable multiple service plans for a single user

	.EXAMPLE
	Enable-MDSMsolLicenseServicePlan -UserPrincipalName user@domain.com -ServicePlan Teams1 -AccountSkuID tenantname:EnterprisePack

	Target one or more AccountSkuIDs, seperated by commas, that should be processed.  Will process only those available per user.  Microsoft may not allow enabling a service plan in more than one AccountSkuID per user.  Listing multiple AccountSkuIDs works best in either/or scenarios in your environment (as in the users will have either license A or license B, but shouldn't have both).

	.EXAMPLE
	Get-MsolUser -UserPrincipalName user@domain.com | Enable-MDSMsolLicenseServicePlan -ServicePlan Teams1

	Utilize Pipeline support with objects that have a UserPrincipalName property.  Also accepts the Licenses property captured by Get-MsolUser.

    .NOTES
	Written by Rick A, April 2017

    #>
    [CmdletBinding(SupportsShouldProcess=$True)]
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

        [Parameter(Mandatory=$True)]
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
					Continue
				}
			}

			# Flatten the license details for the user only if the license contains a
			# provided service plan.
			[array]$LicenseCollection = ForEach ($License in $Licenses) {
				$ProcessLicense = $False
				ForEach ($Plan in $ServicePlan) {
					If ($License.ServiceStatus.ServicePlan.ServiceName -match $Plan) {
						$ProcessLicense = $True
					}
				}

				If ($ProcessLicense -eq $True) {
					ForEach ($Status in $License.ServiceStatus) {
						[pscustomobject] @{
							ServiceName			= $Status.ServicePlan.ServiceName
							ProvisioningStatus	= $Status.ProvisioningStatus
							AccountSkuID		= $License.AccountSkuID
						}
					}
				}
			} # End license collection
			$Licenses = $Null

			# Report any service plans not assigned to the user.
			ForEach ($Plan in $ServicePlan) {
				$PlanProvisioningStatus = ($LicenseCollection | Where-Object {$_.ServiceName -eq $Plan}).ProvisioningStatus
				# Ensure the service plan was located in the license.
				If ($Null -eq $PlanProvisioningStatus) {
					Write-Warning ("{0}:  Service plan {1} not found." -f $UPN,$Plan)
					Continue
				}
			}

			# Seperate the objects by AccountSkuID for license processing
			[array]$UpdateLicenses = ($LicenseCollection | Select-Object AccountSkuID -Unique).AccountSkuID
			# Go through the licenses to reapply the license with the updated disable options where necessary
			# (The disable options will exclude the plans you want enabled)
			ForEach ($UpdateLicense in $UpdateLicenses) {
				Write-Verbose ("{0}:  Processing license {1}." -f $UPN,$UpdateLicense)
				$CurrentLicense = $LicenseCollection | Where-Object {$_.AccountSkuId -match $UpdateLicense}

				$ConfirmedPlansToEnable = New-Object System.Collections.ArrayList
				ForEach ($Plan in $ServicePlan) {
					# Get the current status of the specified service plan to be enabled
					$PlanProvisioningStatus = ($CurrentLicense | Where-Object {$_.ServiceName -eq $Plan}).ProvisioningStatus
					# Ensure the service plan was located in the license.
					If ($Null -eq $PlanProvisioningStatus) {
						# The user would have been notified previously of this scenario so we silently continue
						Continue
					}

					# Ensure the specified service plan is active
					If ($PlanProvisioningStatus -ne "Success") {
						[void]$ConfirmedPlansToEnable.Add($Plan)
					} # End If
					Else {
						Write-Warning ("{0}:  The service plan {1} in license {2} is already enabled." -f $UPN,$Plan,$UpdateLicense)
						Continue
					} # End Else
				} # End ForEach

				# If the user didn't change...
				If (-not ($ConfirmedPlansToEnable)) {
					Write-Warning ("{0}:  No action was taken for license {1}." -f $UPN,$UpdateLicense)
					Continue
				}

				# Get all currently disabled service plans excluding the service plan to be disabled
				$DisabledPlans = ($CurrentLicense |
					Where-Object {$_.ProvisioningStatus -eq "Disabled" -and $ConfirmedPlansToEnable -notcontains $_.ServiceName}).ServiceName
				# Build the licensing options using the current AccountSkuID & collected service plans to disable
				$LicenseOptions = New-MsolLicenseOptions -AccountSkuId $UpdateLicense -DisabledPlans $DisabledPlans
				# Reapply the same license type leaving all previously disabled service plans disabled except
				# the specified service plans.
				If ($PSCmdlet.ShouldProcess($UPN,"Set-MsolUserLicense")) {
					Try {
						#Write-Warning "Set-MsolUserLicense is disabled.  No action taken"
						Set-MsolUserLicense -UserPrincipalName $UPN -LicenseOptions $LicenseOptions -ErrorAction Stop
					}
					Catch {
						$PSCmdlet.ThrowTerminatingError($PSItem)
					}
				}
			}
		}
	} # End Process
    end {}
} # End Function
