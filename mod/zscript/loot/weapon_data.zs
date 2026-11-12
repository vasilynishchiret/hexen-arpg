struct ARPGWeaponData
{
    int kind;       // 0 Sword, 1 Axe, 2 Hammer
    int damage;
    int speed;      // 0 fast, 1 medium, 2 slow
    int manaCost;
}

class ARPGWeaponRules : Object
{
    clearscope static string TypeName(int kind)
    {
        if (kind == 1) return "Axe";
        if (kind == 2) return "Hammer";
        return "Sword";
    }

    clearscope static string SpeedName(int speed)
    {
        if (speed == 1) return "Medium";
        if (speed == 2) return "Slow";
        return "Fast";
    }

    clearscope static int MinDamage(int kind)
    {
        if (kind == 1) return 75;
        if (kind == 2) return 100;
        return 55;
    }

    clearscope static int MaxDamage(int kind)
    {
        if (kind == 1) return 95;
        if (kind == 2) return 130;
        return 75;
    }

    clearscope static int ManaCost(int kind)
    {
        if (kind == 1) return 4;
        if (kind == 2) return 6;
        return 3;
    }
}