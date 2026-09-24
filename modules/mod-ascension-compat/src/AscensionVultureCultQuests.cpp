/* Copyright (C) 2016+ AzerothCore, GNU AGPL v3. */
#include "CreatureAI.h"
#include "Map.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "SpellScript.h"
#include "TemporarySummon.h"

namespace
{
enum VultureCultMoonwell : uint32
{
    QUEST_TRANSSUBSTANTIATING_THE_FLESH = 1660015,
    NPC_ABERRANT_FLESH_REMNANT = 161783
};

constexpr uint32 KalimdorMapId = 1;
constexpr float MoonwellReach = 8.0f;
constexpr float RemnantSearchReach = 20.0f;
constexpr uint32 RemnantLifetimeOutOfCombatMs = 120000;
Position const EyrieMoonwell = { 10834.42f, 545.13f, 1396.39f, 0.0f };
Position const RemnantRise = { 10834.8f, 544.1f, 1396.25f, 3.14f };

class spell_coa_channeling_blessing_of_the_moon : public SpellScript
{
    PrepareSpellScript(spell_coa_channeling_blessing_of_the_moon);

    SpellCastResult CheckAtEyrieMoonwell()
    {
        Player* player = GetCaster()->ToPlayer();
        if (!player || player->GetQuestStatus(QUEST_TRANSSUBSTANTIATING_THE_FLESH) != QUEST_STATUS_INCOMPLETE)
            return SPELL_FAILED_CANT_DO_THAT_RIGHT_NOW;

        if (player->GetMapId() != KalimdorMapId || !player->IsWithinDist3d(&EyrieMoonwell, MoonwellReach))
            return SPELL_FAILED_NOT_HERE;

        return SPELL_CAST_OK;
    }

    void RaiseAberrantFleshRemnant(SpellEffIndex effIndex)
    {
        PreventHitDefaultEffect(effIndex);

        Player* player = GetCaster()->ToPlayer();
        if (!player)
            return;

        if (Creature* remnant = player->FindNearestCreature(NPC_ABERRANT_FLESH_REMNANT, RemnantSearchReach))
        {
            if (!remnant->IsInCombat())
                remnant->AI()->AttackStart(player);
            return;
        }

        if (TempSummon* remnant = player->GetMap()->SummonCreature(NPC_ABERRANT_FLESH_REMNANT, RemnantRise, nullptr,
                                                                   RemnantLifetimeOutOfCombatMs))
        {
            remnant->SetTempSummonType(TEMPSUMMON_TIMED_DESPAWN_OUT_OF_COMBAT);
            remnant->AI()->AttackStart(player);
        }
    }

    void Register() override
    {
        OnCheckCast += SpellCheckCastFn(spell_coa_channeling_blessing_of_the_moon::CheckAtEyrieMoonwell);
        OnEffectHit += SpellEffectFn(spell_coa_channeling_blessing_of_the_moon::RaiseAberrantFleshRemnant, EFFECT_0,
                                     SPELL_EFFECT_SEND_EVENT);
    }
};
}

void AddSC_AscensionVultureCultQuests()
{
    RegisterSpellScript(spell_coa_channeling_blessing_of_the_moon);
}
