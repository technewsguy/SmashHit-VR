# SmashHit-VR

An unofficial PC VR runtime for the **Smash Hit** Gear VR build: play it in a PC VR headset through OpenXR (SteamVR
and others), or flat in a window with a mouse. Formerly called ShatterVR Runtime.

**This download contains no game.** No levels, music, art or other game files are included. You need your own copy of
the Gear VR APK, and this project can't provide one. Please don't post or link the APK, or ask for it, in issues.

SmashHit-VR is an independent project. It is not affiliated with, endorsed by or supported by Mediocre, who made
Smash Hit. Smash Hit is their game and their name; it is used here only to say what this software works with.

## Play

You need:
- Windows 10 or 11, 64-bit, and a graphics card with OpenGL support
- For VR: an OpenXR runtime, such as SteamVR, set as the active runtime
- Your own Smash Hit Gear VR APK

Steps:
1. Download the zip from [Releases](../../releases) and extract it to a folder.
2. Copy your APK into that folder and rename it `game.apk`.
3. Optional: double-click **Add to Steam.bat** to add **Smash Hit VR** to Steam and SteamVR (see below).
4. Start your VR software, then play **Smash Hit VR** from Steam, or double-click `SmashHit-VR.exe`. It starts in your
   headset, or in a window if no VR runtime is ready.

Windows may show "Windows protected your PC" because the program isn't code-signed. To run it, choose **More info**,
then **Run anyway**.

To always play in a window, run `SmashHit-VR.exe game.apk` from a terminal in that folder.

### Add to Steam

**Add to Steam.bat** adds **Smash Hit VR** to your Steam library as a non-Steam game, with "Include in VR Library" on,
so it also shows in SteamVR's library. Its cover, banner, background, logo and icon are made on your PC from your
`game.apk`: real frames of the game rendered by SmashHit-VR with the game's own logo on them. No game art ships with
SmashHit-VR, so run it after copying in your APK. A game window opens briefly a few times while the pictures are
made, and Steam closes and restarts while the entry is added.

To remove it, right-click **Smash Hit VR** in Steam > *Manage* > *Remove non-Steam game*. Running
`add-to-steam.ps1 -Remove` also deletes the artwork.

### With UniGetUI or Scoop

SmashHit-VR is also in the [technewsguy/scoop-vr-mods](https://github.com/technewsguy/scoop-vr-mods) bucket, so
[UniGetUI](https://github.com/marticliment/UniGetUI) (formerly WingetUI) or [Scoop](https://scoop.sh) can install it and
keep it up to date:

- **UniGetUI:** Settings > Package managers > Scoop > Buckets, add `vrmods` with the URL
  `https://github.com/technewsguy/scoop-vr-mods`, then search for `smashhit-vr` and install it.
- **Command line:**
  ```powershell
  scoop bucket add vrmods https://github.com/technewsguy/scoop-vr-mods
  scoop install vrmods/smashhit-vr
  ```

Then copy your APK into the install folder as `game.apk`. The install shows the exact path, normally
`%USERPROFILE%\scoop\apps\smashhit-vr\current`. Run **Smash Hit VR - Add to Steam** from the Start menu, or start
**Smash Hit VR** from the Start menu. Your APK is kept when SmashHit-VR updates.

Had the old `shattervr` package? Run `scoop uninstall shattervr`, then install `smashhit-vr` as above. Your APK and
your progress carry over.

## Controls

| Action | VR controller | Mouse and keyboard |
|---|---|---|
| Throw a ball, click menus | Trigger | Left click |
| Rapid fire, during the green power-up | Hold the trigger | Hold left click |
| Back, pause | B or menu button | Esc |
| Recentre the view | Thumbstick or trackpad click, or C on the keyboard | Not needed |
| Switch between hand and head aiming | A or X (grip on Vive and Windows MR), or G on the keyboard | Not needed |

Hand aiming is the default. Head aiming works as the original did: you aim and pick menu items by looking, and either
trigger throws. Your choice is remembered.

## Game modes

Choose a mode with the button at the bottom left of the menu. This build's data turned that button off; SmashHit-VR
turns it back on without changing your APK.

- **Classic** and **Training** play the campaign normally.
- **Mayhem** plays the campaign with its harder settings. Its menu card says "boss challenge", but this build's data
  has no boss rooms in any level, so there are no bosses.
- **Zen** plays without using up balls. Its own levels aren't in this build's data, so Zen plays the campaign's rooms
  instead. If your APK does include them, SmashHit-VR uses them.

## What has been tested

Played on one PC with SteamVR and Valve Index controllers. Other headsets and controllers have bindings but have not
been tried, and not every level has been played. Water, used only by a room that normal play can't reach, is not
implemented, and the Zen, Training and Mayhem menus have no music of their own in this data. Reports from other setups are welcome: say which headset, controllers and VR runtime you used.

Your progress is saved in `%APPDATA%\SmashHit-VR\SmashHit-VR`. Progress from ShatterVR is copied there the first time
you start it.

## Support the project

Donations are entirely optional: [Ko-fi](https://ko-fi.com/technewsguy). They support the time spent on this
independent project. They don't buy the game, any game content or any extra features, and everything here stays free.

## Build from source

Needs VS 2022 Build Tools (C++ workload), CMake 3.25+ and vcpkg:

```powershell
$env:VCPKG_ROOT = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\vcpkg"
cmake --preset default
cmake --build --preset release
ctest --preset release
```

`packaging\package.ps1` builds, tests and makes the release zip in `dist\`.

## Licence

The code in this repository is under the [MIT licence](LICENSE). That covers this code only and gives no rights to
Smash Hit or its content. Third-party libraries keep their own licences: see
[THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md).
