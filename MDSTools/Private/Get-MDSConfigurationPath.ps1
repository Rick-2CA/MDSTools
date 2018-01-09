function Get-MDSConfigurationPath {
	[cmdletbinding()]
    param(
        [string]$FileName
    )

    begin {}
    process {
        $ConfigurationMachinePath = (Get-StoragePath -Scope Enterprise)
        Join-Path $ConfigurationMachinePath $FileName
    }
    end {}
}
