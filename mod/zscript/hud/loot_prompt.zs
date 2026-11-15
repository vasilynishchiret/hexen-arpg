class ARPGLootPrompt : EventHandler
{
    clearscope static String DamageText(int kind, int damage)
    {
        if (kind == 3) return "50-80 (avg 65)";
        if (kind == 4) return "Arc of Death";
        return String.Format("%d", damage);
    }

    clearscope static String RateText(int kind)
    {
        int tics = ARPGWeaponRules.AttackTics(kind);
        int hundredths = (3500 + tics / 2) / tics;
        return String.Format("%d.%02d attacks/s", hundredths / 100, hundredths % 100);
    }

    clearscope static String DPSText(int kind, int damage)
    {
        if (kind == 4) return "Arc (variable)";
        int tenths = (ARPGWeaponRules.AverageDamage(kind, damage) * 350 + ARPGWeaponRules.AttackTics(kind) / 2) / ARPGWeaponRules.AttackTics(kind);
        return String.Format("%d.%d", tenths / 10, tenths % 10);
    }

    override void RenderOverlay(RenderEvent e)
    {
        let cleric = ARPGCleric(players[consoleplayer].mo);
        if (cleric == null || cleric.arpgLookDrop == null || cleric.arpgComparedWeapon == null) return;
        let found = cleric.arpgLookDrop;
        let equipped = cleric.arpgComparedWeapon;
        int currentKind = equipped.loot.kind;
        int foundKind = found.loot.kind;
        int currentTics = ARPGWeaponRules.AttackTics(currentKind);
        int foundTics = ARPGWeaponRules.AttackTics(foundKind);
        int currentDamage = ARPGWeaponRules.AverageDamage(currentKind, equipped.loot.damage);
        int foundDamage = ARPGWeaponRules.AverageDamage(foundKind, found.loot.damage);
        int damageColor = Font.CR_GRAY;
        int speedColor = Font.CR_GRAY;
        int costColor = Font.CR_GRAY;
        int dpsColor = Font.CR_GRAY;
        if (currentKind != 4 && foundKind != 4)
        {
            if (foundDamage > currentDamage) damageColor = Font.CR_GREEN;
            if (foundDamage < currentDamage) damageColor = Font.CR_RED;
            int currentDPSNumerator = currentDamage * foundTics;
            int foundDPSNumerator = foundDamage * currentTics;
            if (foundDPSNumerator > currentDPSNumerator) dpsColor = Font.CR_GREEN;
            if (foundDPSNumerator < currentDPSNumerator) dpsColor = Font.CR_RED;
        }
        if (foundTics < currentTics) speedColor = Font.CR_GREEN;
        if (foundTics > currentTics) speedColor = Font.CR_RED;
        if (found.loot.manaCost < equipped.loot.manaCost) costColor = Font.CR_GREEN;
        if (found.loot.manaCost > equipped.loot.manaCost) costColor = Font.CR_RED;

        int left = 8;
        int right = 204;
        Screen.DrawText(SmallFont, Font.CR_GOLD, left, 32, String.Format("EQUIPPED  SLOT %d", cleric.arpgActiveSlot));
        Screen.DrawText(SmallFont, Font.CR_GOLD, right, 32, String.Format("FOUND  [E] SLOT %d", cleric.arpgActiveSlot));
        Screen.DrawText(SmallFont, Font.CR_GRAY, left, 42, String.Format("%s / %s", ARPGWeaponRules.TypeName(currentKind), currentKind == 4 ? "Magic" : "Melee"));
        Screen.DrawText(SmallFont, Font.CR_GRAY, right, 42, String.Format("%s / %s", ARPGWeaponRules.TypeName(foundKind), foundKind == 4 ? "Magic" : "Melee"));
        Screen.DrawText(SmallFont, Font.CR_GRAY, left, 52, String.Format("Damage: %s", DamageText(currentKind, equipped.loot.damage)));
        Screen.DrawText(SmallFont, damageColor, right, 52, String.Format("Damage: %s", DamageText(foundKind, found.loot.damage)));
        Screen.DrawText(SmallFont, Font.CR_GRAY, left, 62, String.Format("Speed: %s", RateText(currentKind)));
        Screen.DrawText(SmallFont, speedColor, right, 62, String.Format("Speed: %s", RateText(foundKind)));
        Screen.DrawText(SmallFont, Font.CR_GRAY, left, 72, String.Format("Mana: %d %s", equipped.loot.manaCost, ARPGWeaponRules.ManaName(currentKind)));
        Screen.DrawText(SmallFont, costColor, right, 72, String.Format("Mana: %d %s", found.loot.manaCost, ARPGWeaponRules.ManaName(foundKind)));
        Screen.DrawText(SmallFont, Font.CR_GRAY, left, 82, String.Format("DPS: %s", DPSText(currentKind, equipped.loot.damage)));
        Screen.DrawText(SmallFont, dpsColor, right, 82, String.Format("DPS: %s", DPSText(foundKind, found.loot.damage)));
    }
}
