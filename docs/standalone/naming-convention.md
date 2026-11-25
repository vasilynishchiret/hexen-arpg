# Standalone asset naming

Source assets use lowercase ASCII, underscores, and a mandatory `arpg_`
prefix. Names describe function, not the name of a Hexen lump. Directory names
are plural and lowercase. Do not reuse an upstream sprite, sound, texture, or
map identifier for a new source file.

Format: `arpg_<category>_<subject>_<variant>[_<frame>].<extension>`.

| Category | Meaning | Example |
| --- | --- | --- |
| `wp` | Weapon view/world art | `arpg_wp_cleric_sword_idle_a.png` |
| `it` | Loot item icon or world art | `arpg_it_ring_common_a.png` |
| `gem` | Upgrade stone | `arpg_gem_blue_a.png` |
| `ui` | Interface panel or icon | `arpg_ui_inventory_bg.png` |
| `fx` | Spell or impact effect | `arpg_fx_lightning_hit_a.png` |
| `tx` | Wall, floor, or sky texture | `arpg_tx_castle_wall_a.png` |
| `snd` | Sound | `arpg_snd_cleric_sword_swing_a.ogg` |
| `mus` | Music | `arpg_mus_first_area.ogg` |

Use `a`, `b`, etc. for animation frames or visual variants; use meaningful
variant names (`common`, `idle`, `attack`) before the frame suffix. Keep the
same stem across a related animation sequence. Never use a numeric suffix as
an implicit replacement for a documented purpose.

UZDoom ZScript sprite states use four-character runtime sprite prefixes and
frame letters, whereas these descriptive source filenames may be longer.
When a complete frame set exists, add a documented `TEXTURES` mapping from
each original source PNG to a new four-character runtime name, then switch
the corresponding state. Keep the source name and runtime name together in
[`resource-map.md`](resource-map.md). Sound and texture logical names need
equivalent mappings. This branch reserves `mod/patches/standalone/` for those
future mappings; no new placeholder is wired into the active game yet.

All source art must be original or separately licensed for the intended
commercial use. A new file's name is not evidence of its provenance.
