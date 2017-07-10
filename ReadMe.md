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
* [Configuration](https://www.powershellgallery.com/packages/Configuration) module by Joel Bennett

## Installation
The module is pending availablity on the [PowerShell Gallery](https://www.powershellgallery.com).

## Usage
The main purpose of the module is to make day to day administrative tasks easier through functions or groups of functions that cover the following subgroups:

* Module Configuration - Used to set variables required by some module functions
* Credential Management - Used to store and call credentials.  Many module functions use a MDSCredential parameter to make using admin credentials more convenient.
* Start Processes - Use PowerShell to open administrative tools as the current user or another user.
* Utility Functions - Test AD credentials, 'ANR' AD search, get Exchange servers from LDAP
* Msol Licensing - Get Office 365 licensing and enable/disable service plans

## Available Commands  

    CommandType     Name                                Version    Source
    -----------     ----                                -------    ------
    Alias           Import-MDSEXO                       0.0.6      MDSTools
    Alias           Start-MDSEMC                        0.0.6      MDSTools
    Function        Add-MDSCredential                   0.0.6      MDSTools
    Function        Connect-MDSMsolService              0.0.6      MDSTools
    Function        Disable-MDSMsolLicenseServicePlan   0.0.6      MDSTools
    Function        Enable-MDSMsolLicenseServicePlan    0.0.6      MDSTools
    Function        Find-MDSUserName                    0.0.6      MDSTools
    Function        Get-MDSConfiguration                0.0.6      MDSTools
    Function        Get-MDSCredential                   0.0.6      MDSTools
    Function        Get-MDSExchServerFromLDAP           0.0.6      MDSTools
    Function        Get-MDSMsolLicenseServicePlan       0.0.6      MDSTools
    Function        Import-MDSExchOnline                0.0.6      MDSTools
    Function        Import-MDSExchOnprem                0.0.6      MDSTools
    Function        Import-MDSSkypeOnPrem               0.0.6      MDSTools
    Function        Remove-MDSCredential                0.0.6      MDSTools
    Function        Set-MDSConfiguration                0.0.6      MDSTools
    Function        Start-MDSADSyncSyncCycle            0.0.6      MDSTools
    Function        Start-MDSADUC                       0.0.6      MDSTools
    Function        Start-MDSExchMgmtConsole            0.0.6      MDSTools
    Function        Start-MDSExplorer                   0.0.6      MDSTools
    Function        Start-MDSGPMC                       0.0.6      MDSTools
    Function        Start-MDSPowerShell                 0.0.6      MDSTools
    Function        Start-MDSSitesAndServices           0.0.6      MDSTools
    Function        Test-MDSADAuthentication            0.0.6      MDSTools
    Function        Update-MDSCredential                0.0.6      MDSTools

Documentation for each function is available with `Get-Help`.

## Examples



## Contributing
Feature additions are heavily influenced by the needs of my environment and your contributions!
