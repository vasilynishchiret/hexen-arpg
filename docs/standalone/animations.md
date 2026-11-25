# Standalone animation reference sets

This is technical planning data for **one weapon and one monster**. The private
reference PNGs are exported from the owner's local `HEXEN.WAD` to
`GAMEDEV/_PRIVATE_HEXEN_REFS/`, which is outside this repository. They are not
part of Git or the standalone IPK3. The PNGs under `mod/assets/` are separate,
procedurally drawn geometric placeholders. They use no Hexen palette colours
or source pixels. Similar canvas and timing data does not make them finished
art or a replacement for a commercial content review.

[`animation-frames.csv`](animation-frames.csv) is the per-frame manifest. Its
paths are relative to the private reference root and `mod/assets/`. Each row
records the source lump, logical name, both PNG paths, canvas size, sprite
offset, opaque bounds, direction, frame order, phase, state use, tick duration,
and distinct standalone runtime identifier. A duration joined with `|` means
the same image occurs more than once with those durations. The public CSV
contains metadata only, never reference pixels or an absolute local path.

## Fighter axe reference set

- 24 `FAXE` images (`A0`–`X0`), no rotation variants.
- Private references: `weapons/axe/arpg_wp_axe_<frame>0_ref.png`.
- Standalone placeholders: `mod/assets/sprites/weapons/axe/arpg_wp_axe_<frame>0.png`.
- Runtime prefix `ARXA`, defined in `mod/standalone/ANIMATION_TEXTURES`.
- Baseline `FWeapAxe` state graph from the installed UZDoom 5.0.3
  `zscript/actors/hexen/fighteraxe.zs`: `Select`/`Deselect`/`Ready` use `A`
  for 1 tick. `Fire` uses `B4 C3 D2 D1`; `EndAttack` uses `D2 E1 E2 E7`
  and `A1` recovery steps. Glowing variants use `L`/`M` idle, then
  `N4 O3 P2 P1 P2 Q1 Q2 Q7`; `R`–`X` are the glow puff's 4-tick frames.
  `F`–`K` occur in the IWAD but are not referenced by this selected actor's
  state chain. They are retained so this asset set is complete; they have no
  invented runtime timing.

## Ettin reference set

- 93 images: `ETTN` `A`–`H` in rotations 1–8, `ETTN` `I`–`R` unrotated,
  and `ETTB` `A`–`S` unrotated. The dropped mace frames `M`–`S` are included
  because the enemy's gib death spawns that actor.
- Private references: `monsters/ettin/arpg_mn_ettin_<frame><rotation>_ref.png`
  and `arpg_mn_ettin_gib_<frame>0_ref.png`.
- Standalone placeholders: same stems without `_ref` under
  `mod/assets/sprites/monsters/ettin/`.
- Runtime prefixes `ARET` and `AREB` are distinct from Hexen names.
- Baseline `Ettin` state graph from installed UZDoom 5.0.3
  `zscript/actors/hexen/ettin.zs`: `Spawn AA 10`, `See ABCD 5`,
  `Pain H 7`, `Melee EF 6, G 8`, `Death IJ 4, K 4, L 4, M 4, NOP 4,
  Q -1`, `XDeath A`–`K` at 4 and `L -1`, `Ice R5 R1`.
  `EttinMace.Spawn` uses `ETTB M`–`P` for 5 ticks; `Crash` uses `Q5 R5 S-1`.

These state chains describe the **reference timing**. The prototype does not
spawn an Ettin or use the reference axe as a weapon. The placeholder frames
and `TEXTURES` mappings are compiled into the standalone package for future
independent actors; the current blade and one-room gameplay are unchanged.
Before connecting these frames, implement and test independent AI/weapon
behavior without inheriting Hexen actors.

## Regeneration

Run `tools/prepare-standalone-animation-sets.ps1 -IWAD <your HEXEN.WAD>`.
The default mode creates only missing PNGs and preserves hand edits. Use
`-ForceRegenerate` **only** when you intend to replace every generated frame
in these two sets. Rebuild with `tools/build-standalone.ps1`, then run
`tools/test-standalone-package.ps1`. The exporter writes reference images
only beneath its private root and rejects a private root inside Git. The
build script uses an explicit asset list and does not scan that private root.
