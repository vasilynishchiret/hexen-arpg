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
    int manaVersion; // 0: pre-v0.7 save, 1: generated nonlinear price
    int affixCount;
    ARPGGameplayAffix affix[4];
    int statCount;
    ARPGGameplayAffix statAffix[4];
    int statHP;
    int statDR;
    int statMana1;
    int statMana2;
    int statRegen;
    int statTier;
    int damageType; // reserved for elemental weapon affixes
    int baseDamage; // original rolled power before gems
    int blueUpgrades;
    int greenUpgrades;
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

    clearscope static void Copy(out ARPGWeaponData dest, ARPGWeaponData src)
    {
        dest.kind = src.kind;
        dest.damage = src.damage;
        dest.speed = src.speed;
        dest.manaCost = src.manaCost;
        dest.manaVersion = src.manaVersion;
        dest.affixCount = src.affixCount;
        dest.statCount = src.statCount;
        for (int i = 0; i < 4; i++)
        {
            dest.affix[i].id = src.affix[i].id;
            dest.affix[i].category = src.affix[i].category;
            dest.affix[i].effect = src.affix[i].effect;
            dest.affix[i].power = src.affix[i].power;
            dest.affix[i].duration = src.affix[i].duration;
            dest.affix[i].cooldown = src.affix[i].cooldown;
            dest.affix[i].manaCost = src.affix[i].manaCost;
            dest.statAffix[i].id = src.statAffix[i].id;
            dest.statAffix[i].category = src.statAffix[i].category;
            dest.statAffix[i].effect = src.statAffix[i].effect;
            dest.statAffix[i].power = src.statAffix[i].power;
            dest.statAffix[i].duration = src.statAffix[i].duration;
            dest.statAffix[i].cooldown = src.statAffix[i].cooldown;
            dest.statAffix[i].manaCost = src.statAffix[i].manaCost;
        }
        dest.statHP = src.statHP;
        dest.statDR = src.statDR;
        dest.statMana1 = src.statMana1;
        dest.statMana2 = src.statMana2;
        dest.statRegen = src.statRegen;
        dest.statTier = src.statTier;
        dest.damageType = src.damageType;
        dest.baseDamage = src.baseDamage;
        dest.blueUpgrades = src.blueUpgrades;
        dest.greenUpgrades = src.greenUpgrades;
    }

    clearscope static bool Has(ARPGWeaponData item, int id)
    {
        if (item.damage <= 0) return false;
        for (int i = 0; i < item.affixCount; i++)
            if (item.affix[i].id == id) return true;
        return false;
    }

    clearscope static int Power(ARPGWeaponData item, int id)
    {
        if (item.damage <= 0) return 0;
        for (int i = 0; i < item.affixCount; i++)
            if (item.affix[i].id == id) return item.affix[i].power;
        return 0;
    }

    clearscope static String Description(ARPGGameplayAffix a)
    {
        if (a.id == SPRINT) return String.Format("Sprint +%d%% [hold Shift]", a.power);
        if (a.id == DASH) return "Dash [tap Shift <200ms]";
        if (a.id == DOUBLE_JUMP) return "Double Jump [Space in air]";
        if (a.id == ARCANE_SHIELD) return String.Format("Arcane Shield %d%% [RMB]", a.power);
        if (a.id == GUARDIAN) return "Guardian: ignore one hit";
        if (a.id == INVISIBILITY) return "Invisibility [F]";
        if (a.id == ENEMY_DETECTION) return "Enemy Detection [V]";
        if (a.id == GREEN_REGEN) return "Mana2 +1 every 12s";
        if (a.id == VAMPIRISM) return String.Format("Vampirism %d.%d%%", a.power / 100, a.power % 100 / 10);
        if (a.id == DAMAGE_AURA) return String.Format("Damage Aura %d/s, r96", a.power);
        return "Unknown affix";
    }

    clearscope static String Terms(ARPGGameplayAffix a)
    {
        if (a.id == SPRINT) return String.Format("%d Mana1/sec", a.manaCost);
        if (a.id == DASH) return String.Format("Cooldown %ds", a.cooldown / 35);
        if (a.id == DOUBLE_JUMP) return "One extra jump per landing";
        if (a.id == ARCANE_SHIELD) return String.Format("%d.%ds | CD %ds | 1 Mana1/2 HP",
            a.duration / 35, a.duration * 10 / 35 % 10, a.cooldown / 35);
        if (a.id == GUARDIAN) return String.Format("Cooldown %ds", a.cooldown / 35);
        if (a.id == INVISIBILITY || a.id == ENEMY_DETECTION)
            return String.Format("%ds | CD %ds%s", a.duration / 35,
                a.cooldown / 35, a.id == ENEMY_DETECTION ? " | r640" : "");
        return "";
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

    static void RollBracers(out ARPGWeaponData item)
    {
        int roll = random[ARPGBracerAffix](0, 99);
        if (roll < 30)
            Add(item, ARCANE_SHIELD, CAT_BRACERS, ARPGBalance.SHIELD_BLOCK_PERCENT,
                ARPGBalance.SHIELD_BASE_TICS + random[ARPGShieldPower](0, 35),
                ARPGBalance.SHIELD_COOLDOWN_TICS, 1);
        else if (roll < 60)
            Add(item, GUARDIAN, CAT_BRACERS, 1, 0, ARPGBalance.GUARDIAN_COOLDOWN_TICS);
    }

    static void RollHelmet(out ARPGWeaponData item)
    {
        int roll = random[ARPGHelmetAffix](0, 99);
        if (roll < 30)
            Add(item, INVISIBILITY, CAT_HELMET, 1,
                ARPGBalance.INVIS_TICS, ARPGBalance.INVIS_COOLDOWN_TICS);
        else if (roll < 60)
            Add(item, ENEMY_DETECTION, CAT_HELMET, ARPGBalance.DETECT_RADIUS,
                ARPGBalance.DETECT_TICS, ARPGBalance.DETECT_COOLDOWN_TICS);
    }

    static void RollRing(out ARPGWeaponData item)
    {
        int id = random[ARPGRingAffix](GREEN_REGEN, DAMAGE_AURA);
        Add(item, id, CAT_RING,
            id == VAMPIRISM ? random[ARPGVampPower](300, 600) :
            id == DAMAGE_AURA ? ARPGBalance.AURA_DAMAGE_PER_RING : 1);
    }

    static void RollChest(out ARPGWeaponData item)
    {
        int roll = random[ARPGChestTier](0, 99);
        int tier = roll < 80 ? 0 : roll < 97 ? 1 : 2;
        int count = tier + 1 + random[ARPGChestCount](0, 1);
        int used = 0;
        item.statTier = tier + 1;
        for (int i = 0; i < count; i++)
        {
            int kind;
            do { kind = random[ARPGChestStat](0, 4); }
            while ((used & (1 << kind)) != 0);
            used |= 1 << kind;
            if (kind == 0) item.statHP = 8 + tier * 8 + random[ARPGChestHP](0, 6);
            if (kind == 1) item.statDR = 3 + tier * 2 + random[ARPGChestDR](0, 2);
            if (kind == 2) item.statMana1 = 10 + tier * 10 + random[ARPGChestMana1](0, 5);
            if (kind == 3) item.statMana2 = 10 + tier * 10 + random[ARPGChestMana2](0, 5);
            if (kind == 4) item.statRegen = 10 + tier * 10 + random[ARPGChestRegen](0, 5);
            int at = item.statCount++;
            item.statAffix[at].id = 100 + kind;
            item.statAffix[at].category = 10;
            item.statAffix[at].effect = 100 + kind;
            item.statAffix[at].power = kind == 0 ? item.statHP : kind == 1 ? item.statDR :
                kind == 2 ? item.statMana1 : kind == 3 ? item.statMana2 : item.statRegen;
        }
    }
}

class ARPGWeaponRules : Object
{
    clearscope static String CategoryName(int kind)
    {
        if (kind == 10) return "Chest Armor";
        if (kind == 11) return "Helmet";
        if (kind == 12) return "Bracers";
        if (kind == 13) return "Ring";
        if (kind == 14) return "Boots";
        return "Weapon";
    }
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
        if (kind == 15) return "Blue Gem";
        if (kind == 16) return "Green Gem";
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
        if (kind == 8) return 8;
        if (kind == 1) return 4;
        if (kind == 2) return 6;
        return 3;
    }

    // Price is rolled once per item. Expected hits are fixed balancing values,
    // never the actual number of monsters hit by a particular shot.
    clearscope static int ExpectedRangedDamage(int kind)
    {
        if (kind == 5) return 100; // one Frost hit; extra shards are situational
        if (kind == 6) return 45;  // two Serpent Staff missiles
        if (kind == 7) return 18;  // Wand ripper's expected contact time
        return 100;
    }

    clearscope static int ItemManaCost(int kind, int damage)
    {
        int base = ManaCost(kind);
        if (kind == 3 || kind >= 9 || damage <= 0) return base;
        double factor;
        double price;
        if (kind >= 4 && kind <= 8 && kind != 5 && kind != 6 && kind != 7)
        {
            // Mana2 spell bases already include their original role and the
            // earlier Lightning x5 change (25). Do not multiply either again.
            factor = double(damage) / 100.;
            price = base * exp(log(factor) * ARPGBalance.MANA_POWER_EXPONENT);
        }
        else if (kind >= 5 && kind <= 7)
        {
            int tics = AttackTics(kind);
            factor = double(ExpectedRangedDamage(kind) * damage * ARPGBalance.MANA_REFERENCE_TICS) /
                (100. * ARPGBalance.MANA_REFERENCE_DAMAGE * tics);
            price = ARPGBalance.MANA_REFERENCE_COST *
                exp(log(factor) * ARPGBalance.MANA_POWER_EXPONENT) *
                tics / ARPGBalance.MANA_REFERENCE_TICS * ARPGBalance.RANGED_MANA_MULTIPLIER;
        }
        else
        {
            // Melee base prices already differ by their fixed attack cadence.
            // Individual damage rolls scale relative to that weapon's own DPS.
            factor = double(damage) / BaseDamage(kind);
            price = base * exp(log(factor) * ARPGBalance.MANA_POWER_EXPONENT);
        }
        return max(1, int(price + 0.5));
    }

    clearscope static int StoredManaCost(ARPGWeaponData data)
    {
        if ((data.manaVersion == 0 || data.kind == 8) && data.damage > 0)
            return ItemManaCost(data.kind, data.damage);
        return data.manaCost;
    }

    clearscope static string ManaName(int kind)
    {
        if (kind == 3) return "No mana";
        if (kind == 4 || kind == 8) return "Mana2";
        return "Mana1";
    }
}

class ARPGUpgradeRules : Object
{
    clearscope static int OriginalPower(ARPGWeaponData item)
    {
        return item.baseDamage > 0 ? item.baseDamage : item.damage;
    }

    clearscope static int Total(ARPGWeaponData item)
    {
        return item.blueUpgrades + item.greenUpgrades;
    }

    clearscope static int Damage(ARPGWeaponData item)
    {
        int original = OriginalPower(item);
        return original + item.blueUpgrades + (original * item.greenUpgrades + 50) / 100;
    }

    clearscope static int ReductionTenths(ARPGWeaponData item)
    {
        int base = item.kind == 10 ? 100 + item.statDR * 10 :
            item.kind == 11 ? 50 : item.kind == 12 && item.affixCount == 0 ? 30 : 0;
        return base + item.greenUpgrades * 3;
    }

    clearscope static bool CanUpgrade(ARPGWeaponData item, int color)
    {
        if (item.damage <= 0 || item.kind >= 14 || Total(item) >= 100) return false;
        if (item.kind == 12 && item.affixCount > 0 && color == 2) return false;
        if (item.kind >= 10 && item.kind <= 12 && color == 2 &&
            ReductionTenths(item) >= 450) return false;
        return true;
    }

    clearscope static int Apply(out ARPGWeaponData item, int color, int count)
    {
        int applied = 0;
        while (applied < count && CanUpgrade(item, color))
        {
            if (item.baseDamage <= 0) item.baseDamage = item.damage;
            if (color == 1) item.blueUpgrades++;
            else item.greenUpgrades++;
            applied++;
        }
        if (applied > 0 && item.kind < 10)
        {
            item.damage = Damage(item);
            item.manaCost = ARPGWeaponRules.ItemManaCost(item.kind, item.damage);
            item.manaVersion = 1;
        }
        return applied;
    }
}
