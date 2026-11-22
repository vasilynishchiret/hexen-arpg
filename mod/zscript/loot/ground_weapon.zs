class ARPGGroundWeapon : Actor
// Copyright (C) 2026 Vasily Nishchiret
// SPDX-License-Identifier: GPL-3.0-or-later

{
    ARPGWeaponData loot;
    Actor pickupBlockOwner;
    int pickupBlockUntil;

    Default
    {
        Radius 12;
        Height 16;
        +NOBLOCKMAP
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        if (loot.damage == 0)
        {
            int group = random[ARPGLootType](0, 99);
            if (group < ARPGBalance.LOOT_MELEE_PERCENT) GenerateKind(random[ARPGLootMelee](0, 2));
            else if (group < ARPGBalance.LOOT_MELEE_PERCENT + ARPGBalance.LOOT_MAGIC_PERCENT)
                GenerateKind(random[ARPGLootMagic](4, 8));
            else GenerateKind(random[ARPGLootArmor](10, 14));
        }
        RefreshAppearance();
    }

    void GenerateKind(int kind)
    {
        loot.kind = kind;
        loot.damage = kind == 3 ? 65 : kind <= 8 ? ARPGWeaponRules.RollDamage(kind) : 1;
        loot.baseDamage = loot.damage;
        loot.speed = kind;
        loot.manaCost = ARPGWeaponRules.ItemManaCost(kind, loot.damage);
        loot.manaVersion = 1;
        if (kind == 14) ARPGAffixes.RollBoots(loot);
        if (kind == 12) ARPGAffixes.RollBracers(loot);
        if (kind == 11) ARPGAffixes.RollHelmet(loot);
        if (kind == 13) ARPGAffixes.RollRing(loot);
        if (kind == 10) ARPGAffixes.RollChest(loot);
    }

    void RefreshAppearance()
    {
        if (loot.kind == 1) SetStateLabel("Axe");
        else if (loot.kind == 2) SetStateLabel("Hammer");
        else if (loot.kind == 3) SetStateLabel("Mace");
        else if (loot.kind == 4) SetStateLabel("Lightning");
        else if (loot.kind == 5) SetStateLabel("Frost");
        else if (loot.kind == 6) SetStateLabel("Staff");
        else if (loot.kind == 7) SetStateLabel("Wand");
        else if (loot.kind == 8) SetStateLabel("Firestorm");
        else if (loot.kind == 10) SetStateLabel("Chest");
        else if (loot.kind == 11) SetStateLabel("Helmet");
        else if (loot.kind == 12) SetStateLabel("Bracers");
        else if (loot.kind == 13) SetStateLabel("Ring");
        else if (loot.kind == 14) SetStateLabel("Boots");
        else SetStateLabel("Sword");
    }

    void InitTestItem(int kind, int damage, int speed, int manaCost)
    {
        ARPGWeaponData empty;
        ARPGAffixes.Copy(loot, empty);
        loot.kind = kind;
        loot.damage = damage;
        loot.baseDamage = damage;
        loot.speed = speed;
        loot.manaCost = manaCost;
        loot.manaVersion = 1;
    }

    States
    {
    Spawn:
    Sword:
        ARAW A -1;
        Stop;
    Axe:
        WFAX A -1;
        Stop;
    Hammer:
        WFHM A -1;
        Stop;
    Mace:
        CMCE A -1;
        Stop;
    Lightning:
        WMLG A -1;
        Stop;
    Frost:
        WMCS A -1;
        Stop;
    Staff:
        WCSS A -1;
        Stop;
    Wand:
        MWND A -1;
        Stop;
    Firestorm:
        WCFM A -1;
        Stop;
    Chest:
        AR_1 A -1;
        Stop;
    Helmet:
        AR_3 A -1;
        Stop;
    Bracers:
        BRAC A -1 Bright;
        Stop;
    Ring:
        ARRG A -1 Bright;
        Stop;
    Boots:
        SPED A -1 Bright;
        Stop;
    }
}

// Console smoke test: summon ARPGTestSword / ARPGTestAxe / ARPGTestHammer.
// These classes do not participate in the random monster drop table.
class ARPGTestSword : ARPGGroundWeapon
{
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        InitTestItem(0, 70, 0, 3);
        RefreshAppearance();
    }
}

class ARPGTestAxe : ARPGGroundWeapon
{
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        InitTestItem(1, 85, 1, ARPGWeaponRules.ItemManaCost(1, 85));
        RefreshAppearance();
    }
}
class ARPGTestAxe100 : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(1, 100, 1, ARPGWeaponRules.ItemManaCost(1, 100)); RefreshAppearance(); } }
class ARPGTestAxe200 : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(1, 200, 1, ARPGWeaponRules.ItemManaCost(1, 200)); RefreshAppearance(); } }
class ARPGTestUpgradedAxe : ARPGGroundWeapon
{
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        InitTestItem(1, 100, 1, ARPGWeaponRules.ItemManaCost(1, 100));
        ARPGUpgradeRules.Apply(loot, 1, 50);
        ARPGUpgradeRules.Apply(loot, 2, 50);
        RefreshAppearance();
    }
}

class ARPGTestHammer : ARPGGroundWeapon
{
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        InitTestItem(2, 115, 2, ARPGWeaponRules.ItemManaCost(2, 115));
        RefreshAppearance();
    }
}

class ARPGTestMace : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(3, 65, 0, 0); RefreshAppearance(); } }

class ARPGTestLightning : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(4, 100, 0, ARPGWeaponRules.ItemManaCost(4, 100)); RefreshAppearance(); } }
class ARPGTestFrost : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(5, 100, 0, ARPGWeaponRules.ItemManaCost(5, 100)); RefreshAppearance(); } }
class ARPGTestStaff : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(6, 100, 0, ARPGWeaponRules.ItemManaCost(6, 100)); RefreshAppearance(); } }
class ARPGTestWand : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(7, 100, 0, ARPGWeaponRules.ItemManaCost(7, 100)); RefreshAppearance(); } }
class ARPGTestFirestorm : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(8, 100, 0, ARPGWeaponRules.ItemManaCost(8, 100)); RefreshAppearance(); } }
class ARPGTestChest : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(10, 1, 0, 0); ARPGAffixes.RollChest(loot); RefreshAppearance(); } }
class ARPGTestHelmet : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(11, 1, 0, 0); RefreshAppearance(); } }
class ARPGTestInvisibilityHelmet : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(11, 1, 0, 0); ARPGAffixes.Add(loot, ARPGAffixes.INVISIBILITY, 11, 1, 105, 875); RefreshAppearance(); } }
class ARPGTestDetectionHelmet : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(11, 1, 0, 0); ARPGAffixes.Add(loot, ARPGAffixes.ENEMY_DETECTION, 11, 640, 175, 700); RefreshAppearance(); } }
class ARPGTestBracers : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(12, 1, 0, 0); RefreshAppearance(); } }
class ARPGTestShieldBracers : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(12, 1, 0, 0); ARPGAffixes.Add(loot, ARPGAffixes.ARCANE_SHIELD, 12, 70, 70, 280, 1); RefreshAppearance(); } }
class ARPGTestGuardianBracers : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(12, 1, 0, 0); ARPGAffixes.Add(loot, ARPGAffixes.GUARDIAN, 12, 1, 0, 700); RefreshAppearance(); } }
class ARPGTestRing : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(13, 1, 0, 0); RefreshAppearance(); } }
class ARPGTestGreenRing : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(13, 1, 0, 0); ARPGAffixes.Add(loot, ARPGAffixes.GREEN_REGEN, 13, 1); RefreshAppearance(); } }
class ARPGTestVampRing : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(13, 1, 0, 0); ARPGAffixes.Add(loot, ARPGAffixes.VAMPIRISM, 13, 500); RefreshAppearance(); } }
class ARPGTestAuraRing : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(13, 1, 0, 0); ARPGAffixes.Add(loot, ARPGAffixes.DAMAGE_AURA, 13, 2); RefreshAppearance(); } }
class ARPGTestBoots : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(14, 1, 0, 0); ARPGAffixes.RollBoots(loot); RefreshAppearance(); } }
class ARPGTestSprintBoots : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(14, 1, 0, 0); ARPGAffixes.Add(loot, ARPGAffixes.SPRINT, 14, 50, 0, 0, 2); RefreshAppearance(); } }
class ARPGTestDashBoots : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(14, 1, 0, 0); ARPGAffixes.Add(loot, ARPGAffixes.DASH, 14, 1, 0, ARPGBalance.DASH_COOLDOWN_TICS); RefreshAppearance(); } }
class ARPGTestJumpBoots : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); InitTestItem(14, 1, 0, 0); ARPGAffixes.Add(loot, ARPGAffixes.DOUBLE_JUMP, 14, 1); RefreshAppearance(); } }
