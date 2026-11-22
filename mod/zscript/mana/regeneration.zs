class ARPGMana : EventHandler
// Copyright (C) 2026 Vasily Nishchiret
// SPDX-License-Identifier: GPL-3.0-or-later

{
    override void WorldTick()
    {
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            let cleric = ARPGCleric(players[i].mo);
            if (cleric == null || cleric.health <= 0) continue;
            cleric.MigrateHealthLimit();
            cleric.SyncARPGManaCapacity();
            if (cleric.arpgAttackCooldown > 0) cleric.arpgAttackCooldown--;
            bool running = (players[i].cmd.buttons & BT_RUN) != 0;
            bool moving = players[i].cmd.forwardmove != 0 || players[i].cmd.sidemove != 0;
            bool jump = (players[i].cmd.buttons & BT_JUMP) != 0;
            if (players[i].onground) cleric.arpgDoubleJumpUsed = false;
            if (jump && !cleric.arpgJumpWasDown && !players[i].onground &&
                !cleric.arpgWasOnGround &&
                !cleric.arpgDoubleJumpUsed && !cleric.arpgInventoryOpen &&
                ARPGAffixes.Has(cleric.arpgBoots, ARPGAffixes.DOUBLE_JUMP))
            {
                cleric.Vel.Z = cleric.JumpZ;
                cleric.arpgDoubleJumpUsed = true;
            }
            cleric.arpgJumpWasDown = jump;
            cleric.arpgWasOnGround = players[i].onground;

            bool shieldHeld = (players[i].cmd.buttons & BT_ALTATTACK) != 0;
            if (cleric.arpgShieldActive &&
                (!shieldHeld || cleric.arpgInventoryOpen ||
                !ARPGAffixes.Has(cleric.arpgArmor[2], ARPGAffixes.ARCANE_SHIELD) ||
                level.maptime >= cleric.arpgShieldEndAt)) cleric.EndARPGShield();
            if (!cleric.arpgShieldActive && shieldHeld && !cleric.arpgShieldWasHeld && !cleric.arpgInventoryOpen &&
                ARPGAffixes.Has(cleric.arpgArmor[2], ARPGAffixes.ARCANE_SHIELD) &&
                level.maptime >= cleric.arpgShieldReadyAt)
            {
                let shieldMana = cleric.FindInventory("Mana1");
                if (shieldMana != null && shieldMana.Amount > 0)
                {
                    cleric.arpgShieldActive = true;
                    cleric.arpgShieldEndAt = level.maptime + cleric.arpgArmor[2].affix[0].duration;
                }
            }
            cleric.arpgShieldWasHeld = shieldHeld;

            if (cleric.arpgInventoryOpen)
            {
                cleric.arpgShiftTicks = 0;
                cleric.arpgShiftWasDown = running;
                cleric.arpgSprintActive = false;
            }
            else
            {
                bool hasSprint = ARPGAffixes.Has(cleric.arpgBoots, ARPGAffixes.SPRINT);
                bool hasDash = ARPGAffixes.Has(cleric.arpgBoots, ARPGAffixes.DASH);
                if (running)
                    cleric.arpgShiftTicks++;
                else if (cleric.arpgShiftWasDown)
                {
                    if (hasDash && cleric.arpgShiftTicks > 0 &&
                        cleric.arpgShiftTicks < ARPGBalance.DASH_HOLD_TICS &&
                        level.maptime >= cleric.arpgDashReadyAt)
                    {
                        double dashAngle = cleric.Angle;
                        if (players[i].cmd.forwardmove < 0) dashAngle += 180;
                        else if (players[i].cmd.forwardmove == 0 && players[i].cmd.sidemove != 0)
                            dashAngle += players[i].cmd.sidemove > 0 ? -90 : 90;
                        cleric.Thrust(ARPGBalance.DASH_THRUST, dashAngle);
                        cleric.arpgDashReadyAt = level.maptime + ARPGBalance.DASH_COOLDOWN_TICS;
                    }
                    cleric.arpgShiftTicks = 0;
                }
                cleric.arpgSprintActive = hasSprint && moving && running &&
                    (!hasDash || cleric.arpgShiftTicks >= ARPGBalance.DASH_HOLD_TICS);
                let mana = cleric.FindInventory("Mana1");
                if (mana == null || mana.Amount <= 0) cleric.arpgSprintActive = false;
                if (cleric.arpgSprintActive)
                {
                    cleric.arpgSprintManaTicks += ARPGBalance.SPRINT_MANA_PER_SEC;
                    if (cleric.arpgSprintManaTicks >= 35)
                    {
                        cleric.arpgSprintManaTicks -= 35;
                        cleric.TakeInventory("Mana1", 1);
                    }
                }
                else cleric.arpgSprintManaTicks = 0;
                cleric.arpgShiftWasDown = running;
            }
            if (cleric.arpgSprintActive) continue;
            int regenBonus = cleric.arpgArmor[0].damage > 0 ? cleric.arpgArmor[0].statRegen : 0;
            for (int ring = 3; ring <= 4; ring++)
                if (cleric.arpgArmor[ring].damage > 0)
                    regenBonus += cleric.arpgArmor[ring].greenUpgrades;
            cleric.arpgManaTicks += 100 + regenBonus;
            if (cleric.arpgManaTicks >= ARPGBalance.BLUE_REGEN_TICS * 100)
            {
                cleric.arpgManaTicks -= ARPGBalance.BLUE_REGEN_TICS * 100;
                cleric.GiveInventory("Mana1", 1);
            }
        }
    }
}
