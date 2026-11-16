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
    ARPGWeaponData arpgBoots;
    int arpgShiftTicks;
    bool arpgShiftWasDown;
    bool arpgJumpWasDown;
    bool arpgDoubleJumpUsed;
    bool arpgWasOnGround;
    bool arpgSprintActive;
    int arpgSprintManaTicks;
    int arpgDashReadyAt;
    bool arpgShieldActive;
    bool arpgShieldWasHeld;
    int arpgShieldEndAt;
    int arpgShieldReadyAt;
    int arpgGuardianReadyAt;
    int arpgInvisEndAt;
    int arpgInvisReadyAt;
    int arpgDetectEndAt;
    int arpgDetectReadyAt;
    int arpgDetectCount;
    int arpgDetectAngle[8];
    int arpgDetectDistance[8];
    int arpgGreenTicks;
    int arpgAuraTicks;
    int arpgVampRemainder;
    bool arpgInventoryOpen;
    Array<String> arpgReinforcementMaps;
    Array<int> arpgReinforcementTotals;
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
        int chestHP = arpgArmor[0].damage > 0 ? arpgArmor[0].statHP : 0;
        return Super.GetMaxHealth(withupgrades) + ARPGBalance.HP_PER_LEVEL * max(0, arpgLevel - 1) + rings + chestHP;
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

    bool StoreData(ARPGWeaponData item)
    {
        int slot = FirstFreeBagSlot();
        if (slot < 0) return false;
        ARPGAffixes.Copy(arpgBag[slot], item);
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
        if (kind == 14) return 9;
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
        ARPGWeaponData item;
        ARPGAffixes.Copy(item, arpgBag[bagSlot]);
        if (kind < 10)
        {
            if (equipSlot < 1 || equipSlot > 3) return false;
            ARPGEquippedWeapon weapon = ARPGEquippedWeapon(FindInventory(String.Format("ARPGSlot%d", equipSlot)));
            if (weapon == null) return false;
            ARPGAffixes.Copy(arpgBag[bagSlot], weapon.loot);
            ARPGAffixes.Copy(weapon.loot, item);
            weapon.SetTag(ARPGWeaponRules.TypeName(kind));
            if (player != null && player.ReadyWeapon == weapon)
                player.SetPsprite(PSP_WEAPON, weapon.GetReadyState());
            return true;
        }
        if (kind == 14)
        {
            if (equipSlot != 9) return false;
            ARPGAffixes.Copy(arpgBag[bagSlot], arpgBoots);
            ARPGAffixes.Copy(arpgBoots, item);
            return true;
        }
        int armorSlot = equipSlot - 4;
        if (armorSlot < 0 || armorSlot > 4) return false;
        if (kind != (armorSlot >= 3 ? 13 : armorSlot + 10)) return false;
        ARPGAffixes.Copy(arpgBag[bagSlot], arpgArmor[armorSlot]);
        ARPGAffixes.Copy(arpgArmor[armorSlot], item);
        if (health > GetMaxHealth()) health = GetMaxHealth();
        if (player != null) player.health = health;
        return true;
    }

    bool UnequipItem(int equipSlot)
    {
        if (FirstFreeBagSlot() < 0) return false;
        if (equipSlot == 9)
        {
            if (arpgBoots.damage <= 0 || !StoreData(arpgBoots)) return false;
            ARPGWeaponData empty;
            ARPGAffixes.Copy(arpgBoots, empty);
            arpgSprintActive = false;
            return true;
        }
        if (equipSlot >= 1 && equipSlot <= 3)
        {
            ARPGEquippedWeapon weapon = ARPGEquippedWeapon(FindInventory(String.Format("ARPGSlot%d", equipSlot)));
            if (weapon == null || weapon.loot.damage == 0) return false;
            if (!StoreData(weapon.loot)) return false;
            weapon.loot.damage = 0;
            weapon.loot.kind = -1;
            weapon.SetTag("Empty weapon slot");
            if (player != null && player.ReadyWeapon == weapon)
                player.SetPsprite(PSP_WEAPON, weapon.GetReadyState());
            return true;
        }
        int armorSlot = equipSlot - 4;
        if (armorSlot < 0 || armorSlot > 4 || arpgArmor[armorSlot].damage == 0) return false;
        if (!StoreData(arpgArmor[armorSlot])) return false;
        ARPGWeaponData empty;
        ARPGAffixes.Copy(arpgArmor[armorSlot], empty);
        health = min(health, GetMaxHealth());
        if (player != null) player.health = health;
        return true;
    }

    override void FireWeapon(State stat)
    {
        if (arpgAttackCooldown > 0 && player != null && player.ReadyWeapon is "ARPGEquippedWeapon") return;
        Super.FireWeapon(stat);
    }

    override int DamageMobj(Actor inflictor, Actor source, int damage, Name mod,
        int flags, double angle)
    {
        if (damage > 0 && health > 0 &&
            ARPGAffixes.Has(arpgArmor[2], ARPGAffixes.GUARDIAN) &&
            level.maptime >= arpgGuardianReadyAt)
        {
            arpgGuardianReadyAt = level.maptime + ARPGBalance.GUARDIAN_COOLDOWN_TICS;
            return 0;
        }
        if (damage > 0 && arpgShieldActive &&
            ARPGAffixes.Has(arpgArmor[2], ARPGAffixes.ARCANE_SHIELD))
        {
            let mana = FindInventory("Mana1");
            if (mana != null && mana.Amount > 0)
            {
                int desired = damage * ARPGBalance.SHIELD_BLOCK_PERCENT / 100;
                int absorbed = min(desired, mana.Amount * 2);
                int spent = (absorbed + 1) / 2;
                bool depleted = spent >= mana.Amount;
                TakeInventory("Mana1", spent);
                damage -= absorbed;
                if (depleted) EndARPGShield();
            }
            else EndARPGShield();
        }
        return Super.DamageMobj(inflictor, source, damage, mod, flags, angle);
    }

    void EndARPGShield()
    {
        if (!arpgShieldActive) return;
        arpgShieldActive = false;
        arpgShieldReadyAt = level.maptime + ARPGBalance.SHIELD_COOLDOWN_TICS;
    }

    void ActivateARPGInvisibility()
    {
        if (!ARPGAffixes.Has(arpgArmor[1], ARPGAffixes.INVISIBILITY) ||
            level.maptime < arpgInvisReadyAt || arpgInventoryOpen) return;
        GiveInventory("ARPGStealthPower", 1);
        arpgInvisEndAt = level.maptime + ARPGBalance.INVIS_TICS;
        arpgInvisReadyAt = arpgInvisEndAt + ARPGBalance.INVIS_COOLDOWN_TICS;
        // Break existing pursuit as well as applying native Shadow targeting.
        let it = ThinkerIterator.Create("Actor");
        Actor enemy;
        while ((enemy = Actor(it.Next())) != null)
            if (enemy.bIsMonster && !enemy.bFriendly && enemy.target == self)
                enemy.target = null;
    }

    void ActivateARPGDetection()
    {
        if (!ARPGAffixes.Has(arpgArmor[1], ARPGAffixes.ENEMY_DETECTION) ||
            level.maptime < arpgDetectReadyAt || arpgInventoryOpen) return;
        arpgDetectEndAt = level.maptime + ARPGBalance.DETECT_TICS;
        arpgDetectReadyAt = arpgDetectEndAt + ARPGBalance.DETECT_COOLDOWN_TICS;
    }

    override double, double TweakSpeeds(double forward, double side)
    {
        // Clamp native run input before applying the ordinary walking multipliers.
        forward = clamp(forward, -gameinfo.normforwardmove[0] * 256,
            gameinfo.normforwardmove[0] * 256);
        side = clamp(side, -gameinfo.normsidemove[0] * 256,
            gameinfo.normsidemove[0] * 256);
        double fm, sm;
        [fm, sm] = Super.TweakSpeeds(forward, side);
        if (arpgSprintActive)
        {
            fm *= double(ARPGBalance.SPRINT_PERCENT) / 100;
            sm *= double(ARPGBalance.SPRINT_PERCENT) / 100;
        }
        return fm, sm;
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

    void SyncARPGManaCapacity()
    {
        let mana1 = Ammo(FindInventory("Mana1"));
        let mana2 = Ammo(FindInventory("Mana2"));
        int bonus1 = arpgArmor[0].damage > 0 ? arpgArmor[0].statMana1 : 0;
        int bonus2 = arpgArmor[0].damage > 0 ? arpgArmor[0].statMana2 : 0;
        if (mana1 != null)
        {
            mana1.MaxAmount = ARPGBalance.BASE_MANA_MAX + bonus1;
            mana1.Amount = min(mana1.Amount, mana1.MaxAmount);
        }
        if (mana2 != null)
        {
            mana2.MaxAmount = ARPGBalance.BASE_MANA_MAX + bonus2;
            mana2.Amount = min(mana2.Amount, mana2.MaxAmount);
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
