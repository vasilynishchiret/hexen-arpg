# Standalone dependency and replacement map

The first independent prototype is packaged from `mod/standalone/` and an
explicit list of original `mod/assets/` images. It does not load the original
Hexen mod, its maps, or a commercial IWAD. `Connected` below applies only to
the prototype. The full Hexen-ARPG game still runs separately and retains all
of its Hexen dependencies. Descriptive `arpg_*.png` filenames are mapped to
four-character runtime sprite names by `mod/standalone/TEXTURES`. See the
[naming convention](naming-convention.md) and
[existing asset catalog](../asset-catalog.md).
The two complete technical frame sets are in [animations.md](animations.md)
and [animation-frames.csv](animation-frames.csv).

## First boot: connected prototype resources

| Standalone source | Runtime use | Replaces for prototype | Status |
| --- | --- | --- | --- |
| `sprites/weapons/arpg_wp_cleric_sword_idle_a.png` | `ARWPA0`, independent `ARPGStandaloneWeapon` idle frame | Hexen weapon graphics | Connected; placeholder |
| `sprites/weapons/arpg_wp_cleric_sword_attack_a.png` | `ARWPB0`, attack frame | Hexen attack graphics | Connected; placeholder |
| `sprites/items/arpg_it_chest_common_a.png` | `ARPLA0`, independent player world sprite | Hexen player sprites | Connected; temporary placeholder |
| `sprites/items/arpg_it_ring_common_a.png` | `ARITA0`, prototype token pickup | Hexen item sprites | Connected; placeholder |
| `effects/arpg_fx_melee_hit_a.png` | `ARFXA0`, melee impact puff | Hexen impact sprite | Connected; placeholder |
| `textures/arpg_tx_wall_a.png` | `ARWALL1`, four room walls | Hexen walls | Connected; placeholder |
| `textures/arpg_tx_floor_a.png` | `ARFLOOR`, room floor | Hexen flats | Connected; placeholder |
| `textures/arpg_tx_ceiling_a.png` | `ARCEIL`, ceiling and `BRDR_*` screen border | Hexen flats and border | Connected; placeholder |
| `mod/standalone/maps/MAP01.wad` | Original one-room UDMF map, editable in UDB | Hexen maps | Connected; prototype |
| `mod/standalone/zscript/prototype.zs` | Independent player, weapon, attack, pickup, minimal HP HUD | Hexen actors and status bar | Connected; prototype |
| Generated `PLAYPAL`, `COLORMAP` | Original RGB332 palette and identity colour map | IWAD palette and colour map | Connected; generated |

The package uses the UZDoom engine's built-in `ConsoleFont` for HUD text; that
font is **not copied into this repository or IPK3**. There are no sound or music
files. The prototype uses the engine's Doom-family game configuration in
`IWADINFO` as a technical base, but does not include or request `DOOM.WAD`.

## Prepared files

The new axe and Ettin planning sets contain 117 original geometric PNGs with
one-to-one technical canvas, offset and frame mapping. They are included in
the standalone IPK3 under new runtime identifiers `ARXA`, `ARET` and `AREB`,
but no prototype actor selects them yet. The private Hexen reference PNGs are
outside this repository and outside every build. See
[animations.md](animations.md) for the complete mapping and timing data.

Paths below are relative to `mod/assets/`. The source generator is
`tools/generate-standalone-placeholders.ps1`. Each image is original geometry,
not extracted or traced Hexen artwork. A single `a` frame is a planning sample,
**not** a complete animation or drop-in replacement.

| Standalone file | Purpose and intended use | Current dependency to replace | Status |
| --- | --- | --- | --- |
| `sprites/weapons/arpg_wp_cleric_sword_idle_a.png` | Cleric sword view, idle; future `equipped.zs` state mapping | `ARAX` sword state, including `FAXE` source frames in `TEXTURES` | Connected to prototype; not to full ARPG |
| `sprites/weapons/arpg_wp_cleric_sword_attack_a.png` | Cleric sword view, first attack pose | `ARAX` attack sequence and `FAXEN0` source frame | Connected to prototype; not to full ARPG |
| `sprites/weapons/arpg_wp_cleric_mace_idle_a.png` | Cleric mace view | `CMCE` frames in `equipped.zs` | Prepared; not connected |
| `sprites/weapons/arpg_wp_cleric_staff_idle_a.png` | Cleric staff view | `CSSF` frames in `equipped.zs` | Prepared; not connected |
| `sprites/weapons/arpg_wp_cleric_firestorm_idle_a.png` | Cleric fire weapon view | `CFLM` frames in `equipped.zs` | Prepared; not connected |
| `sprites/items/arpg_it_sword_common_a.png` | Sword ground and inventory icon | Current `ARAW` original project sprite, `ground_weapon.zs` | Prepared; not connected; optional replacement |
| `sprites/items/arpg_it_chest_common_a.png` | Armor chest ground and inventory icon | `AR_1` / `ARM1A0` in `ground_weapon.zs` | Used temporarily as prototype player sprite; not connected to full ARPG |
| `sprites/items/arpg_it_ring_common_a.png` | Ring ground and inventory icon | Current `ARRG` original project sprite, `ground_weapon.zs` | Connected as prototype token; not to full ARPG |
| `sprites/gems/arpg_gem_blue_a.png` | Blue upgrade stone, world and bag | `MAN1` animation in `gems.zs`; `MAN1I0` in `hud/inventory.zs` | Prepared; not connected |
| `sprites/gems/arpg_gem_green_a.png` | Green upgrade stone, world and bag | `MAN2` animation in `gems.zs`; `MAN2G0` in `hud/inventory.zs` | Prepared; not connected |
| `sprites/gems/arpg_gem_combined_a.png` | Combined pickup containing both gem types | `MAN3` animation in `gems.zs` | Prepared; not connected |
| `ui/arpg_ui_inventory_bg.png` | Inventory panel background | Current `ARPGInventoryHud` uses drawn text and built-in menu APIs; no image background | Prepared; not connected; new optional presentation |
| `ui/arpg_ui_slot_empty.png` | Empty equipment/bag slot | Current text-only slot display in `hud/inventory.zs` | Prepared; not connected; new optional presentation |
| `effects/arpg_fx_lightning_hit_a.png` | Lightning impact | `LightningFloor` / `LightningCeiling` and their Hexen `MLFX` / `MLF2` art | Prepared; not connected; projectile classes still needed |
| `effects/arpg_fx_melee_hit_a.png` | Melee impact | `AxePuffGlow`, `HammerPuff`, `ARPGSwordPuff`, with `FAXE` / `FHFX` art | Connected to prototype; full ARPG effect classes still needed |

## Remaining Hexen dependencies by system

| System | Current names and locations | Standalone work remaining |
| --- | --- | --- |
| Game bootstrap and classes | `MAPINFO` selects `FighterPlayer`, `ARPGCleric`, `MagePlayer`; `ARPGCleric : ClericPlayer` in `player/arpg_cleric.zs` | Define original player classes, starts, menu/episode, and game data without Hexen classes. Fighter and Mage currently remain native Hexen classes. |
| Monsters and AI | `ARPGEttin : Ettin` (`ettin.zs`); reinforcement children of `FireDemon`, `Centaur`, `Demon1`, `TeleSmoke` (`systems/reinforcements.zs`); `kill_rewards.zs` checks `Ettin` | Original enemies, animations, sounds, attacks, and encounter/map population. All original Hexen map monsters also need replacement. |
| Weapon class inheritance | `ARPGEquippedWeapon`, `ARPGMace`, `ARPGSword` inherit `CWeapMace`; `ARPGLightning` inherits `MWeapLightning` (`weapons/*.zs`) | Independent bases and complete weapon states; preserve behavior only after dedicated tests. |
| Weapon view art | `ARAX` virtual sword; `FAXE`, `FHMR`, `CMCE`, `MLNG`, `CONE`, `CSSF`, `MWND`, `CFLM` in `weapons/equipped.zs` | Complete animations, runtime names, offsets, and all missing weapon variants. Five Cleric planning frames are prepared. |
| Weapon projectiles and sounds | `AxePuffGlow`, `HammerPuff`, `LightningFloor`, `LightningCeiling`, `FrostMissile`, `CStaffMissile`, `MageWandMissile`, `CFlameMissile`; sounds `MageLightningFire`, `MageShardsFire`, `ClericCStaffFire`, `ClericFlameFire`, `MageLightningReady` in `weapons/equipped.zs` | Original projectiles, effects, sound files, and `SNDINFO` mappings. Two impact planning frames are prepared. Inherited classes may also play additional sounds. |
| Ground loot and items | `ground_weapon.zs` uses `WFAX`, `WFHM`, `CMCE`, `WMLG`, `WMCS`, `WCSS`, `MWND`, `WCFM`, `AR_1`, `AR_3`, `BRAC`, `SPED`; `ARAW` and `ARRG` are project-authored | Original icons and sprites for every weapon, chest, helmet, bracers, boots; current project art can be retained or replaced. Three item planning icons are prepared. |
| Armor and map pickup types | `armor_effect.zs` reads `HexenArmor`; `map_conversion.zs` checks `MeshArmor`, `FalconShield`, `PlatinumHelm`, `AmuletOfWarding`, `ArtiBoostArmor`, `FWeapAxe`, `FWeapHammer`, `CWeapStaff`, `CWeapFlame`, `MWeapFrost`, `MWeapLightning` | Standalone armor system and map placement rules; the conversion handler is specific to Hexen maps and will need a standalone policy. |
| Mana and gems | `ARPGCleric`, regeneration, rings and equipped weapons use `Mana1`, `Mana2`; `gems.zs` detects `Mana1`, `Mana2`, `Mana3` world actors and shows `MAN1`, `MAN2`, `MAN3` | Original ammo/pickup actor classes and full gem animations, preserving both mana channels and combined pickup behavior. Three planning icons are prepared. |
| HUD / UI | Built-in Hexen status bar selected implicitly (no `StatusBarClass` override); `ARPGHud` and `ARPGInventoryHud` are project-authored; `hud/inventory.zs` reads `MAN1I0` / `MAN2G0` | Original status bar, fonts, menus, cursor/slot art and gem icons. Two optional panel/slot placeholders are prepared. Do not copy engine status-bar code. |
| World sprites and textures | Original campaign maps, walls, floors, skies, doors, switches, decorations, keys, and actor sprites are supplied by `HEXEN.WAD`; active `TEXTURES` still references `FAXEB0`, `FAXEC0`, `FAXED0`, `FAXEE0`, `FAXEN0` | Original maps and full environment art, actors, textures, palettes as needed, with independent map and resource names. `mod/assets/textures/` is reserved; ignored local sky drafts are unreviewed. |
| Audio and music | Hexen IWAD and engine definitions supply weapon, monster, world, UI sounds and campaign music. There are no project audio files or `SNDINFO`/music mappings | Compose/record/license all sounds and music, then add original logical names and mappings. `mod/assets/sounds/` and `music/` are reserved. |
| Campaign and launcher | `Play.bat` / `tools/launch.ps1` require a lawful `HEXEN.WAD`; current map names, map scripts, TIDs and events belong to Hexen or compatible WADs | Independent IWAD/game package, launch path, maps, scripts, startup assets, title/branding, plus clean save/profile migration plan. |

The original mod still uses `mod/TEXTURES`, `mod/MAPINFO`, and `mod/zscript.txt`.
The separate prototype uses `mod/standalone/TEXTURES`, `MAPINFO`, and
`zscript.txt`. No original-mod references were redirected. Hexen art is **not**
copied into `mod/assets/`.

## Connection gate

For each replacement, create all required frames and sounds, review rights,
map the source filenames to distinct runtime identifiers, replace the exact
ZScript/MAPINFO references, and test startup, three classes, save/load, map
transition, HUD, inventory, and combat. A commercial standalone requires all
rows above to be resolved, not only the visual placeholders. Keep the current
alpha package and published tag unchanged during this work.
