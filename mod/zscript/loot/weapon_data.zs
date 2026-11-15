struct ARPGWeaponData
{
    int kind;       // 0 Sword, 1 Axe, 2 Hammer, 3 Mace, 4 Lightning
    int damage;
    int speed;      // 0 fast, 1 medium, 2 slow
    int manaCost;
}

class ARPGWeaponRules : Object
{
    clearscope static string TypeName(int kind)
    {
        if (kind == 1) return "Axe";
        if (kind == 2) return "Hammer";
        if (kind == 3) return "Mace";
        if (kind == 4) return "Lightning";
        return "Sword";
    }

    clearscope static string SpeedName(int speed)
    {
        if (speed == 1) return "Medium";
        if (speed == 2) return "Slow";
        return "Fast";
    }

    clearscope static int BaseDamage(int kind)
    {
        if (kind == 1) return ARPGBalance.AXE_DAMAGE;
        if (kind == 2) return ARPGBalance.HAMMER_DAMAGE;
        return ARPGBalance.SWORD_DAMAGE;
    }

    static int RollDamage(int kind)
    {
        int band = random[ARPGLootBand](0, 99);
        int multiplier;
        if (band < ARPGBalance.LOOT_COMMON_PERCENT)
            multiplier = random[ARPGLootCommon](ARPGBalance.LOOT_COMMON_MIN, ARPGBalance.LOOT_COMMON_MAX);
        else if (band < ARPGBalance.LOOT_COMMON_PERCENT + ARPGBalance.LOOT_STRONG_PERCENT)
            multiplier = random[ARPGLootStrong](ARPGBalance.LOOT_STRONG_MIN, ARPGBalance.LOOT_STRONG_MAX);
        else
            multiplier = random[ARPGLootExceptional](ARPGBalance.LOOT_EXCEPTIONAL_MIN, ARPGBalance.LOOT_EXCEPTIONAL_MAX);
        return max(1, (BaseDamage(kind) * multiplier + ARPGBalance.LOOT_MULTIPLIER_SCALE / 2) / ARPGBalance.LOOT_MULTIPLIER_SCALE);
    }

    clearscope static int AttackTics(int kind)
    {
        if (kind == 1) return ARPGBalance.AXE_ATTACK_TICS;
        if (kind == 2) return ARPGBalance.HAMMER_ATTACK_TICS;
        if (kind == 3) return ARPGBalance.MACE_ATTACK_TICS;
        if (kind == 4) return ARPGBalance.LIGHTNING_ATTACK_TICS;
        return ARPGBalance.SWORD_ATTACK_TICS;
    }

    clearscope static int AverageDamage(int kind, int damage)
    {
        if (kind == 3) return 65;
        if (kind == 4) return 0;
        return damage;
    }

    clearscope static int ManaCost(int kind)
    {
        if (kind == 3) return 0;
        if (kind == 4) return 5;
        if (kind == 1) return 4;
        if (kind == 2) return 6;
        return 3;
    }

    clearscope static string ManaName(int kind)
    {
        if (kind == 3) return "No mana";
        if (kind == 4) return "Mana2";
        return "Mana1";
    }
}
