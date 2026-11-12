class ARPGSword : CWeapMace
{
    Default
    {
        Weapon.AmmoType1 "Mana1";
        Weapon.AmmoUse1 ARPGBalance.SWORD_MANA_COST;
        Weapon.SelectionOrder 1700;
        Tag "Charged Sword";
    }

    bool HasCharge() const
    {
        return Ammo1 != null && Ammo1.Amount >= AmmoUse1;
    }

    override State GetUpState()
    {
        if (HasCharge()) return FindState('SelectGlow');
        return FindState('Select');
    }

    override State GetDownState()
    {
        if (HasCharge()) return FindState('DeselectGlow');
        return FindState('Deselect');
    }

    override State GetReadyState()
    {
        if (HasCharge()) return FindState('ReadyGlow');
        return FindState('Ready');
    }

    override State GetAtkState(bool hold)
    {
        if (HasCharge()) return FindState('FireGlow');
        return FindState('Fire');
    }

    action void A_ARPGSwordReady(bool glowing)
    {
        if (player == null || player.ReadyWeapon == null) return;
        let sword = ARPGSword(player.ReadyWeapon);
        if (sword == null) return;
        if (sword.HasCharge() != glowing)
        {
            player.SetPsprite(PSP_WEAPON, sword.GetReadyState());
            return;
        }
        A_WeaponReady();
    }

    action void A_ARPGSwordAttack()
    {
        if (player == null || player.ReadyWeapon == null || !player.ReadyWeapon.DepleteAmmo(false)) return;
        A_CustomPunch(ARPGBalance.SWORD_DAMAGE, true, 0, "ARPGSwordPuff", 2 * DEFMELEERANGE);
    }

    States
    {
    Spawn:
        ARAW A -1;
        Stop;
    Select:
        ARAX A 1 A_Raise;
        Loop;
    Deselect:
        ARAX A 1 A_Lower;
        Loop;
    Ready:
        ARAX A 1 A_ARPGSwordReady(false);
        Loop;
    Fire:
        ARAX B 4 Offset(15, 32);
        ARAX C 3 Offset(15, 32);
        ARAX D 2 Offset(15, 32);
        ARAX D 1 Offset(-5, 70) A_ARPGSwordAttack;
    EndAttack:
        ARAX D 2 Offset(-25, 90);
        ARAX E 1 Offset(15, 32);
        ARAX E 2 Offset(10, 54);
        ARAX E 7 Offset(10, 150);
        ARAX A 1 Offset(0, 60) A_ReFire;
        ARAX A 1 Offset(0, 52);
        ARAX A 1 Offset(0, 44);
        ARAX A 1 Offset(0, 36);
        ARAX A 1;
        Goto Ready;
    SelectGlow:
        ARAX L 1 A_Raise;
        Loop;
    DeselectGlow:
        ARAX L 1 A_Lower;
        Loop;
    ReadyGlow:
        ARAX LLL 1 A_ARPGSwordReady(true);
        ARAX MMM 1 A_ARPGSwordReady(true);
        Loop;
    FireGlow:
        ARAX N 4 Offset(15, 32);
        ARAX O 3 Offset(15, 32);
        ARAX P 2 Offset(15, 32);
        ARAX P 1 Offset(-5, 70) A_ARPGSwordAttack;
        ARAX P 2 Offset(-25, 90);
        ARAX Q 1 Offset(15, 32);
        ARAX Q 2 Offset(10, 54);
        ARAX Q 7 Offset(10, 150);
        ARAX A 1 Offset(0, 60) A_ReFire;
        ARAX A 1 Offset(0, 52);
        ARAX A 1 Offset(0, 44);
        ARAX A 1 Offset(0, 36);
        ARAX A 1;
        Goto Ready;
    }
}
