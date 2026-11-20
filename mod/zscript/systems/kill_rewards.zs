class ARPGKillRewards : ARPGLootGeneration
{
    Array<Actor> rewarded;
    Array<Actor> lethalVictims;
    Array<Actor> lethalSources;

    override void WorldThingDamaged(WorldEvent e)
    {
        if (e.Thing == null || e.Thing.health > 0 || !e.Thing.bIsMonster || e.Thing.bFriendly) return;
        let cleric = ARPGCleric(e.DamageSource);
        if (cleric == null) return;
        lethalVictims.Push(e.Thing);
        lethalSources.Push(cleric);
    }

    override void WorldThingDied(WorldEvent e)
    {
        if (e.Thing == null || !e.Thing.bIsMonster || e.Thing.bFriendly) return;
        for (int i = 0; i < rewarded.Size(); i++)
        {
            if (rewarded[i] == e.Thing) return;
        }

        Actor source = e.Inflictor;
        for (int i = 0; i < 8 && source != null && source.player == null; i++)
        {
            if (source.bIsMonster) return;
            source = source.target;
        }
        let cleric = ARPGCleric(source);
        for (int i = lethalVictims.Size() - 1; i >= 0; i--)
        {
            if (lethalVictims[i] != e.Thing) continue;
            cleric = ARPGCleric(lethalSources[i]);
            lethalVictims.Delete(i);
            lethalSources.Delete(i);
            break;
        }
        if (cleric == null || cleric.health <= 0) return;

        rewarded.Push(e.Thing);
        int xp = e.Thing is "Ettin" ? ARPGBalance.XP_ETTIN : clamp(e.Thing.GetMaxHealth() / ARPGBalance.OTHER_XP_HP_DIVISOR, ARPGBalance.OTHER_XP_MIN, ARPGBalance.OTHER_XP_MAX);
        cleric.AddXP(xp);
        cleric.GiveInventory("Mana2", ARPGBalance.GREEN_MANA_PER_KILL);
        TryDrop(e.Thing);
        if (random[ARPGGemDropChance](0, 9) == 0)
            Actor.Spawn(random[ARPGGemDropColor](0, 1) == 0 ?
                'ARPGBlueGemPickup' : 'ARPGGreenGemPickup', e.Thing.Pos);
    }
}
