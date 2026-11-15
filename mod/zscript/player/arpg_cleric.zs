class ARPGCleric : ClericPlayer
{
    int arpgLevel;
    int arpgXP;
    int arpgNextXP;
    int arpgManaTicks;
    int arpgAttackCooldown;
    bool arpgHealthMigrated;
    ARPGGroundWeapon arpgLookDrop;
    ARPGEquippedWeapon arpgComparedWeapon;
    int arpgActiveSlot;
    ARPGWeaponData arpgBag[20];
    ARPGWeaponData arpgArmor[5];
    bool arpgInventoryOpen;
    int arpgSelectedItem;
    int arpgEquipTarget;

    Default
    {
        Health ARPGBalance.BASE_HEALTH;
        Player.MaxHealth ARPGBalance.BASE_HEALTH;
        Player.Hexenarmor 0, 0, 0, 0, 0;
        Player.StartItem "ARPGSlot1";
        Player.StartItem "ARPGSlot2";
        Player.StartItem "ARPGSlot3";
        Player.StartItem "ARPGArmorEffect";
        Player.StartItem "Mana1", ARPGBalance.START_MANA1;
        Player.StartItem "Mana2", ARPGBalance.START_MANA2;
        Player.WeaponSlot 1, "ARPGSlot1";
        Player.WeaponSlot 2, "ARPGSlot2";
        Player.WeaponSlot 3, "ARPGSlot3";
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        if (arpgLevel == 0)
        {
            arpgLevel = 1;
            arpgNextXP = ARPGBalance.START_XP;
        }
    }

    override int GetMaxHealth(bool withupgrades) const
    {
        int rings = 0;
        if (arpgArmor[3].damage > 0) rings += 5;
        if (arpgArmor[4].damage > 0) rings += 5;
        return Super.GetMaxHealth(withupgrades) + ARPGBalance.HP_PER_LEVEL * max(0, arpgLevel - 1) + rings;
    }

    int FirstFreeBagSlot()
    {
        for (int i = 0; i < 20; i++) if (arpgBag[i].damage == 0) return i;
        return -1;
    }

    bool StoreItem(int kind, int damage, int speed, int manaCost)
    {
        int slot = FirstFreeBagSlot();
        if (slot < 0) return false;
        arpgBag[slot].kind = kind;
        arpgBag[slot].damage = damage;
        arpgBag[slot].speed = speed;
        arpgBag[slot].manaCost = manaCost;
        return true;
    }

    int AutoEquipTarget(int bagSlot, int preferredRing)
    {
        if (bagSlot < 0 || bagSlot >= 20 || arpgBag[bagSlot].damage <= 0) return 0;
        int kind = arpgBag[bagSlot].kind;
        if (kind == 10) return 4;
        if (kind == 11) return 5;
        if (kind == 12) return 6;
        if (kind == 13)
        {
            if (arpgArmor[3].damage <= 0) return 7;
            if (arpgArmor[4].damage <= 0) return 8;
            return preferredRing == 8 ? 8 : 7;
        }
        if (kind < 0 || kind >= 10) return 0;
        for (int slot = 1; slot <= 3; slot++)
        {
            let weapon = ARPGEquippedWeapon(FindInventory(String.Format("ARPGSlot%d", slot)));
            if (weapon != null && weapon.loot.damage <= 0) return slot;
        }
        return arpgActiveSlot >= 1 && arpgActiveSlot <= 3 ? arpgActiveSlot : 1;
    }

    bool EquipBagItem(int bagSlot, int equipSlot)
    {
        if (bagSlot < 0 || bagSlot >= 20 || arpgBag[bagSlot].damage == 0) return false;
        int kind = arpgBag[bagSlot].kind;
        int damage = arpgBag[bagSlot].damage;
        int speed = arpgBag[bagSlot].speed;
        int manaCost = arpgBag[bagSlot].manaCost;
        if (kind < 10)
        {
            if (equipSlot < 1 || equipSlot > 3) return false;
            ARPGEquippedWeapon weapon = ARPGEquippedWeapon(FindInventory(String.Format("ARPGSlot%d", equipSlot)));
            if (weapon == null) return false;
            arpgBag[bagSlot].kind = weapon.loot.kind;
            arpgBag[bagSlot].damage = weapon.loot.damage;
            arpgBag[bagSlot].speed = weapon.loot.speed;
            arpgBag[bagSlot].manaCost = weapon.loot.manaCost;
            weapon.loot.kind = kind;
            weapon.loot.damage = damage;
            weapon.loot.speed = speed;
            weapon.loot.manaCost = manaCost;
            weapon.SetTag(ARPGWeaponRules.TypeName(kind));
            if (player != null && player.ReadyWeapon == weapon)
                player.SetPsprite(PSP_WEAPON, weapon.GetReadyState());
            return true;
        }
        int armorSlot = equipSlot - 4;
        if (armorSlot < 0 || armorSlot > 4) return false;
        if (kind != (armorSlot >= 3 ? 13 : armorSlot + 10)) return false;
        arpgBag[bagSlot].kind = arpgArmor[armorSlot].kind;
        arpgBag[bagSlot].damage = arpgArmor[armorSlot].damage;
        arpgBag[bagSlot].speed = arpgArmor[armorSlot].speed;
        arpgBag[bagSlot].manaCost = arpgArmor[armorSlot].manaCost;
        arpgArmor[armorSlot].kind = kind;
        arpgArmor[armorSlot].damage = damage;
        arpgArmor[armorSlot].speed = speed;
        arpgArmor[armorSlot].manaCost = manaCost;
        if (health > GetMaxHealth()) health = GetMaxHealth();
        if (player != null) player.health = health;
        return true;
    }

    bool UnequipItem(int equipSlot)
    {
        if (FirstFreeBagSlot() < 0) return false;
        if (equipSlot >= 1 && equipSlot <= 3)
        {
            ARPGEquippedWeapon weapon = ARPGEquippedWeapon(FindInventory(String.Format("ARPGSlot%d", equipSlot)));
            if (weapon == null || weapon.loot.damage == 0) return false;
            if (!StoreItem(weapon.loot.kind, weapon.loot.damage, weapon.loot.speed, weapon.loot.manaCost)) return false;
            weapon.loot.damage = 0;
            weapon.loot.kind = -1;
            weapon.SetTag("Empty weapon slot");
            if (player != null && player.ReadyWeapon == weapon)
                player.SetPsprite(PSP_WEAPON, weapon.GetReadyState());
            return true;
        }
        int armorSlot = equipSlot - 4;
        if (armorSlot < 0 || armorSlot > 4 || arpgArmor[armorSlot].damage == 0) return false;
        if (!StoreItem(arpgArmor[armorSlot].kind, arpgArmor[armorSlot].damage, arpgArmor[armorSlot].speed, arpgArmor[armorSlot].manaCost)) return false;
        arpgArmor[armorSlot].damage = 0;
        health = min(health, GetMaxHealth());
        if (player != null) player.health = health;
        return true;
    }

    override void FireWeapon(State stat)
    {
        if (arpgAttackCooldown > 0 && player != null && player.ReadyWeapon is "ARPGEquippedWeapon") return;
        Super.FireWeapon(stat);
    }

    void MigrateHealthLimit()
    {
        if (arpgHealthMigrated) return;
        arpgHealthMigrated = true;
        if (health > GetMaxHealth())
        {
            health = GetMaxHealth();
            if (player != null) player.health = health;
        }
    }

    void AddXP(int amount)
    {
        if (amount <= 0) return;
        arpgXP += amount;
        while (arpgXP >= arpgNextXP)
        {
            arpgXP -= arpgNextXP;
            arpgLevel++;
            arpgNextXP = (arpgNextXP * ARPGBalance.XP_GROWTH_PERCENT + 50) / 100;
            health += ARPGBalance.HP_PER_LEVEL;
            if (player != null) player.health = health;
            A_PrintBold(String.Format("Level Up! Level %d", arpgLevel), 3.0);
        }
    }
}
