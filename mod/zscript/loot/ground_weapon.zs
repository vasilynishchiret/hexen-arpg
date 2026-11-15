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
            loot.kind = random[ARPGLootType](0, 2);
            loot.damage = random[ARPGLootDamage](ARPGWeaponRules.MinDamage(loot.kind), ARPGWeaponRules.MaxDamage(loot.kind));
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
