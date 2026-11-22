# Publication rights review

This is a provenance checklist, not a grant of rights. Git history identifies the committer, but does not establish the original creator or license of every image or code fragment. See [licensing audit](licensing-audit.md) and [rights notice](../RIGHTS.md). No license grant for the project's original contributions is inferred from this checklist.

## Assets requiring human review before public distribution

| Files | Status | Required check |
| --- | --- | --- |
| `mod/patches/arpg_sword/*.png` (7 files) | The project author confirmed that all seven were created from scratch and explicitly authorized publication. Some *virtual* sword frames still reference the user's original Hexen WAD at runtime; those WAD pixels are not stored in this repository. | Keep the author's provenance statement with the project records. |
| `mod/patches/arpg_ring/ARRGA0.png` | Verified as the exact output of `tools/generate-ring-icon.ps1` (SHA-256 `E0AC781D2A4626A8E3C6202EDDC15B2A4555971E3890A715AA0D6A5667636EAC`). The script only draws geometric primitives with literal colours and does not load source PNGs, Hexen sprites or other image files. | The current icon is suitable for this project on the evidence available. |
| `mod/assets/textures/sky/*` (11 files) | Untracked and **excluded** from this commit. Names suggest edited/generated sky textures, but no source or license record is present. Some files are byte-identical copies. | Identify every source and transformation; compare against Hexen skies and third-party artwork, then obtain permission or replace. |
| `maps/first-tower.*` (11 files, including `first-tower.wad`) | Untracked editor database, working WAD, autosaves and backups; **excluded** from this commit. | Decide whether a finished original map should be published later, and review all embedded textures, sounds, scripts and maps. |

No `HEXEN.WAD`, original game map archive, UZDoom executable, third-party map archive, or sound file is tracked. The ZScript deliberately refers to sprite and sound names supplied by the user's own Hexen IWAD and the installed UZDoom. This does not copy those binary resources into the mod.

The former `mod/zscript/hud/arpg_statusbar.zs` was adapted from UZDoom's GPL-3.0-or-later `hexen_sbar.zs`. It was removed from this branch, along with its include and `StatusBarClass` override. The installed engine now supplies its own Hexen status bar at runtime; that engine source is not part of the mod package. The copied file remains in earlier Git history. The pre-license draft release ZIP was replaced with a candidate that excludes it, but that candidate must be rebuilt with the approved rights documents. See the [licensing audit](licensing-audit.md).

Before a public release or PR merge, complete the remaining gameplay checks and code-provenance review. The approved terms for original code and art are in [LICENSE](../LICENSE) and [RIGHTS.md](../RIGHTS.md). The excluded sky textures and map drafts should not be added until their rights and contents are assessed separately.
