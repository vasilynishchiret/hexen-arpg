class ARPGMace : CWeapMace
{
    override void ModifyDamage(int damage, Name damageType, out int newdamage,
        bool passive, Actor inflictor, Actor source, int flags, double angle)
    {
        if (!passive && damageType == 'Melee' && Owner != null &&
            Owner.player != null && Owner.player.ReadyWeapon == self)
        {
            newdamage = damage * 2;
        }
    }
}
