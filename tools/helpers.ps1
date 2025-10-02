$softwareName = 'PawnIO'

function Get-CurrentVersion {
    [array] $keys = Get-UninstallRegistryKey -SoftwareName $softwareName
    if ($keys.Length -ge 1) {
        return [version] $keys[0].DisplayVersion
    }
  
    return $null
}

function Uninstall-CurrentVersion {
    $packageArgs = @{
        packageName    = $env:ChocolateyPackageName
        softwareName   = 'PawnIO'
        fileType       = 'EXE'
        silentArgs     = '-uninstall -silent'
        validExitCodes = @(0)
    }

    [array] $keys = Get-UninstallRegistryKey -SoftwareName $packageArgs['softwareName']

    if ($keys.Count -eq 1) {
        $keys | ForEach-Object {
            $packageArgs['file'] = "$($_.UninstallString)".TrimEnd(' -uninstall')
            Uninstall-ChocolateyPackage @packageArgs
        }
    }
    elseif ($keys.Count -eq 0) {
        Write-Warning "$packageName has already been uninstalled by other means."
    }
    elseif ($keys.Count -gt 1) {
        Write-Warning "$($keys.Count) matches found!"
        Write-Warning 'To prevent accidental data loss, no programs will be uninstalled.'
        Write-Warning 'Please alert package maintainer the following keys were matched:'
        $keys | ForEach-Object { Write-Warning "- $($_.DisplayName)" }
    }
}
