class ARPGSword : CWeapMace
{
    Default
    {
        Weapon.AmmoType1 "Mana1";
        Weapon.AmmoUse1 ARPGBalance.SWORD_MANA_COST;
        Weapon.SelectionOrder 1700;
        Tag "Charged Sword";
    }

    action void A_ARPGSwordAttack()
    {
        if (player == null || player.ReadyWeapon == null || !player.ReadyWeapon.DepleteAmmo(false)) return;
        A_CustomPunch(70, true, 0, "HammerPuff", 2 * DEFMELEERANGE);
    }
    States
    {
    Fire:
        CMCE B 4 Offset(30, 33);
        CMCE C 3 Offset(8, 45);
        CMCE E 1 Offset(-11, 58) A_ARPGSwordAttack;
        CMCE F 8 Offset(-33, 160);
        CMCE A 2 A_ReFire;
        Goto Ready;
    }
}
