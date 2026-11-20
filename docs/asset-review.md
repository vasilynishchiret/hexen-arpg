# Publication rights review

This is a provenance checklist, not a grant of rights. Git history identifies the committer, but does not establish the original creator or license of every image or code fragment. No license is assigned to the entire repository.

## Assets requiring human review before public distribution

| Files | Status | Required check |
| --- | --- | --- |
| `mod/patches/arpg_sword/*.png` (7 files) | The project author confirmed that all seven were created from scratch and explicitly authorized publication. Some *virtual* sword frames still reference the user's original Hexen WAD at runtime; those WAD pixels are not stored in this repository. | Keep the author's provenance statement with the project records. |
| `mod/patches/arpg_ring/ARRGA0.png` | Verified as the exact output of `tools/generate-ring-icon.ps1` (SHA-256 `E0AC781D2A4626A8E3C6202EDDC15B2A4555971E3890A715AA0D6A5667636EAC`). The script only draws geometric primitives with literal colours and does not load source PNGs, Hexen sprites or other image files. | The current icon is suitable for this project on the evidence available. |
| `mod/assets/textures/sky/*` (11 files) | Untracked and **excluded** from this commit. Names suggest edited/generated sky textures, but no source or license record is present. Some files are byte-identical copies. | Identify every source and transformation; compare against Hexen skies and third-party artwork, then obtain permission or replace. |
| `maps/first-tower.*` (11 files, including `first-tower.wad`) | Untracked editor database, working WAD, autosaves and backups; **excluded** from this commit. | Decide whether a finished original map should be published later, and review all embedded textures, sounds, scripts and maps. |

No `HEXEN.WAD`, original game map archive, UZDoom executable, third-party map archive, or sound file is tracked. The ZScript deliberately refers to sprite and sound names supplied by the user's own Hexen IWAD and the installed UZDoom. This does not copy those binary resources into the mod.

`mod/zscript/hud/arpg_statusbar.zs` is adapted from UZDoom's `hexen_sbar.zs`, retaining the upstream copyright and `SPDX-License-Identifier: GPL-3.0-or-later` header. The corresponding GPLv3 text is included at `LICENSES/GPL-3.0.txt`. [UZDoom identifies its code as GPLv3 or later](https://github.com/UZDoom/UZDoom). This notice applies to the adapted file; it does not assign a license to all other repository files. Review the combined distribution obligations before a public release. Other game code is committed under the project author's identity, but commit authorship alone is not a complete provenance record.

Before a public release or PR merge, complete gameplay checks and the remaining code-provenance review. The excluded sky textures and map drafts should not be added until their rights and contents are assessed separately.
