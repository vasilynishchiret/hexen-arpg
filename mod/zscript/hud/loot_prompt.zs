class ARPGLootPrompt : EventHandler
{
    override void RenderOverlay(RenderEvent e)
    {
        let cleric = ARPGCleric(players[consoleplayer].mo);
        if (cleric == null || cleric.arpgLookDrop == null) return;
        let item = cleric.arpgLookDrop;
        String damageText = String.Format("Damage %d", item.loot.damage);
        if (item.loot.kind == 3) damageText = "Damage 50-80";
        if (item.loot.kind == 4) damageText = "Arc of Death";
        Screen.DrawText(SmallFont, Font.CR_GOLD, 8, 32,
            String.Format("%s  %s  %s  %s %d  [E] Slot %d",
                ARPGWeaponRules.TypeName(item.loot.kind), damageText,
                ARPGWeaponRules.SpeedName(item.loot.speed),
                ARPGWeaponRules.ManaName(item.loot.kind), item.loot.manaCost, cleric.arpgActiveSlot));
    }
}
