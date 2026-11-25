// Copyright (C) 2026 Vasily Nishchiret
// SPDX-License-Identifier: GPL-3.0-or-later

class ARPGStandalonePlayer : PlayerPawn
{
    Default
    {
        Health 100;
        Radius 16;
        Height 56;
        Speed 1;
        Player.DisplayName "Explorer";
        Player.ViewHeight 41;
        Player.JumpZ 8;
        Player.StartItem "ARPGStandaloneWeapon";
        Player.WeaponSlot 1, "ARPGStandaloneWeapon";
    }
    override void PostBeginPlay()
    {
        Super.PostBeginPlay();
        if (level.MapName == 'MAP01')
        {
            // The single test token is independent of engine game actor tables.
            let tokens = ThinkerIterator.Create("ARPGStandalonePickup");
            if (tokens.Next() == null)
                Spawn("ARPGStandalonePickup", (160, 0, 0));
        }
    }
    States
    {
    Spawn:
        ARPL A -1;
        Loop;
    See:
        ARPL A 4;
        Loop;
    Pain:
        ARPL A 4;
        Goto Spawn;
    Death:
        ARPL A -1;
        Stop;
    }
}

class ARPGStandalonePuff : Actor
{
    Default { +NOBLOCKMAP +NOGRAVITY }
    States
    {
    Spawn:
        ARFX A 5 Bright;
        Stop;
    }
}

class ARPGStandaloneWeapon : Weapon
{
    Default
    {
        Weapon.SelectionOrder 100;
        Weapon.SlotNumber 1;
        Weapon.AmmoUse1 0;
        Tag "Prototype blade";
    }
    States
    {
    Ready:
        ARWP A 1 A_WeaponReady;
        Loop;
    Select:
        ARWP A 1 A_Raise;
        Loop;
    Deselect:
        ARWP A 1 A_Lower;
        Loop;
    Fire:
        ARWP B 4 A_CustomPunch(15, false, 0, "ARPGStandalonePuff", 96);
        ARWP A 5;
        Goto Ready;
    Spawn:
        ARWP A -1;
        Stop;
    }
}

class ARPGStandalonePickup : Inventory
{
    Default
    {
        Inventory.Amount 1;
        Inventory.MaxAmount 20;
        Inventory.PickupMessage "Picked up a prototype token";
        +FLOATBOB;
        +SPECIAL;
    }
    States
    {
    Spawn:
        ARIT A -1 Bright;
        Stop;
    }
}

class ARPGStandaloneStatusBar : BaseStatusBar
{
    HUDFont numberFont;

    override void Init()
    {
        Super.Init();
        numberFont = HUDFont.Create("ConsoleFont");
    }

    override void Draw(int state, double ticFrac)
    {
        Super.Draw(state, ticFrac);
        if (CPlayer == null || CPlayer.mo == null) return;
        let tokens = CPlayer.mo.FindInventory("ARPGStandalonePickup");
        BeginHUD();
        DrawString(numberFont, String.Format("HP %d  Tokens %d",
            CPlayer.health, tokens == null ? 0 : tokens.Amount), (8, 8),
            0, Font.CR_GOLD);
    }
}
