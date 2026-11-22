# v0.1.0-alpha: final hands-on checks

Use the **extracted release ZIP**, not the Git working tree. Supply your own
UZDoom installation and lawful `HEXEN.WAD`. Record pass/fail, UZDoom version,
resolution, and any visible error for each check. Startup and ZScript parsing
alone do not count as a gameplay pass.

1. Double-click `Play.bat`. Start the original campaign as **Cleric**. Check
   HP, Mana1, Mana2, level, XP, and abilities with the stone and fullscreen
   HUD at two resolutions or aspect ratios. The built-in stone bar may show
   armor `0` for Cleric.
2. Open the inventory with **Alt**. Pick up loot with **E**, equip and remove
   items, use each of the three weapon slots, and activate an equipped affix.
   Confirm combat mana changes and a blue/green gem upgrade.
3. Save and load after equipping and upgrading. Confirm equipment, stats,
   gems, level, and XP persist. Cross a hub portal, return, and check again.
4. Start separate **Fighter** and **Mage** games. Check their attacks, HP/mana
   HUD, inventory behavior, and save/load.
5. Start a compatible custom WAD with `Play-Custom-Map.bat` (drag and drop or
   file picker). Supply its internal map name, such as `MAP01`, if needed.
   Check actual gameplay, HUD, inventory, and save/load. Keep that WAD outside
   the release ZIP.
6. On original Hexen MAP01 near the Emerald Key door, revisit the reported
   spot around `x -8, y 4, z -112`. Check that upgrade gems do not accumulate
   without bound. Repeat after saving/loading. See
   [gem respawn regression](gem-respawn-regression.md).

The rights holder reported completing these hands-on checks from the release
ZIP on 2026-11-22, with no critical problems found. This is a user-reported
result, not an agent-observed play-through. The final license-only package
still needs its own archive, source, and startup checks before publication.
