class ARPGEquipment : EventHandler
{
    ARPGEquippedWeapon SlotWeapon(ARPGCleric cleric, int slot)
    {
        if (cleric == null) return null;
        if (slot == 1) return ARPGEquippedWeapon(cleric.FindInventory("ARPGSlot1"));
        if (slot == 2) return ARPGEquippedWeapon(cleric.FindInventory("ARPGSlot2"));
        if (slot == 3) return ARPGEquippedWeapon(cleric.FindInventory("ARPGSlot3"));
        return null;
    }

    int ActiveSlot(ARPGCleric cleric)
    {
        if (cleric == null || cleric.player == null) return 0;
        let pending = ARPGEquippedWeapon(cleric.player.PendingWeapon);
        if (pending != null) return pending.equipmentSlot;
        let ready = ARPGEquippedWeapon(cleric.player.ReadyWeapon);
        return ready != null ? ready.equipmentSlot : 1;
    }

    bool Exchange(ARPGCleric cleric, ARPGGroundWeapon ground)
    {
        if (cleric == null || ground == null || cleric.health <= 0) return false;
        if (ground.pickupBlockOwner == cleric && level.maptime < ground.pickupBlockUntil) return false;
        int slot = ActiveSlot(cleric);
        let weapon = SlotWeapon(cleric, slot);
        if (weapon == null || ground.loot.damage <= 0) return false;

        ARPGWeaponData old;
        old.kind = weapon.loot.kind;
        old.damage = weapon.loot.damage;
        old.speed = weapon.loot.speed;
        old.manaCost = weapon.loot.manaCost;
        let dropped = ARPGGroundWeapon(Actor.Spawn("ARPGGroundWeapon", ground.Pos));
        if (dropped == null) return false;
        dropped.loot.kind = old.kind;
        dropped.loot.damage = old.damage;
        dropped.loot.speed = old.speed;
        dropped.loot.manaCost = old.manaCost;
        dropped.RefreshAppearance();
        dropped.pickupBlockOwner = cleric;
        dropped.pickupBlockUntil = level.maptime + 35;

        weapon.loot.kind = ground.loot.kind;
        weapon.loot.damage = ground.loot.damage;
        weapon.loot.speed = ground.loot.speed;
        weapon.loot.manaCost = ground.loot.manaCost;
        weapon.SetTag(ARPGWeaponRules.TypeName(weapon.loot.kind));
        ground.Destroy();
        cleric.arpgLookDrop = null;
        if (cleric.player.ReadyWeapon == weapon)
            cleric.player.SetPsprite(PSP_WEAPON, weapon.GetReadyState());
        else
            cleric.player.PendingWeapon = weapon;
        return true;
    }
}
