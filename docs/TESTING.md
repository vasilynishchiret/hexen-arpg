# HEXEN-ARPG v0.5: manual verification in UZDoom 5.0.3

Run `powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tools\launch.ps1` and start a **new** Cleric game. Script loading can be checked from the terminal with `& 'C:\Games\UZDoom\uzdoom.exe' -iwad 'C:\Games\UZDoom\HEXEN.WAD' -file '.\mod' -noautoload -nosound -stdout +quit`; `script parsing took ...` without `Script error` proves compilation only. `+quit` may still leave a graphics window in this environment.

1. Verify 50/50 HP, level 1, Mace/Sword/Lightning in slots 1/2/3. Kill an Ettin: +10 XP and +5 Mana2. Check Mana1 regeneration and weapon attacks as in the previous playable backup.
2. Run each console command: `summon ARPGTestSword`, `ARPGTestAxe`, `ARPGTestHammer`, `ARPGTestMace`, `ARPGTestLightning`, `ARPGTestFrost`, `ARPGTestStaff`, `ARPGTestWand`, `ARPGTestFirestorm`, `ARPGTestChest`, `ARPGTestHelmet`, `ARPGTestBracers`, `ARPGTestRing`. Also try `summon ARPGGroundWeapon` for a random item. Every type should have its own ground image.
3. Aim at a drop within 96 units and press E. It should enter a free bag slot. Open with ALT. Click a bag item: it should highlight and show its stats. Hover for the target-slot comparison, double-click or right-click to equip. Click empty background to clear selection. Check that the mouse no longer moves the camera. Use WASD/arrows to move between bag and equipment, Enter to equip or remove, P to drop, Esc/ALT to close. Check that movement, attack, jump and run controls do not act while the menu is open, and all controls return when it closes. With a full 20-slot bag, E must leave a new item on the ground and removing equipment must fail without loss.
4. Put two different swords into separate weapon slots. Swap one for Axe and verify the other retains its roll. Put Frost, Staff, Wand and Firestorm in any weapon slot, fire each, and verify their in-hand art, projectile or effect, and Mana1/Mana2 consumption. Frozen enemy kills should still award XP and Mana2.
5. Equip Chest, Helmet and Bracers. Compare repeated identical damage sources with and without armor. Check that original Hexen armor pickups do not cause both protection systems to apply simultaneously. Equip two rings: max HP rises by 10. Remove one: max HP falls by 5 and current HP clamps if necessary.
6. Save and load with a partly full bag, two rings, armor and mixed weapons. Switch weapons, move through a Hexen hub portal and back, save again, then die and reload. Verify no missing or duplicated items and exact weapon damage rolls. This requires interactive in-game verification.
7. Start separate Fighter and Mage games. Their original weapons, health and movement should remain intact. The inventory menu is for Cleric; I holds strafe for all classes.

The temporary original sprites and exact replacement list are in [`asset-catalog.md`](asset-catalog.md). The original `HEXEN.WAD` is needed at runtime and is never part of this repository.

## v0.4 focused checks

1. Open inventory with ALT; keep ALT held for a second (it must stay open). Release and press ALT again to close; repeat. Open and close with ESC, then move with WASD and look with the mouse. Open the standard ESC menu and verify its red back button still works. The ARPG inventory should have no red back button. Retest single/right/double clicks, arrows, Enter and P drop.
2. Select slot 3 Lightning. In Ready, the hands should cycle A/B/C. During one attack, watch D/E/F/G/H/I and the C/B return. The lower edge should be visible at the normal resting position. One attack spends 25 Mana2 (formerly 5); with less than 25, it must not create arcs. Hold fire and verify each arc costs 25 once. Re-equip an old saved Lightning item and repeat.
3. Spawn an Ettin in open space. At about 88 map units of melee reach it should begin a 12-tic windup and hit only on G. Side-step outside its 70-degree front sector or retreat before G to avoid damage. Put a wall between player and Ettin to verify no damage through it. Compare damage with the old 2–16 range. Check XP +10, Mana2 +5, inventory slots and save/load once more.

## v0.5 stage A: mobility

Use `summon ARPGTestSprintBoots`, `summon ARPGTestDashBoots`, `summon ARPGTestJumpBoots` and `summon ARPGTestBoots`. Pick up with E and equip from the new ninth slot. Before equipping, Shift must never increase walking speed. Sprint boots: hold Shift while moving and verify about 50% faster movement, 2 Mana1 per second, and no passive Mana1 regeneration. Dash boots: tap Shift for less than 200 ms and release to dash; hold longer to verify no dash. Jump boots: press Space a second time in air, then try a third press and holding Space. Unequip and retry each ability. Repeat Shift tests with inventory open. Save/load equipped boots and verify their affixes remain. The temporary ground sprite is Hexen `SPED A` from the installed WAD.

## v0.5 stage B: defensive bracers

Use `summon ARPGTestBracers`, `summon ARPGTestShieldBracers`, and `summon ARPGTestGuardianBracers`. Ordinary bracers retain 3% protection; special bracers have their ability instead. Hold RMB (the game's configurable AltFire binding) with shield bracers: the blue screen frame indicates active protection. Compare incoming damage with and without the shield, check Mana1 falls by roughly one per two blocked HP, and confirm it ends on release, after two seconds, or when Mana1 empties. It cannot restart for eight seconds, including after swapping bracers. Guardian must ignore exactly one hit, then permit hits for 20 seconds. Save/load and swap bracers during cooldown.

## v0.5 stage C: tactical helmets

Use `summon ARPGTestInvisibilityHelmet`, `summon ARPGTestDetectionHelmet`, and `summon ARPGTestHelmet`. Invisibility is a configurable action, default **F** because UZDoom's existing R reload binding prevented a non-destructive R default. Rebind the action to R in Controls if desired. On activation, the native Shadow effect lasts three seconds and current monster pursuit targets clear; movement and attack remain available. Replacing the helmet ends invisibility. Cooldown is 25 seconds after effect end. Detection defaults to **V**, lasts five seconds, and lists up to eight nearest hostile monsters within 640 units as angles and distances, including those behind walls. Cooldown is 20 seconds after effect end. Replacing the helmet ends detection. Test both with enemies behind walls and verify cooldown survives helmet swaps and save/load.

## v0.5 stage D: passive rings

Use `summon ARPGTestGreenRing`, `summon ARPGTestVampRing`, and `summon ARPGTestAuraRing`; equip in Ring 1 and Ring 2, singly and in pairs. Green regeneration grants one Mana2 per ring every 12 seconds, up to native maximum. Vampirism test ring heals 5% of actual monster HP damage; two such rings cap at 10%, and HP never exceeds maximum. Check overkill on a nearly dead Ettin and repeated small hits. Aura deals two damage per second per ring within 96 units, with sight check; verify it does not affect allies or players. An aura kill must still award XP and five Mana2. Remove each ring and verify its effect stops immediately, then save/load both ring slots.

## v0.5 stage E: quantitative armor and UI

Use `summon ARPGTestChest` repeatedly. Each new Chest Armor has one to four distinct bonuses chosen from HP, damage reduction, Mana1 maximum, Mana2 maximum, and Mana1 regeneration. Equip and swap two chests, then remove them; maximum health and mana should reflect only the equipped chest, with no accumulated bonus. Check the 45% total protection cap alongside Helmet and ordinary Bracers. Hover each test item on the ground and in the bag, then select each equipment slot: name, category, stats, abilities, activation, mana, duration and cooldown should be legible. Check the lower-right HUD cooldowns and compare cooldown before and after swapping items. Save/load with every category equipped and recheck all three weapon slots, XP and Mana1/Mana2. `summon ARPGTestSword`, `ARPGTestLightning`, `ARPGTestBoots`, `ARPGTestShieldBracers`, `ARPGTestDetectionHelmet`, and `ARPGTestVampRing` provide a compact regression set.

## Original magic animations and custom maps

Launch a new Cleric game and use `summon ARPGTestStaff`, `summon ARPGTestFirestorm`, `summon ARPGTestFrost`, `summon ARPGTestWand`, and `summon ARPGTestLightning` to equip each type. Compare each weapon's raise, idle, fire, recovery and lower positions against an unmodded Hexen Cleric or Mage game at the same aspect ratio. Firestorm idle A/B/C should each hold about 0.34 seconds; press fire during each pose and check that the shot still begins immediately and costs the same Mana2. Watch the Staff's C/B/A idle and occasional B/C blink, its J fire and lowered recovery. Check Frost's B–G, Wand's A/B and Lightning's A–I frames for jumps, clipping and missing lower edges. Hold attack and compare fire rates and mana use to the previous version. Switch back to Sword, Axe and Hammer to confirm their animations are unchanged. Test inventory, equipment, affixes, XP and loot after the switch.

For an external compatible archive, follow [`custom-maps.md`](custom-maps.md), use `-StartMap` to load its first map, choose Cleric for a new game, and save under a map-specific name. Confirm the intended map appears in the UZDoom startup log. The launcher should also work with no `-MapWad`.

## v0.6 map loot conversion

Start a new Cleric game with `arpg_convert_map_loot 1`. On MAP01, inspect a placed original armor item; `netevent arpg_maploot_status` should count converted items. Use `summon MeshArmor`, `summon ArtiBoostArmor`, `summon FWeapAxe`, and `summon MWeapLightning` to force each replacement pool. Pick each up with E and verify its rolled stats and affixes in the inventory. Save/load, return through a hub portal, and ensure no duplicate item appears. Check MAP06 armor with TID 21 and MAP21 armor with special 80 for map-script behavior. Verify keys, puzzle items and weapon pieces are still present. Turn `arpg_convert_map_loot 0` before starting a Fighter or Mage map and confirm native pickups remain. Repeat on one compatible external WAD. See [`map-conversion.md`](map-conversion.md) for class mapping and exclusions.

## v0.6 reinforcements


Start a Cleric game with `arpg_reinforcements 1`. After the first minute, inspect `netevent arpg_reinforce_status`: attempts should be scheduled every 30–60 seconds. On a wide, visible room use `netevent arpg_reinforce_test` several times; no more than six additional enemies may be alive, and the per-map total stops at 12. On a long sample of successful spawns, about 40% should be FireDemon/Afrit with the original teleport smoke. Test near walls, doors, other actors, narrow rooms and low ceilings; unsuccessful attempts must not put enemies in geometry. Kill a reinforcement and check XP, +5 Mana2 and ordinary loot. Save/load and revisit the hub map; totals must persist. With inventory or pause menu open, no new attempts should occur. Check that map ACS events and the original kill counter remain unaffected. Turn `arpg_reinforcements 0` to disable only the ARPG arrivals, then test Fighter/Mage. See [`reinforcements.md`](reinforcements.md).

## v0.7 teleport FX and mana

Launch through `tools/launch.ps1`, enter a Cleric game, and check that wheel up/down moves the selected consumable, Mouse3 uses it, and 1/2/3 still select the three weapon slots. The middle button previously carried `+zoom` in the dedicated profile; the launch binding replaces only that key. Open ARPG inventory with Alt: wheel changes its selection, middle click does not use an item, and Escape closes it. Open the ordinary Escape menu and check normal wheel behavior. Brackets remain as optional native inventory selection keys.

In a wide room run `netevent arpg_reinforce_test` until a reinforcement appears. Watch the animated smoke disappear within five seconds while the monster remains active, then try another spawn. Save and load during smoke. Test `summon ARPGTestAxe100` and `summon ARPGTestAxe200`: the inventory should show 5 and 16 Mana1; compare actual Mana1 before and after one hit. `summon ARPGTestStaff`, `summon ARPGTestWand`, `summon ARPGTestLightning`, and `summon ARPGTestFirestorm` show 8/1 Mana1 and 25/8 Mana2 at 100% potency. Hold attack, check each cycle is charged once, verify attack stops when mana is insufficient, and compare inventory and ground tooltip. Repeat after save/load and with exceptional rolled items. See [`mana-economy.md`](mana-economy.md).

## Equipment gems v0.8

See [gems.md](gems.md) for pickup, stack, upgrade, drop, save/load and HUD checks. Run `netevent arpg_gems_test` and `summon ARPGTestUpgradedAxe` for the 100-upgrade cap. Check Firestorm at 8 Mana2 and Lightning at 25 Mana2 in both normal and fullscreen HUD modes.

Before release, follow the [MAP01 gem conversion regression](gem-respawn-regression.md), including the save/load, hub, Fighter/Mage and custom WAD checks.
