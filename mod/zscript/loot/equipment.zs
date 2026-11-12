class ARPGEquipment : EventHandler
{
    bool Exchange(ARPGCleric cleric, ARPGGroundWeapon ground)
    {
        if (cleric == null || ground == null || cleric.health <= 0) return false;
        let weapon = ARPGSword(cleric.FindInventory("ARPGSword"));
        if (weapon == null || ground.loot.damage <= 0) return false;

        ARPGWeaponData old;
        old.kind = weapon.loot.kind;
        old.damage = weapon.loot.damage;
        old.speed = weapon.loot.speed;
        old.manaCost = weapon.loot.manaCost;
        if (old.damage <= 0)
        {
            old.kind = 0;
            old.damage = ARPGBalance.SWORD_DAMAGE;
            old.speed = 0;
            old.manaCost = ARPGBalance.SWORD_MANA_COST;
        }

        let dropped = ARPGGroundWeapon(Actor.Spawn("ARPGGroundWeapon", ground.Pos));
        if (dropped == null) return false;
        dropped.loot.kind = old.kind;
        dropped.loot.damage = old.damage;
        dropped.loot.speed = old.speed;
        dropped.loot.manaCost = old.manaCost;
        weapon.loot.kind = ground.loot.kind;
        weapon.loot.damage = ground.loot.damage;
        weapon.loot.speed = ground.loot.speed;
        weapon.loot.manaCost = ground.loot.manaCost;
        weapon.AmmoUse1 = weapon.loot.manaCost;
        weapon.SetTag(ARPGWeaponRules.TypeName(weapon.loot.kind));
        ground.Destroy();
        cleric.arpgLookDrop = null;

        if (cleric.player != null)
        {
            if (cleric.player.ReadyWeapon == weapon)
                cleric.player.SetPsprite(PSP_WEAPON, weapon.GetReadyState());
            else
                cleric.player.PendingWeapon = weapon;
        }
        return true;
    }
}
