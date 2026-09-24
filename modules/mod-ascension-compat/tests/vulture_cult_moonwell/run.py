import os
from pathlib import Path
import re
import runpy
import shutil
import subprocess
import tempfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
method = runpy.run_path(str(HERE.parent / "client_compat/run.py"))["method"]

HARNESS = r'''
#include <cassert>
#include <cmath>
#include <cstdint>
#include <list>
#include <vector>
using uint8 = std::uint8_t;
using uint32 = std::uint32_t;
// ENUMS
enum SpellEffIndex : uint8 { EFFECT_0 = 0 };
struct Position
{
    float x = 0.0f, y = 0.0f, z = 0.0f, o = 0.0f;
    Position(float px = 0.0f, float py = 0.0f, float pz = 0.0f, float po = 0.0f) : x(px), y(py), z(pz), o(po) { }
    float GetExactDist(Position const& other) const
    { return std::sqrt((x - other.x) * (x - other.x) + (y - other.y) * (y - other.y) + (z - other.z) * (z - other.z)); }
};
struct Player;
struct Unit
{
    Position pos;
    virtual ~Unit() = default;
    virtual Player* ToPlayer() { return nullptr; }
};
struct CreatureAI
{
    std::vector<Unit*> targets;
    void AttackStart(Unit* who) { targets.push_back(who); }
};
struct Creature : Unit
{
    uint32 entry = 0;
    bool alive = true, combat = false;
    CreatureAI ai;
    bool IsInCombat() const { return combat; }
    CreatureAI* AI() { return &ai; }
};
struct TempSummon : Creature
{
    TempSummonType type = TEMPSUMMON_TIMED_DESPAWN;
    uint32 duration = 0;
    void SetTempSummonType(TempSummonType summonType) { type = summonType; }
};
struct SummonPropertiesEntry;
struct Map
{
    std::list<TempSummon> summons;
    TempSummon* SummonCreature(uint32 entry, Position const& at, SummonPropertiesEntry const* properties,
                               uint32 duration)
    {
        assert(!properties);
        TempSummon& summon = summons.emplace_back();
        summon.entry = entry;
        summon.pos = at;
        summon.duration = duration;
        return &summon;
    }
};
constexpr float PlayerCombatReach = DEFAULT_COMBAT_REACH;
struct Player : Unit
{
    uint32 mapId = 1;
    QuestStatus status = QUEST_STATUS_NONE;
    Map* map = nullptr;
    Player* ToPlayer() override { return this; }
    QuestStatus GetQuestStatus(uint32 questId) const { assert(questId == 1660015); return status; }
    uint32 GetMapId() const { return mapId; }
    bool IsWithinDist3d(Position const* target, float dist) const
    { return pos.GetExactDist(*target) < dist + PlayerCombatReach; }
    Map* GetMap() { return map; }
    Creature* FindNearestCreature(uint32 entry, float range)
    {
        Creature* nearest = nullptr;
        for (TempSummon& creature : map->summons)
            if (creature.entry == entry && creature.alive && pos.GetExactDist(creature.pos) <= range &&
                (!nearest || pos.GetExactDist(creature.pos) < pos.GetExactDist(nearest->pos)))
                nearest = &creature;
        return nearest;
    }
};

// SOURCE

struct Script
{
    Unit* caster = nullptr;
    bool prevented = false;
    Unit* GetCaster() { return caster; }
    void PreventHitDefaultEffect(SpellEffIndex effIndex) { assert(effIndex == EFFECT_0); prevented = true; }
// METHODS
};

int main()
{
    Map map;
    Player player;
    player.map = &map;
    player.pos = RemnantRise;
    Script script;
    script.caster = &player;

    for (QuestStatus status : { QUEST_STATUS_NONE, QUEST_STATUS_COMPLETE, QUEST_STATUS_FAILED, QUEST_STATUS_REWARDED })
    {
        player.status = status;
        assert(script.CheckAtEyrieMoonwell() == SPELL_FAILED_CANT_DO_THAT_RIGHT_NOW);
    }
    player.status = QUEST_STATUS_INCOMPLETE;
    assert(script.CheckAtEyrieMoonwell() == SPELL_CAST_OK);
    assert(RemnantRise.GetExactDist(EyrieMoonwell) < 1.5f);

    player.pos = Position(EyrieMoonwell.x + 9.4f, EyrieMoonwell.y, EyrieMoonwell.z);
    assert(script.CheckAtEyrieMoonwell() == SPELL_CAST_OK);
    player.pos = Position(EyrieMoonwell.x + 9.6f, EyrieMoonwell.y, EyrieMoonwell.z);
    assert(script.CheckAtEyrieMoonwell() == SPELL_FAILED_NOT_HERE);
    player.pos = Position(10823.8f, 493.3f, 1396.14f);
    assert(script.CheckAtEyrieMoonwell() == SPELL_FAILED_NOT_HERE);
    player.pos = RemnantRise;
    player.mapId = 0;
    assert(script.CheckAtEyrieMoonwell() == SPELL_FAILED_NOT_HERE);
    player.mapId = 1;

    Creature npc;
    npc.pos = RemnantRise;
    Script foreign;
    foreign.caster = &npc;
    assert(foreign.CheckAtEyrieMoonwell() == SPELL_FAILED_CANT_DO_THAT_RIGHT_NOW);
    foreign.RaiseAberrantFleshRemnant(EFFECT_0);
    assert(foreign.prevented && map.summons.empty());

    script.RaiseAberrantFleshRemnant(EFFECT_0);
    assert(script.prevented && map.summons.size() == 1);
    TempSummon& remnant = map.summons.back();
    assert(remnant.entry == 161783 && remnant.duration == 120000);
    assert(remnant.type == TEMPSUMMON_TIMED_DESPAWN_OUT_OF_COMBAT);
    assert(remnant.pos.x == RemnantRise.x && remnant.pos.y == RemnantRise.y && remnant.pos.z == RemnantRise.z);
    assert(remnant.ai.targets == std::vector<Unit*>{ &player });

    script.RaiseAberrantFleshRemnant(EFFECT_0);
    assert(map.summons.size() == 1 && remnant.ai.targets.size() == 2);
    remnant.combat = true;
    script.RaiseAberrantFleshRemnant(EFFECT_0);
    assert(map.summons.size() == 1 && remnant.ai.targets.size() == 2);
    remnant.combat = false;
    remnant.alive = false;
    script.RaiseAberrantFleshRemnant(EFFECT_0);
    assert(map.summons.size() == 2 && map.summons.back().ai.targets == std::vector<Unit*>{ &player });

    map.summons.back().pos = Position(RemnantRise.x + 25.0f, RemnantRise.y, RemnantRise.z);
    script.RaiseAberrantFleshRemnant(EFFECT_0);
    assert(map.summons.size() == 3);
    return 0;
}
'''


def build_harness(source):
    shared = (ROOT / "src/server/shared/SharedDefines.h").read_text(encoding="utf-8")
    quests = (ROOT / "src/server/game/Quests/QuestDef.h").read_text(encoding="utf-8")
    objects = (ROOT / "src/server/game/Entities/Object/Object.h").read_text(encoding="utf-8")
    defines = (ROOT / "src/server/game/Entities/Object/ObjectDefines.h").read_text(encoding="utf-8")
    enums = "".join(method(text, "enum " + name) + ";\n" for text, name in (
        (shared, "SpellCastResult"), (quests, "QuestStatus"), (objects, "TempSummonType")))
    enums += re.search(r"#define DEFAULT_COMBAT_REACH .*\n", defines).group(0)
    start = source.index("enum VultureCultMoonwell")
    body = source[start:source.index("class spell_coa_channeling_blessing_of_the_moon")]
    methods = "".join(method(source, signature) + "\n" for signature in (
        "SpellCastResult CheckAtEyrieMoonwell()", "void RaiseAberrantFleshRemnant("))
    return HARNESS.replace("// ENUMS", enums).replace("// SOURCE", body).replace("// METHODS", methods)


def compile_and_run(code):
    with tempfile.TemporaryDirectory(prefix="coa-vulture-cult-moonwell-", ignore_cleanup_errors=True) as directory:
        out = Path(directory)
        cpp, exe = out / "moonwell.cpp", out / "moonwell.exe"
        cpp.write_text(code, encoding="utf-8")
        msvc = shutil.which("cl")
        if msvc is None and os.environ.get("VCToolsInstallDir"):
            msvc = str(Path(os.environ["VCToolsInstallDir"]) / "bin/Hostx64/x64/cl.exe")
        if msvc:
            command = [msvc, "/nologo", "/std:c++20", "/EHsc", "/W4", "/WX", "/utf-8", "/UNDEBUG",
                       str(cpp), "/Fe" + str(exe)]
        else:
            compiler = shutil.which(os.environ.get("CXX", "g++"))
            assert compiler, "Run from a Visual Studio developer prompt or set CXX to a C++20 compiler."
            command = [compiler, "-std=c++20", "-Wall", "-Wextra", "-Werror", str(cpp), "-o", str(exe)]
        subprocess.run(command, cwd=out, check=True, timeout=120)
        subprocess.run([str(exe)], cwd=out, check=True, timeout=15)


def check_binding(source):
    name = "spell_coa_channeling_blessing_of_the_moon"
    assert f"OnCheckCast += SpellCheckCastFn({name}::CheckAtEyrieMoonwell);" in source
    assert re.search(rf"OnEffectHit \+= SpellEffectFn\({name}::RaiseAberrantFleshRemnant, EFFECT_0,\s+"
                     r"SPELL_EFFECT_SEND_EVENT\);", source)
    assert f"RegisterSpellScript({name});" in source
    loader = (ROOT / "modules/mod-ascension-compat/src/MP_loader.cpp").read_text(encoding="utf-8")
    assert loader.count("AddSC_AscensionVultureCultQuests();") == 2
    sql = (ROOT / "data/sql/updates/pending_db_world/rev_20260924_10_coa_teldrassil_vulture_cult.sql").read_text(
        encoding="utf-8")
    assert "DELETE FROM `spell_script_names` WHERE `spell_id` = 256707;" in sql
    assert f"(256707, '{name}')" in sql
    assert "event_scripts" not in sql


def main():
    source = (ROOT / "modules/mod-ascension-compat/src/AscensionVultureCultQuests.cpp").read_text(encoding="utf-8")
    check_binding(source)
    compile_and_run(build_harness(source))
    print("PASS: quest, map and moonwell-reach gates, event 3839 prevented, one remnant raised at the pool to attack "
          "the caster, re-aimed while it lives, not stolen in combat, raised again after death or out of reach, "
          "and the spell binding")


if __name__ == "__main__":
    main()
