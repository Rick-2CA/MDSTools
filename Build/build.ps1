<#
.Description
Installs and loads all the required modules for the build.
.Author
Warren F. (RamblingCookieMonster)
#>

[cmdletbinding()]
param ($Task = 'Default')

# Grab nuget bits, install modules, set build variables, start build.
Get-PackageProvider -Name NuGet -ForceBootstrap | Out-Null

$Modules = @("Psake", "PSDeploy","BuildHelpers","PSScriptAnalyzer", "Pester","Posh-Git","Configuration")

ForEach ($Module in $Modules) {
    If (-not (Get-Module -Name $Module -ListAvailable)) {
            Switch ($Module) {
                Pester  {Install-Module $Module -Force -SkipPublisherCheck}
                Configuration {Install-Module $Module -RequiredVersion 1.2.0 -Force -AllowClobber}
                Default {Install-Module $Module -Force}
            }

    }
     Import-Module $Module
}

Try {
    $Path = (Resolve-Path $PSScriptRoot\..).Path
    Set-BuildEnvironment -Path $Path -Force -ErrorAction Stop
}
Catch {
    Write-Error $PSItem
    "Skipping build due to build setup error."
    Exit
}

Invoke-psake -buildFile $PSScriptRoot\psake.ps1 -taskList $Task -nologo
exit ([int](-not $psake.build_success))
