# Editing the standalone map in Ultimate Doom Builder

`mod/standalone/maps/MAP01.wad` is the editable UDMF map. It is the only map
source used by `tools/build-standalone.ps1`; editing the generated IPK3 is not
part of the workflow. The WAD contains only `MAP01`, `TEXTMAP`, and `ENDMAP`
until UDB adds optional map support lumps. It contains no commercial IWAD data.

1. Build once with `powershell -NoProfile -ExecutionPolicy Bypass -File tools/build-standalone.ps1`.
2. In Ultimate Doom Builder choose **Open Map** and select
   `mod/standalone/maps/MAP01.wad`. Select `MAP01` and the
   **UZDoom: Doom 2 (UDMF)** configuration. The `zdoom` UDMF namespace matches
   this map; the name "Doom 2" here is an editor format profile, not a request
   to include `DOOM2.WAD` in the game.
3. In the map's **Resources** list, add
   `build/standalone/HEXEN-ARPG-Standalone.ipk3` via **Add resource → From
   PK3/PKE/PK7**. Do not add `HEXEN.WAD` or any other commercial IWAD. Enable
   long texture names only if needed for future assets; today's texture names
   fit the standard 8-character field.
   UDB R4336 can open this map with the standalone IPK3, but its ZScript
   analyser reports that `PlayerPawn` is undefined and that several base Doom
   sprites are missing. UZDoom 5.0.3 loads the same IPK3 successfully because
   the engine supplies those base classes. For a fuller editor preview, add
   the locally installed UZDoom engine resource `uzdoom.pk3` before the
   standalone IPK3. This editor-only resource is not copied into the project
   or its build. UDB may still list unused base Doom actor sprites as missing;
   inspect runtime results in UZDoom before treating those warnings as map
   errors.
4. Change a wall, sector, or geometry in UDB. Use `ARWALL1` for walls,
   `ARFLOOR` for floors and `ARCEIL` for ceilings. The prototype player start
   is DoomEdNum 1 at `(0, 0)`; keep at least one valid start. New textures must
   first be added to `mod/assets/`, `mod/standalone/TEXTURES` and the build
   asset list. Add new actor DoomEdNums in standalone ZScript and rebuild
   before expecting UDB to show them.
5. **Save** in UDB to the same `MAP01.wad`. Close the editor before rebuilding
   if it holds the WAD open. Keep UDB backups outside Git; `*.bak` is ignored.
6. Run `tools/build-standalone.ps1`, then
   `tools/test-standalone-package.ps1`. The package test compares the map WAD
   bytes in the IPK3 with the saved editable source.
7. Run `Play-Standalone.bat`. It rebuilds and starts `MAP01` with the separate
   standalone profile. Walk to the changed area and confirm the edit appears.

UDB's game configuration and resource list are local editor settings. The
distributed standalone game needs only UZDoom and the independently built
IPK3, no Hexen or Doom IWAD. If UDB asks for an IWAD when opening this map,
verify its selected game configuration and the IPK3 resource instead of adding
a commercial WAD to the project.

The map and resource opened successfully in UDB R4336 in the UZDoom UDMF
profile. An actual geometry edit, save, rebuild, and visual confirmation in the
game remains a manual verification step; no editor change was inferred from
merely opening the map.
