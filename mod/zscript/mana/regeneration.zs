class ARPGMana : EventHandler
{
    override void WorldTick()
    {
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            let cleric = ARPGCleric(players[i].mo);
            if (cleric == null || cleric.health <= 0) continue;
            cleric.MigrateHealthLimit();
            if (cleric.arpgAttackCooldown > 0) cleric.arpgAttackCooldown--;
            bool running = (players[i].cmd.buttons & BT_RUN) != 0;
            bool moving = players[i].cmd.forwardmove != 0 || players[i].cmd.sidemove != 0;
            if (running && moving) continue;
            cleric.arpgManaTicks++;
            if (cleric.arpgManaTicks >= ARPGBalance.BLUE_REGEN_TICS)
            {
                cleric.arpgManaTicks = 0;
                cleric.GiveInventory("Mana1", 1);
            }
        }
    }
}
