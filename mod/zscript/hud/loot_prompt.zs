class ARPGLootPrompt : EventHandler
{
    override void RenderOverlay(RenderEvent e)
    {
        let cleric = ARPGCleric(players[consoleplayer].mo);
        if (cleric == null || cleric.arpgLookDrop == null) return;
        let item = cleric.arpgLookDrop;
        Screen.DrawText(SmallFont, Font.CR_GOLD, 8, 32,
            String.Format("%s  Damage %d  %s  Mana1 %d  [E] Equip",
                ARPGWeaponRules.TypeName(item.loot.kind), item.loot.damage,
                ARPGWeaponRules.SpeedName(item.loot.speed), item.loot.manaCost));
    }
}