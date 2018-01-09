# Messaging and Directory Services Tools (MDSTools)

The MDSTools module is a collection of functions developed supporting an Active Directory environment with Office 365 and an Exchange hybrid deployment (Exchange and Exchange Online).

## Module Requirements

* PowerShell v4

## Function Requirements

Functions may require one or more of the services or modules below. They are only required if the function you wish to use requires them.

* MS Online (Office 365) connectivity.
* Exchange Online connectivity.  See [Connect to Exchange Online PowerShell](https://technet.microsoft.com/en-us/library/jj984289(v=exchg.160).aspx)
* Exchange Server 2010 or newer
* Skype for Business server
* Azure AD Connect server
* ActiveDirectory module
* GroupPolicy module
* [Configuration](https://www.powershellgallery.com/packages/Configuration) module by Joel Bennett.  If you install MDSTools via the PowerShell Gallery the supported version of this module will be installed automatically.

## Installation

The module is available on the [PowerShell Gallery](https://www.powershellgallery.com/packages/mdstools) and can be installed by running:

`Find-Module MDSTools | Install-Module`

## Updating from v1 to v2

Password storage has been moved from the machine location to the user location.  This means you'll need to copy your credential file to the new location or recreate your file.  Also updated to using v1.2 of the Configuration module which uses a folder called PowerShell instead of WindowsPowerShell.

* Old location:  C:\Users\$($Env:UserName)\AppData\Local\WindowsPowerShell\MDSTools\MDSTools\MDSCredentials.xml
* New location:  C:\Users\$($Env:UserName)\AppData\Local\PowerShell\MDSTools\MDSTools\MDSCredentials.xml

Configuration storage was also impacted by the folder change:

* Old location:  C:\Users\$($Env:UserName)\AppData\Roaming\WindowsPowerShell\MDSTools\mdstools\Configuration.psd1
* New location:  C:\Users\$($Env:UserName)\AppData\Roaming\PowerShell\MDSTools\mdstools\Configuration.psd1

## Usage

The main purpose of the module is to make day to day administrative tasks easier through functions or groups of functions that cover the following subgroups:

* Module Configuration - Used to set variables required by some module functions
* Credential Management - Used to store and call credentials.  Many module functions use a MDSCredential parameter to make using admin credentials more convenient.
* Start Processes - Use PowerShell to open administrative tools as the current user or another user.
* Utility Functions - Test AD credentials, 'ANR' AD search, get Exchange servers from LDAP
* Msol Licensing - Get Office 365 licensing and enable/disable service plans

## Available Commands

    CommandType     Name                                    Version    Source
    -----------     ----                                    -------    ------
    Alias           Import-MDSEXO                           2.0.7.27   MDSTools
    Alias           Start-MDSEMC                            2.0.7.27   MDSTools
    Function        Add-MDSCredential                       2.0.7.27   MDSTools
    Function        Connect-MDSMsolService                  2.0.7.27   MDSTools
    Function        Disable-MDSMsolLicenseServicePlan       2.0.7.27   MDSTools
    Function        Enable-MDSMsolLicenseServicePlan        2.0.7.27   MDSTools
    Function        Find-MDSUserName                        2.0.7.27   MDSTools
    Function        Get-MDSADLockoutSource                  2.0.7.27   MDSTools
    Function        Get-MDSConfiguration                    2.0.7.27   MDSTools
    Function        Get-MDSCredential                       2.0.7.27   MDSTools
    Function        Get-MDSExchServerFromLDAP               2.0.7.27   MDSTools
    Function        Get-MDSForestADGroupMember              2.0.7.27   MDSTools
    Function        Get-MDSMsolLicenseServicePlan           2.0.7.27   MDSTools
    Function        Import-MDSExchOnline                    2.0.7.27   MDSTools
    Function        Import-MDSExchOnprem                    2.0.7.27   MDSTools
    Function        Import-MDSSkypeOnPrem                   2.0.7.27   MDSTools
    Function        Remove-MDSCredential                    2.0.7.27   MDSTools
    Function        Set-MDSConfiguration                    2.0.7.27   MDSTools
    Function        Start-MDSADSyncSyncCycle                2.0.7.27   MDSTools
    Function        Start-MDSADUC                           2.0.7.27   MDSTools
    Function        Start-MDSExchMgmtConsole                2.0.7.27   MDSTools
    Function        Start-MDSExplorer                       2.0.7.27   MDSTools
    Function        Start-MDSGPMC                           2.0.7.27   MDSTools
    Function        Start-MDSPowerShell                     2.0.7.27   MDSTools
    Function        Start-MDSSitesAndServices               2.0.7.27   MDSTools
    Function        Start-MDSWebBrowser                     2.0.7.27   MDSTools
    Function        Test-MDSADAuthentication                2.0.7.27   MDSTools
    Function        Update-MDSCredential                    2.0.7.27   MDSTools

Documentation for each function is available with `Get-Help`.

## Contributing

Feature additions are heavily influenced by the needs of my environment and your contributions!
