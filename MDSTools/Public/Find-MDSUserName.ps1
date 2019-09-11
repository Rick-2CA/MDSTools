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
    Find-MDSUserName Smith

    .EXAMPLE
    Find-MDSUserName Smi

    .EXAMPLE
    Find-MDSUserName -GivenName John

    .EXAMPLE
    Find-MDSUserName -GivenName Jo

    .EXAMPLE
    Find-MDSUserName John -FilterAttribute Surname

    .EXAMPLE
    Find-MDSUserName John,Smith -FilterAttribute Surname

    .EXAMPLE
    Find-MDSUserName 12345 -FilterAttribute EmployeeID
    #>

    Param(
        [parameter(Mandatory=$true)]
        [string[]]$NameValue,

        [parameter(Mandatory=$false)]
        [string]$FilterAttribute='ANR'
    )

    Begin {}
    Process {
        # Use ADSISearcher to query Active Directory
        $Searcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
        $Searcher.PageSize = 200
        $PropertiesToLoad = 'givenname','sn','samaccountname','userprincipalname','mail'
        $Searcher.PropertiesToLoad.AddRange(($PropertiesToLoad))

        ForEach ($User in $NameValue) {
            $Searcher.Filter = ("{0}={1}" -f $FilterAttribute,$User)
            ForEach ($Object in $($Searcher.FindAll())) {
                [PSCustomObject] @{
                    PSTypeName        = 'MDSTools.findMDSUserName'
                    GivenName         = [string]$Object.properties.givenname
                    SurName           = [string]$Object.properties.sn
                    SamAccountName    = [string]$Object.properties.samaccountname
                    UserPrincipalName = [string]$Object.properties.userprincipalname
                    Mail              = [string]$Object.properties.mail
                }
            }
        }
    }
    End {}

} # End Find-MDSUserName
