class ARPGInventoryHud : EventHandler
{
    clearscope static String SlotName(int slot)
    {
        if (slot <= 3) return String.Format("Weapon %d", slot);
        if (slot == 4) return "Chest Armor";
        if (slot == 5) return "Helmet";
        if (slot == 6) return "Bracers";
        if (slot == 7) return "Ring 1";
        if (slot == 8) return "Ring 2";
        return "Boots";
    }

    override void InterfaceProcess(ConsoleEvent e)
    {
        if (e.Name != "arpg_inventory" || Menu.GetCurrentMenu() != null) return;
        let cleric = ARPGCleric(players[consoleplayer].mo);
        if (cleric == null || cleric.health <= 0) return;
        Menu.SetMenu('ARPGInventory');
        SendNetworkEvent("arpg_inventory_state", 1);
    }

    override void RenderOverlay(RenderEvent e)
    {
        let cleric = ARPGCleric(players[consoleplayer].mo);
        if (cleric == null) return;
        if (cleric.arpgShieldActive)
        {
            Screen.Dim(0x2277CC, 0.13, 0, 0, Screen.GetWidth(), Screen.GetHeight());
            Screen.DrawLineFrame(0x8833CCFF, 12, 12,
                Screen.GetWidth() - 24, Screen.GetHeight() - 24, 2);
        }
        if (cleric.arpgDetectCount > 0 && level.maptime < cleric.arpgDetectEndAt)
        {
            int x = Screen.GetWidth() - 170;
            Screen.DrawText(SmallFont, Font.CR_GOLD, x, 38, "ENEMY DETECTION");
            for (int i = 0; i < cleric.arpgDetectCount; i++)
                Screen.DrawText(SmallFont, Font.CR_RED, x, 50 + i * 10,
                    String.Format("%+d deg   %d units", cleric.arpgDetectAngle[i], cleric.arpgDetectDistance[i]));
        }
        int x = Screen.GetWidth() - 170;
        int y = Screen.GetHeight() - 78;
        if (ARPGAffixes.Has(cleric.arpgBoots, ARPGAffixes.DASH))
        {
            Screen.DrawText(SmallFont, Font.CR_GOLD, x, y,
                String.Format("Dash: %s", level.maptime >= cleric.arpgDashReadyAt ? "ready" :
                    String.Format("%ds", (cleric.arpgDashReadyAt - level.maptime + 34) / 35)));
            y += 12;
        }
        if (ARPGAffixes.Has(cleric.arpgArmor[2], ARPGAffixes.ARCANE_SHIELD))
        {
            Screen.DrawText(SmallFont, Font.CR_GOLD, x, y,
                String.Format("Shield: %s", cleric.arpgShieldActive ? "active" :
                    level.maptime >= cleric.arpgShieldReadyAt ? "ready" :
                    String.Format("%ds", (cleric.arpgShieldReadyAt - level.maptime + 34) / 35)));
            y += 12;
        }
        if (ARPGAffixes.Has(cleric.arpgArmor[2], ARPGAffixes.GUARDIAN))
        {
            Screen.DrawText(SmallFont, Font.CR_GOLD, x, y,
                String.Format("Guardian: %s", level.maptime >= cleric.arpgGuardianReadyAt ? "ready" :
                    String.Format("%ds", (cleric.arpgGuardianReadyAt - level.maptime + 34) / 35)));
            y += 12;
        }
        if (ARPGAffixes.Has(cleric.arpgArmor[1], ARPGAffixes.INVISIBILITY))
        {
            Screen.DrawText(SmallFont, Font.CR_GOLD, x, y,
                String.Format("Invisible: %s", level.maptime < cleric.arpgInvisEndAt ? "active" :
                    level.maptime >= cleric.arpgInvisReadyAt ? "ready" :
                    String.Format("%ds", (cleric.arpgInvisReadyAt - level.maptime + 34) / 35)));
            y += 12;
        }
        if (ARPGAffixes.Has(cleric.arpgArmor[1], ARPGAffixes.ENEMY_DETECTION))
            Screen.DrawText(SmallFont, Font.CR_GOLD, x, y,
                String.Format("Detection: %s", level.maptime < cleric.arpgDetectEndAt ? "active" :
                    level.maptime >= cleric.arpgDetectReadyAt ? "ready" :
                    String.Format("%ds", (cleric.arpgDetectReadyAt - level.maptime + 34) / 35)));
    }
}

class ARPGInventoryMenu : ListMenu
{
    int selected;
    int hovered;
    int preferredRing;
    int lastClickItem;
    int lastClickTime;
    int gemColor;
    int upgradeTarget;
    int upgradeCount;

    override void Init(Menu parent, ListMenuDescriptor desc)
    {
        Super.Init(parent, desc);
        selected = -1;
        hovered = -1;
        preferredRing = 7;
        lastClickItem = -1;
        lastClickTime = -100;
        upgradeTarget = -1;
        upgradeCount = 1;
    }

    ARPGCleric Cleric() { return ARPGCleric(players[consoleplayer].mo); }

    void DrawLine(int color, int x, int y, String label)
    {
        Screen.DrawText(SmallFont, color, x, y, label,
            DTA_VIRTUALWIDTH, 640, DTA_VIRTUALHEIGHT, 400);
    }

    void DrawDetails(ARPGWeaponData data)
    {
        if (data.damage <= 0) return;
        int kind = data.kind;
        if (kind == 15 || kind == 16)
        {
            DrawLine(Font.CR_GOLD, 20, 264, String.Format("%s x%d", ARPGWeaponRules.TypeName(kind), data.damage));
            DrawLine(Font.CR_GRAY, 20, 284, "Select equipment to preview, then press Enter");
            return;
        }
        DrawLine(Font.CR_GOLD, 20, 264, String.Format("%s / %s",
            ARPGWeaponRules.TypeName(kind), ARPGWeaponRules.CategoryName(kind)));
        if (kind < 10)
            DrawLine(Font.CR_GRAY, 20, 284, String.Format("Base %d  Power %d  Mana %d %s", ARPGUpgradeRules.OriginalPower(data), data.damage,
                ARPGWeaponRules.StoredManaCost(data), ARPGWeaponRules.ManaName(kind)));
        else if (kind == 10)
        {
            DrawLine(Font.CR_GRAY, 20, 284, String.Format("HP +%d (+%d)  DR %d.%d%%", data.statHP, data.blueUpgrades,
                ARPGUpgradeRules.ReductionTenths(data) / 10, ARPGUpgradeRules.ReductionTenths(data) % 10));
            DrawLine(Font.CR_GRAY, 20, 302, String.Format("Max Mana1 +%d  Mana2 +%d", data.statMana1, data.statMana2));
            DrawLine(Font.CR_GRAY, 20, 320, String.Format("Mana1 regen +%d%%", data.statRegen));
        }
        else if (kind == 11) DrawLine(Font.CR_GRAY, 20, 284, String.Format("HP +%d  Protection %d.%d%%",
            data.blueUpgrades, ARPGUpgradeRules.ReductionTenths(data) / 10, ARPGUpgradeRules.ReductionTenths(data) % 10));
        else if (kind == 12) DrawLine(Font.CR_GRAY, 20, 284,
            data.affixCount > 0 ? "Special defense" : "Protection 3%");
        else if (kind == 13) DrawLine(Font.CR_GRAY, 20, 284, String.Format("Max HP +5  Mana1 +%d  Regen +%d%%",
            data.blueUpgrades, data.greenUpgrades));
        DrawLine(Font.CR_GOLD, 20, 340, String.Format("Upgrades: %d/100  Blue %d  Green %d",
            ARPGUpgradeRules.Total(data), data.blueUpgrades, data.greenUpgrades));
        DrawLine(Font.CR_GOLD, 330, 264, "GAMEPLAY AFFIXES");
        if (data.affixCount == 0) DrawLine(Font.CR_GRAY, 330, 284, "None");
        for (int i = 0; i < data.affixCount; i++)
        {
            int y = 282 + i * 25;
            DrawLine(Font.CR_GREEN, 330, y, ARPGAffixes.Description(data.affix[i]));
            String terms = ARPGAffixes.Terms(data.affix[i]);
            if (terms.IsNotEmpty()) DrawLine(Font.CR_GRAY, 330, y + 11, terms);
        }
    }

    int Hit(int mx, int my)
    {
        int x = mx * 640 / Screen.GetWidth();
        int y = my * 400 / Screen.GetHeight();
        if (y < 60 || y >= 260) return -1;
        if (x >= 20 && x < 195) return (y - 60) / 20;
        if (x >= 200 && x < 375) return 10 + (y - 60) / 20;
        if (x >= 400 && x < 620 && y < 240) return 20 + (y - 60) / 20;
        return -1;
    }

    int Target(ARPGCleric cleric, int item)
    {
        if (cleric == null || item < 0 || item >= 20 || cleric.arpgBag[item].damage <= 0) return 0;
        int kind = cleric.arpgBag[item].kind;
        if (kind == 10) return 4;
        if (kind == 11) return 5;
        if (kind == 12) return 6;
        if (kind == 13)
        {
            if (cleric.arpgArmor[3].damage <= 0) return 7;
            if (cleric.arpgArmor[4].damage <= 0) return 8;
            return preferredRing;
        }
        if (kind == 14) return 9;
        if (kind < 0 || kind >= 10) return 0;
        for (int slot = 1; slot <= 3; slot++)
        {
            let weapon = ARPGEquippedWeapon(cleric.FindInventory(String.Format("ARPGSlot%d", slot)));
            if (weapon != null && weapon.loot.damage <= 0) return slot;
        }
        return cleric.arpgActiveSlot >= 1 && cleric.arpgActiveSlot <= 3 ? cleric.arpgActiveSlot : 1;
    }

    void EquipSelected()
    {
        let cleric = Cleric();
        if (cleric == null) return;
        if (selected >= 0 && selected < 20 && cleric.arpgBag[selected].damage > 0)
            EventHandler.SendNetworkEvent("arpg_auto_equip", selected, preferredRing);
        else if (selected >= 20 && selected < 29)
            EventHandler.SendNetworkEvent("arpg_slot_unequip", selected - 19);
    }

    void ConfirmUpgrade()
    {
        if (gemColor == 0 || upgradeTarget < 0) return;
        EventHandler.SendNetworkEvent("arpg_upgrade", upgradeTarget, gemColor, upgradeCount);
    }

    void Navigate(int key)
    {
        if (selected < 0) { selected = 0; return; }
        int column = selected < 10 ? 0 : selected < 20 ? 1 : 2;
        int row = selected < 10 ? selected : selected < 20 ? selected - 10 : selected - 20;
        if (key == 0) row = max(0, row - 1);
        if (key == 1) row = min(column == 2 ? 8 : 9, row + 1);
        if (key == 2) column = max(0, column - 1);
        if (key == 3) column = min(2, column + 1);
        if (column == 2) row = min(8, row);
        selected = column == 0 ? row : column == 1 ? row + 10 : row + 20;
        if (selected == 26 || selected == 27) preferredRing = selected - 19;
    }

    override bool OnUIEvent(UIEvent ev)
    {
        if (ev.Type == UIEvent.Type_WheelUp) { Navigate(0); return true; }
        if (ev.Type == UIEvent.Type_WheelDown) { Navigate(1); return true; }
        if (ev.Type == UIEvent.Type_MButtonDown || ev.Type == UIEvent.Type_MButtonUp ||
            ev.Type == UIEvent.Type_MButtonClick) return true;
        if (ev.Type == UIEvent.Type_MouseMove)
        {
            hovered = Hit(ev.MouseX, ev.MouseY);
            return Super.OnUIEvent(ev);
        }
        if (ev.Type == UIEvent.Type_LButtonDown || ev.Type == UIEvent.Type_RButtonDown)
        {
            int item = Hit(ev.MouseX, ev.MouseY);
            if (item < 0) { selected = -1; lastClickItem = -1; return true; }
            let cleric = Cleric();
            if (cleric != null && item < 20 && cleric.arpgBag[item].damage > 0 &&
                (cleric.arpgBag[item].kind == 15 || cleric.arpgBag[item].kind == 16))
            {
                gemColor = cleric.arpgBag[item].kind == 15 ? 1 : 2;
                upgradeTarget = -1;
                selected = item;
                return true;
            }
            if (gemColor != 0)
            {
                upgradeTarget = item;
                selected = item;
                return true;
            }
            if (item == 26 || item == 27) preferredRing = item - 19;
            bool twice = item == lastClickItem && MenuTime() - lastClickTime <= 12;
            selected = item;
            lastClickItem = item;
            lastClickTime = MenuTime();
            if (ev.Type == UIEvent.Type_RButtonDown || twice) EquipSelected();
            return true;
        }
        if (ev.Type == UIEvent.Type_KeyDown || ev.Type == UIEvent.Type_KeyRepeat)
        {
            int key = ev.KeyChar;
            if (key == UIEvent.Key_Escape) return MenuEvent(MKEY_Back, false);
            if (key == UIEvent.Key_Up || key == 87 || key == 119) { Navigate(0); return true; }
            if (key == UIEvent.Key_Down || key == 83 || key == 115) { Navigate(1); return true; }
            if (key == UIEvent.Key_Left || key == 65 || key == 97) { Navigate(2); return true; }
            if (key == UIEvent.Key_Right || key == 68 || key == 100) { Navigate(3); return true; }
            if (key == UIEvent.Key_Return)
            {
                if (gemColor != 0) ConfirmUpgrade(); else EquipSelected();
                return true;
            }
            if (gemColor != 0 && key == 49) { upgradeCount = 1; return true; }
            if (gemColor != 0 && key == 48) { upgradeCount = 10; return true; }
            if (gemColor != 0 && (key == 77 || key == 109)) { upgradeCount = 100; return true; }
            if ((key == 80 || key == 112) && gemColor == 0 && selected >= 0 && selected < 20)
            {
                EventHandler.SendNetworkEvent("arpg_slot_drop", selected);
                return true;
            }
        }
        return Super.OnUIEvent(ev);
    }

    override bool OnInputEvent(InputEvent ev)
    {
        // Modifier keys are delivered as raw input rather than GUI KeyChar events.
        if (ev.Type == InputEvent.Type_KeyDown && ev.KeyScan == InputEvent.Key_LAlt)
            return MenuEvent(MKEY_Back, false);
        return Super.OnInputEvent(ev);
    }

    override bool MenuEvent(int mkey, bool fromcontroller)
    {
        if (mkey == MKEY_Back)
        {
            EventHandler.SendNetworkEvent("arpg_inventory_state", 0);
            return Super.MenuEvent(mkey, fromcontroller);
        }
        if (mkey == MKEY_Up) { Navigate(0); return true; }
        if (mkey == MKEY_Down) { Navigate(1); return true; }
        if (mkey == MKEY_Left) { Navigate(2); return true; }
        if (mkey == MKEY_Right) { Navigate(3); return true; }
        if (mkey == MKEY_Enter) { if (gemColor != 0) ConfirmUpgrade(); else EquipSelected(); return true; }
        return Super.MenuEvent(mkey, fromcontroller);
    }

    override void Drawer()
    {
        let cleric = Cleric();
        if (cleric == null) return;
        DrawLine(Font.CR_GOLD, 20, 30, "INVENTORY 20 SLOTS");
        DrawLine(Font.CR_GOLD, 400, 30, "EQUIPMENT");
        for (int i = 0; i < 20; i++)
        {
            int x = i < 10 ? 20 : 200;
            int y = 60 + (i % 10) * 20;
            int color = i == selected ? Font.CR_GREEN : i == hovered ? Font.CR_GOLD : Font.CR_GRAY;
            String title = cleric.arpgBag[i].damage > 0 ? ARPGWeaponRules.TypeName(cleric.arpgBag[i].kind) : "(empty)";
            if (cleric.arpgBag[i].kind >= 15 && cleric.arpgBag[i].damage > 0)
                title = String.Format("%s x%d", title, cleric.arpgBag[i].damage);
            DrawLine(color, x, y, String.Format("%s%02d %s", i == selected ? ">" : " ", i + 1, title));
            if (cleric.arpgBag[i].kind == 15 || cleric.arpgBag[i].kind == 16)
            {
                let icon = TexMan.CheckForTexture(cleric.arpgBag[i].kind == 15 ? "MAN1I0" : "MAN2G0", TexMan.Type_MiscPatch);
                if (icon.IsValid()) Screen.DrawTexture(icon, true, x + 155, y,
                    DTA_VirtualWidth, 640, DTA_VirtualHeight, 400, DTA_DestWidth, 12, DTA_DestHeight, 12);
            }
        }
        for (int slot = 1; slot <= 9; slot++)
        {
            int kind = -1;
            if (slot <= 3)
            {
                let weapon = ARPGEquippedWeapon(cleric.FindInventory(String.Format("ARPGSlot%d", slot)));
                if (weapon != null && weapon.loot.damage > 0) kind = weapon.loot.kind;
            }
            else if (slot == 9 && cleric.arpgBoots.damage > 0) kind = 14;
            else if (slot <= 8 && cleric.arpgArmor[slot - 4].damage > 0) kind = cleric.arpgArmor[slot - 4].kind;
            int index = slot + 19;
            int color = index == selected ? Font.CR_GREEN : index == hovered ? Font.CR_GOLD : Font.CR_GRAY;
            DrawLine(color, 400, 60 + (slot - 1) * 20,
                String.Format("%s%s: %s", index == selected ? ">" : " ", ARPGInventoryHud.SlotName(slot),
                    kind >= 0 ? ARPGWeaponRules.TypeName(kind) : "(empty)"));
        }
        int item = gemColor != 0 && upgradeTarget >= 0 ? upgradeTarget :
            hovered >= 0 ? hovered : selected;
        ARPGWeaponData detail;
        if (item >= 0 && item < 20) ARPGAffixes.Copy(detail, cleric.arpgBag[item]);
        else if (item >= 20 && item < 23)
        {
            let weapon = ARPGEquippedWeapon(cleric.FindInventory(String.Format("ARPGSlot%d", item - 19)));
            if (weapon != null) ARPGAffixes.Copy(detail, weapon.loot);
        }
        else if (item >= 23 && item < 28) ARPGAffixes.Copy(detail, cleric.arpgArmor[item - 23]);
        else if (item == 28) ARPGAffixes.Copy(detail, cleric.arpgBoots);
        if (item >= 0 && item < 20 && detail.damage > 0)
        {
            int target = Target(cleric, item);
            if (target > 0)
            {
                String comparison = "Empty slot";
                if (target <= 3)
                {
                    let weapon = ARPGEquippedWeapon(cleric.FindInventory(String.Format("ARPGSlot%d", target)));
                    if (weapon != null && weapon.loot.damage > 0)
                        comparison = String.Format("Replacing %s, power %d", ARPGWeaponRules.TypeName(weapon.loot.kind), weapon.loot.damage);
                }
                else if (target == 9 && cleric.arpgBoots.damage > 0)
                    comparison = "Replacing Boots";
                else if (target <= 8 && cleric.arpgArmor[target - 4].damage > 0)
                    comparison = String.Format("Replacing %s", ARPGWeaponRules.TypeName(cleric.arpgArmor[target - 4].kind));
                DrawLine(Font.CR_GREEN, 20, 248, String.Format("Target %s: %s", ARPGInventoryHud.SlotName(target), comparison));
            }
        }
        DrawDetails(detail);
        if (gemColor != 0)
        {
            if (upgradeTarget >= 0)
            {
                ARPGWeaponData preview;
                ARPGAffixes.Copy(preview, detail);
                int gemSlot = cleric.GemSlot(gemColor == 1 ? 15 : 16);
                int available = gemSlot >= 0 ? cleric.arpgBag[gemSlot].damage : 0;
                int count = ARPGUpgradeRules.Apply(preview, gemColor, min(upgradeCount, available));
                String change = "This item cannot be upgraded";
                if (count > 0 && preview.kind < 10)
                    change = String.Format("Preview: %d gems, power %d -> %d, mana %d -> %d", count,
                        detail.damage, preview.damage, ARPGWeaponRules.StoredManaCost(detail),
                        ARPGWeaponRules.StoredManaCost(preview));
                else if (count > 0 && preview.kind == 13)
                    change = String.Format("Preview: %d gems, Mana1 +%d, regen +%d%%", count,
                        preview.blueUpgrades, preview.greenUpgrades);
                else if (count > 0)
                    change = String.Format("Preview: %d gems, HP +%d, DR %d.%d%%", count,
                        preview.blueUpgrades, ARPGUpgradeRules.ReductionTenths(preview) / 10,
                        ARPGUpgradeRules.ReductionTenths(preview) % 10);
                DrawLine(Font.CR_GREEN, 20, 360, change);
            }
            DrawLine(Font.CR_GRAY, 20, 380, "Gem selected: click item, 1/0/M quantity, Enter apply, ALT/Esc close");
        }
        else DrawLine(Font.CR_GRAY, 20, 380, "Click select  Double/right click/Enter equip  P drop  WASD/arrows move  ALT/Esc close");
        // This custom menu has no ListMenu items. The inherited drawer would
        // show UZDoom's back button, whose click is consumed by our item picker.
    }
}
