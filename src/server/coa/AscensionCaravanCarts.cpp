/* Copyright (C) 2016+ AzerothCore, GNU AGPL v3. */
#include "DBCStores.h"
#include "GridDefines.h"
#include "Log.h"
#include "Map.h"
#include "MapMgr.h"
#include "ObjectMgr.h"
#include "ScriptMgr.h"
#include <algorithm>
#include <array>
#include <set>
#include <utility>

namespace
{
constexpr std::array<uint32, 5> CaravanCartEntries = { 50470, 50473, 50474, 50475, 50476 };

bool IsCaravanCart(CreatureData const& spawn)
{
    return std::find(CaravanCartEntries.begin(), CaravanCartEntries.end(), spawn.id) != CaravanCartEntries.end();
}

bool IsOnOpenWorldMap(CreatureData const& spawn)
{
    MapEntry const* mapEntry = sMapStore.LookupEntry(spawn.mapid);
    return mapEntry && !mapEntry->Instanceable() && Acore::IsValidMapCoord(spawn.posX, spawn.posY);
}

class CaravanCartGrids : public WorldScript
{
public:
    CaravanCartGrids() : WorldScript("CoACaravanCartGrids", { WORLDHOOK_ON_BEFORE_WORLD_INITIALIZED }) { }

    void OnBeforeWorldInitialized() override
    {
        uint32 carts = 0;
        std::set<std::pair<uint32, uint32>> grids;
        for (auto const& [spawnId, spawn] : sObjectMgr->GetAllCreatureData())
        {
            if (!IsCaravanCart(spawn) || !IsOnOpenWorldMap(spawn))
                continue;

            ++carts;
            if (grids.emplace(spawn.mapid, Acore::ComputeGridCoord(spawn.posX, spawn.posY).GetId()).second)
                sMapMgr->CreateBaseMap(spawn.mapid)->LoadGrid(spawn.posX, spawn.posY);
        }

        LOG_INFO("server.loading", ">> Loaded {} grids for {} caravan cart spawns", grids.size(), carts);
    }
};
}

void AddSC_AscensionCaravanCarts()
{
    new CaravanCartGrids();
}
