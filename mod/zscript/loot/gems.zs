// Convert only world actors. Ammo created by GiveInventory has an Owner.
class ARPGGemPickup : Actor
{
    int gemKind; // 1 blue, 2 green, 3 combined
    Default { Radius 8; Height 8; +FLOATBOB +NOBLOCKMAP }
    void SetKind(int kind)
    {
        gemKind = kind;
        if (kind == 2) SetStateLabel('Green');
        else if (kind == 3) SetStateLabel('Combined');
        else SetStateLabel('Blue');
    }
    States
    {
    Spawn:
    Blue:
        MAN1 ABCDEFGHI 4 Bright;
        Loop;
    Green:
        MAN2 ABCDEFGHIJKLMNOP 4 Bright;
        Loop;
    Combined:
        MAN3 ABCDEFGHIJKLMNOP 4 Bright;
        Loop;
    }
}
class ARPGBlueGemPickup : ARPGGemPickup
{
    override void PostBeginPlay() { Super.PostBeginPlay(); SetKind(1); }
}
class ARPGGreenGemPickup : ARPGGemPickup
{
    override void PostBeginPlay() { Super.PostBeginPlay(); SetKind(2); }
}
class ARPGCombinedGemPickup : ARPGGemPickup
{
    override void PostBeginPlay() { Super.PostBeginPlay(); SetKind(3); }
}
class ARPGGemWorld : EventHandler
{
    override void WorldTick()
    {
        bool hasCleric = false;
        for (int i = 0; i < MAXPLAYERS; i++)
            if (ARPGCleric(players[i].mo) != null) hasCleric = true;
        if (!hasCleric) return;
        let actors = ThinkerIterator.Create('Inventory');
        Inventory actor;
        while ((actor = Inventory(actors.Next())) != null)
        {
            if (actor.Owner != null) continue;
            Name name = actor.GetClassName();
            int kind = name == 'Mana1' ? 1 : name == 'Mana2' ? 2 : name == 'Mana3' ? 3 : 0;
            if (kind == 0) continue;
            ARPGGemPickup gem = ARPGGemPickup(Actor.Spawn('ARPGGemPickup', actor.Pos));
            if (gem == null) continue;
            gem.SetKind(kind);
            if (actor.tid != 0) gem.ChangeTID(actor.tid);
            gem.special = actor.special;
            for (int j = 0; j < 5; j++) gem.args[j] = actor.args[j];
            actor.Destroy();
        }
        let gems = ThinkerIterator.Create('ARPGGemPickup');
        ARPGGemPickup gem;
        while ((gem = ARPGGemPickup(gems.Next())) != null)
        {
            for (int i = 0; i < MAXPLAYERS; i++)
            {
                let cleric = ARPGCleric(players[i].mo);
                if (cleric == null || cleric.health <= 0 ||
                    cleric.Distance2D(gem) > 20 || abs(cleric.Pos.Z - gem.Pos.Z) > 32) continue;
                if (!cleric.AddGems(gem.gemKind == 2 ? 0 : 1,
                    gem.gemKind == 1 ? 0 : 1)) continue;
                if (gem.special != 0)
                    level.ExecuteSpecial(gem.special, cleric, null, false,
                        gem.args[0], gem.args[1], gem.args[2], gem.args[3], gem.args[4]);
                gem.Destroy();
                break;
            }
        }
    }
}
