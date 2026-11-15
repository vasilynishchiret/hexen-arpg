class ARPGInventoryHud : EventHandler
{
    clearscope static String IconName(int kind)
    {
        if (kind == 0) return "ARAWA0";
        if (kind == 1) return "WFAXA0";
        if (kind == 2) return "WFHMA0";
        if (kind == 3) return "CMCEA0";
        if (kind == 4) return "WMLGA0";
        if (kind == 5) return "WMCSA0";
        if (kind == 6) return "WCSSA0";
        if (kind == 7) return "MWNDA0";
        if (kind == 8) return "WCFMA0";
        if (kind == 10) return "ARM1A0";
        if (kind == 11) return "ARM3A0";
        if (kind == 12) return "ARTIBRAC";
        if (kind == 13) return "ARRGA0";
        return "";
    }

    clearscope static String SlotName(int slot)
    {
        if (slot <= 3) return String.Format("Weapon %d", slot);
        if (slot == 4) return "Chest Armor";
        if (slot == 5) return "Helmet";
        if (slot == 6) return "Bracers";
        if (slot == 7) return "Ring 1";
        return "Ring 2";
    }

    override void RenderOverlay(RenderEvent e)
    {
        let cleric = ARPGCleric(players[consoleplayer].mo);
        if (cleric == null || !cleric.arpgInventoryOpen) return;
        Screen.DrawText(SmallFont, Font.CR_GOLD, 8, 108, "INVENTORY 20 SLOTS");
        for (int i = 0; i < 20; i++)
        {
            int x = 8 + (i / 10) * 155;
            int y = 120 + (i % 10) * 10;
            int color = i == cleric.arpgSelectedItem ? Font.CR_GREEN : Font.CR_GRAY;
            String title = cleric.arpgBag[i].damage > 0 ? ARPGWeaponRules.TypeName(cleric.arpgBag[i].kind) : "(empty)";
            Screen.DrawText(SmallFont, color, x, y, String.Format("%02d %s", i + 1, title));
            if (cleric.arpgBag[i].damage > 0)
                Screen.DrawTexture(TexMan.CheckForTexture(IconName(cleric.arpgBag[i].kind), TexMan.Type_Any), false,
                    x + 130, y, DTA_DESTWIDTH, 8, DTA_DESTHEIGHT, 8);
        }
        Screen.DrawText(SmallFont, Font.CR_GOLD, 320, 108, "EQUIPMENT");
        for (int slot = 1; slot <= 8; slot++)
        {
            int kind = -1;
            if (slot <= 3)
            {
                let weapon = ARPGEquippedWeapon(cleric.FindInventory(String.Format("ARPGSlot%d", slot)));
                if (weapon != null && weapon.loot.damage > 0) kind = weapon.loot.kind;
            }
            else if (cleric.arpgArmor[slot - 4].damage > 0) kind = cleric.arpgArmor[slot - 4].kind;
            String item = kind >= 0 ? ARPGWeaponRules.TypeName(kind) : "(empty)";
            int color = slot == cleric.arpgEquipTarget ? Font.CR_GREEN : Font.CR_GRAY;
            Screen.DrawText(SmallFont, color, 320, 120 + (slot - 1) * 10,
                String.Format("%s: %s", SlotName(slot), item));
            if (kind >= 0)
                Screen.DrawTexture(TexMan.CheckForTexture(IconName(kind), TexMan.Type_Any), false,
                    455, 120 + (slot - 1) * 10, DTA_DESTWIDTH, 8, DTA_DESTHEIGHT, 8);
        }
        int selected = cleric.arpgSelectedItem;
        if (cleric.arpgBag[selected].damage > 0)
        {
            int kind = cleric.arpgBag[selected].kind;
            Screen.DrawText(SmallFont, Font.CR_GOLD, 8, 225, ARPGWeaponRules.TypeName(kind));
            if (kind < 4)
                Screen.DrawText(SmallFont, Font.CR_GRAY, 8, 235,
                    String.Format("Damage %d  Mana %d %s", cleric.arpgBag[selected].damage,
                        cleric.arpgBag[selected].manaCost, ARPGWeaponRules.ManaName(kind)));
            else if (kind < 10)
                Screen.DrawText(SmallFont, Font.CR_GRAY, 8, 235,
                    String.Format("Spell power %d%%  Mana %d %s", cleric.arpgBag[selected].damage, cleric.arpgBag[selected].manaCost,
                        ARPGWeaponRules.ManaName(kind)));
            else
                Screen.DrawText(SmallFont, Font.CR_GRAY, 8, 235,
                    kind == 13 ? "+5 max HP" : String.Format("Protection %d%%", kind == 10 ? 10 : kind == 11 ? 5 : 3));
            int target = cleric.arpgEquipTarget;
            if (target <= 3)
            {
                let current = ARPGEquippedWeapon(cleric.FindInventory(String.Format("ARPGSlot%d", target)));
                if (current != null && current.loot.damage > 0)
                    Screen.DrawText(SmallFont, Font.CR_GRAY, 8, 245,
                        String.Format("vs %s: damage %d, mana %d", ARPGWeaponRules.TypeName(current.loot.kind),
                            current.loot.damage, current.loot.manaCost));
            }
            else if (cleric.arpgArmor[target - 4].damage > 0)
                Screen.DrawText(SmallFont, Font.CR_GRAY, 8, 245,
                    String.Format("vs equipped %s", ARPGWeaponRules.TypeName(cleric.arpgArmor[target - 4].kind)));
        }
        Screen.DrawText(SmallFont, Font.CR_GRAY, 8, 260, "J/K item  H/L slot  U equip  O remove  P drop  I close");
    }
}
