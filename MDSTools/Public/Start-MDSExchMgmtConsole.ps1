Function Start-MDSExchMgmtConsole {
	<#
		.SYNOPSIS
		Open the Exchange Management Console

		.DESCRIPTION
		Open the Exchange Management Console as the current user.  No credential options exist.  You must open PowerShell as the user you wish to open the Exchange Management Console as before running this function to specify a user.

		.EXAMPLE
		Start-MDSExchMgmtConsole

		Open the ADUC console as the current user

		.NOTES

	#>
	[CmdletBinding()]
	Param()
	Start-Process 'Exchange Management Console'
}
