/* Copyright (C) 2016+ AzerothCore, GNU AGPL v3. */
#include "GameObject.h"
#include "GameObjectScript.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "SpellScript.h"
#include "SpellScriptLoader.h"
#include <algorithm>
#include <array>
#include <chrono>

namespace
{
constexpr uint32 QUEST_ACCURSED_SISTERHOOD = 1660003;
constexpr std::chrono::seconds RelicRespawn = std::chrono::seconds(120);

struct Relic
{
    uint32 gameObject;
    uint32 spell;
    uint32 credit;
};

constexpr std::array<Relic, 4> Relics = {{
    {2300520, 256701, 161715},
    {2300521, 256726, 161824},
    {2300522, 256701, 161825},
    {2300523, 256726, 161826},
}};

struct RopeLanding
{
    ObjectGuid::LowType spawn;
    float x;
    float y;
    float z;
    float orientation;
};

constexpr std::array<RopeLanding, 3> RopeLandings = {{
    {7910011, -8613.5f, -566.9f, 149.652f, 2.094f},
    {7910012, -8603.1f, -580.0f, 150.34f, 3.142f},
    {7910013, -8597.5f, -564.5f, 150.81f, 0.0f},
}};

Relic const* FindRelic(uint32 gameObject)
{
    auto relic = std::find_if(Relics.begin(), Relics.end(), [gameObject](Relic const& r) { return r.gameObject == gameObject; });
    return relic == Relics.end() ? nullptr : &*relic;
}

bool ObjectiveOpen(Player* player, Relic const& relic)
{
    return player->GetQuestStatus(QUEST_ACCURSED_SISTERHOOD) == QUEST_STATUS_INCOMPLETE &&
        player->GetReqKillOrCastCurrentCount(QUEST_ACCURSED_SISTERHOOD, int32(relic.credit)) == 0;
}

class go_coa_abbess_relic : public GameObjectScript
{
public:
    go_coa_abbess_relic() : GameObjectScript("go_coa_abbess_relic") { }

    bool OnGossipHello(Player* player, GameObject* go) override
    {
        Relic const* relic = FindRelic(go->GetEntry());
        if (relic && ObjectiveOpen(player, *relic) && !player->IsNonMeleeSpellCast(false))
            player->CastSpell(go, relic->spell, false);
        return true;
    }
};

class go_coa_theologian_rope : public GameObjectScript
{
public:
    go_coa_theologian_rope() : GameObjectScript("go_coa_theologian_rope") { }

    bool OnGossipHello(Player* player, GameObject* go) override
    {
        auto rope = std::find_if(RopeLandings.begin(), RopeLandings.end(),
            [go](RopeLanding const& r) { return r.spawn == go->GetSpawnId(); });
        if (rope != RopeLandings.end())
            player->NearTeleportTo(rope->x, rope->y, rope->z, rope->orientation);
        return true;
    }
};

class spell_coa_abbess_relic_prayer : public SpellScript
{
    PrepareSpellScript(spell_coa_abbess_relic_prayer);

    void HandlePrayer(SpellEffIndex /*effIndex*/)
    {
        Player* player = GetCaster() ? GetCaster()->ToPlayer() : nullptr;
        GameObject* go = GetHitGObj();
        Relic const* relic = go ? FindRelic(go->GetEntry()) : nullptr;
        if (!player || !relic || !ObjectiveOpen(player, *relic))
            return;

        player->KilledMonsterCredit(relic->credit);
        go->DespawnOrUnsummon(0ms, RelicRespawn);
    }

    void Register() override
    {
        OnEffectHitTarget += SpellEffectFn(spell_coa_abbess_relic_prayer::HandlePrayer, EFFECT_0, SPELL_EFFECT_DUMMY);
    }
};
}

void AddSC_AscensionNorthshireRuins()
{
    new go_coa_abbess_relic();
    new go_coa_theologian_rope();
    RegisterSpellScript(spell_coa_abbess_relic_prayer);
}
