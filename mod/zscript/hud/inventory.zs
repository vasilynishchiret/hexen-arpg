class ARPGInventoryHud : EventHandler
{
    clearscope static String SlotName(int slot)
    {
        if (slot <= 3) return String.Format("Weapon %d", slot);
        if (slot == 4) return "Chest Armor";
        if (slot == 5) return "Helmet";
        if (slot == 6) return "Bracers";
        if (slot == 7) return "Ring 1";
        return "Ring 2";
    }

    override void InterfaceProcess(ConsoleEvent e)
    {
        if (e.Name != "arpg_inventory" || Menu.GetCurrentMenu() != null) return;
        let cleric = ARPGCleric(players[consoleplayer].mo);
        if (cleric == null || cleric.health <= 0) return;
        Menu.SetMenu('ARPGInventory');
        SendNetworkEvent("arpg_inventory_state", 1);
    }
}

class ARPGInventoryMenu : ListMenu
{
    int selected;
    int hovered;
    int preferredRing;
    int lastClickItem;
    int lastClickTime;

    override void Init(Menu parent, ListMenuDescriptor desc)
    {
        Super.Init(parent, desc);
        selected = -1;
        hovered = -1;
        preferredRing = 7;
        lastClickItem = -1;
        lastClickTime = -100;
    }

    ARPGCleric Cleric() { return ARPGCleric(players[consoleplayer].mo); }

    void DrawLine(int color, int x, int y, String label)
    {
        Screen.DrawText(SmallFont, color, x, y, label,
            DTA_VIRTUALWIDTH, 640, DTA_VIRTUALHEIGHT, 400);
    }

    int Hit(int mx, int my)
    {
        int x = mx * 640 / Screen.GetWidth();
        int y = my * 400 / Screen.GetHeight();
        if (y < 60 || y >= 260) return -1;
        if (x >= 20 && x < 195) return (y - 60) / 20;
        if (x >= 200 && x < 375) return 10 + (y - 60) / 20;
        if (x >= 400 && x < 620 && y < 220) return 20 + (y - 60) / 20;
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
        else if (selected >= 20 && selected < 28)
            EventHandler.SendNetworkEvent("arpg_slot_unequip", selected - 19);
    }

    void Navigate(int key)
    {
        if (selected < 0) { selected = 0; return; }
        int column = selected < 10 ? 0 : selected < 20 ? 1 : 2;
        int row = selected < 10 ? selected : selected < 20 ? selected - 10 : selected - 20;
        if (key == 0) row = max(0, row - 1);
        if (key == 1) row = min(column == 2 ? 7 : 9, row + 1);
        if (key == 2) column = max(0, column - 1);
        if (key == 3) column = min(2, column + 1);
        if (column == 2) row = min(7, row);
        selected = column == 0 ? row : column == 1 ? row + 10 : row + 20;
        if (selected == 26 || selected == 27) preferredRing = selected - 19;
    }

    override bool OnUIEvent(UIEvent ev)
    {
        if (ev.Type == UIEvent.Type_MouseMove)
        {
            hovered = Hit(ev.MouseX, ev.MouseY);
            return Super.OnUIEvent(ev);
        }
        if (ev.Type == UIEvent.Type_LButtonDown || ev.Type == UIEvent.Type_RButtonDown)
        {
            int item = Hit(ev.MouseX, ev.MouseY);
            if (item < 0) { selected = -1; lastClickItem = -1; return true; }
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
            if (key == UIEvent.Key_Escape || ev.IsAlt || ev.KeyString == "ALT" ||
                ev.KeyString == "LALT" || ev.KeyString == "RALT") return MenuEvent(MKEY_Back, false);
            if (key == UIEvent.Key_Up || key == 87 || key == 119) { Navigate(0); return true; }
            if (key == UIEvent.Key_Down || key == 83 || key == 115) { Navigate(1); return true; }
            if (key == UIEvent.Key_Left || key == 65 || key == 97) { Navigate(2); return true; }
            if (key == UIEvent.Key_Right || key == 68 || key == 100) { Navigate(3); return true; }
            if (key == UIEvent.Key_Return) { EquipSelected(); return true; }
            if ((key == 80 || key == 112) && selected >= 0 && selected < 20)
            {
                EventHandler.SendNetworkEvent("arpg_slot_drop", selected);
                return true;
            }
        }
        return Super.OnUIEvent(ev);
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
        if (mkey == MKEY_Enter) { EquipSelected(); return true; }
        return Super.MenuEvent(mkey, fromcontroller);
    }

    override void Drawer()
    {
        let cleric = Cleric();
        if (cleric == null) { Super.Drawer(); return; }
        DrawLine(Font.CR_GOLD, 20, 30, "INVENTORY 20 SLOTS");
        DrawLine(Font.CR_GOLD, 400, 30, "EQUIPMENT");
        for (int i = 0; i < 20; i++)
        {
            int x = i < 10 ? 20 : 200;
            int y = 60 + (i % 10) * 20;
            int color = i == selected ? Font.CR_GREEN : i == hovered ? Font.CR_GOLD : Font.CR_GRAY;
            String title = cleric.arpgBag[i].damage > 0 ? ARPGWeaponRules.TypeName(cleric.arpgBag[i].kind) : "(empty)";
            DrawLine(color, x, y, String.Format("%s%02d %s", i == selected ? ">" : " ", i + 1, title));
        }
        for (int slot = 1; slot <= 8; slot++)
        {
            int kind = -1;
            if (slot <= 3)
            {
                let weapon = ARPGEquippedWeapon(cleric.FindInventory(String.Format("ARPGSlot%d", slot)));
                if (weapon != null && weapon.loot.damage > 0) kind = weapon.loot.kind;
            }
            else if (cleric.arpgArmor[slot - 4].damage > 0) kind = cleric.arpgArmor[slot - 4].kind;
            int index = slot + 19;
            int color = index == selected ? Font.CR_GREEN : index == hovered ? Font.CR_GOLD : Font.CR_GRAY;
            DrawLine(color, 400, 60 + (slot - 1) * 20,
                String.Format("%s%s: %s", index == selected ? ">" : " ", ARPGInventoryHud.SlotName(slot),
                    kind >= 0 ? ARPGWeaponRules.TypeName(kind) : "(empty)"));
        }
        int item = hovered >= 0 && hovered < 20 ? hovered : selected;
        if (item >= 0 && item < 20 && cleric.arpgBag[item].damage > 0)
        {
            int kind = cleric.arpgBag[item].kind;
            int target = Target(cleric, item);
            DrawLine(Font.CR_GOLD, 20, 280, ARPGWeaponRules.TypeName(kind));
            if (kind < 10)
                DrawLine(Font.CR_GRAY, 20, 300, String.Format("Power %d  Mana %d %s", cleric.arpgBag[item].damage,
                    cleric.arpgBag[item].manaCost, ARPGWeaponRules.ManaName(kind)));
            else
                DrawLine(Font.CR_GRAY, 20, 300, kind == 13 ? "+5 max HP" :
                    String.Format("Protection %d%%", kind == 10 ? 10 : kind == 11 ? 5 : 3));
            if (target > 0)
            {
                String comparison = "Empty slot";
                if (target <= 3)
                {
                    let weapon = ARPGEquippedWeapon(cleric.FindInventory(String.Format("ARPGSlot%d", target)));
                    if (weapon != null && weapon.loot.damage > 0)
                        comparison = String.Format("Replacing %s, power %d", ARPGWeaponRules.TypeName(weapon.loot.kind), weapon.loot.damage);
                }
                else if (cleric.arpgArmor[target - 4].damage > 0)
                    comparison = String.Format("Replacing %s", ARPGWeaponRules.TypeName(cleric.arpgArmor[target - 4].kind));
                DrawLine(Font.CR_GREEN, 20, 320, String.Format("Target %s: %s", ARPGInventoryHud.SlotName(target), comparison));
            }
        }
        DrawLine(Font.CR_GRAY, 20, 365, "Click select  Double/right click/Enter equip  P drop  WASD/arrows move  ALT/Esc close");
        Super.Drawer();
    }
}
