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
constexpr uint32 SPELL_STOMP_TELEGRAPH = 256108;
constexpr uint32 SPELL_WAR_STOMP = 202949;
constexpr uint32 SPELL_SHIELD_WALL = 256752;
constexpr uint32 SPELL_ENRAGED_REGENERATION = 256755;
constexpr uint32 SPELL_WALL_STUN = 256727;

constexpr uint8 SAY_AGGRO_DISGUISED = 0;
constexpr uint8 SAY_AGGRO = 1;
constexpr uint8 SAY_STOMP = 2;
constexpr uint8 SAY_INTERMISSION = 3;
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
constexpr uint32 STOMP_WINDUP_MS = 2000;
constexpr int32 WALL_STUN_MS = 6000;
constexpr int32 STUNNED_EXTRA_DAMAGE_PCT = 50;
constexpr uint32 INTERMISSION_HEALTH_PCT = 50;
constexpr int32 INTERMISSION_MAX_MS = 45000;
constexpr uint32 LOW_HEALTH_PCT = 20;

enum MalgormEvents
{
    EVENT_MALGORM_STOMP = 1,
    EVENT_MALGORM_CHARGE,
    EVENT_MALGORM_INTERMISSION_TIMEOUT
};
}

struct npc_coa_malgorm_hollowhoof : public ScriptedAI
{
    explicit npc_coa_malgorm_hollowhoof(Creature* creature) : ScriptedAI(creature) { }

    void Reset() override
    {
        _events.Reset();
        _intermissionUsed = false;
        _inIntermission = false;
        _saidLowHealth = false;
        _saidStomp = false;
        _stompWindupMs = 0;
        _chargeRunMs = 0;
        _trampleTickMs = 0;
        _trampled.clear();
        for (uint32 spell : { SPELL_CHARGE_TELEGRAPH, SPELL_STOMP_TELEGRAPH, SPELL_CHARGE_TRAIL, SPELL_SHIELD_WALL,
                 SPELL_ENRAGED_REGENERATION, SPELL_WALL_STUN })
            me->RemoveAurasDueToSpell(spell);
        me->SetControlled(false, UNIT_STATE_ROOT);
    }

    void JustEngagedWith(Unit* who) override
    {
        Unit* attacker = who->GetCharmerOrOwnerPlayerOrPlayerItself();
        bool const disguised = attacker
            && (attacker->HasAura(SPELL_DISGUISE_WARRIOR) || attacker->HasAura(SPELL_DISGUISE_GUARD));
        Talk(disguised ? SAY_AGGRO_DISGUISED : SAY_AGGRO, attacker);
        _events.ScheduleEvent(EVENT_MALGORM_STOMP, 8s, 10s);
        _events.ScheduleEvent(EVENT_MALGORM_CHARGE, 13s, 15s);
    }

    void DamageTaken(Unit*, uint32& damage, DamageEffectType, SpellSchoolMask) override
    {
        if (me->HasAura(SPELL_WALL_STUN))
            damage += damage * STUNNED_EXTRA_DAMAGE_PCT / 100;

        if (!_intermissionUsed && me->HealthBelowPctDamaged(INTERMISSION_HEALTH_PCT, damage))
            StartIntermission();

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
        if (_chargeRunMs)
        {
            UpdateChargeRun(diff);
            return;
        }

        if (_stompWindupMs)
        {
            UpdateStompWindup(diff);
            return;
        }

        if (!UpdateVictim())
            return;

        if (me->HasUnitState(UNIT_STATE_CASTING | UNIT_STATE_STUNNED))
            return;

        _events.Update(diff);

        switch (_events.ExecuteEvent())
        {
            case EVENT_MALGORM_STOMP:
                BeginStomp();
                _events.Repeat(14s, 16s);
                KeepApart(EVENT_MALGORM_CHARGE);
                return;
            case EVENT_MALGORM_CHARGE:
                BeginCharge();
                if (!_inIntermission)
                {
                    _events.Repeat(18s, 22s);
                    KeepApart(EVENT_MALGORM_STOMP);
                }
                return;
            case EVENT_MALGORM_INTERMISSION_TIMEOUT:
                EndIntermission();
                return;
            default:
                break;
        }

        DoMeleeAttackIfReady();
    }

private:
    void KeepApart(uint32 eventId)
    {
        if (_events.GetTimeUntilEvent(eventId) < 5s)
            _events.RescheduleEvent(eventId, 5s);
    }

    void BeginStomp()
    {
        me->StopMoving();
        me->SetControlled(true, UNIT_STATE_ROOT);
        HoldFor(SPELL_STOMP_TELEGRAPH, STOMP_WINDUP_MS);
        if (!_saidStomp || urand(0, 2) == 0)
        {
            _saidStomp = true;
            Talk(SAY_STOMP);
        }
        _stompWindupMs = STOMP_WINDUP_MS;
    }

    void UpdateStompWindup(uint32 diff)
    {
        if (_stompWindupMs > diff)
        {
            _stompWindupMs -= diff;
            return;
        }

        _stompWindupMs = 0;
        me->RemoveAurasDueToSpell(SPELL_STOMP_TELEGRAPH);
        DoCastSelf(SPELL_WAR_STOMP, true);
        me->SetControlled(false, UNIT_STATE_ROOT);
    }

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
        if (me->CastSpell(me, SPELL_CHARGE_WINDUP, false) != SPELL_CAST_OK)
            FinishCharge(false);
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
            if (player->IsAlive() && me->IsValidAttackTarget(player) && _trampled.insert(player->GetGUID()).second)
                struck = true;
        if (struck)
            DoCastSelf(SPELL_CHARGE_TRAMPLE, true);
    }

    void FinishCharge(bool hitWall)
    {
        bool const wasRunning = _chargeRunMs != 0;
        _chargeRunMs = 0;
        me->RemoveAurasDueToSpell(SPELL_CHARGE_TELEGRAPH);
        me->RemoveAurasDueToSpell(SPELL_CHARGE_TRAIL);
        me->SetControlled(false, UNIT_STATE_ROOT);
        if (wasRunning)
            Trample();

        if (hitWall)
        {
            DoCastSelf(SPELL_CHARGE_IMPACT, true);
            HoldFor(SPELL_WALL_STUN, WALL_STUN_MS);
            if (_inIntermission)
                EndIntermission();
        }
        else if (_inIntermission)
            _events.ScheduleEvent(EVENT_MALGORM_CHARGE, 2s);

        if (Unit* victim = me->GetVictim())
            me->SetTarget(victim->GetGUID());
    }

    void StartIntermission()
    {
        _intermissionUsed = true;
        _inIntermission = true;
        Talk(SAY_INTERMISSION);
        _events.CancelEvent(EVENT_MALGORM_STOMP);
        _events.CancelEvent(EVENT_MALGORM_CHARGE);
        _events.ScheduleEvent(EVENT_MALGORM_CHARGE, 1s);
        _events.ScheduleEvent(EVENT_MALGORM_INTERMISSION_TIMEOUT, Milliseconds(INTERMISSION_MAX_MS));
        HoldFor(SPELL_SHIELD_WALL, INTERMISSION_MAX_MS);
        HoldFor(SPELL_ENRAGED_REGENERATION, INTERMISSION_MAX_MS);
    }

    void EndIntermission()
    {
        _inIntermission = false;
        me->RemoveAurasDueToSpell(SPELL_SHIELD_WALL);
        me->RemoveAurasDueToSpell(SPELL_ENRAGED_REGENERATION);
        _events.CancelEvent(EVENT_MALGORM_INTERMISSION_TIMEOUT);
        _events.CancelEvent(EVENT_MALGORM_CHARGE);
        _events.ScheduleEvent(EVENT_MALGORM_STOMP, 8s, 10s);
        _events.ScheduleEvent(EVENT_MALGORM_CHARGE, 16s, 18s);
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
    bool _intermissionUsed = false;
    bool _inIntermission = false;
    bool _saidLowHealth = false;
    bool _saidStomp = false;
    bool _chargeHitsWall = false;
    uint32 _stompWindupMs = 0;
    uint32 _chargeRunMs = 0;
    uint32 _trampleTickMs = 0;
};

void AddSC_AscensionThreeTotems()
{
    RegisterCreatureAI(npc_coa_malgorm_hollowhoof);
}
