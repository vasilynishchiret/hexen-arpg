# Publication rights review (pending)

This is a provenance checklist, not a grant of rights. Git history identifies the committer, but does not establish the original creator or license of every image or code fragment. No license is assigned to the entire repository.

## Assets requiring human review before public distribution

| Files | Status | Required check |
| --- | --- | --- |
| `mod/patches/arpg_sword/*.png` (7 files) | Already tracked; authorship and source material are undocumented. Names, proportions and `mod/TEXTURES` mappings correspond to Hexen weapon frames. Some virtual sword frames intentionally use the buyer's original WAD at runtime. | Compare the PNG pixels against `HEXEN.WAD` and any source artwork; obtain creator permission or replace derivatives. Runtime references to the user's own WAD are separate from distributing copied pixels. |
| `mod/patches/arpg_ring/ARRGA0.png` | Tracked. `tools/generate-ring-icon.ps1` draws the icon from geometric primitives and colours. | Confirm that the generator and icon were created by the project author and do not trace another icon. |
| `mod/assets/textures/sky/*` (11 files) | Untracked and **excluded** from this commit. Names suggest edited/generated sky textures, but no source or license record is present. Some files are byte-identical copies. | Identify every source and transformation; compare against Hexen skies and third-party artwork, then obtain permission or replace. |
| `maps/first-tower.*` (11 files, including `first-tower.wad`) | Untracked editor database, working WAD, autosaves and backups; **excluded** from this commit. | Decide whether a finished original map should be published later, and review all embedded textures, sounds, scripts and maps. |

No `HEXEN.WAD`, original game map archive, UZDoom executable, third-party map archive, or sound file is tracked. The ZScript deliberately refers to sprite and sound names supplied by the user's own Hexen IWAD and the installed UZDoom. This does not copy those binary resources into the mod. No `LICENSE` file is present. The code is committed under the repository author's identity; its use of stock actor APIs and animation descriptions should still be compared with upstream UZDoom code before a license is chosen. If any code was copied from UZDoom, follow its applicable license and attribution requirements.

Before a public release or PR merge, resolve the sword images in particular. Removing them without changing the runtime references would break the current sword visuals, so the alpha build should remain a review candidate until they are cleared or replaced and tested.
