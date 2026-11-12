class ARPGLootGeneration : EventHandler
{
    void TryDrop(Actor victim)
    {
        if (random[ARPGLootChance](0, 99) < ARPGBalance.LOOT_CHANCE_PERCENT)
            Actor.Spawn("ARPGGroundWeapon", victim.Pos);
    }
}