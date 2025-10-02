Import-Module PowerShellForGitHub

$installerFileNameRegex = '^PawnIO_Setup\.exe$'
$owner = 'namazso'
$repository = 'PawnIO.Setup'

function Get-LatestStableVersion {
    $latestRelease = (Get-GitHubRelease -OwnerName $owner -RepositoryName $repository -Latest)[0]

    return [version] $latestRelease.tag_name
}

function Get-InstallerAsset($Version) {
    if ($null -eq $Version) {
        # Default to latest stable version
        $release = (Get-GitHubRelease -OwnerName $owner -RepositoryName $repository -Latest)[0]
    }
    else {
        $release = Get-GitHubRelease -OwnerName $owner -RepositoryName $repository -Tag "$($Version.ToString())"
    }
    $releaseAssets = Get-GitHubReleaseAsset -OwnerName $owner -RepositoryName $repository -Release $release.ID

    $windowsInstallerAsset = $null
    foreach ($asset in $releaseAssets) {
        if ($asset.name -match $installerFileNameRegex) {
            $windowsInstallerAsset = $asset
            break
        }
        else {
            continue
        }
    }

    if ($null -eq $windowsInstallerAsset) {
        throw 'Cannot find published Windows installer asset!'
    }

    return $windowsInstallerAsset
}

function Get-SoftwareUri($Version) {
    $windowsInstallerAsset = Get-InstallerAsset -Version $Version
    return $windowsInstallerAsset.browser_download_url
}

function Get-InstallerChecksum($Version) {
    $windowsInstallerAsset = Get-InstallerAsset -Version $Version
    $assetId = $windowsInstallerAsset.Id
    $assetDetails = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repository/releases/assets/$assetId"
    return $assetDetails.digest.TrimStart('sha256:')
}
