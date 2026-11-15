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

    Default
    {
        Health ARPGBalance.BASE_HEALTH;
        Player.MaxHealth ARPGBalance.BASE_HEALTH;
        Player.StartItem "ARPGSlot1";
        Player.StartItem "ARPGSlot2";
        Player.StartItem "ARPGSlot3";
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
        return Super.GetMaxHealth(withupgrades) + ARPGBalance.HP_PER_LEVEL * max(0, arpgLevel - 1);
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
