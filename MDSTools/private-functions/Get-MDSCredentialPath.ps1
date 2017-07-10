function Get-MDSCredentialPath {
	[cmdletbinding()]
    param(
        [string]$FileName
    )

    begin {}
    process {
        $ConfigurationMachinePath = (Get-StoragePath -Scope Machine)
        Join-Path $ConfigurationMachinePath $FileName
    }
    end {}

}