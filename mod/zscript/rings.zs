class ARPGRingEffects : EventHandler
{
    int RingCount(ARPGCleric cleric, int id)
    {
        int count = 0;
        if (ARPGAffixes.Has(cleric.arpgArmor[3], id)) count++;
        if (ARPGAffixes.Has(cleric.arpgArmor[4], id)) count++;
        return count;
    }

    override void WorldTick()
    {
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            let cleric = ARPGCleric(players[i].mo);
            if (cleric == null || cleric.health <= 0) continue;
            int green = RingCount(cleric, ARPGAffixes.GREEN_REGEN);
            if (green > 0)
            {
                if (++cleric.arpgGreenTicks >= ARPGBalance.GREEN_RING_TICS)
                {
                    cleric.arpgGreenTicks = 0;
                    cleric.GiveInventory("Mana2", green);
                }
            }
            else cleric.arpgGreenTicks = 0;

            int aura = RingCount(cleric, ARPGAffixes.DAMAGE_AURA);
            if (aura > 0)
            {
                if (++cleric.arpgAuraTicks >= ARPGBalance.AURA_TICS)
                {
                    cleric.arpgAuraTicks = 0;
                    let it = ThinkerIterator.Create("Actor");
                    Actor enemy;
                    while ((enemy = Actor(it.Next())) != null)
                    {
                        if (!enemy.bIsMonster || enemy.bFriendly || enemy.health <= 0 ||
                            cleric.Distance2D(enemy) > ARPGBalance.AURA_RADIUS ||
                            !cleric.CheckSight(enemy)) continue;
                        enemy.DamageMobj(cleric, cleric,
                            aura * ARPGBalance.AURA_DAMAGE_PER_RING, 'ARPGAura');
                    }
                }
            }
            else cleric.arpgAuraTicks = 0;
        }
    }

    override void WorldThingDamaged(WorldEvent e)
    {
        if (e.Thing == null || !e.Thing.bIsMonster || e.Thing.bFriendly ||
            e.Damage <= 0) return;
        Actor source = e.DamageSource;
        for (int i = 0; i < 8 && source != null && source.player == null; i++)
        {
            if (source.bIsMonster) return;
            source = source.target;
        }
        let cleric = ARPGCleric(source);
        if (cleric == null || cleric.health <= 0) return;
        int rate = ARPGAffixes.Power(cleric.arpgArmor[3], ARPGAffixes.VAMPIRISM) +
            ARPGAffixes.Power(cleric.arpgArmor[4], ARPGAffixes.VAMPIRISM);
        rate = min(rate, ARPGBalance.VAMP_MAX_BASIS_POINTS);
        if (rate <= 0) { cleric.arpgVampRemainder = 0; return; }
        // WorldThingDamaged fires after health changed. Cap overkill to the
        // victim's remaining health before the hit.
        int actual = min(e.Damage, max(0, e.Thing.health + e.Damage));
        if (actual <= 0) return;
        int total = actual * rate + cleric.arpgVampRemainder;
        int healing = total / 10000;
        cleric.arpgVampRemainder = total % 10000;
        if (healing <= 0 || cleric.health >= cleric.GetMaxHealth()) return;
        cleric.health = min(cleric.GetMaxHealth(), cleric.health + healing);
        if (cleric.player != null) cleric.player.health = cleric.health;
    }
}
