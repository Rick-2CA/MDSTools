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
* [Configuration](https://www.powershellgallery.com/packages/Configuration) module by Joel Bennett.  If you install via the PowerShell Gallery the supported version of this module will be installed automatically.

## Installation
The module is available on the [PowerShell Gallery](https://www.powershellgallery.com/packages/mdstools) and can be installed by running:

`Find-Module MDSTools | Install-Module`

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
    Alias           Import-MDSEXO                           1.0.6.20   mdstools
    Alias           Start-MDSEMC                            1.0.6.20   mdstools
    Function        Add-MDSCredential                       1.0.6.20   mdstools
    Function        Connect-MDSMsolService                  1.0.6.20   mdstools
    Function        Disable-MDSMsolLicenseServicePlan       1.0.6.20   mdstools
    Function        Enable-MDSMsolLicenseServicePlan        1.0.6.20   mdstools
    Function        Find-MDSUserName                        1.0.6.20   mdstools
    Function        Get-MDSConfiguration                    1.0.6.20   mdstools
    Function        Get-MDSCredential                       1.0.6.20   mdstools
    Function        Get-MDSExchServerFromLDAP               1.0.6.20   mdstools
    Function        Get-MDSMsolLicenseServicePlan           1.0.6.20   mdstools
    Function        Import-MDSExchOnline                    1.0.6.20   mdstools
    Function        Import-MDSExchOnprem                    1.0.6.20   mdstools
    Function        Import-MDSSkypeOnPrem                   1.0.6.20   mdstools
    Function        Remove-MDSCredential                    1.0.6.20   mdstools
    Function        Set-MDSConfiguration                    1.0.6.20   mdstools
    Function        Start-MDSADSyncSyncCycle                1.0.6.20   mdstools
    Function        Start-MDSADUC                           1.0.6.20   mdstools
    Function        Start-MDSExchMgmtConsole                1.0.6.20   mdstools
    Function        Start-MDSExplorer                       1.0.6.20   mdstools
    Function        Start-MDSGPMC                           1.0.6.20   mdstools
    Function        Start-MDSPowerShell                     1.0.6.20   mdstools
    Function        Start-MDSSitesAndServices               1.0.6.20   mdstools
    Function        Test-MDSADAuthentication                1.0.6.20   mdstools
    Function        Update-MDSCredential                    1.0.6.20   mdstools

Documentation for each function is available with `Get-Help`.

## Contributing
Feature additions are heavily influenced by the needs of my environment and your contributions!
