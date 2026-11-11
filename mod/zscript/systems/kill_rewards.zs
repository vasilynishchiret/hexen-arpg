class ARPGKillRewards : EventHandler
{
    Array<Actor> rewarded;

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
        if (cleric == null || cleric.health <= 0) return;

        rewarded.Push(e.Thing);
        int xp = e.Thing is "Ettin" ? ARPGBalance.XP_ETTIN : clamp(e.Thing.GetMaxHealth() / ARPGBalance.OTHER_XP_HP_DIVISOR, ARPGBalance.OTHER_XP_MIN, ARPGBalance.OTHER_XP_MAX);
        cleric.AddXP(xp);
        cleric.GiveInventory("Mana2", ARPGBalance.GREEN_MANA_PER_KILL);
    }
}
