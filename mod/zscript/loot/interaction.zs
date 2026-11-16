class ARPGInteraction : ARPGEquipment
{
    int useWasDown[MAXPLAYERS];

    void DropBagItem(ARPGCleric cleric, int index)
    {
        if (index < 0 || index >= 20 || cleric.arpgBag[index].damage <= 0) return;
        let dropped = ARPGGroundWeapon(Actor.Spawn("ARPGGroundWeapon", cleric.Pos));
        if (dropped == null) return;
        ARPGAffixes.Copy(dropped.loot, cleric.arpgBag[index]);
        dropped.RefreshAppearance();
        dropped.pickupBlockOwner = cleric;
        dropped.pickupBlockUntil = level.maptime + 35;
        cleric.arpgBag[index].damage = 0;
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        let cleric = ARPGCleric(players[e.Player].mo);
        if (cleric == null || cleric.health <= 0) return;
        if (e.Name == "arpg_invisibility") { cleric.ActivateARPGInvisibility(); return; }
        if (e.Name == "arpg_detection") { cleric.ActivateARPGDetection(); return; }
        if (e.Name == "arpg_inventory_state")
        {
            cleric.arpgInventoryOpen = e.Args[0] != 0;
            return;
        }
        if (e.Name == "arpg_auto_equip")
        {
            int bagSlot = e.Args[0];
            int target = cleric.AutoEquipTarget(bagSlot, e.Args[1]);
            if (target == 0 || !cleric.EquipBagItem(bagSlot, target))
                cleric.A_PrintBold("Cannot equip item", 2.0);
            else cleric.arpgEquipTarget = target;
        }
        else if (e.Name == "arpg_slot_equip")
        {
            if (!cleric.EquipBagItem(e.Args[0], e.Args[1]))
                cleric.A_PrintBold("Cannot equip in this slot", 2.0);
            else cleric.arpgEquipTarget = e.Args[1];
        }
        else if (e.Name == "arpg_slot_unequip")
        {
            if (!cleric.UnequipItem(e.Args[0]))
                cleric.A_PrintBold("No free space or slot is empty", 2.0);
        }
        else if (e.Name == "arpg_slot_drop") DropBagItem(cleric, e.Args[0]);
        else if (!cleric.arpgInventoryOpen) return;
        else if (e.Name == "arpg_prev") cleric.arpgSelectedItem = (cleric.arpgSelectedItem + 19) % 20;
        else if (e.Name == "arpg_next") cleric.arpgSelectedItem = (cleric.arpgSelectedItem + 1) % 20;
        else if (e.Name == "arpg_target_prev") cleric.arpgEquipTarget = cleric.arpgEquipTarget <= 1 ? 9 : cleric.arpgEquipTarget - 1;
        else if (e.Name == "arpg_target_next") cleric.arpgEquipTarget = cleric.arpgEquipTarget >= 9 ? 1 : cleric.arpgEquipTarget + 1;
        else if (e.Name == "arpg_equip")
        {
            if (!cleric.EquipBagItem(cleric.arpgSelectedItem, cleric.arpgEquipTarget))
                cleric.A_PrintBold("Cannot equip in this slot", 2.0);
        }
        else if (e.Name == "arpg_unequip")
        {
            if (!cleric.UnequipItem(cleric.arpgEquipTarget))
                cleric.A_PrintBold("No free space or slot is empty", 2.0);
        }
        else if (e.Name == "arpg_drop")
        {
            DropBagItem(cleric, cleric.arpgSelectedItem);
        }
    }

    ARPGGroundWeapon FindTarget(ARPGCleric cleric)
    {
        if (cleric == null || cleric.health <= 0) return null;
        let it = ThinkerIterator.Create("ARPGGroundWeapon");
        ARPGGroundWeapon item;
        ARPGGroundWeapon best;
        double bestDistance = ARPGBalance.LOOT_INTERACT_RANGE;
        while ((item = ARPGGroundWeapon(it.Next())) != null)
        {
            double distance = cleric.Distance2D(item);
            if (distance > bestDistance || abs(item.Pos.Z - cleric.Pos.Z) > 64) continue;
            if (item.pickupBlockOwner == cleric && level.maptime < item.pickupBlockUntil) continue;
            double yaw = abs(cleric.AngleTo(item) - cleric.Angle);
            if (yaw > 180) yaw = 360 - yaw;
            if (yaw > 13) continue;
            double pitch = abs(cleric.PitchTo(item, cleric.ViewHeight, item.Height * 0.5) - cleric.Pitch);
            if (pitch > 18 || !cleric.CheckSight(item)) continue;
            best = item;
            bestDistance = distance;
        }
        return best;
    }

    override void WorldTick()
    {
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            let cleric = ARPGCleric(players[i].mo);
            bool down = (players[i].cmd.buttons & BT_USE) != 0;
            if (cleric != null)
            {
                if (!ARPGAffixes.Has(cleric.arpgArmor[1], ARPGAffixes.INVISIBILITY) &&
                    cleric.FindInventory("ARPGStealthPower") != null)
                    cleric.TakeInventory("ARPGStealthPower", 1);
                if (!ARPGAffixes.Has(cleric.arpgArmor[1], ARPGAffixes.ENEMY_DETECTION))
                    cleric.arpgDetectEndAt = 0;
                cleric.arpgDetectCount = 0;
                if (level.maptime < cleric.arpgDetectEndAt)
                {
                    let enemies = ThinkerIterator.Create("Actor");
                    Actor enemy;
                    while ((enemy = Actor(enemies.Next())) != null)
                    {
                        if (!enemy.bIsMonster || enemy.bFriendly || enemy.health <= 0) continue;
                        int distance = int(cleric.Distance2D(enemy));
                        if (distance > ARPGBalance.DETECT_RADIUS) continue;
                        int at = cleric.arpgDetectCount;
                        while (at > 0 && distance < cleric.arpgDetectDistance[at - 1]) at--;
                        if (at >= 8) continue;
                        if (cleric.arpgDetectCount < 8) cleric.arpgDetectCount++;
                        for (int j = cleric.arpgDetectCount - 1; j > at; j--)
                        {
                            cleric.arpgDetectDistance[j] = cleric.arpgDetectDistance[j - 1];
                            cleric.arpgDetectAngle[j] = cleric.arpgDetectAngle[j - 1];
                        }
                        cleric.arpgDetectDistance[at] = distance;
                        cleric.arpgDetectAngle[at] = int(Actor.deltaangle(cleric.Angle, cleric.AngleTo(enemy)));
                    }
                }
                cleric.arpgActiveSlot = ActiveSlot(cleric);
                cleric.arpgComparedWeapon = SlotWeapon(cleric, cleric.arpgActiveSlot);
                cleric.arpgLookDrop = FindTarget(cleric);
                if (down && useWasDown[i] == 0 && cleric.arpgLookDrop != null)
                {
                    let ground = cleric.arpgLookDrop;
                    if (cleric.StoreData(ground.loot))
                    {
                        if (ground.special != 0)
                            level.ExecuteSpecial(ground.special, cleric, null, false,
                                ground.args[0], ground.args[1], ground.args[2], ground.args[3], ground.args[4]);
                        ground.Destroy();
                        cleric.arpgLookDrop = null;
                    }
                    else cleric.A_PrintBold("Inventory full (20/20)", 2.0);
                }
            }
            useWasDown[i] = down;
        }
    }
}
