# Builds SmashHit-VR (Release) and packages the release zip in dist\:
#   SmashHit-VR\SmashHit-VR.exe, Add to Steam.bat, add-to-steam.ps1, SteamShortcut.exe, README.md, LICENSE, THIRD-PARTY-NOTICES.md
# Needs VCPKG_ROOT (see README) and the .NET Framework 4 C# compiler that comes with Windows.
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$ver = ([regex]'"ProductVersion", "([^"]+)"').Match((Get-Content (Join-Path $PSScriptRoot 'smashhit-vr.rc') -Raw)).Groups[1].Value
if (-not $ver) { throw 'No ProductVersion in smashhit-vr.rc' }
Push-Location $root
try {
    cmake --build --preset release
    if ($LASTEXITCODE -ne 0) { throw 'build failed' }
    ctest --preset release
    if ($LASTEXITCODE -ne 0) { throw 'tests failed' }
} finally { Pop-Location }

$stage = Join-Path $root "dist\SmashHit-VR"
Remove-Item (Join-Path $root 'dist') -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force $stage | Out-Null
$csc = "$env:WINDIR\Microsoft.NET\Framework\v4.0.30319\csc.exe"
& $csc /nologo /optimize+ "/out:$stage\SteamShortcut.exe" (Join-Path $PSScriptRoot 'steam\SteamShortcut.cs')
if ($LASTEXITCODE -ne 0) { throw 'SteamShortcut build failed' }
Copy-Item (Join-Path $root 'build\Release\SmashHit-VR.exe') $stage
Copy-Item (Join-Path $PSScriptRoot 'steam\add-to-steam.ps1'), (Join-Path $PSScriptRoot 'steam\Add to Steam.bat') $stage
Copy-Item (Join-Path $root 'README.md'), (Join-Path $root 'LICENSE'), (Join-Path $root 'THIRD-PARTY-NOTICES.md') $stage
$zip = Join-Path $root "dist\SmashHit-VR-v$ver-windows-x64.zip"
# Windows' tar.exe writes "/" in entry names (Compress-Archive and .NET Framework's ZipFile write "\").
& "$env:WINDIR\System32\tar.exe" -a -c -f $zip -C (Split-Path $stage -Parent) (Split-Path $stage -Leaf)
if ($LASTEXITCODE -ne 0) { throw 'zip failed' }
Write-Host "Packaged $zip"
(Get-FileHash $zip -Algorithm SHA256).Hash.ToLower()
