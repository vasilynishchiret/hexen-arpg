class ARPGInteraction : ARPGEquipment
{
    int useWasDown[MAXPLAYERS];

    override void NetworkProcess(ConsoleEvent e)
    {
        let cleric = ARPGCleric(players[e.Player].mo);
        if (cleric == null || cleric.health <= 0) return;
        if (e.Name == "arpg_inventory")
        {
            cleric.arpgInventoryOpen = !cleric.arpgInventoryOpen;
            if (cleric.arpgEquipTarget < 1) cleric.arpgEquipTarget = 1;
            return;
        }
        if (!cleric.arpgInventoryOpen) return;
        if (e.Name == "arpg_prev") cleric.arpgSelectedItem = (cleric.arpgSelectedItem + 19) % 20;
        else if (e.Name == "arpg_next") cleric.arpgSelectedItem = (cleric.arpgSelectedItem + 1) % 20;
        else if (e.Name == "arpg_target_prev") cleric.arpgEquipTarget = cleric.arpgEquipTarget <= 1 ? 8 : cleric.arpgEquipTarget - 1;
        else if (e.Name == "arpg_target_next") cleric.arpgEquipTarget = cleric.arpgEquipTarget >= 8 ? 1 : cleric.arpgEquipTarget + 1;
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
            int index = cleric.arpgSelectedItem;
            if (cleric.arpgBag[index].damage == 0) return;
            let dropped = ARPGGroundWeapon(Actor.Spawn("ARPGGroundWeapon", cleric.Pos));
            if (dropped == null) return;
            dropped.loot.kind = cleric.arpgBag[index].kind;
            dropped.loot.damage = cleric.arpgBag[index].damage;
            dropped.loot.speed = cleric.arpgBag[index].speed;
            dropped.loot.manaCost = cleric.arpgBag[index].manaCost;
            dropped.RefreshAppearance();
            dropped.pickupBlockOwner = cleric;
            dropped.pickupBlockUntil = level.maptime + 35;
            cleric.arpgBag[index].damage = 0;
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
                cleric.arpgActiveSlot = ActiveSlot(cleric);
                cleric.arpgComparedWeapon = SlotWeapon(cleric, cleric.arpgActiveSlot);
                cleric.arpgLookDrop = FindTarget(cleric);
                if (down && useWasDown[i] == 0 && cleric.arpgLookDrop != null)
                {
                    let ground = cleric.arpgLookDrop;
                    if (cleric.StoreItem(ground.loot.kind, ground.loot.damage, ground.loot.speed, ground.loot.manaCost))
                    {
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
