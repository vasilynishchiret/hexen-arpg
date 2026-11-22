# HEXEN-ARPG

[Русский](README.ru.md)

Return to the original *Hexen: Beyond Heretic* campaign with loot, equipment, and character growth. HEXEN-ARPG is a free, unofficial alpha mod for UZDoom. Choose **Cleric** to play with the ARPG systems; Fighter and Mage are still available in their usual Hexen form.

## Quick Start

1. [Download UZDoom](https://github.com/UZDoom/UZDoom/releases) for Windows.
2. Have your own legally obtained copy of the original **`HEXEN.WAD`**. The game and engine are not included in this mod.
3. [Download HEXEN-ARPG v0.1.0-alpha](https://github.com/vasilynishchiret/hexen-arpg/releases/download/v0.1.0-alpha/HEXEN-ARPG-v0.1.0-alpha.zip) and extract the ZIP to a folder.
4. Double-click **`Play.bat`**. If UZDoom or `HEXEN.WAD` is not found, choose its location in the file dialog.
5. Start a new game and choose **Cleric**. `Play.bat` starts the original Hexen campaign with the mod enabled.

Tested on Windows with UZDoom 5.0.3. This is an early alpha, so bugs and balance issues may still occur.

## What you can play now

- **Three independent weapon slots:** equip different weapons and switch with `1`, `2`, and `3`.
- **Loot and equipment:** find melee and magic weapons, armor, helmets, bracers, two rings, and boots. Items can roll different power and stat bonuses.
- **Affixes and abilities:** equipment can grant sprint, dash, double jump, shields, invisibility, enemy detection, Mana2 regeneration, vampirism, or a damage aura. An ability works only while its item is equipped.
- **Two combat mana pools:** Mana1 regenerates over time; eligible kills grant Mana2. Weapon mana costs depend on the weapon and its rolled power.
- **Upgrade gems:** world mana pickups become blue and green gems for improving eligible items. Combined mana pickups give one of each.
- **XP and levels:** eligible kills award XP, and levels increase the Cleric's health. The HUD shows level, XP, mana, abilities, and nearby loot.

For the current numbers and item rules, see [loot](docs/loot.md), [mana](docs/mana-economy.md), and [gems](docs/gems.md).

## Controls

- `1` / `2` / `3`: select a weapon slot. An empty slot cannot attack.
- `Alt`: open or close the 20-cell inventory. Aim at ground loot and press `E` to pick it up.
- In the inventory: click to select; double-click or right-click to equip; hover for a comparison. Use `WASD` or arrows to navigate, `Enter` to equip or remove, `U` to place a selected weapon in the active slot, `P` to drop, and `Esc` or `Alt` to close.
- `F` and `V`: use invisibility or enemy detection when the corresponding helmet ability is equipped. Other equipment abilities depend on the item.
- Mouse wheel or `[` / `]`: select a Hexen consumable; middle mouse uses it.

To use gems, select a stack in the inventory and then an eligible item. The menu previews the result; press `1`, `0`, or `M` for 1, 10, or the maximum number of gems, then `Enter` to apply. [Gem details](docs/gems.md) explain eligible equipment and limits.

## Custom maps

Drag a **Hexen-compatible** `.wad`, `.pk3`, or `.pk7` onto **`Play-Custom-Map.bat`**. Double-clicking the launcher opens a file picker. Some maps also need their internal level name; see [Advanced usage](#advanced-usage). Custom maps may conflict if they replace game code or player classes. No third-party map is included.

## Alpha limits and roadmap

This alpha focuses on the Cleric. Fighter and Mage remain playable without the Cleric's ARPG systems. Compatibility with custom maps and unusual equipment or hub-save combinations may vary.

Future plans, with no promised dates, include broader weapon progression, more magic and affixes, expanded monster variety, procedural dungeons, and deeper character development. These are plans, not features of this build. A future standalone game would require its own lawful game data and replacement of all protected Hexen resources and dependencies.

## Advanced usage

Keep `Play.bat`, `Play-Custom-Map.bat`, `mod/`, and `tools/` together in the extracted folder. The launcher can find UZDoom and `HEXEN.WAD` beside the mod or engine, on `PATH`, and in common Windows, Steam, and GOG locations. You can also give exact paths:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\launch.ps1 -UZDoom "D:\Games\UZDoom\uzdoom.exe" -IWAD "D:\Games\Hexen\HEXEN.WAD"
```

The launcher passes other arguments to UZDoom. It uses a separate profile at `%LOCALAPPDATA%\HEXEN-ARPG\uzdoom.ini` and applies `tools/controls.cfg`; it does not edit an existing global UZDoom or Hexen configuration. An explicit engine `-config` argument selects your own profile.

For a custom map, `-MapWad` loads its archive and `-StartMap` can select an internal level name such as `MAP01`:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\launch.ps1 -MapWad "D:\Maps\example.wad" -StartMap MAP01
```

You can also pass the internal level name as the second argument to `Play-Custom-Map.bat`. The level name is not necessarily the archive filename, and loading an archive does not necessarily add an episode to New Game. Check its `MAPINFO`/`ZMAPINFO` or map editor. Keep the map archive available for its saves. See [custom-map notes](docs/custom-maps.md).

## Rights

HEXEN-ARPG is an unofficial fan modification and is not affiliated with or endorsed by the owners of *Hexen*. You need your own lawful copy of Hexen. The release ZIP does not include `HEXEN.WAD`, original Hexen maps, UZDoom binaries, or third-party WADs; their rights remain with their respective owners.

Project-authored program code and scripts are [GPL-3.0-or-later](LICENSE). The original PNG files and project documentation have separate [Original Content terms](LICENSES/ORIGINAL-CONTENT.md); they are not automatically GPL-licensed. See [RIGHTS.md](RIGHTS.md) for the file-by-file boundary and [the asset review](docs/asset-review.md) for provenance. The GPL grant does not transfer the author's copyright. The current mod source is included in the ZIP.
