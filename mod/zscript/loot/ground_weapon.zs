class ARPGGroundWeapon : Actor
{
    ARPGWeaponData loot;

    Default
    {
        Radius 12;
        Height 16;
        +NOBLOCKMAP
    }

    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        if (loot.damage != 0) return;
        loot.kind = random[ARPGLootType](0, 2);
        loot.damage = random[ARPGLootDamage](ARPGWeaponRules.MinDamage(loot.kind), ARPGWeaponRules.MaxDamage(loot.kind));
        loot.speed = loot.kind;
        loot.manaCost = ARPGWeaponRules.ManaCost(loot.kind);
    }

    States
    {
    Spawn:
        ARAW A -1;
        Stop;
    }
}