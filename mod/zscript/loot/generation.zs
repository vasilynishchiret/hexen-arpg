class ARPGLootGeneration : EventHandler
// Copyright (C) 2026 Vasily Nishchiret
// SPDX-License-Identifier: GPL-3.0-or-later

{
    void TryDrop(Actor victim)
    {
        if (random[ARPGLootChance](0, ARPGBalance.LOOT_ONE_IN - 1) == 0)
            Actor.Spawn("ARPGGroundWeapon", victim.Pos);
    }
}
