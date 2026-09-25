/*
 * This file is part of the AzerothCore Project. See AUTHORS file for Copyright information
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
 * more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include "Field.h"
#include "IntegrationTestFixture.h"
#include "ItemTemplate.h"
#include "QuestDef.h"
#include <array>

namespace
{
constexpr uint32 ClassMask(Classes playerClass)
{
    return uint32(1) << (playerClass - 1);
}

class AuthoredClassQuest : public Quest
{
public:
    AuthoredClassQuest(::Field* questRecord, uint32 authoredClassMask) : Quest(questRecord)
    {
        RequiredClasses = authoredClassMask;
    }
};

class QuestClassMaskTest : public IntegrationTestFixture
{
protected:
    AuthoredClassQuest MakeQuest(uint32 authoredClassMask)
    {
        std::array<::Field, 106> emptyQuestRecord;
        return AuthoredClassQuest(emptyQuestRecord.data(), authoredClassMask);
    }

    bool CanTakeQuest(Classes playerClass, Quest const& quest)
    {
        TestPlayer* player = CreateTestPlayer(++_guid);
        player->SetByteValue(UNIT_FIELD_BYTES_0, 1, uint8(playerClass));
        return player->SatisfyQuestClass(&quest, false);
    }

private:
    ObjectGuid::LowType _guid = 0;
};
}

TEST_F(QuestClassMaskTest, StockClassQuestsStayClosedToMappedCustomClasses)
{
    struct StockClassQuest
    {
        Classes stockClass;
        Classes mappedCustomClass;
    };

    for (StockClassQuest const& stockQuest : {
             StockClassQuest{CLASS_PALADIN, CLASS_CULTIST},
             StockClassQuest{CLASS_DRUID, CLASS_SON_OF_ARUGAL},
             StockClassQuest{CLASS_DRUID, CLASS_STARCALLER},
             StockClassQuest{CLASS_WARLOCK, CLASS_NECROMANCER},
             StockClassQuest{CLASS_SHAMAN, CLASS_SPIRIT_MAGE},
             StockClassQuest{CLASS_ROGUE, CLASS_MONK}})
    {
        AuthoredClassQuest quest = MakeQuest(ClassMask(stockQuest.stockClass));

        EXPECT_TRUE(CanTakeQuest(stockQuest.stockClass, quest)) << uint32(stockQuest.stockClass);
        EXPECT_FALSE(CanTakeQuest(stockQuest.mappedCustomClass, quest)) << uint32(stockQuest.mappedCustomClass);
    }
}

TEST_F(QuestClassMaskTest, MultiClassStockQuestsAdmitNoCustomClass)
{
    AuthoredClassQuest quest = MakeQuest(ClassMask(CLASS_PRIEST) | ClassMask(CLASS_MAGE) | ClassMask(CLASS_WARLOCK));

    for (uint8 classId = CLASS_BARBARIAN; classId < MAX_CLASSES; ++classId)
        EXPECT_FALSE(CanTakeQuest(Classes(classId), quest)) << uint32(classId);
}

TEST_F(QuestClassMaskTest, AuthoredCustomClassQuestsAdmitOnlyTheirClasses)
{
    AuthoredClassQuest cultistQuest = MakeQuest(ClassMask(CLASS_CULTIST));
    EXPECT_TRUE(CanTakeQuest(CLASS_CULTIST, cultistQuest));
    EXPECT_FALSE(CanTakeQuest(CLASS_PALADIN, cultistQuest));

    AuthoredClassQuest runemasterQuest = MakeQuest(ClassMask(CLASS_SPIRIT_MAGE));
    EXPECT_TRUE(CanTakeQuest(CLASS_SPIRIT_MAGE, runemasterQuest));
    EXPECT_FALSE(CanTakeQuest(CLASS_SHAMAN, runemasterQuest));
}

TEST_F(QuestClassMaskTest, UnrestrictedQuestsAdmitEveryCustomClass)
{
    AuthoredClassQuest quest = MakeQuest(0);

    for (uint8 classId = CLASS_BARBARIAN; classId < MAX_CLASSES; ++classId)
        EXPECT_TRUE(CanTakeQuest(Classes(classId), quest)) << uint32(classId);
}

TEST_F(QuestClassMaskTest, ItemsKeepExpandingTheMasksQuestsDoNot)
{
    uint32 paladinMask = ClassMask(CLASS_PALADIN);

    EXPECT_EQ(GetItemAllowableClassMask(paladinMask), paladinMask | ClassMask(CLASS_CULTIST));
    EXPECT_FALSE(CanTakeQuest(CLASS_CULTIST, MakeQuest(paladinMask)));
}
