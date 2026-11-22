# Asset catalog: HEXEN-ARPG v0.5

This catalog was checked against UZDoom 5.0.3's bundled ZScript and the user's local `HEXEN.WAD` (SHA-256 `F74B857076B3FFE2597D0E05BDECC687496E6A9582D7A47DB681E0E78E4001`). The WAD and UZDoom assets are **dependencies**, not files in this repository. All original frames below should be extracted by the user from their own copy in SLADE when making replacement art. No commercial image is copied into Git.

The `Sprite` names in ZScript are four-letter prefixes plus frame letters; the physical WAD lumps add rotation, usually `0`. For example `CONE F` means `CONEF0`. The exact source lumps, sizes, and offsets are listed in the appendix. Multi-rotation lumps such as `SHRDA2A8` are one physical lump used for two angles. `AR_1` and `AR_3` are engine sprite aliases for physical WAD lumps `ARM1A0` and `ARM3A0`.

| Item | Original class | ARPG class / kind | In-hand frames | Ground frames | Projectiles / impacts | Existing icon | Replacement and usage |
| --- | --- | --- | --- | --- | --- | --- | --- |
| Mace | `CWeapMace` | `ARPGEquippedWeapon`, 3 | `CMCEA0`–`CMCEF0` | `CMCEA0` (ARPG fallback) | `FHFXS0`–`FHFXW0` via `HammerPuff` | No separate original weapon icon | `mod/zscript/weapons/equipped.zs`; ground `mod/zscript/loot/ground_weapon.zs` |
| Sword | Original frame basis `FWeapAxe`; independent ARPG attack | `ARPGEquippedWeapon`, 0 | `ARAXA0`, `ARAXL0`–`ARAXQ0`; original source frames `FAXEB0`–`FAXEE0`, `FAXEN0` | `ARAWA0` | `FAXER0`–`FAXEX0` via `ARPGSwordPuff` / `AxePuffGlow` | No separate original icon | `mod/patches/arpg_sword/*.png` mapped in `mod/TEXTURES`; code `equipped.zs`, `ground_weapon.zs` |
| Axe | `FWeapAxe` | `ARPGEquippedWeapon`, 1 | `FAXEA0`, `FAXEL0`, `FAXEN0`–`FAXEQ0` | `WFAXA0` | `FAXER0`–`FAXEX0` (`AxePuffGlow`) | No separate original icon | `equipped.zs`, `ground_weapon.zs` |
| Hammer | `FWeapHammer` | `ARPGEquippedWeapon`, 2 | `FHMRA0`–`FHMRE0` | `WFHMA0` | `FHFXS0`–`FHFXW0` (`HammerPuff`); original thrown attack also has `FHFXA*`–`FHFXR0`, **not used** by ARPG melee | No separate original icon | `equipped.zs`, `ground_weapon.zs` |
| Lightning / Arc of Death | `MWeapLightning` | `ARPGEquippedWeapon`, 4 | `MLNGA0`–`MLNGI0` | `WMLGA0`–`WMLGH0` (ARPG uses A) | `MLFXA0`–`MLFXU0`, `MLF2A0`–`MLF2Q0` | No separate original icon | `equipped.zs`, `ground_weapon.zs` |
| Frost Shards | `MWeapFrost` | `ARPGEquippedWeapon`, 5 | `CONEA0`–`CONEG0` | `WMCSA0`–`WMCSC0` (ARPG uses A) | `SHRDA*`–`SHRDC*`, `SHEXA0`–`SHEXE0` | No separate original icon | `equipped.zs`, `ground_weapon.zs` |
| Serpent Staff | `CWeapStaff` | `ARPGEquippedWeapon`, 6 | `CSSFA0`–`CSSFK0` | `WCSSA0` | `CSSFD0`–`CSSFI0`; `FHFXS0`–`FHFXW0` (`CStaffPuff`) | No separate original icon | `equipped.zs`, `ground_weapon.zs` |
| Sapphire Wand | `MWeapWand` | `ARPGEquippedWeapon`, 7 | `MWNDA0`–`MWNDB0` | No original ground state; ARPG uses `MWNDA0` temporarily | `MWNDC0`–`MWNDI0` (`MageWandMissile`, smoke, explosion) | No separate original icon | `equipped.zs`, `ground_weapon.zs` |
| Firestorm | `CWeapFlame` | `ARPGEquippedWeapon`, 8 | `CFLMA0`–`CFLMG0` | `WCFMA0`–`WCFMH0` (ARPG uses A) | `CFFXA0`–`CFFXP*`, `CFCFA0`–`CFCFZ0` | No separate original icon | `equipped.zs`, `ground_weapon.zs` |
| Chest Armor | `MeshArmor` | `ARPGGroundWeapon` / ARPG armor slot, 10 | None | `ARM1A0` via `AR_1 A` | None | No separate original icon | `ground_weapon.zs`, `hud/inventory.zs`, `loot/armor_effect.zs` |
| Helmet | `PlatinumHelm` | `ARPGGroundWeapon` / ARPG armor slot, 11 | None | `ARM3A0` via `AR_3 A` | None | No separate original icon | Same as Chest Armor |
| Bracers | `ArtiBoostArmor` (Dragonskin Bracers) | `ARPGGroundWeapon` / ARPG armor slot, 12 | None | `BRACA0`–`BRACH0` (ARPG uses A) | None | `ARTIBRAC` | `ground_weapon.zs`, `hud/inventory.zs`, `loot/armor_effect.zs` |
| Ring | No original Hexen ring | `ARPGGroundWeapon` / ARPG ring slots, 13 | None | Custom `ARRGA0` | None | No original icon; custom `ARRGA0` | `mod/patches/arpg_ring/ARRGA0.png`, `mod/TEXTURES`, `tools/generate-ring-icon.ps1` |

The inventory shows small versions of each item's ground sprite or the Bracers icon. Item types have distinct on-ground states. The original Hexen images are displayed at runtime from the player's WAD; they are not shipped here.

## Original weapon animation mapping (UZDoom 5.0.3)

Compared with the `zscript/actors/hexen/*.zs` files inside the installed `uzdoom.pk3`. Frame names refer to unchanged sprites in the player's `HEXEN.WAD`; the ARPG code only chooses weapon states and `Weapon.YAdjust`.

| Weapon | Select / Deselect | Ready | Fire / Hold and recovery | Original and ARPG YAdjust |
| --- | --- | --- | --- | --- |
| Serpent Staff (`clericstaff.zs`) | `CSSF C` raise; `B` 3, `C` 4, then lower | `C` 4, `B` 3, `A` 8-tic loop with intermittent `BBBCCCCCBBB` blink | `A` 1, `J` 1+2+2, `A` 2+2; original offset path `(0,45)→(0,50)→(0,45)→(0,40)→(0,36)` | `10 / 10` (ARPG previously `-8`) |
| Firestorm (`clericflame.zs`) | `CFLM A` raise/lower | Original `AAAA BBBB CCCC` at 1 tic each; ARPG `A×12 B×12 C×12`, invoking `A_WeaponReady` every tic | `A` 2, `D` 2+2 at Y 50/36, `E` 4, `F` 4, `E` 4, `G` 2+2 at Y 40/default. The 22-tic attack cycle and shot timing are unchanged. | `10 / 10` (previously `-8`) |
| Frost Shards (`magecone.zs`) | `CONE A` raise/lower | `A` 1 loop | `B` 3, `C` 4; Hold `D` 3, `E` 5, `F` 3, `G` 3, `A` 9+1. The original final refire frame lasts 10; ARPG retains 1 to preserve its existing 31-tic attack cadence. | `20 / 20` (previously `-8`) |
| Sapphire Wand (`magewand.zs`) | `MWND A` raise/lower | `A` 1 loop | `A` 6, `B` 6 at `(0,48)`, `A` 3 at `(0,40)`, `A` 3 at `(0,36)` | `9 / 9` (previously `-8`) |
| Arc of Death (`magelightning.zs`) | `MLNG A` raise/lower | `A×6 B×6 C×6 B×6`, with original occasional ready sound | `D` 3, `E` 3, `F` 4, `G` 4, `H` 3, `I` 3+6, `C` 2, `B` 2+2+2. Original recovery offsets retained. | `20 / 20` |

The Staff's original close-range draining `Drain` branch is deliberately absent from the ARPG projectile attack. The original Frost ten-tic recovery is likewise not copied because both change established gameplay timing. No PNG, virtual `TEXTURES` offset, sprite dimensions, projectile behavior, mana cost, or damage was changed in this animation pass.

## Own PNG and TEXTURES mappings

| PNG | Virtual sprite | Dimensions | Offset | Used by |
| --- | --- | --- | --- | --- |
| `mod/patches/arpg_sword/FBLADEA0.png` | `ARAXA0` | 94×69 | −186, −111 | Sword ready |
| `mod/patches/arpg_sword/glow_l.png` | `ARAXL0` | 102×73 | −182, −107 | Sword select/ready glow |
| `mod/patches/arpg_sword/glow_m.png` | `ARAXM0` | 102×73 | −182, −107 | Sword ready glow |
| `mod/patches/arpg_sword/FBLADEO0.png` | `ARAXO0` | 173×200 | −147, 29 | Sword attack |
| `mod/patches/arpg_sword/FBLADEP0.png` | `ARAXP0` | 194×159 | −96, −21 | Sword attack |
| `mod/patches/arpg_sword/FBLADEQ0.png` | `ARAXQ0` | 65×69 | −62, −111 | Sword attack recovery |
| `mod/patches/arpg_sword/WBLADEA0.png` | `ARAWA0` | 28×41 | 12, 37 | Sword ground and inventory |
| `mod/patches/arpg_ring/ARRGA0.png` | `ARRGA0` | 32×32 | 16, 24 | Ring ground and inventory |

Other `ARAX` virtual frames in `mod/TEXTURES` still reference original `FAXE` WAD frames: `ARAXB0` ← `FAXEB0` (66×188, offset −254,131), `ARAXC0` ← `FAXEC0` (169×200, −151,20), `ARAXD0` ← `FAXED0` (190×155, −100,−25), `ARAXE0` ← `FAXEE0` (57×65, −66,−115), `ARAXN0` ← `FAXEN0` (70×188, −250,134). Replace these with original PNG later to make the sword fully independent of original axe graphics.

## Physical WAD sprite appendix

The following entries are the **exact** lump names in the checked WAD. Dimensions and offsets are decoded from each Doom patch header; they are useful for matching alignment in replacement PNGs. This appendix intentionally contains metadata only.

| Lump | Width×height | Left, top offset |
| --- | --- | --- |
| `FAXEA0` | 94×69 | -186, -111 |
| `FAXEB0` | 66×188 | -254, 20 |
| `FAXEC0` | 169×200 | -151, 20 |
| `FAXED0` | 190×155 | -100, -25 |
| `FAXEE0` | 57×65 | -66, -115 |
| `FAXEF0` | 25×20 | 12, 10 |
| `FAXEG0` | 31×32 | 15, 16 |
| `FAXEH0` | 37×43 | 21, 23 |
| `FAXEI0` | 40×42 | 22, 22 |
| `FAXEJ0` | 35×39 | 19, 20 |
| `FAXEK0` | 28×17 | 14, 4 |
| `FAXEL0` | 102×73 | -182, -107 |
| `FAXEM0` | 102×73 | -182, -107 |
| `FAXEN0` | 70×188 | -250, 20 |
| `FAXEO0` | 173×200 | -147, 20 |
| `FAXEP0` | 194×159 | -96, -21 |
| `FAXEQ0` | 65×69 | -62, -111 |
| `FAXER0` | 30×35 | 16, 19 |
| `FAXES0` | 37×43 | 15, 21 |
| `FAXET0` | 50×43 | 25, 24 |
| `FAXEU0` | 57×46 | 26, 26 |
| `FAXEV0` | 48×53 | 26, 26 |
| `FAXEW0` | 46×49 | 21, 24 |
| `FAXEX0` | 44×50 | 21, 24 |
| `FHMRA0` | 130×96 | -167, -84 |
| `FHMRB0` | 67×188 | -253, 20 |
| `FHMRC0` | 170×191 | -150, 11 |
| `FHMRD0` | 125×119 | -87, -61 |
| `FHMRE0` | 84×60 | -62, -120 |
| `FHFXA1` | 15×28 | 8, 19 |
| `FHFXB1` | 16×33 | 7, 19 |
| `FHFXC1` | 14×45 | 5, 29 |
| `FHFXD1` | 15×36 | 6, 23 |
| `FHFXE1` | 14×28 | 6, 19 |
| `FHFXF1` | 17×38 | 9, 21 |
| `FHFXG1` | 16×49 | 8, 21 |
| `FHFXH1` | 14×31 | 6, 19 |
| `FHFXA8A2` | 33×33 | 16, 21 |
| `FHFXB8B2` | 37×29 | 18, 14 |
| `FHFXC8C2` | 38×38 | 15, 22 |
| `FHFXD8D2` | 31×34 | 13, 19 |
| `FHFXE8E2` | 32×37 | 11, 16 |
| `FHFXF8F2` | 34×30 | 11, 15 |
| `FHFXG8G2` | 38×38 | 20, 20 |
| `FHFXH8H2` | 30×35 | 14, 18 |
| `FHFXA7A3` | 43×41 | 24, 23 |
| `FHFXB7B3` | 44×35 | 23, 17 |
| `FHFXC7C3` | 41×38 | 17, 21 |
| `FHFXD7D3` | 34×41 | 16, 22 |
| `FHFXE7E3` | 43×41 | 16, 20 |
| `FHFXF7F3` | 41×34 | 18, 17 |
| `FHFXG7G3` | 41×39 | 22, 18 |
| `FHFXH7H3` | 34×41 | 15, 20 |
| `FHFXA6A4` | 32×37 | 18, 20 |
| `FHFXB6B4` | 33×34 | 17, 18 |
| `FHFXC6C4` | 39×37 | 15, 21 |
| `FHFXD6D4` | 36×36 | 13, 18 |
| `FHFXE6E4` | 31×34 | 11, 17 |
| `FHFXF6F4` | 35×34 | 13, 15 |
| `FHFXG6G4` | 42×38 | 21, 17 |
| `FHFXH6H4` | 32×32 | 16, 16 |
| `FHFXA5` | 15×32 | 7, 19 |
| `FHFXB5` | 15×33 | 6, 19 |
| `FHFXC5` | 14×44 | 6, 24 |
| `FHFXD5` | 13×41 | 5, 21 |
| `FHFXE5` | 15×39 | 6, 18 |
| `FHFXF5` | 15×30 | 6, 15 |
| `FHFXG5` | 14×45 | 5, 21 |
| `FHFXH5` | 17×36 | 7, 21 |
| `FHFXI0` | 39×33 | 22, 16 |
| `FHFXJ0` | 59×44 | 29, 23 |
| `FHFXK0` | 73×55 | 35, 26 |
| `FHFXL0` | 68×62 | 29, 30 |
| `FHFXM0` | 57×36 | 27, 20 |
| `FHFXN0` | 57×36 | 26, 21 |
| `FHFXO0` | 57×36 | 25, 23 |
| `FHFXP0` | 58×38 | 24, 25 |
| `FHFXQ0` | 46×34 | 21, 15 |
| `FHFXR0` | 24×22 | 13, 11 |
| `FHFXS0` | 14×14 | 6, 6 |
| `FHFXT0` | 20×20 | 10, 10 |
| `FHFXU0` | 34×28 | 16, 14 |
| `FHFXV0` | 40×30 | 18, 14 |
| `FHFXW0` | 40×34 | 18, 16 |
| `CMCEA0` | 78×98 | -166, -92 |
| `CMCEB0` | 79×193 | -241, 36 |
| `CMCEC0` | 131×200 | -189, 36 |
| `CMCED0` | 175×186 | -145, 22 |
| `CMCEE0` | 193×169 | -127, 5 |
| `CMCEF0` | 110×108 | -79, -56 |
| `CSSFA0` | 189×64 | -66, -100 |
| `CSSFB0` | 189×64 | -66, -100 |
| `CSSFC0` | 189×67 | -66, -97 |
| `CSSFJ0` | 189×70 | -66, -94 |
| `CSSFK0` | 187×89 | -67, -75 |
| `CSSFD0` | 15×16 | 8, 7 |
| `CSSFE0` | 18×18 | 9, 8 |
| `CSSFF0` | 29×29 | 14, 13 |
| `CSSFG0` | 35×31 | 18, 15 |
| `CSSFH0` | 46×39 | 22, 18 |
| `CSSFI0` | 53×46 | 26, 22 |
| `CFLMA0` | 227×55 | -42, -109 |
| `CFLMB0` | 228×55 | -40, -109 |
| `CFLMC0` | 225×56 | -42, -108 |
| `CFLMD0` | 239×83 | -28, -81 |
| `CFLME0` | 275×125 | 0, -39 |
| `CFLMF0` | 275×126 | 0, -38 |
| `CFLMG0` | 249×84 | -25, -80 |
| `CFFXA0` | 9×14 | 4, 4 |
| `CFFXB0` | 25×34 | 12, 16 |
| `CFFXC0` | 39×64 | 17, 41 |
| `CFFXD0` | 42×64 | 22, 43 |
| `CFFXE0` | 41×61 | 22, 39 |
| `CFFXF0` | 40×61 | 23, 39 |
| `CFFXG0` | 35×61 | 19, 39 |
| `CFFXH0` | 35×63 | 19, 41 |
| `CFFXI0` | 35×61 | 17, 37 |
| `CFFXJ0` | 38×58 | 15, 35 |
| `CFFXK0` | 42×41 | 21, 39 |
| `CFFXL0` | 41×25 | 21, 44 |
| `CFFXM0` | 27×19 | 17, 52 |
| `CFCFA0` | 18×36 | 6, 33 |
| `CFCFB0` | 18×38 | 7, 35 |
| `CFCFC0` | 19×32 | 7, 29 |
| `CFCFD0` | 18×35 | 7, 32 |
| `CFCFE0` | 17×34 | 6, 31 |
| `CFCFF0` | 16×29 | 6, 26 |
| `CFCFG0` | 17×29 | 7, 26 |
| `CFCFH0` | 17×32 | 7, 29 |
| `CFCFI0` | 17×35 | 7, 32 |
| `CFCFJ0` | 18×38 | 7, 35 |
| `CFCFK0` | 18×31 | 7, 28 |
| `CFCFL0` | 19×33 | 7, 30 |
| `CFCFM0` | 19×34 | 7, 31 |
| `CFCFN0` | 24×19 | 11, 19 |
| `CFCFO0` | 23×14 | 11, 23 |
| `CFCFP0` | 17×11 | 7, 29 |
| `CFFXN1` | 10×20 | 5, 10 |
| `CFFXN2N8` | 25×14 | 11, 6 |
| `CFFXN3N7` | 32×13 | 16, 5 |
| `CFFXN4N6` | 25×16 | 12, 6 |
| `CFFXN5` | 11×23 | 4, 10 |
| `CFFXO1` | 7×13 | 4, 7 |
| `CFFXO2O8` | 14×12 | 7, 6 |
| `CFFXO3O7` | 21×12 | 10, 6 |
| `CFFXO4O6` | 18×13 | 8, 7 |
| `CFFXO5` | 10×16 | 4, 8 |
| `CFFXP1` | 6×9 | 3, 5 |
| `CFFXP2P8` | 11×8 | 7, 4 |
| `CFFXP3P7` | 14×8 | 7, 4 |
| `CFFXP4P6` | 13×9 | 6, 4 |
| `CFFXP5` | 8×11 | 4, 5 |
| `CFCFQ0` | 27×19 | 12, 20 |
| `CFCFR0` | 37×34 | 17, 32 |
| `CFCFS0` | 39×44 | 18, 41 |
| `CFCFT0` | 44×51 | 19, 48 |
| `CFCFU0` | 42×49 | 20, 50 |
| `CFCFV0` | 46×43 | 22, 43 |
| `CFCFW0` | 40×45 | 21, 48 |
| `CFCFX0` | 36×37 | 20, 45 |
| `CFCFY0` | 39×34 | 19, 46 |
| `CFCFZ0` | 12×13 | 16, 34 |
| `MWNDA0` | 72×52 | -125, -112 |
| `MWNDB0` | 93×64 | -115, -100 |
| `MWNDC0` | 7×7 | 3, 3 |
| `MWNDD0` | 7×7 | 3, 3 |
| `MWNDE0` | 15×15 | 7, 7 |
| `MWNDF0` | 24×24 | 12, 12 |
| `MWNDG0` | 43×42 | 21, 20 |
| `MWNDH0` | 41×38 | 20, 18 |
| `MWNDI0` | 50×41 | 25, 19 |
| `CONEA0` | 228×37 | -50, -113 |
| `CONEB0` | 218×65 | -42, -85 |
| `CONEC0` | 101×100 | -160, -50 |
| `CONED0` | 101×100 | -161, -50 |
| `CONEE0` | 110×102 | -156, -48 |
| `CONEF0` | 96×97 | -163, -53 |
| `CONEG0` | 231×55 | -37, -95 |
| `SHRDA1` | 5×10 | 3, 5 |
| `SHRDA2A8` | 26×4 | 12, 3 |
| `SHRDA3A7` | 34×3 | 17, 2 |
| `SHRDA4A6` | 22×5 | 11, 4 |
| `SHRDA5` | 9×10 | 5, 6 |
| `SHRDB1` | 5×10 | 3, 5 |
| `SHRDB2B8` | 27×4 | 13, 3 |
| `SHRDB3B7` | 33×3 | 17, 2 |
| `SHRDB4B6` | 26×6 | 12, 4 |
| `SHRDB5` | 9×10 | 4, 5 |
| `SHRDC1` | 5×10 | 3, 5 |
| `SHRDC2C8` | 27×4 | 14, 3 |
| `SHRDC3C7` | 33×3 | 16, 2 |
| `SHRDC4C6` | 28×6 | 13, 4 |
| `SHRDC5` | 10×11 | 6, 5 |
| `SHEXA0` | 26×23 | 12, 13 |
| `SHEXB0` | 33×29 | 17, 16 |
| `SHEXC0` | 42×33 | 20, 20 |
| `SHEXD0` | 43×42 | 19, 24 |
| `SHEXE0` | 47×37 | 20, 20 |
| `MLNGA0` | 151×58 | -86, -106 |
| `MLNGB0` | 157×65 | -88, -99 |
| `MLNGC0` | 142×68 | -97, -96 |
| `MLNGD0` | 131×62 | -95, -102 |
| `MLNGE0` | 229×80 | -22, -84 |
| `MLNGF0` | 246×113 | -29, -51 |
| `MLNGG0` | 320×115 | 0, -49 |
| `MLNGH0` | 320×85 | 0, -79 |
| `MLNGI0` | 320×57 | 0, -107 |
| `MLFXA0` | 61×58 | 31, 48 |
| `MLFXB0` | 45×55 | 24, 49 |
| `MLFXC0` | 48×53 | 24, 47 |
| `MLFXD0` | 45×55 | 21, 49 |
| `MLFXE0` | 45×55 | 20, 47 |
| `MLFXF0` | 48×53 | 24, 47 |
| `MLFXG0` | 45×55 | 26, 46 |
| `MLFXH0` | 61×58 | 31, 48 |
| `MLFXI0` | 12×49 | 5, 23 |
| `MLFXJ0` | 12×58 | 6, 27 |
| `MLFXK0` | 14×50 | 7, 25 |
| `MLFXL0` | 18×35 | 8, 16 |
| `MLFXM0` | 12×49 | 6, 24 |
| `MLFXN0` | 12×37 | 5, 17 |
| `MLFXO0` | 11×35 | 5, 16 |
| `MLFXP0` | 10×32 | 5, 14 |
| `MLFXQ0` | 10×30 | 5, 12 |
| `MLFXR0` | 9×25 | 4, 11 |
| `MLFXS0` | 8×21 | 3, 9 |
| `MLFXT0` | 6×16 | 2, 7 |
| `MLFXU0` | 4×11 | 2, 5 |
| `MLF2K0` | 9×43 | 4, 37 |
| `MLF2L0` | 7×39 | 3, 35 |
| `MLF2M0` | 6×30 | 3, 31 |
| `MLF2N0` | 59×44 | 31, 23 |
| `MLF2O0` | 42×37 | 22, 17 |
| `MLF2P0` | 29×30 | 15, 17 |
| `MLF2Q0` | 29×24 | 16, 4 |
| `MLF2A0` | 61×58 | 32, 48 |
| `MLF2B0` | 48×53 | 24, 45 |
| `MLF2C0` | 50×51 | 28, 47 |
| `MLF2D0` | 45×41 | 27, 40 |
| `MLF2E0` | 24×42 | 12, 37 |
| `MLF2F0` | 61×58 | 32, 47 |
| `MLF2G0` | 48×53 | 24, 44 |
| `MLF2H0` | 50×51 | 28, 39 |
| `MLF2I0` | 50×41 | 24, 35 |
| `MLF2J0` | 24×42 | 12, 41 |
| `WFHMA0` | 20×40 | 8, 36 |
| `WFAXA0` | 28×41 | 12, 37 |
| `WMCSA0` | 33×28 | 14, 29 |
| `WMCSB0` | 33×28 | 14, 29 |
| `WMCSC0` | 33×28 | 14, 29 |
| `WCSSA0` | 26×43 | 12, 39 |
| `WCFMA0` | 24×50 | 11, 47 |
| `WCFMB0` | 18×52 | 7, 49 |
| `WCFMC0` | 19×46 | 8, 43 |
| `WCFMD0` | 28×49 | 13, 46 |
| `WCFME0` | 29×48 | 14, 45 |
| `WCFMF0` | 19×43 | 9, 40 |
| `WCFMG0` | 16×43 | 7, 40 |
| `WCFMH0` | 25×46 | 11, 43 |
| `WMLGA0` | 15×28 | 6, 49 |
| `WMLGB0` | 26×28 | 13, 49 |
| `WMLGC0` | 29×29 | 15, 49 |
| `WMLGD0` | 25×28 | 12, 49 |
| `WMLGE0` | 17×29 | 8, 49 |
| `WMLGF0` | 25×28 | 12, 49 |
| `WMLGG0` | 29×30 | 14, 50 |
| `WMLGH0` | 26×29 | 11, 49 |
| `ARTIBRAC` | 22×22 | -5, -4 |
| `BRACA0` | 26×19 | 12, 47 |
| `BRACB0` | 26×21 | 12, 47 |
| `BRACC0` | 32×21 | 16, 48 |
| `BRACD0` | 36×21 | 17, 47 |
| `BRACE0` | 30×21 | 15, 47 |
| `BRACF0` | 27×21 | 13, 48 |
| `BRACG0` | 27×21 | 13, 48 |
| `BRACH0` | 36×20 | 17, 47 |
| `ARM1A0` | 32×24 | 15, 42 |
| `ARM3A0` | 22×15 | 10, 42 |
