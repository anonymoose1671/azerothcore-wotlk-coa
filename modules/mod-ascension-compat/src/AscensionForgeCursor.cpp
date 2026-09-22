/* Copyright (C) 2016+ AzerothCore, GNU AGPL v3. */
#include "Chat.h"
#include "CommandScript.h"
#include "Creature.h"
#include "DBCStores.h"
#include "DatabaseEnv.h"
#include "GameObject.h"
#include "MapMgr.h"
#include "MotionMaster.h"
#include "ObjectMgr.h"
#include "Player.h"
#include "PlayerScript.h"
#include "ScriptMgr.h"
#include "Spell.h"
#include "SpellMgr.h"
#include "Transport.h"

#include <unordered_map>

namespace
{
using namespace Acore::ChatCommands;

constexpr uint32 ForgeMaxAuraLength = 200;
constexpr uint32 ForgePickSpell = 257464;

struct ForgeCursor
{
    uint32 mapId = 0;
    float x = 0.0f;
    float y = 0.0f;
    float z = 0.0f;
    float orientation = 0.0f;
    bool valid = false;
};

std::unordered_map<ObjectGuid, ForgeCursor>& CursorStore()
{
    static std::unordered_map<ObjectGuid, ForgeCursor> store;
    return store;
}

Player* CommandPlayer(ChatHandler* handler)
{
    return handler->GetSession() ? handler->GetSession()->GetPlayer() : nullptr;
}

bool IsAuraList(std::string_view text)
{
    if (text.empty() || text.size() > ForgeMaxAuraLength)
        return false;

    bool digitSeen = false;
    for (char character : text)
    {
        if (character >= '0' && character <= '9')
        {
            digitSeen = true;
            continue;
        }

        if (character == ' ' || character == ',')
        {
            if (!digitSeen)
                return false;

            digitSeen = false;
            continue;
        }

        return false;
    }

    return digitSeen;
}

std::string NormalizeAuraList(std::string_view text)
{
    std::string normalized;
    bool pending = false;
    for (char character : text)
    {
        if (character >= '0' && character <= '9')
        {
            if (pending && !normalized.empty())
                normalized += ' ';

            normalized += character;
            pending = false;
            continue;
        }

        pending = !normalized.empty();
    }

    return normalized;
}

class AscensionForgeCursorPlayer final : public PlayerScript
{
public:
    AscensionForgeCursorPlayer() : PlayerScript("AscensionForgeCursorPlayer") { }

    void OnPlayerSpellCast(Player* player, Spell* spell, bool) override
    {
        if (!player || !spell || !player->GetSession())
            return;

        if (player->GetSession()->GetSecurity() < SEC_ADMINISTRATOR)
            return;

        if (!spell->m_targets.HasDst())
            return;

        WorldLocation const* destination = spell->m_targets.GetDstPos();
        if (!destination)
            return;

        ForgeCursor& cursor = CursorStore()[player->GetGUID()];
        cursor.mapId = player->GetMapId();
        cursor.x = destination->GetPositionX();
        cursor.y = destination->GetPositionY();
        cursor.z = destination->GetPositionZ();
        cursor.orientation = player->GetOrientation();
        cursor.valid = true;
    }

    void OnPlayerLogout(Player* player) override
    {
        if (player)
            CursorStore().erase(player->GetGUID());
    }
};

class AscensionForgeCommands final : public CommandScript
{
public:
    AscensionForgeCommands() : CommandScript("AscensionForgeCommands") { }

    ChatCommandTable GetCommands() const override
    {
        static ChatCommandTable const forgeCommands = {
            { "cursor",   HandleCursorCommand,   SEC_ADMINISTRATOR, Console::No },
            { "pickspell", HandlePickSpellCommand, SEC_ADMINISTRATOR, Console::No },
            { "npcpos",   HandleNpcPosCommand,   SEC_ADMINISTRATOR, Console::No },
            { "gopos",    HandleGoPosCommand,    SEC_ADMINISTRATOR, Console::No },
            { "select",   HandleSelectCommand,   SEC_ADMINISTRATOR, Console::No },
            { "spawnnpc", HandleSpawnNpcCommand, SEC_ADMINISTRATOR, Console::No },
            { "spawngo",  HandleSpawnGoCommand,  SEC_ADMINISTRATOR, Console::No },
            { "scale",    HandleScaleCommand,    SEC_ADMINISTRATOR, Console::Yes },
            { "aura",     HandleAuraCommand,     SEC_ADMINISTRATOR, Console::Yes },
            { "npcinfo",  HandleNpcInfoCommand,  SEC_ADMINISTRATOR, Console::Yes },
            { "goinfo",   HandleGoInfoCommand,   SEC_ADMINISTRATOR, Console::Yes }
        };
        static ChatCommandTable const commands = {
            { "coa", forgeCommands }
        };
        return commands;
    }

    static bool HandleCursorCommand(ChatHandler* handler)
    {
        Player* player = CommandPlayer(handler);
        if (!player)
            return false;

        auto const found = CursorStore().find(player->GetGUID());
        if (found == CursorStore().end() || !found->second.valid)
        {
            handler->SendErrorMessage("No ground target recorded. Cast a ground targeted spell first.");
            return false;
        }

        ForgeCursor const& cursor = found->second;
        handler->PSendSysMessage("Map: {} (cursor)", cursor.mapId);
        handler->PSendSysMessage("X: {} Y: {} Z: {} Orientation: {}",
            cursor.x, cursor.y, cursor.z, cursor.orientation);
        return true;
    }

    static bool HandlePickSpellCommand(ChatHandler* handler)
    {
        Player* player = CommandPlayer(handler);
        if (!player)
            return false;

        SpellInfo const* spell = sSpellMgr->GetSpellInfo(ForgePickSpell);
        if (!spell)
        {
            handler->SendErrorMessage("Placement spell {} is missing from this client's data.", ForgePickSpell);
            return false;
        }

        if (!player->HasSpell(ForgePickSpell))
            player->learnSpell(ForgePickSpell);

        handler->PSendSysMessage("COAPICKSPELL {} {}", ForgePickSpell, spell->SpellName[0]);
        return true;
    }

    static bool HandleNpcPosCommand(ChatHandler* handler, uint32 guid, float x, float y, float z, float o)
    {
        Player* player = CommandPlayer(handler);
        if (!player)
            return false;

        CreatureData const* data = sObjectMgr->GetCreatureData(guid);
        if (!data)
        {
            handler->SendErrorMessage("No creature spawn with guid {}.", guid);
            return false;
        }

        if (player->GetMapId() != data->mapid)
        {
            handler->SendErrorMessage("Creature {} is on map {}, you are on map {}.",
                guid, data->mapid, player->GetMapId());
            return false;
        }

        if (!MapMgr::IsValidMapCoord(data->mapid, x, y, z, o))
        {
            handler->SendErrorMessage("{} {} {} is not a valid position on map {}.", x, y, z, data->mapid);
            return false;
        }

        sObjectMgr->RemoveCreatureFromGrid(guid, data);
        const_cast<CreatureData*>(data)->posX = x;
        const_cast<CreatureData*>(data)->posY = y;
        const_cast<CreatureData*>(data)->posZ = z;
        const_cast<CreatureData*>(data)->orientation = o;
        sObjectMgr->AddCreatureToGrid(guid, data);

        Creature* creature = handler->GetCreatureFromPlayerMapByDbGuid(guid);
        if (creature)
        {
            creature->SetHomePosition(x, y, z, o);
            creature->NearTeleportTo(x, y, z, o);
            creature->GetMotionMaster()->Initialize();
        }
        else
        {
            creature = new Creature();
            if (!creature->LoadCreatureFromDB(guid, player->GetMap(), true, true))
            {
                delete creature;
                creature = nullptr;
            }
        }

        WorldDatabase.Execute("UPDATE creature SET position_x = {}, position_y = {}, position_z = {}, "
            "orientation = {} WHERE guid = {}", x, y, z, o, guid);
        handler->PSendSysMessage("Creature {} moved to {} {} {} facing {}.{}", guid, x, y, z, o,
            creature ? "" : " The spawn is saved but is not loaded in your map.");
        return true;
    }

    static bool HandleGoPosCommand(ChatHandler* handler, uint32 guid, float x, float y, float z, float o)
    {
        Player* player = CommandPlayer(handler);
        if (!player)
            return false;

        GameObject* object = handler->GetObjectFromPlayerMapByDbGuid(guid);
        if (!object)
        {
            handler->SendErrorMessage("Gameobject {} is not loaded in your map.", guid);
            return false;
        }

        Map* map = object->GetMap();
        if (!MapMgr::IsValidMapCoord(object->GetMapId(), x, y, z, o))
        {
            handler->SendErrorMessage("{} {} {} is not a valid position on map {}.", x, y, z, object->GetMapId());
            return false;
        }

        Position position(x, y, z, o);
        object->Relocate(position);
        object->SetWorldRotationAngles(o, 0.0f, 0.0f);

        sObjectMgr->RemoveGameobjectFromGrid(guid, object->GetGameObjectData());
        object->SaveToDB();
        sObjectMgr->AddGameobjectToGrid(guid, object->GetGameObjectData());

        object->Delete();
        object = new GameObject();
        if (!object->LoadGameObjectFromDB(guid, map, true))
        {
            delete object;
            handler->SendErrorMessage("Gameobject {} could not be reloaded after the move.", guid);
            return false;
        }

        handler->PSendSysMessage("Gameobject {} moved to {} {} {} facing {}.", guid, x, y, z, o);
        return true;
    }

    static bool HandleSpawnNpcCommand(ChatHandler* handler, uint32 entry, float x, float y, float z, float o)
    {
        Player* player = CommandPlayer(handler);
        if (!player)
            return false;

        if (!sObjectMgr->GetCreatureTemplate(entry))
        {
            handler->SendErrorMessage("No creature template with entry {}.", entry);
            return false;
        }

        Map* map = player->GetMap();
        if (!MapMgr::IsValidMapCoord(map->GetId(), x, y, z, o))
        {
            handler->SendErrorMessage("{} {} {} is not a valid position on map {}.", x, y, z, map->GetId());
            return false;
        }

        Creature* creature = new Creature();
        if (!creature->Create(map->GenerateLowGuid<HighGuid::Unit>(), map, player->GetPhaseMaskForSpawn(),
                              entry, 0, x, y, z, o))
        {
            delete creature;
            handler->SendErrorMessage("Creature {} could not be created; check its model data.", entry);
            return false;
        }

        creature->SaveToDB(map->GetId(), (1 << map->GetSpawnMode()), player->GetPhaseMaskForSpawn());
        ObjectGuid::LowType spawnId = creature->GetSpawnId();
        creature->CleanupsBeforeDelete();
        delete creature;

        creature = new Creature();
        if (!creature->LoadCreatureFromDB(spawnId, map, true, true))
        {
            delete creature;
            handler->SendErrorMessage("Spawn {} was saved but could not be loaded into the world.", spawnId);
            return false;
        }

        sObjectMgr->AddCreatureToGrid(spawnId, sObjectMgr->GetCreatureData(spawnId));
        player->SetSelection(creature->GetGUID());
        handler->PSendSysMessage("COASPAWN npc {} {}", spawnId, entry);
        return true;
    }

    static bool HandleSpawnGoCommand(ChatHandler* handler, uint32 entry, float x, float y, float z, float o)
    {
        Player* player = CommandPlayer(handler);
        if (!player)
            return false;

        GameObjectTemplate const* info = sObjectMgr->GetGameObjectTemplate(entry);
        if (!info)
        {
            handler->SendErrorMessage("No gameobject template with entry {}.", entry);
            return false;
        }

        if (info->displayId && !sGameObjectDisplayInfoStore.LookupEntry(info->displayId))
        {
            handler->SendErrorMessage("Gameobject {} has display {}, which the client does not have.",
                entry, info->displayId);
            return false;
        }

        Map* map = player->GetMap();
        if (!MapMgr::IsValidMapCoord(map->GetId(), x, y, z, o))
        {
            handler->SendErrorMessage("{} {} {} is not a valid position on map {}.", x, y, z, map->GetId());
            return false;
        }

        bool transport = sObjectMgr->IsGameObjectStaticTransport(entry);
        GameObject* object = transport ? new StaticTransport() : new GameObject();
        G3D::Quat rotation = G3D::Quat::fromAxisAngleRotation(G3D::Vector3::unitZ(), o);
        if (!object->Create(map->GenerateLowGuid<HighGuid::GameObject>(), entry, map,
                            player->GetPhaseMaskForSpawn(), x, y, z, o, rotation, 0, GO_STATE_READY))
        {
            delete object;
            handler->SendErrorMessage("Gameobject {} could not be created.", entry);
            return false;
        }

        object->SaveToDB(map->GetId(), (1 << map->GetSpawnMode()), player->GetPhaseMaskForSpawn());
        ObjectGuid::LowType spawnId = object->GetSpawnId();
        delete object;

        object = transport ? new StaticTransport() : new GameObject();
        if (!object->LoadGameObjectFromDB(spawnId, map, true))
        {
            delete object;
            handler->SendErrorMessage("Spawn {} was saved but could not be loaded into the world.", spawnId);
            return false;
        }

        sObjectMgr->AddGameobjectToGrid(spawnId, sObjectMgr->GetGameObjectData(spawnId));
        handler->PSendSysMessage("COASPAWN go {} {}", spawnId, entry);
        return true;
    }

    static bool HandleSelectCommand(ChatHandler* handler, uint32 guid)
    {
        Player* player = CommandPlayer(handler);
        if (!player)
            return false;

        Creature* creature = handler->GetCreatureFromPlayerMapByDbGuid(guid);
        if (!creature)
        {
            handler->SendErrorMessage("Creature {} is not loaded in your map.", guid);
            return false;
        }

        player->SetSelection(creature->GetGUID());
        handler->PSendSysMessage("Selected creature {}.", guid);
        return true;
    }

    static bool HandleScaleCommand(ChatHandler* handler, uint32 entry, float scale)
    {
        if (!sObjectMgr->GetCreatureTemplate(entry))
        {
            handler->SendErrorMessage("No creature template with entry {}.", entry);
            return false;
        }

        if (scale <= 0.0f || scale > 20.0f)
        {
            handler->SendErrorMessage("Scale must be greater than 0 and at most 20.");
            return false;
        }

        WorldDatabase.Execute("UPDATE creature_template_model SET DisplayScale = {} WHERE CreatureID = {}",
            scale, entry);
        handler->PSendSysMessage("Stored DisplayScale {} for creature {}. Reload the template to apply it.",
            scale, entry);
        return true;
    }

    static bool HandleAuraCommand(ChatHandler* handler, uint32 entry, Tail auras)
    {
        if (!sObjectMgr->GetCreatureTemplate(entry))
        {
            handler->SendErrorMessage("No creature template with entry {}.", entry);
            return false;
        }

        std::string_view text(auras);
        if (text == "none")
        {
            WorldDatabase.Execute("UPDATE creature_template_addon SET auras = NULL WHERE entry = {}", entry);
            handler->PSendSysMessage("Cleared stored auras for creature {}.", entry);
            return true;
        }

        if (!IsAuraList(text))
        {
            handler->SendErrorMessage("Give spell ids separated by spaces or commas, or none.");
            return false;
        }

        std::string normalized = NormalizeAuraList(text);
        WorldDatabase.Execute("INSERT INTO creature_template_addon (entry, auras) VALUES ({}, '{}') "
            "ON DUPLICATE KEY UPDATE auras = VALUES(auras)", entry, normalized);
        handler->PSendSysMessage("Stored auras '{}' for creature {}. Reload the template to apply them.",
            normalized, entry);
        return true;
    }

    static bool HandleNpcInfoCommand(ChatHandler* handler, uint32 guid)
    {
        CreatureData const* data = sObjectMgr->GetCreatureData(guid);
        if (!data)
        {
            handler->SendErrorMessage("No creature spawn with guid {}.", guid);
            return false;
        }

        Creature* creature = handler->GetCreatureFromPlayerMapByDbGuid(guid);
        uint32 display = creature ? creature->GetDisplayId() : 0;
        handler->PSendSysMessage("COAINFO npc {} {} {} {} {} {} {} {} {} {} {} {}",
            guid, data->id, data->mapid, data->posX, data->posY, data->posZ, data->orientation,
            data->phaseMask, display, data->wander_distance, uint32(data->movementType), data->spawntimesecs);
        return true;
    }

    static bool HandleGoInfoCommand(ChatHandler* handler, uint32 guid)
    {
        GameObjectData const* data = sObjectMgr->GetGameObjectData(guid);
        if (!data)
        {
            handler->SendErrorMessage("No gameobject spawn with guid {}.", guid);
            return false;
        }

        handler->PSendSysMessage("COAINFO go {} {} {} {} {} {} {} {} {} {} {} {}",
            guid, data->id, data->mapid, data->posX, data->posY, data->posZ, data->orientation,
            data->phaseMask, 0, 0.0f, 0, data->spawntimesecs);
        return true;
    }
};
}

void AddSC_AscensionForgeCursor()
{
    new AscensionForgeCursorPlayer();
    new AscensionForgeCommands();
}
