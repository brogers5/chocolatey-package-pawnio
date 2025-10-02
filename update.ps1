Import-Module au
Import-Module PowerShellForGitHub

$currentPath = (Split-Path $MyInvocation.MyCommand.Definition)
. $currentPath\helpers.ps1

$toolsPath = Join-Path -Path $currentPath -ChildPath 'tools'

$owner = 'namazso'
$codeRepository = 'PawnIO'
$releaseRepository = 'PawnIO.Setup' 

function global:au_BeforeUpdate ($Package) {
    Get-RemoteFiles -Purge -NoSuffix -Algorithm sha256

    Copy-Item -Path "$toolsPath\VERIFICATION.txt.template" -Destination "$toolsPath\VERIFICATION.txt" -Force

    Set-DescriptionFromReadme -Package $Package -ReadmePath '.\DESCRIPTION.md'
}

function global:au_AfterUpdate ($Package) {
    $licenseUri = "https://raw.githubusercontent.com/$($owner)/$($codeRepository)/master/COPYING"
    $licenseContents = Invoke-WebRequest -Uri $licenseUri -UseBasicParsing

    Set-Content -Path 'tools\LICENSE.txt' -Value "From: $licenseUri`r`n`r`n$licenseContents" -NoNewline
}

function global:au_SearchReplace {
    @{
        "$($Latest.PackageName).nuspec" = @{
            '(<packageSourceUrl>)[^<]*(</packageSourceUrl>)' = "`$1https://github.com/brogers5/chocolatey-package-$($Latest.PackageName)/tree/v$($Latest.Version)`$2"
            '(<releaseNotes>)[^<]*(</releaseNotes>)'         = "`$1https://github.com/$($owner)/$($releaseRepository)/releases/tag/$($Latest.SoftwareVersion)`$2"
            '(<copyright>)[^<]*(</copyright>)'               = "`$1Copyright © $((Get-Date).Year) namazso`$2"
        }
        'tools\VERIFICATION.txt'        = @{
            '%checksumValue%'  = "$($Latest.Checksum64)"
            '%checksumType%'   = "$($Latest.ChecksumType64.ToUpper())"
            '%tagReleaseUrl%'  = "https://github.com/$($owner)/$($releaseRepository)/releases/tag/$($Latest.SoftwareVersion)"
            '%binaryUrl%'      = "$($Latest.Url64)"
            '%binaryFileName%' = "$($Latest.FileName64)"
        }
        'tools\chocolateyinstall.ps1'   = @{
            "(^\s*file64\s*=\s.*)('.*')" = "`$1'$($Latest.FileName64)'"
        }
        'build.ps1'                     = @{
            '(^[$]filePath\s*=\s*.*)(''.*'')' = "`$1'$($Latest.FileName64)'"
        }
    }
}

function global:au_GetLatest {
    $version = Get-LatestStableVersion

    return @{
        Url64           = Get-SoftwareUri
        Version         = $version #This may change if building a package fix version
        SoftwareVersion = $version
    }
}

Update-Package -ChecksumFor None -NoReadme
