function Find-MDSUserName {
    <# 
    .SYNOPSIS
    Retrieve users' account usernames based on full or partial name search. 
    .Parameter NameValue
    The full or partial name of the user or users.
    .Parameter FilterAttribute
    Specify a single attribute to query.  Default value uses Ambiguous Name Resolution (ANR) which searches up to 17 name related attributes in Active Directory.
    .DESCRIPTION
    The Get-MDSUserName function uses the Get-ADUser cmdlet to query Active Directory for all users 

    .EXAMPLE
    MDSUserName Smith
    .EXAMPLE
    MDSUserName Smi 
    .EXAMPLE
    MDSUserName -GivenName John
    .EXAMPLE
    MDSUserName -GivenName Jo
    .EXAMPLE
    Find-MDSUserName John -FilterAttribute Surname
    .EXAMPLE
    Find-MDSUserName John,Smith -FilterAttribute Surname
    .EXAMPLE
    Find-MDSUserName 12345 -FilterAttribute EmployeeID
    #>

    #requires -Module ActiveDirectory

        Param([parameter(Mandatory=$true)] 
            [string[]]$NameValue,
            [string]$FilterAttribute='ANR'
        )

        Begin {}
        Process {
            ForEach ($User in $NameValue) {
                # Get SAM Account Name for specified user
                Get-ADUser -Filter "$FilterAttribute -like '$User*'" | 
                    Select-Object GivenName,SurName,SamAccountName,UserPrincipalName
            }
        }
        End {}
        
} # End Find-MDSUserName