# HEXEN-ARPG (alpha)

[Русский](README.ru.md)

HEXEN-ARPG is a free, unofficial ARPG mod for the original *Hexen: Beyond Heretic*. It adds loot, equipment, randomized weapon power, abilities, gems, and character levels to the Cleric. The original campaign remains the default game. Fighter and Mage remain selectable but do not have the ARPG systems.

## Requirements and installation

- Windows, [UZDoom](https://github.com/UZDoom/UZDoom) (developed against 5.0.3), and your own legally obtained original `HEXEN.WAD`.
- Download or clone this repository. Keep its `mod` and `tools` folders beside `Play.bat`.
- Do not copy `HEXEN.WAD` or UZDoom into a redistributed mod package. You may keep your own copies locally.

Double-click **`Play.bat`**. The launcher looks beside the project, beside UZDoom, on `PATH`, and in common Windows, Steam, and GOG locations. If it cannot find UZDoom or `HEXEN.WAD`, select the file in the Windows dialog. Missing files produce an error. The game opens its normal menu; start a new game and choose **Cleric**. `Play.bat` does not load a custom map.

For command-line use:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\launch.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\launch.ps1 -UZDoom "D:\Games\UZDoom\uzdoom.exe" -IWAD "D:\Games\Hexen\HEXEN.WAD"
```

Other arguments are passed to UZDoom. The default settings profile is `%LOCALAPPDATA%\HEXEN-ARPG\uzdoom.ini`; the launcher executes `tools/controls.cfg` there. An explicit engine `-config` argument selects the profile you provide. The launcher does not edit an existing global UZDoom or Hexen configuration.

## Implemented in this alpha

### Controls and interface

`1`, `2`, `3` select three independent weapon slots; each can hold a different weapon, and an empty slot cannot attack. `Alt` opens the 20-cell inventory. Aim at ground loot and press `E` to pick it up; full inventory leaves it on the ground. In the inventory, single-click selects, double-click or right-click equips, and hovering shows item comparisons. `WASD`/arrows navigate, `Enter` equips or removes, `P` drops, and `Esc`/`Alt` closes. `U` equips a selected item into the selected weapon slot. The mouse wheel selects Hexen consumables and middle mouse uses one; `[` and `]` also select consumables. `I` is strafe in the separate profile.

### Combat, loot, and character growth

The Cleric has two **combat mana** pools. Mana1 regenerates over time, except while sprinting; Mana2 gains 5 on an eligible monster kill and can also regenerate from a ring affix. Weapon mana costs depend on the weapon and its rolled power. World mana pickups become **upgrade gems**, separate from combat mana; a combined pickup gives one of each.

Eligible kills award XP and independently roll for equipment and a gem. There is a 10% equipment roll and a separate 10% gem roll. Equipment includes melee and magic weapons, chest armor, helmets, bracers, two independent rings, and boots. Existing map armor and ordinary weapon pickups are converted to ARPG loot for the Cleric; quest items and weapon pieces remain. Item power is rolled per instance. Melee and magic weapon rolls use common (80%), strong (17%), and exceptional (3%) ranges. Chest armor has one to four random stat bonuses across three tiers. These are current roll tiers, not a complete item rarity system with named legendary items.

Equipment affixes include sprint, dash, and double jump on boots; Arcane Shield or Guardian on some bracers; invisibility (`F`) or enemy detection (`V`) on some helmets; and Mana2 regeneration, vampirism, or damage aura on rings. Chest armor can improve health, damage reduction, mana capacity, and Mana1 regeneration. Abilities appear only when the relevant item is equipped. The HUD shows level, XP, mana, equipped abilities, and loot information.

Cleric starts at level 1. Eligible kills grant XP; the first level threshold is 100 XP, later thresholds rise by 35%, and each level adds 5 maximum and current HP. Bounded monster reinforcements may appear over time on supported maps.

### Gem upgrades

Blue and green gems stack in the inventory. Select a gem stack, then an item in the bag or equipment; the menu previews the change. Press `1`, `0`, or `M` for 1, 10, or the maximum number, then `Enter` to apply. Each item has a combined 100-gem limit. On weapons, gems increase power and the mana cost is recalculated. On chest armor, helmets, and ordinary bracers, blue adds maximum HP and green adds protection up to the armor cap. On rings, blue adds maximum Mana1 and green improves Mana1 regeneration. Boots cannot be upgraded. See [gem details](docs/gems.md).

## Custom maps

Drag a Hexen-compatible `.wad`, `.pk3`, or `.pk7` onto **`Play-Custom-Map.bat`**. Double-clicking that file without an argument opens a Windows file picker. A map may need an explicit internal level name such as `MAP01`; the archive filename is not necessarily its map name. From a terminal:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\launch.ps1 -MapWad "D:\Maps\example.wad" -StartMap MAP01
```

You can also pass the internal map name as the second argument to `Play-Custom-Map.bat`. Without `-StartMap`, the map's own menu and transitions decide what starts; loading a WAD does **not** necessarily add an episode to New Game. Use a map editor or inspect `MAPINFO`/`ZMAPINFO` to find the level name. Maps built for other games, or maps that replace player classes and game code, may conflict. Keep a map archive available when loading its save. No third-party map is included. See [custom map notes](docs/custom-maps.md).

## Alpha limits and roadmap

This is an alpha focused on the Cleric. Balance, custom-map compatibility, save/load across hubs, and all equipment interactions still need broader playtesting. Before the public prerelease, follow the [short release checklist](docs/release-checklist.md) from the extracted ZIP. Weapon elemental damage types are reserved in data but do not affect attacks. There is no full procedural dungeon system or complete character skill tree.

Future areas of work, with no promised dates: broader weapon progression, more magic, more affixes, expanded monster variety and behavior, procedural dungeons, and deeper character development. These are **plans**, not features of this build.

## Rights and project status

This is an unofficial fan modification and is not affiliated with or endorsed by the owners of *Hexen*. UZDoom, the original game, and their resources are separate dependencies. This repository must not contain `HEXEN.WAD`, original maps, UZDoom binaries, or third-party WADs without permission. See [asset review](docs/asset-review.md) before redistribution.

The author's original code, scripts, graphics, and documentation are covered by the project-specific [LICENSE](LICENSE), with provenance and third-party boundaries described in [RIGHTS.md](RIGHTS.md). You may play for free and share an unmodified complete archive with notices intact. Private changes and monetized gameplay videos or streams are allowed. Public distribution of modified Original Materials or patches containing their copyrighted portions, and commercial reuse of original code or graphics, require separate permission. These terms do not license Hexen or UZDoom material and do not assign GPL to the author's original files.

This branch uses UZDoom's built-in Hexen status bar at runtime; the previously adapted UZDoom status-bar source is absent from the current mod but remains in Git history. The remaining GPL/ZScript boundary and hands-on gameplay checks are documented in the [licensing audit](docs/licensing-audit.md) and [native status-bar test record](docs/native-statusbar-check.md). The draft Release is **not ready to publish** until those checks are resolved and the final ZIP is tested.
