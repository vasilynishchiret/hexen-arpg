// CheckReplacement keeps map position, TID, flags, and actor special on the
// Copyright (C) 2026 Vasily Nishchiret
// SPDX-License-Identifier: GPL-3.0-or-later

// replacement actor. The ARPG ground item fires the special on successful E pickup.
class ARPGMapArmorDrop : ARPGGroundWeapon
{
    Default { +NOGRAVITY }
    override void PostBeginPlay()
    {
        GenerateKind(random[ARPGMapArmor](10, 14));
        Super.PostBeginPlay();
    }
}

class ARPGMapWeaponDrop : ARPGGroundWeapon
{
    Default { +NOGRAVITY }
    override void PostBeginPlay()
    {
        int category = random[ARPGMapWeaponCategory](0,
            ARPGBalance.LOOT_MELEE_PERCENT + ARPGBalance.LOOT_MAGIC_PERCENT - 1);
        int kind = category < ARPGBalance.LOOT_MELEE_PERCENT ?
            random[ARPGMapMelee](0, 3) : random[ARPGMapMagic](4, 8);
        GenerateKind(kind);
        Super.PostBeginPlay();
    }
}

class ARPGMapConversion : EventHandler
{
    override void NetworkProcess(ConsoleEvent e)
    {
        if (e.Name != "arpg_maploot_status") return;
        int armor = 0;
        int weapons = 0;
        let armors = ThinkerIterator.Create("ARPGMapArmorDrop");
        while (armors.Next() != null) armor++;
        let guns = ThinkerIterator.Create("ARPGMapWeaponDrop");
        while (guns.Next() != null) weapons++;
        Console.Printf("ARPG map loot: %d armor, %d weapons waiting for E pickup", armor, weapons);
    }

    override void CheckReplacement(ReplaceEvent e)
    {
        let setting = CVar.GetCVar("arpg_convert_map_loot");
        if (setting == null || !setting.GetBool()) return;
        if (e.Replacee == 'MeshArmor' || e.Replacee == 'FalconShield' ||
            e.Replacee == 'PlatinumHelm' || e.Replacee == 'AmuletOfWarding' ||
            e.Replacee == 'ArtiBoostArmor')
        {
            e.Replacement = 'ARPGMapArmorDrop';
            e.IsFinal = true;
        }
        else if (e.Replacee == 'FWeapAxe' || e.Replacee == 'FWeapHammer' ||
            e.Replacee == 'CWeapStaff' || e.Replacee == 'CWeapFlame' ||
            e.Replacee == 'MWeapFrost' || e.Replacee == 'MWeapLightning')
        {
            e.Replacement = 'ARPGMapWeaponDrop';
            e.IsFinal = true;
        }
    }
}
