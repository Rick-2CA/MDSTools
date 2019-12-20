Function Get-MDSForestADGroupMember {
    <#
    .SYNOPSIS
    Get AD Group Membership for any group you have read access to in the forest

    .DESCRIPTION
    Get AD Group Membership for any group you have read access to in the forest.  Requires the PDC Emulator to be able to respond to PowerShell requests.  Use the FQDN of the domain for best results.

    .EXAMPLE
    Get-MDSForestADGroupMember -Identity 'AD Group'

    Searches the domain you're in for 'AD Group'

    .EXAMPLE
    Get-MDSForestADGroupMember -Identity 'AD Group' -Domain contoso.com

    Searches the contoso.com domain for 'AD Group'
    .NOTES
    Written by Rick A, August 2017

    #>

    #Requires -Module ActiveDirectory

    [CmdletBinding(
		SupportsShouldProcess,
		DefaultParameterSetName="MDSCredential"
	)]
    param(
        # Pipeline variable
        [parameter(Mandatory=$True,ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [string]$Identity,

        [parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$Domain
    )

	begin {}
	process	{
        Try {
            # Get domain information
            If ($null -ne $PSBoundParameters.Domain) {

                $DomainType     = [System.DirectoryServices.ActiveDirectory.DirectoryContextType]::Domain
                $DomainContext  = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext($DomainType, $Domain)
                $Server = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($DomainContext).PdcRoleOwner.Name
            }
            Else {
                $Server = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().PdcRoleOwner.Name
            }

            # Select the object type to query based on the identity provided
                <#
                    Distinguished Name
                        Example: CN=saradavisreports,OU=europe,CN=users,DC=corp,DC=contoso,DC=com
                    GUID (objectGUID)
                        Example: 599c3d2e-f72d-4d20-8a88-030d99495f20
                    Security Identifier (objectSid)
                        Example: S-1-5-21-3165297888-301567370-576410423-1103
                    Security Accounts Manager (SAM) Account Name (sAMAccountName)
                        Example: saradavisreports
                #>
            $FilterProperty = Switch -Regex ($Identity) {
                'CN=.*DC='  {'DistinguishedName'}
                'S-1-5-.*'  {'ObjectSID'}
                default {
                    $isGUID =   Try {[System.Guid]::Parse($Identity) | Out-Null;$True}
                                Catch {$False}
                    If ($isGUID -eq $True) {
                        'objectGUID'
                    }
                    Else {
                        'name'
                    }
                }
            }

            # Query AD for the group
            Write-Verbose "Get-ADGroup:  Querying server $($Server) where $($FilterProperty) equals $($Identity)"
            #TODO:  Replace Get-ADGroup
            $getADGroupSplat = @{
                Filter      = "$FilterProperty -eq '$Identity'"
                Server      = $Server
                ErrorAction = 'Stop'
            }
            $ADGroup = Get-ADGroup @getADGroupSplat

            # If the group wasn't found throw an error
            If ($null -eq $ADGroup) {
                Throw "$Identity not found in $($ADDomain.distinguishedname)"
            }

            # Query the group for group members & return the group members
            $getADGroupMemberSplat = @{
                Identity    = $ADGroup.DistinguishedName
                Server      = $Server
                Recursive   = $true
                ErrorAction = 'Stop'
            }

            $ShouldProcessTarget = $ADGroup.DistinguishedName
            If ($PSCmdlet.ShouldProcess($ShouldProcessTarget,$MyInvocation.MyCommand)) {
                #TODO:  Replace Get-ADGroupMember
                Get-ADGroupMember @getADGroupMemberSplat | Sort-Object Name
            }
        }
        Catch {
            Write-Error $PSItem
        }
    }
	end {}
}
