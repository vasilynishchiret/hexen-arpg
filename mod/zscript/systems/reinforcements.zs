// These subclasses retain the original monster AI and stats. COUNTKILL is
// Copyright (C) 2026 Vasily Nishchiret
// SPDX-License-Identifier: GPL-3.0-or-later

// removed so random arrivals cannot change level-completion kill counters.
class ARPGReinfAfrit : FireDemon { Default { -COUNTKILL } }
class ARPGReinfEttin : ARPGEttin { Default { -COUNTKILL } }
class ARPGReinfCentaur : Centaur { Default { -COUNTKILL } }
class ARPGReinfDemon : Demon1 { Default { -COUNTKILL } }

// Keep Hexen's smoke animation, but bound this mod's visual effect independently.
class ARPGReinfSmoke : TeleSmoke
{
    int age;

    override void Tick()
    {
        Super.Tick();
        if (++age >= ARPGBalance.REINF_SMOKE_TICS) Destroy();
    }
}

class ARPGReinforcements : EventHandler
{
    String currentMap;
    int nextAttemptAt;

    ARPGCleric ActiveCleric()
    {
        for (int i = 0; i < MAXPLAYERS; i++)
        {
            let cleric = ARPGCleric(players[i].mo);
            if (cleric != null && cleric.health > 0) return cleric;
        }
        return null;
    }

    int MapIndex(ARPGCleric cleric)
    {
        for (int i = 0; i < cleric.arpgReinforcementMaps.Size(); i++)
            if (cleric.arpgReinforcementMaps[i] == level.MapName) return i;
        cleric.arpgReinforcementMaps.Push(level.MapName);
        cleric.arpgReinforcementTotals.Push(0);
        return cleric.arpgReinforcementMaps.Size() - 1;
    }

    int LiveCount()
    {
        int live = 0;
        let all = ThinkerIterator.Create("Actor");
        Actor actor;
        while ((actor = Actor(all.Next())) != null)
            if (actor.health > 0 &&
                (actor is 'ARPGReinfAfrit' || actor is 'ARPGReinfEttin' ||
                 actor is 'ARPGReinfCentaur' || actor is 'ARPGReinfDemon')) live++;
        return live;
    }

    bool TrySpawnOne(ARPGCleric cleric)
    {
        bool afrit = random[ARPGReinfType](0, 99) < ARPGBalance.REINF_AFRIT_PERCENT;
        Class<Actor> kind;
        if (afrit) kind = 'ARPGReinfAfrit';
        else kind = ARPGBalance.ReinforcementNormal(random[ARPGReinfNormal](0, 2));
        for (int i = 0; i < ARPGBalance.REINF_POSITION_TRIES; i++)
        {
            double angle = random[ARPGReinfAngle](0, 359);
            double radius = random[ARPGReinfRadius](ARPGBalance.REINF_MIN_RADIUS,
                ARPGBalance.REINF_MAX_RADIUS);
            Vector3 spot = (cleric.Pos.X + cos(angle) * radius,
                cleric.Pos.Y + sin(angle) * radius, Actor.ONFLOORZ);
            Actor monster = Actor.Spawn(kind, spot, NO_REPLACE);
            if (monster == null) continue;
            bool valid = monster.cursector == cleric.cursector &&
                abs(monster.floorz - cleric.floorz) <= ARPGBalance.REINF_MAX_FLOOR_DELTA &&
                monster.ceilingz - monster.floorz >= monster.Height +
                    (afrit ? ARPGBalance.REINF_AFRIT_HEIGHT : 0);
            if (valid && afrit) monster.SetZ(monster.floorz + ARPGBalance.REINF_AFRIT_HEIGHT);
            if (valid) valid = monster.CheckPosition(monster.Pos.XY) &&
                monster.TestMobjLocation() && cleric.CheckSight(monster) &&
                cleric.Distance2D(monster) >= ARPGBalance.REINF_MIN_RADIUS;
            if (!valid) { monster.Destroy(); continue; }
            monster.bCountKill = false;
            monster.special = 0;
            monster.target = cleric;
            Actor.Spawn("ARPGReinfSmoke", monster.Pos, NO_REPLACE);
            return true;
        }
        return false;
    }

    void AttemptGroup(ARPGCleric cleric)
    {
        int index = MapIndex(cleric);
        int live = LiveCount();
        int available = min(ARPGBalance.REINF_MAX_LIVE - live,
            ARPGBalance.REINF_MAX_PER_MAP - cleric.arpgReinforcementTotals[index]);
        if (available <= 0) return;
        int group = min(available, random[ARPGReinfGroup](ARPGBalance.REINF_GROUP_MIN,
            ARPGBalance.REINF_GROUP_MAX));
        for (int i = 0; i < group; i++)
            if (TrySpawnOne(cleric)) cleric.arpgReinforcementTotals[index]++;
    }

    override void WorldTick()
    {
        if (currentMap != level.MapName)
        {
            currentMap = level.MapName;
            nextAttemptAt = level.maptime + ARPGBalance.REINF_FIRST_DELAY_TICS;
        }
        let cleric = ActiveCleric();
        if (cleric == null || cleric.arpgInventoryOpen) return;
        let enabled = CVar.GetCVar("arpg_reinforcements");
        if (enabled == null || !enabled.GetBool()) return;
        if (level.maptime < nextAttemptAt) return;
        nextAttemptAt = level.maptime + random[ARPGReinfInterval](
            ARPGBalance.REINF_MIN_INTERVAL_TICS, ARPGBalance.REINF_MAX_INTERVAL_TICS);
        AttemptGroup(cleric);
    }

    override void NetworkProcess(ConsoleEvent e)
    {
        if (e.Name != "arpg_reinforce_status" && e.Name != "arpg_reinforce_test") return;
        let cleric = ARPGCleric(players[e.Player].mo);
        if (cleric == null) return;
        if (e.Name == "arpg_reinforce_test") AttemptGroup(cleric);
        int index = MapIndex(cleric);
        Console.Printf("ARPG reinforcements: %d/%d alive, %d/%d spawned on %s, next attempt in %ds",
            LiveCount(), ARPGBalance.REINF_MAX_LIVE,
            cleric.arpgReinforcementTotals[index], ARPGBalance.REINF_MAX_PER_MAP,
            level.MapName, max(0, (nextAttemptAt - level.maptime + 34) / 35));
    }
}
