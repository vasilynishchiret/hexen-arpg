class ARPGLootGeneration : EventHandler
{
    void TryDrop(Actor victim)
    {
        if (random[ARPGLootChance](0, ARPGBalance.LOOT_ONE_IN - 1) == 0)
            Actor.Spawn("ARPGGroundWeapon", victim.Pos);
    }
}
