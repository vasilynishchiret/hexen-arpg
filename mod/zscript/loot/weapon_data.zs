struct ARPGGameplayAffix
{
    int id;
    int category;
    int effect;
    int power;
    int duration;
    int cooldown;
    int manaCost;
}

struct ARPGWeaponData
{
    int kind;       // 0..9 weapons, 10 Chest, 11 Helmet, 12 Bracers, 13 Ring
    int damage;
    int speed;      // 0 fast, 1 medium, 2 slow
    int manaCost;
    int affixCount;
    ARPGGameplayAffix affix[4];
    int statHP;
    int statDR;
    int statMana1;
    int statMana2;
    int statRegen;
    int damageType; // reserved for elemental weapon affixes
}

class ARPGAffixes : Object
{
    const CAT_BOOTS = 14;
    const CAT_BRACERS = 12;
    const CAT_HELMET = 11;
    const CAT_RING = 13;
    const SPRINT = 1;
    const DASH = 2;
    const DOUBLE_JUMP = 3;
    const ARCANE_SHIELD = 4;
    const GUARDIAN = 5;
    const INVISIBILITY = 6;
    const ENEMY_DETECTION = 7;
    const GREEN_REGEN = 8;
    const VAMPIRISM = 9;
    const DAMAGE_AURA = 10;

    static void Copy(out ARPGWeaponData dest, ARPGWeaponData src)
    {
        dest.kind = src.kind;
        dest.damage = src.damage;
        dest.speed = src.speed;
        dest.manaCost = src.manaCost;
        dest.affixCount = src.affixCount;
        for (int i = 0; i < 4; i++)
        {
            dest.affix[i].id = src.affix[i].id;
            dest.affix[i].category = src.affix[i].category;
            dest.affix[i].effect = src.affix[i].effect;
            dest.affix[i].power = src.affix[i].power;
            dest.affix[i].duration = src.affix[i].duration;
            dest.affix[i].cooldown = src.affix[i].cooldown;
            dest.affix[i].manaCost = src.affix[i].manaCost;
        }
        dest.statHP = src.statHP;
        dest.statDR = src.statDR;
        dest.statMana1 = src.statMana1;
        dest.statMana2 = src.statMana2;
        dest.statRegen = src.statRegen;
        dest.damageType = src.damageType;
    }

    clearscope static bool Has(ARPGWeaponData item, int id)
    {
        if (item.damage <= 0) return false;
        for (int i = 0; i < item.affixCount; i++)
            if (item.affix[i].id == id) return true;
        return false;
    }

    static void Add(out ARPGWeaponData item, int id, int category, int power = 0,
        int duration = 0, int cooldown = 0, int manaCost = 0)
    {
        if (item.affixCount >= 4 || Has(item, id)) return;
        int i = item.affixCount++;
        item.affix[i].id = id;
        item.affix[i].category = category;
        item.affix[i].effect = id;
        item.affix[i].power = power;
        item.affix[i].duration = duration;
        item.affix[i].cooldown = cooldown;
        item.affix[i].manaCost = manaCost;
    }

    static void RollBoots(out ARPGWeaponData item)
    {
        int roll = random[ARPGMobilityCount](0, 99);
        int count = roll < 80 ? 1 : roll < 98 ? 2 : 3;
        for (int i = 0; i < count; i++)
        {
            int id;
            do { id = random[ARPGMobilityType](SPRINT, DOUBLE_JUMP); }
            while (Has(item, id));
            Add(item, id, CAT_BOOTS, id == SPRINT ? 50 : 1,
                0, id == DASH ? ARPGBalance.DASH_COOLDOWN_TICS : 0,
                id == SPRINT ? ARPGBalance.SPRINT_MANA_PER_SEC : 0);
        }
    }
}

class ARPGWeaponRules : Object
{
    clearscope static string TypeName(int kind)
    {
        if (kind == 1) return "Axe";
        if (kind == 2) return "Hammer";
        if (kind == 3) return "Mace";
        if (kind == 4) return "Lightning";
        if (kind == 5) return "Frost Shards";
        if (kind == 6) return "Serpent Staff";
        if (kind == 7) return "Sapphire Wand";
        if (kind == 8) return "Firestorm";
        if (kind == 10) return "Chest Armor";
        if (kind == 11) return "Helmet";
        if (kind == 12) return "Bracers";
        if (kind == 13) return "Ring";
        if (kind == 14) return "Boots of Speed";
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
        if (kind >= 4 && kind <= 8) return 100; // spell potency percent
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
        if (kind == 5) return 31;
        if (kind == 6) return 10;
        if (kind == 7) return 18;
        if (kind == 8) return 20;
        return ARPGBalance.SWORD_ATTACK_TICS;
    }

    clearscope static int AverageDamage(int kind, int damage)
    {
        if (kind == 3) return 65;
        if (kind == 4) return 0;
        if (kind >= 5) return 0;
        return damage;
    }

    clearscope static int ManaCost(int kind)
    {
        if (kind == 3) return 0;
        if (kind == 4) return 25;
        if (kind == 5) return 3;
        if (kind == 6) return 1;
        if (kind == 7) return 0;
        if (kind == 8) return 4;
        if (kind == 1) return 4;
        if (kind == 2) return 6;
        return 3;
    }

    clearscope static string ManaName(int kind)
    {
        if (kind == 3) return "No mana";
        if (kind == 4 || kind == 8) return "Mana2";
        if (kind == 7) return "No mana";
        return "Mana1";
    }
}
