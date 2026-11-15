// One inventory weapon per slot. Its loot struct is the actual equipped item;
// changing a slot never changes a class-wide Weapon.SlotNumber.
class ARPGEquippedWeapon : CWeapMace
{
    ARPGWeaponData loot;
    int equipmentSlot;

    Default
    {
        Weapon.AmmoUse1 0;
        Weapon.SelectionOrder 1500;
        Tag "Equipped weapon";
    }

    bool HasMana() const
    {
        if (loot.kind == 3 || loot.manaCost <= 0) return true;
        if (Owner == null) return false;
        let mana = Owner.FindInventory(loot.kind == 4 ? "Mana2" : "Mana1");
        return mana != null && mana.Amount >= loot.manaCost;
    }

    override State GetUpState()
    {
        if (loot.kind == 1) return FindState('AxeSelect');
        if (loot.kind == 2) return FindState('HammerSelect');
        if (loot.kind == 3) return FindState('MaceSelect');
        if (loot.kind == 4) return FindState('LightningSelect');
        return FindState('SwordSelect');
    }

    override State GetDownState()
    {
        if (loot.kind == 1) return FindState('AxeDeselect');
        if (loot.kind == 2) return FindState('HammerDeselect');
        if (loot.kind == 3) return FindState('MaceDeselect');
        if (loot.kind == 4) return FindState('LightningDeselect');
        return FindState('SwordDeselect');
    }

    override State GetReadyState()
    {
        if (loot.kind == 1) return FindState('AxeReady');
        if (loot.kind == 2) return FindState('HammerReady');
        if (loot.kind == 3) return FindState('MaceReady');
        if (loot.kind == 4) return FindState('LightningReady');
        return FindState('SwordReady');
    }

    override State GetAtkState(bool hold)
    {
        if (loot.kind == 1) return FindState('AxeFire');
        if (loot.kind == 2) return FindState('HammerFire');
        if (loot.kind == 3) return FindState('MaceFire');
        if (loot.kind == 4) return FindState('LightningFire');
        return FindState('SwordFire');
    }

    action void A_ARPGStrike()
    {
        if (player == null) return;
        let weapon = ARPGEquippedWeapon(player.ReadyWeapon);
        if (weapon == null || !weapon.HasMana()) return;
        if (weapon.loot.kind != 3)
            player.mo.TakeInventory("Mana1", weapon.loot.manaCost);
        int damage = weapon.loot.kind == 3 ? random[ARPGMaceDamage](50, 80) : weapon.loot.damage;
        if (weapon.loot.kind == 0)
            A_CustomPunch(damage, true, 0, "ARPGSwordPuff", 2 * DEFMELEERANGE);
        else if (weapon.loot.kind == 1)
            A_CustomPunch(damage, true, 0, "AxePuffGlow", 2.25 * DEFMELEERANGE);
        else
            A_CustomPunch(damage, true, 0, "HammerPuff", 1.5 * DEFMELEERANGE);
    }

    action void A_ARPGLightningAttack()
    {
        if (player == null) return;
        let weapon = ARPGEquippedWeapon(player.ReadyWeapon);
        if (weapon == null || !weapon.HasMana()) return;
        player.mo.TakeInventory("Mana2", weapon.loot.manaCost);
        LightningFloor floorArc = LightningFloor(SpawnPlayerMissile("LightningFloor"));
        LightningCeiling ceilingArc = LightningCeiling(SpawnPlayerMissile("LightningCeiling"));
        if (floorArc != null)
        {
            floorArc.special1 = 0;
            floorArc.lastenemy = ceilingArc;
            floorArc.A_LightningZap();
        }
        if (ceilingArc != null)
        {
            ceilingArc.tracer = null;
            ceilingArc.lastenemy = floorArc;
            ceilingArc.A_LightningZap();
        }
        A_StartSound("MageLightningFire", CHAN_BODY);
    }

    States
    {
    Spawn:
        ARAW A -1;
        Stop;
    SwordSelect:
        ARAX L 1 A_Raise;
        Loop;
    SwordDeselect:
        ARAX L 1 A_Lower;
        Loop;
    SwordReady:
        ARAX L 1 A_WeaponReady;
        Loop;
    SwordFire:
        ARAX N 4 Offset(15, 32);
        ARAX O 3 Offset(15, 32);
        ARAX P 2 Offset(15, 32);
        ARAX P 1 Offset(-5, 70) A_ARPGStrike;
        ARAX P 2 Offset(-25, 90);
        ARAX Q 1 Offset(15, 32);
        ARAX Q 2 Offset(10, 54);
        ARAX Q 7 Offset(10, 150);
        ARAX A 1 Offset(0, 60) A_ReFire;
        ARAX A 4 Offset(0, 36);
        Goto SwordReady;
    AxeSelect:
        FAXE L 1 A_Raise;
        Loop;
    AxeDeselect:
        FAXE L 1 A_Lower;
        Loop;
    AxeReady:
        FAXE L 1 A_WeaponReady;
        Loop;
    AxeFire:
        FAXE N 4 Offset(15, 32);
        FAXE O 3 Offset(15, 32);
        FAXE P 2 Offset(15, 32);
        FAXE P 1 Offset(-5, 70) A_ARPGStrike;
        FAXE P 2 Offset(-25, 90);
        FAXE Q 1 Offset(15, 32);
        FAXE Q 2 Offset(10, 54);
        FAXE Q 14 Offset(10, 150);
        FAXE A 1 Offset(0, 60) A_ReFire;
        FAXE A 4 Offset(0, 36);
        Goto AxeReady;
    HammerSelect:
        FHMR A 1 A_Raise;
        Loop;
    HammerDeselect:
        FHMR A 1 A_Lower;
        Loop;
    HammerReady:
        FHMR A 1 A_WeaponReady;
        Loop;
    HammerFire:
        FHMR B 6 Offset(5, 0);
        FHMR C 3 Offset(5, 0) A_ARPGStrike;
        FHMR D 3 Offset(5, 0);
        FHMR E 22 Offset(5, 150);
        FHMR A 6 Offset(0, 40) A_ReFire;
        Goto HammerReady;
    MaceSelect:
        CMCE A 1 A_Raise;
        Loop;
    MaceDeselect:
        CMCE A 1 A_Lower;
        Loop;
    MaceReady:
        CMCE A 1 A_WeaponReady;
        Loop;
    MaceFire:
        CMCE B 2 Offset(60, 20);
        CMCE B 3 Offset(8, 45);
        CMCE CDE 1 Offset(8, 45);
        CMCE E 1 Offset(-11, 58) A_ARPGStrike;
        CMCE F 12 Offset(-20, 96);
        CMCE A 2 Offset(8, 75) A_ReFire;
        CMCE A 4 Offset(8, 45);
        Goto MaceReady;
    LightningSelect:
        MLNG A 1 Bright A_Raise;
        Loop;
    LightningDeselect:
        MLNG A 1 Bright A_Lower;
        Loop;
    LightningReady:
        MLNG A 1 Bright A_WeaponReady;
        Loop;
    LightningFire:
        MLNG DE 3 Bright;
        MLNG F 4 Bright A_ARPGLightningAttack;
        MLNG G 4 Bright;
        MLNG HI 3 Bright;
        MLNG I 6 Bright Offset(0, 199);
        MLNG C 2 Bright Offset(0, 55);
        MLNG B 8 Bright Offset(0, 40);
        Goto LightningReady;
    }
}

class ARPGSlot1 : ARPGEquippedWeapon
{
    Default { Weapon.SelectionOrder 3500; }
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        equipmentSlot = 1;
        if (loot.damage == 0) { loot.kind = 3; loot.damage = 65; loot.speed = 0; loot.manaCost = 0; }
    }
}

class ARPGSlot2 : ARPGEquippedWeapon
{
    Default { Weapon.SelectionOrder 1700; }
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        equipmentSlot = 2;
        if (loot.damage == 0) { loot.kind = 0; loot.damage = ARPGBalance.SWORD_DAMAGE; loot.speed = 0; loot.manaCost = ARPGBalance.SWORD_MANA_COST; }
    }
}

class ARPGSlot3 : ARPGEquippedWeapon
{
    Default { Weapon.SelectionOrder 1200; }
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        equipmentSlot = 3;
        if (loot.damage == 0) { loot.kind = 4; loot.damage = 1; loot.speed = 0; loot.manaCost = 5; }
    }
}
