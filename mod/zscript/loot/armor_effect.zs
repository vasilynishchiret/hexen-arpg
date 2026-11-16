// Only ARPG armor uses this inventory modifier. It does not replace HexenArmor.
class ARPGArmorEffect : Inventory
{
    Default { Inventory.MaxAmount 1; +INVENTORY.UNDROPPABLE }

    override void ModifyDamage(int damage, Name damageType, out int newdamage,
        bool passive, Actor inflictor, Actor source, int flags, double angle)
    {
        let cleric = ARPGCleric(Owner);
        if (!passive || cleric == null || damage <= 0) return;
        // Native HexenArmor takes precedence if a map artifact granted any.
        let nativeArmor = HexenArmor(cleric.FindInventory("HexenArmor"));
        if (nativeArmor != null)
        {
            for (int i = 0; i < 5; i++)
                if (nativeArmor.Slots[i] > 0) return;
        }
        int reduction = 0;
        if (cleric.arpgArmor[0].damage > 0) reduction += 10 + cleric.arpgArmor[0].statDR;
        if (cleric.arpgArmor[1].damage > 0) reduction += 5;
        if (cleric.arpgArmor[2].damage > 0 && cleric.arpgArmor[2].affixCount == 0) reduction += 3;
        reduction = min(reduction, 45);
        newdamage = max(1, (damage * (100 - reduction) + 99) / 100);
    }
}
