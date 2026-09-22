/* Copyright (C) 2016+ AzerothCore, GNU AGPL v3. */
#include "Chat.h"
#include "CommandScript.h"
#include "Player.h"
#include "PlayerScript.h"
#include "ScriptMgr.h"
#include "Spell.h"

#include <unordered_map>

namespace
{
using namespace Acore::ChatCommands;

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

class AscensionForgeCursorPlayer final : public PlayerScript
{
public:
    AscensionForgeCursorPlayer() : PlayerScript("AscensionForgeCursorPlayer") { }

    void OnPlayerSpellCast(Player* player, Spell* spell, bool) override
    {
        if (!player || !spell || !player->GetSession())
            return;

        if (player->GetSession()->GetSecurity() < SEC_GAMEMASTER)
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

class AscensionForgeCursorCommands final : public CommandScript
{
public:
    AscensionForgeCursorCommands() : CommandScript("AscensionForgeCursorCommands") { }

    ChatCommandTable GetCommands() const override
    {
        static ChatCommandTable const forgeCommands = {
            { "cursor", HandleCursorCommand, SEC_GAMEMASTER, Console::No },
            { "clearcursor", HandleClearCursorCommand, SEC_GAMEMASTER, Console::No }
        };
        static ChatCommandTable const commands = {
            { "coa", forgeCommands }
        };
        return commands;
    }

    static bool HandleCursorCommand(ChatHandler* handler)
    {
        Player* player = handler->GetSession() ? handler->GetSession()->GetPlayer() : nullptr;
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

    static bool HandleClearCursorCommand(ChatHandler* handler)
    {
        Player* player = handler->GetSession() ? handler->GetSession()->GetPlayer() : nullptr;
        if (!player)
            return false;

        CursorStore().erase(player->GetGUID());
        handler->SendSysMessage("Ground target cursor cleared.");
        return true;
    }
};
}

void AddSC_AscensionForgeCursor()
{
    new AscensionForgeCursorPlayer();
    new AscensionForgeCursorCommands();
}
