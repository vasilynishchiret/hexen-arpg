# Release licensing audit: v0.1.0-alpha

Updated 2026-11-22. This is a technical provenance and distribution review,
not a legal opinion. The file-level grants are in [LICENSE](../LICENSE),
[Original Content terms](../LICENSES/ORIGINAL-CONTENT.md), and
[RIGHTS.md](../RIGHTS.md).

## Current alpha package

The rights holder approved GPL-3.0-or-later for their project-authored ZScript,
launch and utility scripts, and textual mod configuration identified in
`RIGHTS.md`. This grant permits third parties to use, modify, and commercially
redistribute that code under GPL conditions. It does **not** transfer the
author's copyright or prevent separate use and licensing of code they own.
Independent contributions from others require a rights and license review,
especially if dual licensing is intended later. GPL rights already granted to
recipients cannot be withdrawn from their copies.

The eight tracked original PNG files and original documentation use separate
Original Content terms. Their rights are not assigned to GPL by the code
grant. The ring icon is the exact output of the project's procedural generator
and the seven sword PNGs have author confirmation. Untracked sky textures and
draft map archives remain excluded pending provenance review; see
[asset review](asset-review.md). The alpha archive contains no `HEXEN.WAD`,
original maps, UZDoom executable or engine data, third-party WAD, or sound
file. It contains editable ZScript, launch scripts, mod declarations, both
licenses, notices, and documentation. Players supply UZDoom and a lawful
Hexen copy separately.

## Former status-bar source and remaining uncertainty

The former `mod/zscript/hud/arpg_statusbar.zs` closely adapted UZDoom's
GPL-3.0-or-later `zscript/ui/statusbar/hexen_sbar.zs`. It was deleted from
the current mod, together with its include and the `StatusBarClass` override.
UZDoom now provides its own Hexen status bar at runtime. The former file
remains in Git history, where the upstream copyright and GPL obligations
continue to matter. Do not claim that Vasily Nishchiret owns the UZDoom source.

The owner reports creating the remaining ZScript and scripts for this project
with Codex assistance, without intentional copying. A previous comparison
against 294 files from installed UZDoom 5.0.3 found no exact run of six
consecutive nonempty lines in the 24 then-remaining project ZScript files.
This heuristic cannot prove originality or exclude modified copying from
another source. The code's GPL grant avoids a conflict if the mod is legally
treated as a combined work with GPL engine code, but it does not settle every
boundary between code and separately licensed game content. Mere use of a
GPL interpreter, or the historical presence of one copied file, is not by
itself proof that every present mod resource must be GPL-licensed.

## Manual and technical checks

The rights holder reported completing the hands-on release checks from the
extracted candidate ZIP on 2026-11-22, with no critical problem found. This
is a user report, not an independently observed play-through. The earlier
[status-bar record](native-statusbar-check.md) lists what the agent actually
observed with UZDoom 5.0.3. License-only changes require a rebuilt archive,
an exact entry/source/notice check, and a startup smoke test from an extracted
copy before publication.

## Future commercial standalone

UZDoom's GPL-3.0-or-later license permits commercial distribution. A future
standalone game may sell separately licensed original art and content, while
honoring GPL for covered program components. If an engine binary is bundled,
review the exact engine version and every included dependency; preserve
upstream notices and license texts; provide the Corresponding Source and the
scripts needed to build, install, and run the distributed GPL code; and make
that source available alongside downloads for as long as required. Store or
DRM terms must not take away recipients' GPL rights. Rights in independently
licensed art and music need explicit, separate notices and provenance.

The present mod is **not** standalone. It inherits `ClericPlayer` and `Ettin`,
loads original Hexen resources by names such as `FAXE*`, and depends on the
Hexen IWAD and its built-in interface and game data. A standalone branch must
replace all protected characters, enemies, weapons, graphics, animations,
sounds, textures, maps, interface elements, and branding and verify the absence
of other Hexen dependencies. Omitting `HEXEN.WAD` or renaming the game alone
would not achieve this.

Professional review is still advisable before a commercial release: the
code/content boundary in its actual package, all licenses in its precise
engine build, contributor and generated-asset provenance, possible Hexen
derivative elements or trademark issues, and distribution-platform terms.
No future asset is automatically covered by this alpha's content license.

## Primary references

- [GNU GPL version 3](https://www.gnu.org/licenses/gpl-3.0.html), especially
  sections 4–6 on notices and Corresponding Source.
- [GNU GPL FAQ](https://www.gnu.org/licenses/gpl-faq.en.html) on selling GPL
  software, dual licensing one's own code, interpreters, and separately
  licensed game art and audio.
- [UZDoom repository](https://github.com/UZDoom/UZDoom) and
  [standalone-game guidance](https://github.com/UZDoom/UZDoom/wiki/Getting-Started).
