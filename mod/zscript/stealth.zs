// The native Shadow flag makes the player less accurate as a monster target.
// Copyright (C) 2026 Vasily Nishchiret
// SPDX-License-Identifier: GPL-3.0-or-later

class ARPGStealthPower : PowerInvisibility
{
    Default
    {
        Powerup.Duration 105;
        Powerup.Strength 80;
        Powerup.Mode "Translucent";
        Inventory.MaxAmount 1;
    }
}
