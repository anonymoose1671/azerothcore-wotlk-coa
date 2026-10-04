/* Copyright (C) 2016+ AzerothCore, GNU AGPL v3. */
#include "CellImpl.h"
#include "GridNotifiers.h"
#include "GridNotifiersImpl.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "ScriptedCreature.h"
#include "SpellAuras.h"
#include "SpellInfo.h"
#include "SpellMgr.h"

namespace
{
constexpr uint32 SPELL_DISGUISE_WARRIOR = 256709;
constexpr uint32 SPELL_DISGUISE_GUARD = 256710;
constexpr uint32 SPELL_CHARGE_WINDUP = 256743;
constexpr uint32 SPELL_CHARGE_TRAIL = 256744;
constexpr uint32 SPELL_CHARGE_TRAMPLE = 256745;
constexpr uint32 SPELL_CHARGE_IMPACT = 256746;
constexpr uint32 SPELL_CHARGE_TELEGRAPH = 255356;
constexpr uint32 SPELL_CHARGE_TREMOR = 64228;
constexpr uint32 SPELL_ENRAGE = 256756;

constexpr uint8 SAY_AGGRO_DISGUISED = 0;
constexpr uint8 SAY_AGGRO = 1;
constexpr uint8 SAY_CHARGE = 2;
constexpr uint8 SAY_ENRAGE = 3;
constexpr uint8 SAY_LOW_HEALTH = 4;
constexpr uint8 SAY_KILL = 5;
constexpr uint8 SAY_DEATH = 6;

constexpr uint32 POINT_CHARGE_END = 1;
constexpr float CHARGE_RANGE = 30.0f;
constexpr float CHARGE_SPEED = 12.0f;
constexpr float CHARGE_MIN_RUN = 2.0f;
constexpr float WALL_TOLERANCE = 1.0f;
constexpr float TRAMPLE_REACH = 2.5f;
constexpr uint32 TRAMPLE_TICK_MS = 200;
constexpr uint32 CHARGE_RUN_GRACE_MS = 1000;
constexpr uint32 TREMOR_PULSE_MS = 1000;
constexpr uint32 ENRAGE_HEALTH_PCT = 50;
constexpr int32 ENRAGE_MS = 10000;
constexpr uint32 LOW_HEALTH_PCT = 20;

enum MalgormEvents
{
    EVENT_MALGORM_CHARGE = 1
};
}

struct npc_coa_malgorm_hollowhoof : public ScriptedAI
{
    explicit npc_coa_malgorm_hollowhoof(Creature* creature) : ScriptedAI(creature) { }

    void Reset() override
    {
        _events.Reset();
        _enraged = false;
        _saidLowHealth = false;
        _saidCharge = false;
        _chargeRunMs = 0;
        _trampleTickMs = 0;
        _tremorPulseMs = 0;
        _trampled.clear();
        for (uint32 spell : { SPELL_CHARGE_TELEGRAPH, SPELL_CHARGE_TRAIL, SPELL_ENRAGE })
            me->RemoveAurasDueToSpell(spell);
        me->SetControlled(false, UNIT_STATE_ROOT);
    }

    void JustEngagedWith(Unit* who) override
    {
        Unit* attacker = who->GetCharmerOrOwnerPlayerOrPlayerItself();
        bool const disguised = attacker
            && (attacker->HasAura(SPELL_DISGUISE_WARRIOR) || attacker->HasAura(SPELL_DISGUISE_GUARD));
        Talk(disguised ? SAY_AGGRO_DISGUISED : SAY_AGGRO, attacker);
        _events.ScheduleEvent(EVENT_MALGORM_CHARGE, 10s, 12s);
    }

    void DamageTaken(Unit*, uint32& damage, DamageEffectType, SpellSchoolMask) override
    {
        if (!_enraged && me->HealthBelowPctDamaged(ENRAGE_HEALTH_PCT, damage))
        {
            _enraged = true;
            Talk(SAY_ENRAGE);
            HoldFor(SPELL_ENRAGE, ENRAGE_MS);
        }

        if (!_saidLowHealth && me->HealthBelowPctDamaged(LOW_HEALTH_PCT, damage))
        {
            _saidLowHealth = true;
            Talk(SAY_LOW_HEALTH);
        }
    }

    void KilledUnit(Unit* victim) override
    {
        if (victim->IsPlayer())
            Talk(SAY_KILL);
    }

    void JustDied(Unit*) override
    {
        Talk(SAY_DEATH);
    }

    void OnSpellStart(SpellInfo const* spell) override
    {
        if (spell->Id != SPELL_CHARGE_WINDUP)
            return;

        if (Spell* windup = me->GetCurrentSpell(CURRENT_GENERIC_SPELL))
            me->FocusTarget(windup, me);
    }

    void OnSpellCast(SpellInfo const* spell) override
    {
        if (spell->Id == SPELL_CHARGE_WINDUP)
            RunCharge();
    }

    void OnSpellFailed(SpellInfo const* spell) override
    {
        if (spell->Id == SPELL_CHARGE_WINDUP)
            FinishCharge(false);
    }

    void MovementInform(uint32 type, uint32 id) override
    {
        if (type == POINT_MOTION_TYPE && id == POINT_CHARGE_END && _chargeRunMs)
            FinishCharge(_chargeHitsWall);
    }

    void UpdateAI(uint32 diff) override
    {
        if (_tremorPulseMs)
            UpdateTremor(diff);

        if (_chargeRunMs)
        {
            UpdateChargeRun(diff);
            return;
        }

        if (!UpdateVictim())
            return;

        if (me->HasUnitState(UNIT_STATE_CASTING))
            return;

        _events.Update(diff);

        if (_events.ExecuteEvent() == EVENT_MALGORM_CHARGE)
        {
            BeginCharge();
            _events.Repeat(20s);
            return;
        }

        DoMeleeAttackIfReady();
    }

private:
    void BeginCharge()
    {
        Unit* target = SelectTarget(SelectTargetMethod::Random, 0, CHARGE_RANGE, true);
        if (!target)
            return;

        me->StopMoving();
        me->SetFacingToObject(target);
        me->SetControlled(true, UNIT_STATE_ROOT);
        me->SetTarget();
        HoldFor(SPELL_CHARGE_TELEGRAPH, int32(sSpellMgr->AssertSpellInfo(SPELL_CHARGE_WINDUP)->CalcCastTime()));
        if (!_saidCharge || urand(0, 2) == 0)
        {
            _saidCharge = true;
            Talk(SAY_CHARGE);
        }
        DoCastSelf(SPELL_CHARGE_TREMOR, true);
        _tremorPulseMs = TREMOR_PULSE_MS;
        if (me->CastSpell(me, SPELL_CHARGE_WINDUP, false) != SPELL_CAST_OK)
            FinishCharge(false);
    }

    void UpdateTremor(uint32 diff)
    {
        if (_tremorPulseMs > diff)
        {
            _tremorPulseMs -= diff;
            return;
        }

        _tremorPulseMs = 0;
        if (me->FindCurrentSpellBySpellId(SPELL_CHARGE_WINDUP))
        {
            DoCastSelf(SPELL_CHARGE_TREMOR, true);
            _tremorPulseMs = TREMOR_PULSE_MS;
        }
    }

    void RunCharge()
    {
        me->RemoveAurasDueToSpell(SPELL_CHARGE_TELEGRAPH);
        Position destination = me->GetPosition();
        me->MovePositionToFirstCollision(destination, CHARGE_RANGE, 0.0f);
        float const run = me->GetExactDist2d(&destination);
        _chargeHitsWall = run < CHARGE_RANGE - WALL_TOLERANCE;
        if (run < CHARGE_MIN_RUN)
        {
            FinishCharge(_chargeHitsWall);
            return;
        }

        _trampled.clear();
        _trampleTickMs = 0;
        _chargeRunMs = uint32(run / CHARGE_SPEED * IN_MILLISECONDS) + CHARGE_RUN_GRACE_MS;
        me->SetControlled(false, UNIT_STATE_ROOT);
        DoCastSelf(SPELL_CHARGE_TRAIL, true);
        me->GetMotionMaster()->MoveCharge(destination.GetPositionX(), destination.GetPositionY(),
            destination.GetPositionZ(), CHARGE_SPEED, POINT_CHARGE_END);
    }

    void UpdateChargeRun(uint32 diff)
    {
        if (_trampleTickMs > diff)
            _trampleTickMs -= diff;
        else
        {
            _trampleTickMs = TRAMPLE_TICK_MS;
            Trample();
        }

        if (_chargeRunMs > diff)
            _chargeRunMs -= diff;
        else
            FinishCharge(_chargeHitsWall);
    }

    void Trample()
    {
        std::list<Player*> players;
        Acore::AnyPlayerInObjectRangeCheck check(me, TRAMPLE_REACH);
        Acore::PlayerListSearcher<Acore::AnyPlayerInObjectRangeCheck> searcher(me, players, check);
        Cell::VisitObjects(me, searcher, TRAMPLE_REACH);
        bool struck = false;
        for (Player* player : players)
            if (me->IsValidAttackTarget(player) && _trampled.insert(player->GetGUID()).second)
                struck = true;
        if (struck)
            DoCastSelf(SPELL_CHARGE_TRAMPLE, true);
    }

    void FinishCharge(bool hitWall)
    {
        bool const wasRunning = _chargeRunMs != 0;
        _chargeRunMs = 0;
        _tremorPulseMs = 0;
        me->RemoveAurasDueToSpell(SPELL_CHARGE_TELEGRAPH);
        me->RemoveAurasDueToSpell(SPELL_CHARGE_TRAIL);
        me->SetControlled(false, UNIT_STATE_ROOT);
        if (wasRunning)
            Trample();
        if (hitWall)
            DoCastSelf(SPELL_CHARGE_IMPACT, true);
        if (Unit* victim = me->GetVictim())
            me->SetTarget(victim->GetGUID());
    }

    void HoldFor(uint32 spellId, int32 durationMs)
    {
        if (Aura* aura = me->AddAura(spellId, me))
        {
            aura->SetMaxDuration(durationMs);
            aura->SetDuration(durationMs);
        }
    }

    EventMap _events;
    GuidUnorderedSet _trampled;
    bool _enraged = false;
    bool _saidLowHealth = false;
    bool _saidCharge = false;
    bool _chargeHitsWall = false;
    uint32 _chargeRunMs = 0;
    uint32 _trampleTickMs = 0;
    uint32 _tremorPulseMs = 0;
};

void AddSC_AscensionThreeTotems()
{
    RegisterCreatureAI(npc_coa_malgorm_hollowhoof);
}
