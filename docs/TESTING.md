# HEXEN-ARPG v0.3: manual verification in UZDoom 5.0.3

Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\launch.ps1` and start a **new** Cleric game. Script loading can be checked from the terminal with `& 'C:\Games\UZDoom\uzdoom.exe' -iwad 'C:\Games\UZDoom\HEXEN.WAD' -file '.\mod' -noautoload -nosound -stdout +quit`; `script parsing took ...` without `Script error` proves compilation only. `+quit` may still leave a graphics window in this environment.

1. Verify 50/50 HP, level 1, Mace/Sword/Lightning in slots 1/2/3. Kill an Ettin: +10 XP and +5 Mana2. Check Mana1 regeneration and weapon attacks as in the previous playable backup.
2. Run each console command: `summon ARPGTestSword`, `ARPGTestAxe`, `ARPGTestHammer`, `ARPGTestMace`, `ARPGTestLightning`, `ARPGTestFrost`, `ARPGTestStaff`, `ARPGTestWand`, `ARPGTestFirestorm`, `ARPGTestChest`, `ARPGTestHelmet`, `ARPGTestBracers`, `ARPGTestRing`. Also try `summon ARPGGroundWeapon` for a random item. Every type should have its own ground image.
3. Aim at a drop within 96 units and press E. It should enter a free bag slot. Open with I, select with J/K, target equipment slot with H/L, equip with U, remove with O, drop with P. Check a full 20-slot bag: E must leave a new item on the ground; O must not lose gear when full.
4. Put two different swords into separate weapon slots. Swap one for Axe and verify the other retains its roll. Put Frost, Staff, Wand and Firestorm in any weapon slot, fire each, and verify their in-hand art, projectile or effect, and Mana1/Mana2 consumption. Frozen enemy kills should still award XP and Mana2.
5. Equip Chest, Helmet and Bracers. Compare repeated identical damage sources with and without armor. Check that original Hexen armor pickups do not cause both protection systems to apply simultaneously. Equip two rings: max HP rises by 10. Remove one: max HP falls by 5 and current HP clamps if necessary.
6. Save and load with a partly full bag, two rings, armor and mixed weapons. Switch weapons, move through a Hexen hub portal and back, save again, then die and reload. Verify no missing or duplicated items and exact weapon damage rolls. This requires interactive in-game verification.
7. Start separate Fighter and Mage games. Their original weapons, health, movement and input should remain intact. ALT retains the original strafe binding unless manually remapped.

The temporary original sprites and exact replacement list are in [`asset-catalog.md`](asset-catalog.md). The original `HEXEN.WAD` is needed at runtime and is never part of this repository.
