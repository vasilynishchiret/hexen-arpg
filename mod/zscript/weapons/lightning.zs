class ARPGLightning : MWeapLightning
// Copyright (C) 2026 Vasily Nishchiret
// SPDX-License-Identifier: GPL-3.0-or-later

{
    Default
    {
        Weapon.SelectionOrder 1200;
        Tag "Lightning Book";
    }

    override bool CanPickup(Actor toucher)
    {
        if (toucher is "ARPGCleric") return true;
        return Super.CanPickup(toucher);
    }
}
