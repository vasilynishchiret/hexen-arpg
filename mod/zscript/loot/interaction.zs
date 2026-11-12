class ARPGInteraction : ARPGEquipment
{
    int useWasDown[MAXPLAYERS];

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
                cleric.arpgLookDrop = FindTarget(cleric);
                if (down && useWasDown[i] == 0 && cleric.arpgLookDrop != null)
                    Exchange(cleric, cleric.arpgLookDrop);
            }
            useWasDown[i] = down;
        }
    }
}