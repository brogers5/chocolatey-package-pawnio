$ErrorActionPreference = 'Stop'
$toolsDir = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"
. $toolsDir\helpers.ps1

Confirm-Win10 -ReqBuild 17763

$softwareName = 'PawnIO'
[version] $softwareVersion = '2.2.0.0'
$currentVersion = Get-CurrentVersion
$installerFilePath = Join-Path -Path $toolsDir -ChildPath 'PawnIO_setup.exe'

if ($currentVersion -eq $softwareVersion -and !$env:ChocolateyForce) {
  Write-Output "$softwareName v$softwareVersion is already installed."
  Write-Output 'Skipping execution of installer.'
}
else {
  if ($null -ne $currentVersion -and $currentVersion -ge $softwareVersion) {
    Write-Output "Current installed version (v$currentVersion) must be uninstalled first..."
    Uninstall-CurrentVersion
  }

  $packageArgs = @{
    packageName    = $env:ChocolateyPackageName
    fileType       = 'EXE'
    file64         = $installerFilePath
    softwareName   = $softwareName
    silentArgs     = '-install -silent'
    validExitCodes = @(0, 3010)
  }

  Install-ChocolateyInstallPackage @packageArgs
}

$pp = Get-PackageParameters
$shimName = 'PawnIOUtil'
if ($pp.NoShim) {
  Uninstall-BinFile -Name $shimName
}
else {
  $installLocation = Get-AppInstallLocation -AppNamePattern $softwareName
  if ($null -ne $installLocation) {
    $shimPath = Join-Path -Path $installLocation -ChildPath 'PawnIOUtil.exe'
    Install-BinFile -Name $shimName -Path $shimPath
  }
  else {
    Write-Warning 'Skipping shim creation - install location not detected'
  }
}

#Remove installer binary post-install to prevent disk bloat
Remove-Item -Path $installerFilePath -Force -ErrorAction SilentlyContinue
