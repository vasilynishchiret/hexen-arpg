# Built-in Hexen status-bar check

Checked on 2026-11-21 with UZDoom 5.0.3 and a separately installed legal `HEXEN.WAD`, on branch `fix/native-hexen-statusbar`.

## Observed

- `mod/zscript.txt` no longer includes `arpg_statusbar.zs`; `mod/MAPINFO` no longer overrides `StatusBarClass`; the adapted source file is removed from the branch.
- Loading `-iwad HEXEN.WAD -file mod -stdout -nosound +quit` completed with exit code 0, without ZScript compilation errors or missing-resource reports.
- `tools/launch.ps1` reached `Init complete` and loaded MAP01 using an isolated test profile. The normal `Play.bat` path also opened the game and presented the class menu.
- Cleric was selected interactively. At 1280 × 720, the fullscreen HUD showed HP, Mana1, Mana2, and the ARPG level/XP overlay. With `screenblocks=10` in a separate test profile, the ordinary stone Hexen status bar showed HP, both mana counters, and the ARPG level/XP overlay.
- Visual difference: the engine's standard bar shows armor `0` for Cleric in both HUD modes; the removed custom bar hid it. No other visual difference was established in this session.
- A local review ZIP was built from the committed tree with 73 entries. Its entry list contains both launchers, `mod/`, `tools/`, documentation, and `RIGHTS.md`; it contains no `HEXEN.WAD`, UZDoom executable/data, third-party WAD, copied status-bar source, GPL text, or editor files. `tools/launch.ps1` from a separate extraction folder loaded the mod in UZDoom 5.0.3 with exit code 0 and no ZScript compilation error. This was a startup/compile smoke test, not an interactive play-through from the ZIP.

## Still requiring manual play testing

- Fighter and Mage startup and HUD behavior. An attempted extra launch stayed on the splash screen during automation, so no class result is claimed.
- Inventory on Alt, equipment panels, ARPG ability display and activation, weapon slots, and loot prompts with representative items equipped.
- Save and reload with the inventory open/closed and on another map; transition between maps.
- Other resolutions/aspect ratios and changes between ordinary and fullscreen HUD during play.
- Custom WAD through `-MapWad`, including an internal map name where needed.

Automated UI input did not reliably reach in-map hotkeys, so these interactions were not verified. This record is evidence for the observed checks only, not a complete gameplay sign-off.
