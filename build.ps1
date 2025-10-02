$ErrorActionPreference = 'Stop'

$currentPath = (Split-Path $MyInvocation.MyCommand.Definition)
. $currentPath\helpers.ps1

$nuspecFileRelativePath = Join-Path -Path $currentPath -ChildPath 'pawnio.nuspec'

[xml] $nuspec = Get-Content -Path $nuspecFileRelativePath
$version = [Version] $nuspec.package.metadata.version

$global:Latest = @{
    Url64   = Get-SoftwareUri -Version $version
    Version = $version
}

Write-Output 'Downloading installer...'
Get-RemoteFiles -Purge -NoSuffix

Write-Output 'Confirming installer integrity...'
$expectedHash = Get-InstallerChecksum -Version $version
$filePath = Join-Path -Path $currentPath -ChildPath 'tools' | Join-Path -ChildPath 'PawnIO_setup.exe'
$actualHash = Get-FileHash -Path $filePath
if ($actualHash.Hash -ne $expectedHash) {
    throw 
}

Write-Output 'Creating package...'
choco pack $nuspecFileRelativePath
