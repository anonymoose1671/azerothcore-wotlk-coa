/* Copyright (C) 2016+ AzerothCore, GNU AGPL v3. */
#include "Chat.h"
#include "GameObject.h"
#include "GameObjectScript.h"
#include "Player.h"
#include "ScriptMgr.h"

namespace
{
constexpr uint32 ITEM_REPAIRED_CELLAR_KEY = 559141;
}

class go_coa_cain_cellar_door : public GameObjectScript
{
public:
    go_coa_cain_cellar_door() : GameObjectScript("go_coa_cain_cellar_door") { }

    bool OnGossipHello(Player* player, GameObject*) override
    {
        if (player->HasItemCount(ITEM_REPAIRED_CELLAR_KEY, 1))
            return false;

        ChatHandler(player->GetSession()).SendNotification("The door is locked.");
        return true;
    }
};

void AddSC_AscensionCainManor()
{
    new go_coa_cain_cellar_door();
}
