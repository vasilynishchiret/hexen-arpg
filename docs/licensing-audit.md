# Release licensing audit (pending)

This is a release checklist based on the files in `feature/independent-weapon-slots` as inspected on 2026-11-20. It records evidence and unresolved rights; it does **not** grant a license on behalf of any contributor. Do not publish the draft release until the blockers below are resolved.

## UZDoom-derived status bar and the combined mod

`mod/zscript/hud/arpg_statusbar.zs` is an adaptation of UZDoom's `zscript/ui/statusbar/hexen_sbar.zs` (also present in the locally installed UZDoom data archive). Its original copyright holders and `SPDX-License-Identifier: GPL-3.0-or-later` header are retained. A dated HEXEN-ARPG modification notice has been added. UZDoom identifies its code as GPLv3 or later. [GPLv3](../LICENSES/GPL-3.0.txt) is included verbatim.

The status bar is loaded by `mod/zscript.txt`, selected by `mod/MAPINFO`, and exchanges data with other ARPG classes. For release planning, treat the ZScript mod as **one combined derivative work**, not as a mere collection of independent files. GPLv3 section 5 requires a distributor of a modified source work to retain copyright/license notices, mark modifications and dates, and license the *entire combined work* under GPL-3.0-or-later (or a later GPL version chosen under the upstream grant). A GPL copy and SPDX line on the status-bar file alone do not satisfy that requirement. Merely placing independent programs together would be different, but does not describe this integrated ZScript mod.

The mod archive contains editable ZScript, configuration, launch scripts, and project graphics. Its source code should accompany every downloadable mod ZIP, along with the GPL text and applicable copyright/modification notices. If a future build ships compiled or otherwise non-source code, provide the complete corresponding source and installation/build scripts by one of GPLv3 section 6's permitted methods. The engine and the buyer's `HEXEN.WAD` are separate dependencies and are not bundled; this audit does not purport to relicense either. GPL permission for UZDoom code also grants no rights to Hexen game art or third-party maps.

## Rights inventory and release blockers

1. **License grant for original contributions:** Confirm who owns every other ZScript file, `mod` definition, launch/tool script, and included PNG. The seven sword PNGs were confirmed by the project author as created from scratch and approved for publication; that statement did not expressly grant GPL-3.0-or-later rights to downstream recipients. The ring PNG was reproducibly generated from geometric primitives by `tools/generate-ring-icon.ps1`. Obtain the rights holder's explicit GPL-compatible grant for all components of the combined work, or replace/remove any incompatible component before distribution. Do not infer such a grant from a Git commit, public repository, or permission merely to publish.
2. **Project notice:** Once rights are confirmed, add a clear top-level `LICENSE`/`COPYING` or equivalent notice identifying the combined mod's GPL-3.0-or-later license, project copyright holders, upstream status-bar attribution, and any separately licensed material. Keep `LICENSES/GPL-3.0.txt` in both repository and ZIP. Do not present the whole repository as licensed until authorization is established.
3. **Source and archive:** Rebuild the ZIP from the reviewed branch after licensing changes. The ZIP attached to the unpublished GitHub draft release matches the inspected local copy (SHA-256 `42c54001106286157886f0794fd57a411169ca0d553f822f488821e429800381`). It contains the source tree and GPL text and no `.wad`, `.pk3`, `.pk7`, `.exe`, or `.dll` entry, but its `mod/zscript/loot/gems.zs` differs from the current branch and lacks the latest fix. The draft is stale and must not be published as the release asset. Recheck the exact rebuilt ZIP, including its source/notice files, against the release commit.
4. **Excluded work files:** Keep untracked `mod/assets/textures/sky/*` and `maps/first-tower.*` outside the archive. Their provenance is unresolved. No tracked `HEXEN.WAD`, original map archive, UZDoom executable, third-party WAD, or sound file was found. Runtime references to textures/sprites/sounds in a user's legally obtained IWAD do not place those binary assets in this repository.
5. **Other borrowed code:** A scan found no other explicit upstream copyright/SPDX header in `mod` or `tools`, but absence of a header is not proof of originality. Review contributor and copy/paste provenance for the rest of the code. Any additional borrowed material needs attribution and a license compatible with the combined GPL work.
6. **Interface notices:** GPLv3 section 5(d) may require Appropriate Legal Notices in interactive interfaces, unless the upstream program's interfaces lacked them. Verify how this applies to the adapted status bar and document the conclusion. Do not change gameplay or UI solely on an unverified assumption.

## Release package minimum after clearance

Package `Play.bat`, `Play-Custom-Map.bat`, `mod/` (including readable ZScript and project graphics), `tools/` (including launcher/config and relevant generators), `README.md`, `README.ru.md`, `LICENSE` or equivalent project notice, `LICENSES/GPL-3.0.txt`, and provenance/attribution documentation. The archive must exclude UZDoom binaries, `HEXEN.WAD`, copyrighted original map data, unreviewed sky/map work files, saves, personal paths, and editor files. A published GitHub source tree alone is not a substitute for checking what the downloadable ZIP contains.

## References

- [GNU GPL version 3](https://www.gnu.org/licenses/gpl-3.0.html), particularly sections 1, 4, 5 and 6.
- [UZDoom source repository and license statement](https://github.com/UZDoom/UZDoom).
- [Project asset review](asset-review.md).
