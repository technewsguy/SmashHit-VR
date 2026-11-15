# Adds "Smash Hit VR" to the Steam library as a non-Steam game with "Include in VR Library" on (so it is in
# SteamVR's library too), with artwork made from YOUR game.apk: the cover, banner and background are frames of the game
# rendered by SmashHit-VR.exe with the game's own logo on them, plus the logo and the app icon. No game art ships with
# SmashHit-VR; it is made on your PC from your APK.
# Steam must be closed while its shortcut list is edited: this script closes Steam and starts it again.
# Usage: .\add-to-steam.ps1            (or double-click "Add to Steam.bat")
#        .\add-to-steam.ps1 -Remove    removes the artwork (remove the entry in Steam: right-click > Manage > Remove non-Steam game)
# Testing: -SteamDir <folder> uses that folder as Steam (its userdata\<id>\config) and leaves the Steam program alone.
param([switch]$Remove, [string]$SteamDir)
$ErrorActionPreference = 'Stop'
$name = 'Smash Hit VR'
$here = $PSScriptRoot
# Installed with Scoop: point Steam at the 'current' folder, so the entry keeps working after updates.
$appDir = Split-Path $here -Parent
if ((Split-Path $appDir -Leaf) -eq 'smashhit-vr' -and (Test-Path (Join-Path $appDir 'current\SmashHit-VR.exe'))) { $here = Join-Path $appDir 'current' }
$exe = Join-Path $here 'SmashHit-VR.exe'
$apk = Join-Path $here 'game.apk'
$art = Join-Path $env:APPDATA 'SmashHit-VR\steam-art'

if ($SteamDir) { $steam = $SteamDir; $steamExe = $null; $user = $null }
else {
    $steamKey = Get-ItemProperty HKCU:\Software\Valve\Steam -ErrorAction SilentlyContinue
    if (-not $steamKey -or -not $steamKey.SteamPath) { throw 'Steam is not installed.' }
    $steam = $steamKey.SteamPath; $steamExe = $steamKey.SteamExe
    $user = (Get-ItemProperty HKCU:\Software\Valve\Steam\ActiveProcess -ErrorAction SilentlyContinue).ActiveUser
}
if (-not $user) { $user = (Get-ChildItem "$steam\userdata" -Directory | Where-Object Name -ne '0' | Select-Object -First 1).Name }
$cfg = "$steam\userdata\$user\config"
$idFile = Join-Path $art 'steam_appid.txt'

if ($Remove) {
    if (Test-Path $idFile) { Get-ChildItem "$cfg\grid\$((Get-Content $idFile).Trim())*" -ErrorAction SilentlyContinue | Remove-Item -Force }
    if (Test-Path $art) { Remove-Item $art -Recurse -Force }
    Write-Host "Removed the artwork. Remove '$name' in Steam: right-click it > Manage > Remove non-Steam game."
    return
}

if (-not (Test-Path $exe)) { throw "SmashHit-VR.exe not found in $here" }
if (-not (Test-Path $apk)) { throw "Copy your own Smash Hit Gear VR APK to $apk first, then run this again." }

# 1. The artwork, from the APK. SmashHit-VR.exe is a windowed program: Start-Process -Wait waits for it.
function Invoke-Game([string[]]$arguments) {
    $quoted = ($arguments | ForEach-Object { if ($_ -match '\s') { "`"$_`"" } else { $_ } }) -join ' '
    $p = Start-Process -FilePath $exe -ArgumentList $quoted -WorkingDirectory $here -Wait -PassThru
    if ($p.ExitCode -ne 0) { throw "SmashHit-VR.exe $($arguments[1]) failed (exit code $($p.ExitCode))." }
}
New-Item -ItemType Directory -Force $art | Out-Null
Write-Host 'Making the artwork from your game.apk (a game window opens briefly a few times)...'
Invoke-Game @($apk, '--export-art', $art)
# The night room of the first level: the cover (600x900), the banner (920x430) and the background (1920x620).
$shots = [ordered]@{ capsule = '600x900'; header = '920x430'; hero = '1920x620' }
foreach ($k in $shots.Keys) {
    Invoke-Game @($apk, '--room', '3', '--frames', '300', '--mute', '--no-hud', '--size', $shots[$k], '--screenshot', (Join-Path $art "$k-frame.png"))
}

Add-Type -AssemblyName System.Drawing
$jpeg = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object MimeType -eq 'image/jpeg'
$quality = New-Object Drawing.Imaging.EncoderParameters 1
$quality.Param[0] = New-Object Drawing.Imaging.EncoderParameter ([Drawing.Imaging.Encoder]::Quality), ([long]92)
$logo = [Drawing.Image]::FromFile((Join-Path $art 'logo.png'))
# A frame scaled to the exact size (a high-DPI window can render bigger), the logo on top when $logoWidth > 0.
function New-Art([string]$frame, [int]$w, [int]$h, [double]$logoWidth, [double]$logoTop, [string]$out) {
    $src = [Drawing.Image]::FromFile((Join-Path $art $frame))
    $bmp = New-Object Drawing.Bitmap $w, $h
    $g = [Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.DrawImage($src, 0, 0, $w, $h)
    if ($logoWidth -gt 0) {
        $lw = [int]($w * $logoWidth); $lh = [int]($logo.Height * $lw / $logo.Width)
        $g.DrawImage($logo, [int](($w - $lw) / 2), [int]($h * $logoTop), $lw, $lh)
    }
    $g.Dispose(); $src.Dispose()
    $bmp.Save((Join-Path $art $out), $jpeg, $quality); $bmp.Dispose()
}
New-Art 'capsule-frame.png' 600 900 0.85 0.10 'capsule.jpg'
New-Art 'header-frame.png' 920 430 0.70 0.09 'header.jpg'
New-Art 'hero-frame.png' 1920 620 0 0 'hero.jpg'
$logo.Dispose()
Get-ChildItem $art -Filter '*-frame.png' | Remove-Item -Force

# 2. The Steam entry (Steam closed while shortcuts.vdf is edited), then the artwork under its id.
$wasRunning = $steamExe -and [bool](Get-Process steam -ErrorAction SilentlyContinue)
if ($wasRunning) {
    Write-Host 'Closing Steam...'
    Start-Process $steamExe -ArgumentList '-shutdown'
    $t = 0; while ((Get-Process steam -ErrorAction SilentlyContinue) -and $t -lt 60) { Start-Sleep 1; $t++ }
    if (Get-Process steam -ErrorAction SilentlyContinue) { throw 'Steam did not close; close it and run this again.' }
}
New-Item -ItemType Directory -Force $cfg | Out-Null
if ((Test-Path "$cfg\shortcuts.vdf") -and -not (Test-Path "$cfg\shortcuts.vdf.smashhitvr-backup")) { Copy-Item "$cfg\shortcuts.vdf" "$cfg\shortcuts.vdf.smashhitvr-backup" }
$id = & (Join-Path $PSScriptRoot 'SteamShortcut.exe') "$cfg\shortcuts.vdf" $name $exe $here (Join-Path $art 'icon.png') '-' 1
if ($LASTEXITCODE -ne 0 -or -not $id) { throw 'Adding the Steam shortcut failed.' }
$id = "$id".Trim()
Set-Content $idFile $id
New-Item -ItemType Directory -Force "$cfg\grid" | Out-Null
$pairs = [ordered]@{ 'header.jpg' = "$id.jpg"; 'capsule.jpg' = "${id}p.jpg"; 'hero.jpg' = "${id}_hero.jpg"; 'logo.png' = "${id}_logo.png"; 'icon.png' = "${id}_icon.png" }
foreach ($k in $pairs.Keys) { Copy-Item (Join-Path $art $k) "$cfg\grid\$($pairs[$k])" -Force }
Write-Host "Added '$name' to Steam and SteamVR with artwork from your game (shortcut id $id)."
if ($wasRunning) { Write-Host 'Starting Steam...'; Start-Process $steamExe }
