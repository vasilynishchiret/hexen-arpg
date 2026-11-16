// Only Ettin receives the longer mace reach. All other states are inherited.
class ARPGEttin : Ettin replaces Ettin
{
    void A_ARPGChase()
    {
        A_Chase();
        if (target != null && target.health > 0 &&
            CheckMeleeRange(ARPGBalance.ETTIN_MELEE_RANGE) && CheckSight(target))
            SetStateLabel("Melee");
    }

    void A_ARPGMaceHit()
    {
        if (target == null || target.health <= 0) return;
        if (!CheckMeleeRange(ARPGBalance.ETTIN_MELEE_RANGE)) return;
        if (abs(deltaangle(angle, AngleTo(target))) > ARPGBalance.ETTIN_MELEE_HALF_ANGLE) return;
        if (!CheckSight(target)) return;
        target.DamageMobj(self, self, random[EttinAttack](1, 8) * 2, 'Melee');
        A_StartSound(AttackSound, CHAN_WEAPON);
    }

    States
    {
    See:
        ETTN ABCD 5 A_ARPGChase;
        Loop;
    Melee:
        ETTN EF 6 A_FaceTarget;
        ETTN G 8 A_ARPGMaceHit;
        Goto See;
    }
}
