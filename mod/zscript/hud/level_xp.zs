class ARPGHud : EventHandler
{
    override void RenderOverlay(RenderEvent e)
    {
        let cleric = ARPGCleric(players[consoleplayer].mo);
        if (cleric != null)
        {
            Screen.DrawText(SmallFont, Font.CR_GOLD, 8, 8,
                String.Format("Level %d  XP %d/%d", cleric.arpgLevel, cleric.arpgXP, cleric.arpgNextXP));
        }
    }
}
