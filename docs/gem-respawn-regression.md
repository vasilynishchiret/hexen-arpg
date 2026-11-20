# Gem conversion regression: MAP01 world origin

The original Hexen MAP01 (Winnowing Hall) ACS does not spawn mana or use
`ThingCount` to replace it. Its periodic spawn script 255 creates Ettins.
With the old `ARPGGemWorld`, a fresh Cleric game nevertheless converted
temporary `Mana1` actors at `(0, 0, 0)` repeatedly. UZDoom creates these
actors at the world origin when `GiveInventory` grants combat mana; after
pickup they briefly remain unowned but are no longer active world pickups.
The reported accumulation point was `(x=-8, y=4, z=-112)`: the spawned gems
fall from `(0, 0, 0)` to that nearby floor.

## Reproduce and verify

Use a legally owned `HEXEN.WAD`, UZDoom, and `Play.bat`. Start the original
campaign as Cleric on MAP01. The reported spot near the Emerald Key door is
`(-8, 4, -112)`. Leave the player away from that spot for
at least two minutes while Mana1 regenerates, then visit it. The number of
gems must not grow while no actual world mana pickup is being spawned.

In the console, `give Mana1` repeatedly and wait another minute. This grants
combat mana and must not create ground gems at the origin. `summon Mana1`,
`summon Mana2`, and `summon Mana3` should each create one collectible ground
pickup: blue, green, and one of each gem respectively. A full gem stack or
full inventory must leave the pickup in the world until there is room.

Save while the three summoned pickups are present, load, collect them, and
verify that they do not reappear in normal single-player play. Revisit MAP01
through a hub portal and repeat. Check Fighter and Mage separately: their
ordinary mana pickups and combat mana must work as before.

For a compatible custom WAD, place all three mana types, including one with
a TID and a pickup special. Verify that scripts can still find the original
actor by TID before collection, that its special runs once on collection,
and that a pickup configured to respawn produces a new gem only when the
original item legitimately respawns. Repeat after saving and loading.

The diagnosis was reproduced in UZDoom 5.0.3 with an instrumented copy of
`gems.zs`: the old code logged repeated `Mana1` conversions at `(0, 0, 0)`.
With the fix, the same 15-second startup logged zero such conversions, while
three explicitly spawned world mana actors (`Mana1`, `Mana2`, `Mana3`) were
each converted once. These are engine startup and scripted diagnostics, not
interactive gameplay verification; the manual checks above remain required.
