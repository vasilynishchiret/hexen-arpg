# HEXEN-ARPG

Minimal UZDoom 5.0.3 mod for the original Hexen IWAD. This is an independent project, not an engine fork.

## Current change

The Fighter starts with `ARPGFighterGauntlets`, a subclass of the original `FWeapFist`. Its `Inventory.ModifyDamage` hook doubles outgoing `Melee` damage while the gauntlets are selected. The original attack action, animation, timing, number of hits, and combo logic are inherited unchanged. `MAPINFO` lists this Fighter subclass alongside the original Cleric and Mage classes. The original IWAD and engine are untouched.

## Run

From the project root in PowerShell:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\launch.ps1
```

The script defaults to `C:\Games\UZDoom\uzdoom.exe` and `C:\Games\UZDoom\HEXEN.WAD`. Override either path with `-UZDoom` or `-IWAD`. Other arguments are passed to UZDoom, for example `+playerclass 0 +map MAP01` to start as Fighter on the first map.

In VS Code, open the `hexen-arpg` folder and use **Terminal -> Run Task -> Run Hexen ARPG**.

## Manual A/B check

Launch the mod with the command above and choose Fighter. Save at the start of MAP01, then hit a nearby Ettin with the starting gauntlets. For the baseline, start UZDoom with `-iwad C:\Games\UZDoom\HEXEN.WAD` and no `-file` argument, choose Fighter, and repeat from the same position. The unmodified punch rolls 40-55 base damage; this mod rolls 80-110. The third successful contact in either version triggers the original stronger combo hit. For a precise comparison, use the same target and inspect its health through a ZScript test handler; counts of hits to kill can vary with the random damage roll and combo.

Do not commit game WADs, engine binaries, saves, or other copyrighted game resources.
