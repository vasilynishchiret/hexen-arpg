# First standalone boot

This is a one-room UZDoom 5.0.3 prototype. It is separate from the published
HEXEN-ARPG alpha and needs **no Hexen, Doom, or other commercial IWAD**. You
provide UZDoom; this repository builds its own `HEXEN-ARPG-Standalone.ipk3`.

## Run on Windows

1. Install UZDoom 5.0.3.
2. Double-click `Play-Standalone.bat` in the repository root. The launcher
   builds the IPK3 under `build/standalone/` and finds `uzdoom.exe` or asks you
   to select it.
3. The prototype opens directly on `MAP01`. Use mouse to look, WASD to move,
   Space to jump, and primary fire to swing the blade. Approach the ring token
   to pick it up; its count appears beside HP in the upper left. Press Esc to
   open the game menu and quit.

For a specific engine installation, run
`powershell -NoProfile -ExecutionPolicy Bypass -File tools/launchstandalone.ps1 -UZDoom "C:\path\to\uzdoom.exe"`.
Extra arguments are forwarded to UZDoom. `-NoBuild` uses the existing IPK3;
the normal launcher rebuilds it from current sources. To build only, run
`powershell -NoProfile -ExecutionPolicy Bypass -File tools/build-standalone.ps1`.
The launcher keeps configuration and saves under
`%LOCALAPPDATA%\HEXEN-ARPG-Standalone\`, apart from the Hexen mod.

## What is connected

The prototype has an original UDMF room, generated wall/floor/ceiling textures,
an independent player actor, a placeholder blade with a short melee attack,
one ring-token pickup, a placeholder impact sprite, and a minimal HP/token
display. The IPK3 contains a generated palette and colour map. Its source is
in `mod/standalone/`; images are in `mod/assets/`. The build script lists every
included source explicitly. See [resource-map.md](resource-map.md).

The weapon, player sprite, ring, effects, and environment art are geometric
placeholders. There is no monster, soundtrack, sound design, campaign,
inventory, or progression system here. Engine-supplied menu and console UI
remain while dedicated UI is developed; engine resources are not bundled in
the IPK3.

## Next migration steps

Move the original ARPG systems in small, separately tested stages: player
stats and XP; two mana channels and gems; inventory and equipment; weapon
slots and abilities; affixes and item upgrades. Each transferred system must
replace any Hexen class, sprite, sound, texture, map, UI, and name dependency
with original content or a licensed standalone-compatible dependency. This
prototype does not import the existing Hexen-specific ZScript tree.
