class ARPGBalance : Object
{
    const START_XP = 100;
    const XP_GROWTH_PERCENT = 135;
    const XP_ETTIN = 10;
    const OTHER_XP_HP_DIVISOR = 15;
    const OTHER_XP_MIN = 5;
    const OTHER_XP_MAX = 100;
    const HP_PER_LEVEL = 5;
    const BASE_HEALTH = 50;
    const BLUE_REGEN_TICS = 35;
    const GREEN_MANA_PER_KILL = 5;
    const START_MANA1 = 30;
    const START_MANA2 = 30;
    const BASE_MANA_MAX = 200;
    const MACE_DAMAGE_MULTIPLIER = 2;
    const SWORD_DAMAGE = 70;
    const SWORD_MANA_COST = 3;
    const LOOT_ONE_IN = 10;
    const ETTIN_MELEE_RANGE = 88;
    const ETTIN_MELEE_HALF_ANGLE = 35;
    const LOOT_MELEE_PERCENT = 40;
    const LOOT_MAGIC_PERCENT = 35;
    const LOOT_ARMOR_PERCENT = 25;
    const DASH_HOLD_TICS = 7; // 200 ms at 35 tics/s
    const DASH_COOLDOWN_TICS = 35;
    const DASH_THRUST = 20;
    const SPRINT_MANA_PER_SEC = 2;
    const SPRINT_PERCENT = 150;
    const SHIELD_BLOCK_PERCENT = 70;
    const SHIELD_BASE_TICS = 70;
    const SHIELD_COOLDOWN_TICS = 280;
    const GUARDIAN_COOLDOWN_TICS = 700;
    const INVIS_TICS = 105;
    const INVIS_COOLDOWN_TICS = 875;
    const DETECT_TICS = 175;
    const DETECT_COOLDOWN_TICS = 700;
    const DETECT_RADIUS = 640;
    const GREEN_RING_TICS = 420;
    const AURA_TICS = 35;
    const AURA_RADIUS = 96;
    const AURA_DAMAGE_PER_RING = 2;
    const VAMP_MAX_BASIS_POINTS = 1000;
    const LOOT_COMMON_PERCENT = 80;
    const LOOT_STRONG_PERCENT = 17;
    const LOOT_EXCEPTIONAL_PERCENT = 3;
    const LOOT_MULTIPLIER_SCALE = 1000;
    const LOOT_COMMON_MIN = 650;
    const LOOT_COMMON_MAX = 1100;
    const LOOT_STRONG_MIN = 1150;
    const LOOT_STRONG_MAX = 1800;
    const LOOT_EXCEPTIONAL_MIN = 2000;
    const LOOT_EXCEPTIONAL_MAX = 3500;
    const AXE_DAMAGE = 85;
    const HAMMER_DAMAGE = 115;
    const SWORD_ATTACK_TICS = 16;
    const AXE_ATTACK_TICS = 30;
    const HAMMER_ATTACK_TICS = 70;
    const MACE_ATTACK_TICS = 22;
    const LIGHTNING_ATTACK_TICS = 36;
    const LOOT_INTERACT_RANGE = 96;
    // Independent ARPG reinforcements. All time values are 35-tic seconds.
    const REINF_FIRST_DELAY_TICS = 2100;
    const REINF_MIN_INTERVAL_TICS = 1050;
    const REINF_MAX_INTERVAL_TICS = 2100;
    const REINF_MAX_LIVE = 6;
    const REINF_MAX_PER_MAP = 12;
    const REINF_AFRIT_PERCENT = 40;
    const REINF_GROUP_MIN = 1;
    const REINF_GROUP_MAX = 2;
    const REINF_MIN_RADIUS = 192;
    const REINF_MAX_RADIUS = 384;
    const REINF_POSITION_TRIES = 24;
    const REINF_MAX_FLOOR_DELTA = 48;
    const REINF_AFRIT_HEIGHT = 64;

    static Class<Actor> ReinforcementNormal(int choice)
    {
        // Only ordinary enemies; no bosses or script-specific monsters.
        if (choice == 0) return 'ARPGReinfEttin';
        if (choice == 1) return 'ARPGReinfCentaur';
        return 'ARPGReinfDemon';
    }
}
