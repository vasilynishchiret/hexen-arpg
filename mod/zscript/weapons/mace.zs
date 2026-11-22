class ARPGMace : CWeapMace
// Copyright (C) 2026 Vasily Nishchiret
// SPDX-License-Identifier: GPL-3.0-or-later

{
    override void ModifyDamage(int damage, Name damageType, out int newdamage,
        bool passive, Actor inflictor, Actor source, int flags, double angle)
    {
        if (!passive && damageType == 'Melee' && Owner != null &&
            Owner.player != null && Owner.player.ReadyWeapon == self)
        {
            newdamage = damage * ARPGBalance.MACE_DAMAGE_MULTIPLIER;
        }
    }
}
