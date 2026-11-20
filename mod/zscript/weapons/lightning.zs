class ARPGLightning : MWeapLightning
{
    Default
    {
        Weapon.SelectionOrder 1200;
        Tag "Lightning Book";
    }

    override bool CanPickup(Actor toucher)
    {
        if (toucher is "ARPGCleric") return true;
        return Super.CanPickup(toucher);
    }
}
