class ARPGCleric : ClericPlayer
{
    int arpgLevel;
    int arpgXP;
    int arpgNextXP;
    int arpgManaTicks;
    ARPGGroundWeapon arpgLookDrop;

    Default
    {
        Player.StartItem "ARPGMace";
        Player.StartItem "ARPGSword";
        Player.StartItem "ARPGLightning";
        Player.StartItem "Mana1", ARPGBalance.START_MANA1;
        Player.StartItem "Mana2", ARPGBalance.START_MANA2;
        Player.WeaponSlot 1, "ARPGMace";
        Player.WeaponSlot 2, "ARPGSword";
        Player.WeaponSlot 3, "ARPGLightning";
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
