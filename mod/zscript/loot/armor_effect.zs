// Only ARPG armor uses this inventory modifier. It does not replace HexenArmor.
// Copyright (C) 2026 Vasily Nishchiret
// SPDX-License-Identifier: GPL-3.0-or-later

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
        int reduction = 0; // tenths of a percentage point
        for (int i = 0; i < 3; i++)
            if (cleric.arpgArmor[i].damage > 0)
                reduction += ARPGUpgradeRules.ReductionTenths(cleric.arpgArmor[i]);
        reduction = min(reduction, 450);
        newdamage = max(1, (damage * (1000 - reduction) + 999) / 1000);
    }
}
