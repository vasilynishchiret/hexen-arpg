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
        if (loot.kind == 3) return true;
        if (Owner == null) return false;
        let mana = Owner.FindInventory(loot.kind == 4 || loot.kind == 8 ? "Mana2" : "Mana1");
        return mana != null && mana.Amount >= EffectiveManaCost();
    }

    int EffectiveManaCost() const
    {
        return ARPGWeaponRules.StoredManaCost(loot);
    }

    void SyncSpritePosition()
    {
        // These are the original Hexen Weapon.YAdjust values. The shared
        // slot class otherwise inherits the Cleric mace's -8 adjustment.
        if (loot.kind == 4 || loot.kind == 5) YAdjust = 20;
        else if (loot.kind == 6 || loot.kind == 8) YAdjust = 10;
        else if (loot.kind == 7) YAdjust = 9;
        else YAdjust = -8;
    }

    override void ModifyDamage(int damage, Name damageType, out int newdamage,
        bool passive, Actor inflictor, Actor source, int flags, double angle)
    {
        if (!passive && loot.kind >= 4 && loot.kind <= 8 && Owner != null && source == Owner &&
            Owner.player != null && Owner.player.ReadyWeapon == self)
            newdamage = max(1, (damage * loot.damage + 50) / 100);
    }

    override State GetUpState()
    {
        SyncSpritePosition();
        if (loot.kind < 0) return FindState('EmptySelect');
        if (loot.kind == 5) return FindState('FrostSelect');
        if (loot.kind == 6) return FindState('StaffSelect');
        if (loot.kind == 7) return FindState('WandSelect');
        if (loot.kind == 8) return FindState('FirestormSelect');
        if (loot.kind == 1) return FindState('AxeSelect');
        if (loot.kind == 2) return FindState('HammerSelect');
        if (loot.kind == 3) return FindState('MaceSelect');
        if (loot.kind == 4) return FindState('LightningSelect');
        return FindState('SwordSelect');
    }

    override State GetDownState()
    {
        SyncSpritePosition();
        if (loot.kind < 0) return FindState('EmptyDeselect');
        if (loot.kind == 5) return FindState('FrostDeselect');
        if (loot.kind == 6) return FindState('StaffDeselect');
        if (loot.kind == 7) return FindState('WandDeselect');
        if (loot.kind == 8) return FindState('FirestormDeselect');
        if (loot.kind == 1) return FindState('AxeDeselect');
        if (loot.kind == 2) return FindState('HammerDeselect');
        if (loot.kind == 3) return FindState('MaceDeselect');
        if (loot.kind == 4) return FindState('LightningDeselect');
        return FindState('SwordDeselect');
    }

    override State GetReadyState()
    {
        SyncSpritePosition();
        if (loot.kind < 0) return FindState('EmptyReady');
        if (loot.kind == 5) return FindState('FrostReady');
        if (loot.kind == 6) return FindState('StaffReady');
        if (loot.kind == 7) return FindState('WandReady');
        if (loot.kind == 8) return FindState('FirestormReady');
        if (loot.kind == 1) return FindState('AxeReady');
        if (loot.kind == 2) return FindState('HammerReady');
        if (loot.kind == 3) return FindState('MaceReady');
        if (loot.kind == 4) return FindState('LightningReady');
        return FindState('SwordReady');
    }

    override State GetAtkState(bool hold)
    {
        SyncSpritePosition();
        if (loot.kind < 0) return FindState('EmptyReady');
        let cleric = ARPGCleric(Owner);
        if (cleric != null && cleric.arpgAttackCooldown > 0) return GetReadyState();
        if (loot.kind == 1) return FindState('AxeFire');
        if (loot.kind == 2) return FindState('HammerFire');
        if (loot.kind == 3) return FindState('MaceFire');
        if (loot.kind == 4) return FindState('LightningFire');
        if (loot.kind == 5) return FindState('FrostFire');
        if (loot.kind == 6) return FindState('StaffFire');
        if (loot.kind == 7) return FindState('WandFire');
        if (loot.kind == 8) return FindState('FirestormFire');
        return FindState('SwordFire');
    }

    action void A_ARPGBeginAttack()
    {
        if (player == null) return;
        let cleric = ARPGCleric(player.mo);
        let weapon = ARPGEquippedWeapon(player.ReadyWeapon);
        if (cleric != null && weapon != null)
            cleric.arpgAttackCooldown = ARPGWeaponRules.AttackTics(weapon.loot.kind);
    }

    action void A_ARPGStrike()
    {
        if (player == null) return;
        let weapon = ARPGEquippedWeapon(player.ReadyWeapon);
        if (weapon == null || !weapon.HasMana()) return;
        if (weapon.loot.kind != 3)
            player.mo.TakeInventory("Mana1", weapon.EffectiveManaCost());
        int damage = weapon.loot.kind == 3 ?
            random[ARPGMaceDamage](50, 80) + weapon.loot.damage - ARPGUpgradeRules.OriginalPower(weapon.loot) :
            weapon.loot.damage;
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
        player.mo.TakeInventory("Mana2", weapon.EffectiveManaCost());
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

    action void A_ARPGFrostAttack()
    {
        if (player == null) return;
        let weapon = ARPGEquippedWeapon(player.ReadyWeapon);
        if (weapon == null || !weapon.HasMana()) return;
        player.mo.TakeInventory("Mana1", weapon.EffectiveManaCost());
        A_StartSound("MageShardsFire", CHAN_WEAPON);
        FTranslatedLineTarget hit;
        bool found = false;
        for (int i = 0; i < 16; i++)
        {
            double ang = angle + i * (45. / 16);
            AimLineAttack(ang, DEFMELEERANGE, hit, 0., ALF_CHECK3D);
            if (hit.linetarget != null)
            {
                hit.linetarget.DamageMobj(self, self, random[ARPGFrostDamage](90, 105), 'Ice', DMG_USEANGLE, hit.angleFromSource);
                found = true;
                break;
            }
        }
        if (!found)
        {
            Actor missile = SpawnPlayerMissile("FrostMissile");
            if (missile != null)
            {
                missile.special1 = FrostMissile.SHARDSPAWN_LEFT | FrostMissile.SHARDSPAWN_DOWN | FrostMissile.SHARDSPAWN_UP | FrostMissile.SHARDSPAWN_RIGHT;
                missile.special2 = 3;
                missile.target = self;
                missile.args[0] = 3;
            }
        }
    }

    action void A_ARPGStaffAttack()
    {
        if (player == null) return;
        let weapon = ARPGEquippedWeapon(player.ReadyWeapon);
        if (weapon == null || !weapon.HasMana()) return;
        player.mo.TakeInventory("Mana1", weapon.EffectiveManaCost());
        Actor left = SpawnPlayerMissile("CStaffMissile", angle - 3.0);
        Actor right = SpawnPlayerMissile("CStaffMissile", angle + 3.0);
        if (left != null) left.WeaveIndexXY = 32;
        if (right != null) right.WeaveIndexXY = 0;
        A_StartSound("ClericCStaffFire", CHAN_WEAPON);
    }

    action void A_ARPGWandAttack()
    {
        if (player == null) return;
        let weapon = ARPGEquippedWeapon(player.ReadyWeapon);
        if (weapon == null || !weapon.HasMana()) return;
        player.mo.TakeInventory("Mana1", weapon.EffectiveManaCost());
        A_FireProjectile("MageWandMissile");
    }

    action void A_ARPGFirestormAttack()
    {
        if (player == null) return;
        let weapon = ARPGEquippedWeapon(player.ReadyWeapon);
        if (weapon == null || !weapon.HasMana()) return;
        player.mo.TakeInventory("Mana2", weapon.EffectiveManaCost());
        SpawnPlayerMissile("CFlameMissile");
        A_StartSound("ClericFlameFire", CHAN_WEAPON);
    }

    action void A_ARPGLightningReady()
    {
        A_WeaponReady();
        if (random[ARPGLightningReady]() < 160)
            A_StartSound("MageLightningReady", CHAN_WEAPON);
    }

    action void A_ARPGStaffInitBlink()
    {
        weaponspecial = (random[ARPGStaffBlink]() >> 1) + 20;
    }

    action void A_ARPGStaffCheckBlink()
    {
        if (player == null || player.ReadyWeapon == null) return;
        if (!--weaponspecial)
        {
            player.SetPsprite(PSP_WEAPON, player.ReadyWeapon.FindState("StaffBlink"));
            weaponspecial = (random[ARPGStaffBlink]() + 50) >> 2;
        }
        else A_WeaponReady();
    }

    States
    {
    EmptySelect:
        TNT1 A 1 A_Raise;
        Loop;
    EmptyDeselect:
        TNT1 A 1 A_Lower;
        Loop;
    EmptyReady:
        TNT1 A 1 A_WeaponReady;
        Loop;
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
        ARAX N 2 Offset(15, 32) A_ARPGBeginAttack;
        ARAX O 2 Offset(15, 32);
        ARAX P 1 Offset(15, 32);
        ARAX P 1 Offset(-5, 70) A_ARPGStrike;
        ARAX P 1 Offset(-25, 90);
        ARAX Q 1 Offset(15, 32);
        ARAX Q 2 Offset(10, 54);
        ARAX Q 4 Offset(10, 150);
        ARAX A 1 Offset(0, 60);
        ARAX A 1 Offset(0, 36) A_ReFire;
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
        FAXE N 4 Offset(15, 32) A_ARPGBeginAttack;
        FAXE O 3 Offset(15, 32);
        FAXE P 2 Offset(15, 32);
        FAXE P 1 Offset(-5, 70) A_ARPGStrike;
        FAXE P 2 Offset(-25, 90);
        FAXE Q 1 Offset(15, 32);
        FAXE Q 2 Offset(10, 54);
        FAXE Q 14 Offset(10, 150);
        FAXE A 1 Offset(0, 60) A_ReFire;
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
        FHMR B 8 Offset(5, 0) A_ARPGBeginAttack;
        FHMR C 5 Offset(5, 0) A_ARPGStrike;
        FHMR D 5 Offset(5, 0);
        FHMR E 51 Offset(5, 150);
        FHMR A 1 Offset(0, 40) A_ReFire;
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
        CMCE B 2 Offset(60, 20) A_ARPGBeginAttack;
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
        MLNG AAAAA 1 Bright A_WeaponReady;
        MLNG A 1 Bright A_ARPGLightningReady;
        MLNG BBBBBB 1 Bright A_WeaponReady;
        MLNG CCCCC 1 Bright A_WeaponReady;
        MLNG C 1 Bright A_ARPGLightningReady;
        MLNG BBBBBB 1 Bright A_WeaponReady;
        Loop;
    LightningFire:
        MLNG D 3 Bright A_ARPGBeginAttack;
        MLNG E 3 Bright;
        MLNG F 4 Bright A_ARPGLightningAttack;
        MLNG G 4 Bright;
        MLNG HI 3 Bright;
        MLNG I 6 Bright Offset(0, 199);
        MLNG C 2 Bright Offset(0, 55);
        MLNG B 2 Bright Offset(0, 50);
        MLNG B 2 Bright Offset(0, 45);
        MLNG B 2 Bright Offset(0, 40);
        Goto LightningReady;
    FrostSelect:
        CONE A 1 A_Raise;
        Loop;
    FrostDeselect:
        CONE A 1 A_Lower;
        Loop;
    FrostReady:
        CONE A 1 A_WeaponReady;
        Loop;
    FrostFire:
        CONE B 3 A_ARPGBeginAttack;
        CONE C 4;
    FrostHold:
        CONE D 3;
        CONE E 5;
        CONE F 3 A_ARPGFrostAttack;
        CONE G 3;
        CONE A 9;
        CONE A 1 A_ReFire;
        Goto FrostReady;
    StaffSelect:
        CSSF C 1 A_Raise;
        Loop;
    StaffDeselect:
        CSSF B 3;
        CSSF C 4;
        CSSF C 1 A_Lower;
        Wait;
    StaffReady:
        CSSF C 4;
        CSSF B 3 A_ARPGStaffInitBlink;
    StaffReadyLoop:
        CSSF AAAAAAA 1 A_WeaponReady;
        CSSF A 1 A_ARPGStaffCheckBlink;
        Goto StaffReadyLoop;
    StaffFire:
        CSSF A 1 Offset(0, 45) A_ARPGBeginAttack;
        CSSF J 1 Offset(0, 50) A_ARPGStaffAttack;
        CSSF J 2 Offset(0, 50);
        CSSF J 2 Offset(0, 45);
        CSSF A 2 Offset(0, 40);
        CSSF A 2 Offset(0, 36);
        Goto StaffReadyLoop;
    StaffBlink:
        CSSF BBBCCCCCBBB 1 A_WeaponReady;
        Goto StaffReadyLoop;
    WandSelect:
        MWND A 1 A_Raise;
        Loop;
    WandDeselect:
        MWND A 1 A_Lower;
        Loop;
    WandReady:
        MWND A 1 A_WeaponReady;
        Loop;
    WandFire:
        MWND A 6 A_ARPGBeginAttack;
        MWND B 6 Bright Offset(0, 48) A_ARPGWandAttack;
        MWND A 3 Offset(0, 40);
        MWND A 3 Offset(0, 36) A_ReFire;
        Goto WandReady;
    FirestormSelect:
        CFLM A 1 A_Raise;
        Loop;
    FirestormDeselect:
        CFLM A 1 A_Lower;
        Loop;
    FirestormReady:
        // One-tic states keep A_WeaponReady responsive on every game tic.
        CFLM AAAAAAAAAAAA 1 A_WeaponReady;
        CFLM BBBBBBBBBBBB 1 A_WeaponReady;
        CFLM CCCCCCCCCCCC 1 A_WeaponReady;
        Loop;
    FirestormFire:
        CFLM A 2 Offset(0, 40) A_ARPGBeginAttack;
        CFLM D 2 Offset(0, 50);
        CFLM D 2 Offset(0, 36);
        CFLM E 4 Bright;
        CFLM F 4 Bright A_ARPGFirestormAttack;
        CFLM E 4 Bright;
        CFLM G 2 Offset(0, 40);
        CFLM G 2;
        Goto FirestormReady;
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
        if (loot.damage == 0) { loot.kind = 0; loot.damage = ARPGBalance.SWORD_DAMAGE; loot.speed = 0; loot.manaCost = ARPGWeaponRules.ItemManaCost(0, loot.damage); loot.manaVersion = 1; }
    }
}

class ARPGSlot3 : ARPGEquippedWeapon
{
    Default { Weapon.SelectionOrder 1200; }
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        equipmentSlot = 3;
        if (loot.damage == 0) { loot.kind = 4; loot.damage = 100; loot.speed = 0; loot.manaCost = ARPGWeaponRules.ItemManaCost(4, loot.damage); loot.manaVersion = 1; }
    }
}
