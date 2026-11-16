class ARPGGroundWeapon : Actor
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
            if (group < ARPGBalance.LOOT_MELEE_PERCENT) loot.kind = random[ARPGLootMelee](0, 2);
            else if (group < ARPGBalance.LOOT_MELEE_PERCENT + ARPGBalance.LOOT_MAGIC_PERCENT) loot.kind = random[ARPGLootMagic](4, 8);
            else loot.kind = random[ARPGLootArmor](10, 13);
            loot.damage = loot.kind <= 8 ? ARPGWeaponRules.RollDamage(loot.kind) : 1;
            loot.speed = loot.kind;
            loot.manaCost = ARPGWeaponRules.ManaCost(loot.kind);
        }
        RefreshAppearance();
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
        else SetStateLabel("Sword");
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
    }
}

// Console smoke test: summon ARPGTestSword / ARPGTestAxe / ARPGTestHammer.
// These classes do not participate in the random monster drop table.
class ARPGTestSword : ARPGGroundWeapon
{
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        loot.kind = 0; loot.damage = 70; loot.speed = 0; loot.manaCost = 3;
        RefreshAppearance();
    }
}

class ARPGTestAxe : ARPGGroundWeapon
{
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        loot.kind = 1; loot.damage = 85; loot.speed = 1; loot.manaCost = 4;
        RefreshAppearance();
    }
}

class ARPGTestHammer : ARPGGroundWeapon
{
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        loot.kind = 2; loot.damage = 115; loot.speed = 2; loot.manaCost = 6;
        RefreshAppearance();
    }
}

class ARPGTestMace : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); loot.kind = 3; loot.damage = 65; loot.manaCost = 0; RefreshAppearance(); } }

class ARPGTestLightning : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); loot.kind = 4; loot.damage = 100; loot.manaCost = ARPGWeaponRules.ManaCost(4); RefreshAppearance(); } }
class ARPGTestFrost : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); loot.kind = 5; loot.damage = 100; loot.manaCost = 3; RefreshAppearance(); } }
class ARPGTestStaff : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); loot.kind = 6; loot.damage = 100; loot.manaCost = 1; RefreshAppearance(); } }
class ARPGTestWand : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); loot.kind = 7; loot.damage = 100; loot.manaCost = 0; RefreshAppearance(); } }
class ARPGTestFirestorm : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); loot.kind = 8; loot.damage = 100; loot.manaCost = 4; RefreshAppearance(); } }
class ARPGTestChest : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); loot.kind = 10; loot.damage = 1; loot.manaCost = 0; RefreshAppearance(); } }
class ARPGTestHelmet : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); loot.kind = 11; loot.damage = 1; loot.manaCost = 0; RefreshAppearance(); } }
class ARPGTestBracers : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); loot.kind = 12; loot.damage = 1; loot.manaCost = 0; RefreshAppearance(); } }
class ARPGTestRing : ARPGGroundWeapon { override void PostBeginPlay() { Super.PostBeginPlay(); loot.kind = 13; loot.damage = 1; loot.manaCost = 0; RefreshAppearance(); } }
