-- Conquest of Azeroth continued the Spada storyline from Northshire into Goldshire: Bianca's maid,
-- Lady Agria's failing health and the curse her majordomo blames on a broken mirror, a mad woman's
-- kobolds, the refugees in the shadow of the new town hall, and a historian who wants a moment of your
-- time. None of it exists in this world. This restores the six quests 1660055-1660060.
--
-- WHERE EACH VALUE COMES FROM
--   quests, creatures, objects  the realm's own client cache (data-cache-945cd3b8b0ce4a496586). Every quest
--     and reward item already exists in item_template, so no item is written here.
--   places  CoA rebuilt Goldshire, and its client terrain (patch-WB1) shows where: the Spada Family Manor
--     (AreaTable 10217) on the hill above Mirror Lake, the town hall on the old faire ground with a refugee
--     camp against it, a market plaza where the Lion's Pride Inn stood (the inn moved 39 yards south-east),
--     and crop plots for melons, pumpkins and apples. Floors come from the server collision data.
--     Which NPC stands where inside those places is INFERRED; no source records their spawns.
--   kobold warrens  INFERRED: a ring around the village, since no source places them.
--   vendors  the four market sellers and their ingredients are tied together by the cache (questItem).
--   appearance  STAND-IN displays: every CoA display of this cast is missing from the client.
--   credits  the Mirror Shard and Kobold Warren objects credit their hidden markers when used, then
--     despawn until they respawn. 'Stay a While' credits from a gossip option shown only during the quest;
--     no source keeps the lecture itself.
--   dialogue  the greetings of Aliscar Lend (85190) and the mayor (85163, 85164) are from the cache.
--
-- Spawn guid blocks: creature 9002000-9002199, gameobject 6911000-6911199.

-- ---------------------------------------------------------------------------
-- 1. Creatures
-- ---------------------------------------------------------------------------
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `minlevel`, `maxlevel`, `exp`, `faction`, `npcflag`, `rank`, `unit_class`, `unit_flags`, `type`, `lootid`, `AIName`, `MovementType`, `HealthModifier`, `ManaModifier`, `ArmorModifier`, `RegenHealth`, `flags_extra`, `KillCredit1`, `gossip_menu_id`)
VALUES
(162800, 'Dulcinea', 'Maid of House Spada', 8, 8, 0, 12, 2, 0, 1, 0, 7, 0, '', 0, 1, 1, 1, 1, 0, 0, 0),
(162802, 'Aldia Crayon', 'Majordomo', 10, 10, 0, 12, 2, 0, 1, 0, 7, 0, '', 0, 1, 1, 1, 1, 0, 0, 0),
(162803, 'Lady Agria Spada', NULL, 8, 8, 0, 12, 0, 0, 1, 0, 7, 0, '', 0, 1, 1, 1, 1, 0, 0, 0),
(162805, 'Clara the Mad', NULL, 8, 8, 0, 12, 2, 0, 1, 0, 7, 0, '', 0, 0.96, 1, 1, 1, 0, 0, 0),
(162806, 'Aliscar Lend', NULL, 12, 12, 0, 12, 3, 0, 8, 0, 7, 0, 'SmartAI', 0, 1, 1, 1, 1, 0, 0, 85190),
(162807, 'Harvend Thorm', 'Mayor of Goldshire', 10, 10, 0, 12, 3, 0, 1, 0, 7, 0, '', 0, 1, 1, 1, 1, 0, 0, 85163),
(162801, 'Eldor Hammer', 'Westfall Refugee', 8, 8, 0, 12, 2, 0, 1, 0, 7, 0, '', 0, 1, 1, 1, 1, 0, 0, 0),
(162814, 'Ainora', 'Florist', 10, 10, 0, 12, 128, 0, 1, 0, 7, 0, '', 0, 0.96, 1, 1, 1, 0, 0, 0),
(162811, 'Darron', NULL, 10, 10, 0, 12, 128, 0, 1, 0, 7, 0, '', 0, 0.96, 1, 1, 1, 0, 0, 0),
(162809, 'Rowena', NULL, 10, 10, 0, 12, 128, 0, 1, 0, 7, 0, '', 0, 0.96, 1, 1, 1, 0, 0, 0),
(162826, 'Joaquin', NULL, 10, 10, 0, 12, 128, 0, 1, 0, 7, 0, '', 0, 0.96, 1, 1, 1, 0, 0, 0),
(162808, 'Thalira Conacher', NULL, 8, 8, 0, 12, 0, 0, 1, 0, 7, 0, '', 0, 1, 1, 1, 1, 0, 0, 0),
(162817, 'Westfall Refugee', NULL, 5, 5, 0, 12, 0, 0, 1, 0, 7, 0, '', 0, 0.96, 1, 1, 1, 0, 0, 0),
(162818, 'Westfall Refugee', NULL, 5, 5, 0, 12, 0, 0, 1, 0, 7, 0, '', 0, 0.96, 1, 1, 1, 0, 0, 0),
(162819, 'Westfall Refugee', NULL, 5, 5, 0, 12, 0, 0, 1, 0, 7, 0, '', 0, 0.96, 1, 1, 1, 0, 0, 0),
(162820, 'Westfall Refugee', NULL, 5, 5, 0, 12, 0, 0, 1, 0, 7, 0, '', 0, 0.96, 1, 1, 1, 0, 0, 0),
(162821, 'Goldshire Farmer', NULL, 6, 6, 0, 12, 0, 0, 1, 0, 7, 0, '', 0, 0.93, 1, 1, 1, 0, 0, 0),
(162822, 'Goldshire Farmer', NULL, 6, 6, 0, 12, 0, 0, 1, 0, 7, 0, '', 0, 0.96, 1, 1, 1, 0, 0, 0),
(162823, 'Goldshire Farmer', NULL, 6, 6, 0, 12, 0, 0, 1, 0, 7, 0, '', 0, 0.96, 1, 1, 1, 0, 0, 0),
(162824, 'Goldshire Farmer', NULL, 6, 6, 0, 12, 0, 0, 1, 0, 7, 0, '', 0, 0.96, 1, 1, 1, 0, 0, 0),
(162943, 'Arcane Projection of Aliscar', NULL, 12, 12, 0, 35, 0, 0, 8, 0, 7, 0, '', 0, 1, 1, 1, 1, 0, 162921, 0),
(162920, '[TG] kharanos hops', NULL, 1, 1, 0, 35, 0, 0, 1, 33555202, 10, 0, '', 0, 1, 1, 1, 1, 130, 0, 0),
(162921, '[KC] Listen to Aliscar Lend', NULL, 1, 1, 0, 35, 0, 0, 1, 33555202, 10, 0, '', 0, 1, 1, 1, 1, 130, 0, 0),
(162940, '[KC] Kobold Warren Destroyed', NULL, 1, 1, 0, 35, 0, 0, 1, 33555202, 10, 0, '', 0, 1, 1, 1, 1, 130, 0, 0)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `subname` = VALUES(`subname`), `minlevel` = VALUES(`minlevel`), `maxlevel` = VALUES(`maxlevel`), `exp` = VALUES(`exp`), `faction` = VALUES(`faction`), `npcflag` = VALUES(`npcflag`), `rank` = VALUES(`rank`), `unit_class` = VALUES(`unit_class`), `unit_flags` = VALUES(`unit_flags`), `type` = VALUES(`type`), `lootid` = VALUES(`lootid`), `AIName` = VALUES(`AIName`), `MovementType` = VALUES(`MovementType`), `HealthModifier` = VALUES(`HealthModifier`), `ManaModifier` = VALUES(`ManaModifier`), `ArmorModifier` = VALUES(`ArmorModifier`), `RegenHealth` = VALUES(`RegenHealth`), `flags_extra` = VALUES(`flags_extra`), `KillCredit1` = VALUES(`KillCredit1`), `gossip_menu_id` = VALUES(`gossip_menu_id`);

DELETE FROM `creature_template_model` WHERE `CreatureID` IN (162800, 162801, 162802, 162803, 162805, 162806, 162807, 162808, 162809, 162811, 162814, 162817, 162818, 162819, 162820, 162821, 162822, 162823, 162824, 162826, 162920, 162921, 162940, 162943);
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`)
VALUES
(162800, 0, 3367, 1, 1),
(162802, 0, 8632, 1, 1),
(162803, 0, 1544, 1, 1),
(162805, 0, 2959, 1, 1),
(162806, 0, 5080, 1, 1),
(162807, 0, 1753, 1, 1),
(162801, 0, 1944, 1, 1),
(162814, 0, 1441, 1, 1),
(162811, 0, 3370, 1, 1),
(162809, 0, 1443, 1, 1),
(162826, 0, 3361, 1, 1),
(162808, 0, 5552, 1, 1),
(162817, 0, 18616, 1, 1),
(162818, 0, 18617, 1, 1),
(162819, 0, 18618, 1, 1),
(162820, 0, 18619, 1, 1),
(162821, 0, 3534, 1, 1),
(162822, 0, 3703, 1, 1),
(162823, 0, 1943, 1, 1),
(162824, 0, 3324, 1, 1),
(162943, 0, 5080, 1, 1),
(162920, 0, 11686, 1, 1),
(162921, 0, 11686, 1, 1),
(162940, 0, 11686, 1, 1);

DELETE FROM `creature_template_addon` WHERE `entry` = 162803;
INSERT INTO `creature_template_addon` (`entry`, `path_id`, `mount`, `bytes1`, `bytes2`, `emote`, `visibilityDistanceType`, `auras`)
VALUES
(162803, 0, 0, 3, 1, 0, 0, NULL);

DELETE FROM `npc_vendor` WHERE `entry` IN (162809, 162811, 162814, 162826);
INSERT INTO `npc_vendor` (`entry`, `slot`, `item`, `maxcount`, `incrtime`, `ExtendedCost`)
VALUES
(162814, 0, 558956, 0, 0, 0),
(162811, 0, 558957, 0, 0, 0),
(162809, 0, 558958, 0, 0, 0),
(162826, 0, 558959, 0, 0, 0);

DELETE FROM `creature_questitem` WHERE `CreatureEntry` IN (162809, 162811, 162814, 162826);
INSERT INTO `creature_questitem` (`CreatureEntry`, `Idx`, `ItemId`)
VALUES
(162814, 0, 558956),
(162811, 0, 558957),
(162809, 0, 558958),
(162826, 0, 558959);

-- ---------------------------------------------------------------------------
-- 2. Dialogue
-- ---------------------------------------------------------------------------
DELETE FROM `npc_text` WHERE `ID` IN (85163, 85164, 85190);
INSERT INTO `npc_text` (`ID`, `text0_0`, `text0_1`, `lang0`, `Probability0`)
VALUES
(85163, '<The mayor can’t help the flicker of a smile when his eyes meet Thalira Conacher’s across the great hall.>', '<The mayor can’t help the flicker of a smile when his eyes meet Thalira Conacher’s across the great hall.>', 0, 1),
(85164, 'The kingdom is divided into provinces, which in turn are divided into smaller territories. There’s still a feudal administration, with various noble families heading each region, but all are subordinate to the authority of the crown.$b$bThis part of Elwynn belongs to the Bruck family’s estate, on whose behalf I serve as mayor. While the Brucks enjoy the well-earned comforts of their centuries-old manor, I handle Goldshire’s governance and justice in accordance with their wisdom and the laws of the realm.$b$bOther noble families in Elwynn, like the Spada, Herbad, Locker, or Feandor, limit themselves to managing their holdings and properties, or what remains of them. Many have little left of nobility but the title.', 'The kingdom is divided into provinces, which in turn are divided into smaller territories. There’s still a feudal administration, with various noble families heading each region, but all are subordinate to the authority of the crown.$b$bThis part of Elwynn belongs to the Bruck family’s estate, on whose behalf I serve as mayor. While the Brucks enjoy the well-earned comforts of their centuries-old manor, I handle Goldshire’s governance and justice in accordance with their wisdom and the laws of the realm.$b$bOther noble families in Elwynn, like the Spada, Herbad, Locker, or Feandor, limit themselves to managing their holdings and properties, or what remains of them. Many have little left of nobility but the title.', 0, 1),
(85190, 'Welcome, $C.$b$bMy name is Aliscar Lend; mage, sorcerer, and public advisor for Goldshire.', 'Welcome, $C.$b$bMy name is Aliscar Lend; mage, sorcerer, and public advisor for Goldshire.', 0, 1);

DELETE FROM `gossip_menu` WHERE `MenuID` IN (85163, 85164, 85190);
INSERT INTO `gossip_menu` (`MenuID`, `TextID`)
VALUES
(85163, 85163),
(85164, 85164),
(85190, 85190);

DELETE FROM `gossip_menu_option` WHERE `MenuID` IN (85163, 85190);
INSERT INTO `gossip_menu_option` (`MenuID`, `OptionID`, `OptionIcon`, `OptionText`, `OptionBroadcastTextID`, `OptionType`, `OptionNpcFlag`, `ActionMenuID`, `ActionPoiID`, `BoxCoded`, `BoxMoney`, `BoxText`, `BoxBroadcastTextID`)
VALUES
(85163, 0, 0, 'Who governs Goldshire?', 0, 1, 1, 85164, 0, 0, 0, '', 0),
(85190, 0, 0, 'I have a moment. Tell me about Goldshire.', 0, 1, 1, 0, 0, 0, 0, '', 0);

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 15 AND `SourceGroup` = 85190;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`)
VALUES
(15, 85190, 0, 0, 0, 9, 0, 1660060, 0, 0, 0, 0, 0, '', 'Aliscar Lend - the history lesson only while Stay a While is taken');

-- ---------------------------------------------------------------------------
-- 3. World objects
-- ---------------------------------------------------------------------------
INSERT INTO `gameobject_template` (`entry`, `type`, `displayId`, `name`, `castBarCaption`, `size`, `AIName`, `Data0`, `Data1`, `Data2`, `Data3`, `Data4`, `Data5`, `Data6`, `Data7`, `Data8`, `Data9`, `Data10`, `Data11`, `Data12`, `Data13`, `Data14`, `Data15`, `Data16`, `Data17`, `Data18`, `Data19`, `Data20`, `Data21`, `Data22`, `Data23`)
VALUES
(2300546, 10, 1061017, 'Mirror Shard', '', 1, 'SmartGameObjectAI', 0, 1660057, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2300547, 3, 60, 'Pumpkin', '', 0.5, '', 1689, 2300547, 0, 1, 0, 0, 0, 0, 1660059, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2300548, 3, 332, 'Melon', '', 0.7, '', 1689, 2300548, 0, 1, 0, 0, 0, 0, 1660059, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2300549, 3, 433, 'Apple', '', 0.5, '', 1689, 2300549, 0, 1, 0, 0, 0, 0, 1660059, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(2300579, 10, 1017889, 'Kobold Warren', '', 0.3, 'SmartGameObjectAI', 0, 1660058, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
ON DUPLICATE KEY UPDATE `type` = VALUES(`type`), `displayId` = VALUES(`displayId`), `name` = VALUES(`name`), `castBarCaption` = VALUES(`castBarCaption`), `size` = VALUES(`size`), `AIName` = VALUES(`AIName`), `Data0` = VALUES(`Data0`), `Data1` = VALUES(`Data1`), `Data2` = VALUES(`Data2`), `Data3` = VALUES(`Data3`), `Data4` = VALUES(`Data4`), `Data5` = VALUES(`Data5`), `Data6` = VALUES(`Data6`), `Data7` = VALUES(`Data7`), `Data8` = VALUES(`Data8`), `Data9` = VALUES(`Data9`), `Data10` = VALUES(`Data10`), `Data11` = VALUES(`Data11`), `Data12` = VALUES(`Data12`), `Data13` = VALUES(`Data13`), `Data14` = VALUES(`Data14`), `Data15` = VALUES(`Data15`), `Data16` = VALUES(`Data16`), `Data17` = VALUES(`Data17`), `Data18` = VALUES(`Data18`), `Data19` = VALUES(`Data19`), `Data20` = VALUES(`Data20`), `Data21` = VALUES(`Data21`), `Data22` = VALUES(`Data22`), `Data23` = VALUES(`Data23`);

DELETE FROM `gameobject_loot_template` WHERE `Entry` IN (2300547, 2300548, 2300549);
INSERT INTO `gameobject_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`, `Comment`)
VALUES
(2300547, 558961, 0, 100, 1, 1, 0, 1, 1, 'CoA Goldshire: Pumpkin for Goldshire''s Generosity'),
(2300548, 558962, 0, 100, 1, 1, 0, 1, 1, 'CoA Goldshire: Melon for Goldshire''s Generosity'),
(2300549, 558963, 0, 100, 1, 1, 0, 1, 1, 'CoA Goldshire: Apple for Goldshire''s Generosity');

DELETE FROM `gameobject_questitem` WHERE `GameObjectEntry` IN (2300547, 2300548, 2300549);
INSERT INTO `gameobject_questitem` (`GameObjectEntry`, `Idx`, `ItemId`)
VALUES
(2300547, 0, 558961),
(2300548, 0, 558962),
(2300549, 0, 558963);

-- ---------------------------------------------------------------------------
-- 4. Quests
-- ---------------------------------------------------------------------------
INSERT INTO `quest_template` (`ID`, `QuestType`, `QuestLevel`, `MinLevel`, `QuestSortID`, `QuestInfoID`, `SuggestedGroupNum`, `RequiredFactionId1`, `RequiredFactionId2`, `RequiredFactionValue1`, `RequiredFactionValue2`, `RewardNextQuest`, `RewardXPDifficulty`, `RewardMoney`, `RewardMoneyDifficulty`, `RewardDisplaySpell`, `RewardSpell`, `RewardHonor`, `RewardKillHonor`, `StartItem`, `Flags`, `RequiredPlayerKills`, `RewardItem1`, `RewardAmount1`, `RewardItem2`, `RewardAmount2`, `RewardItem3`, `RewardAmount3`, `RewardItem4`, `RewardAmount4`, `ItemDrop1`, `ItemDropQuantity1`, `ItemDrop2`, `ItemDropQuantity2`, `ItemDrop3`, `ItemDropQuantity3`, `ItemDrop4`, `ItemDropQuantity4`, `RewardChoiceItemID1`, `RewardChoiceItemQuantity1`, `RewardChoiceItemID2`, `RewardChoiceItemQuantity2`, `RewardChoiceItemID3`, `RewardChoiceItemQuantity3`, `RewardChoiceItemID4`, `RewardChoiceItemQuantity4`, `RewardChoiceItemID5`, `RewardChoiceItemQuantity5`, `RewardChoiceItemID6`, `RewardChoiceItemQuantity6`, `POIContinent`, `POIx`, `POIy`, `POIPriority`, `RewardTitle`, `RewardTalents`, `RewardArenaPoints`, `RewardFactionID1`, `RewardFactionValue1`, `RewardFactionOverride1`, `RewardFactionID2`, `RewardFactionValue2`, `RewardFactionOverride2`, `RewardFactionID3`, `RewardFactionValue3`, `RewardFactionOverride3`, `RewardFactionID4`, `RewardFactionValue4`, `RewardFactionOverride4`, `RewardFactionID5`, `RewardFactionValue5`, `RewardFactionOverride5`, `LogTitle`, `LogDescription`, `QuestDescription`, `AreaDescription`, `QuestCompletionLog`, `RequiredNpcOrGo1`, `RequiredNpcOrGo2`, `RequiredNpcOrGo3`, `RequiredNpcOrGo4`, `RequiredNpcOrGoCount1`, `RequiredNpcOrGoCount2`, `RequiredNpcOrGoCount3`, `RequiredNpcOrGoCount4`, `RequiredItemId1`, `RequiredItemId2`, `RequiredItemId3`, `RequiredItemId4`, `RequiredItemId5`, `RequiredItemId6`, `RequiredItemCount1`, `RequiredItemCount2`, `RequiredItemCount3`, `RequiredItemCount4`, `RequiredItemCount5`, `RequiredItemCount6`, `ObjectiveText1`, `ObjectiveText2`, `ObjectiveText3`, `ObjectiveText4`)
VALUES
(1660055, 2, 8, 5, 12, 0, 0, 0, 0, 0, 0, 0, 4, 120, 135, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'The Maid I Left Behind', 'Find Dulcinea, Bianca''s maid, in Goldshire.', 'You''ve been in and out of the abbey all day, yet I still haven''t seen my brother anywhere.$b$bI take it you couldn''t snap him out of it. Well... worth a try.$b$b<Her long, weary sigh says enough.>$b$bHeading out again? Maybe you can do me one more favor. On the way to the abbey I left one of my maids in Goldshire with a long list of ingredients to buy; medicine for my mother.$b$bHer name is Dulcinea. Could you find her and let her know I''ll be late?', '', 'Speak with Dulcinea.', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', ''),
(1660056, 2, 8, 5, 12, 0, 0, 0, 0, 0, 0, 0, 5, 110, 120, 0, 0, 0, 0, 558960, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2302015, 1, 2302020, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Agria''s Medicine', 'Buy the potion''s ingredients at the Goldshire market: Elgris Blossom Petals, Dun Kazad Liquor Concentrate, Pumpkin Juice, and a Murloc Eyeball.', 'Lady Agria Spada is a woman besieged by age. Of late she''s borne a litany of ailments that keep her to her bed.$b$bOnly one thing eases her: the draught brewed by her master alchemist.$b$bI''ve gathered a few ingredients, but the list is long and fussy. We still need Elgris Blossom Petals, Dun Kazad Liquor Concentrate, Pumpkin Juice, and a Murloc Eyeball.$b$bTake a turn through the market. Once you''ve got the lot, report to my lady''s manor. I don''t dare the roads alone, but you... you''re made of sterner stuff, aren''t you?', '', 'Speak with Aldia Crayon, butler to the Spadas, at the family manor.', 0, 0, 0, 0, 0, 0, 0, 0, 558956, 558957, 558958, 558959, 558960, 0, 1, 1, 1, 1, 1, 0, '', '', '', ''),
(1660057, 2, 8, 5, 12, 0, 0, 0, 0, 0, 0, 0, 5, 350, 382, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2302030, 1, 2302035, 1, 2302040, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Seven Years of Bad Luck', 'Inspect the broken mirror shards that Aldia Crayon blames for the curse afflicting Lady Agria Spada.', 'Hm...$b$b<The majordomo gives you a long, measuring look.>$b$bBefore you go... I need your help with one more matter.$b$bI''ve had the sense for some time that my lady''s ailments aren''t physical, but magical. A curse.$b$bIt started with a broken mirror. And you know what they say. However thorough I''ve been, shards keep turning up; bits of glass tucked around the manor and the grounds.$b$bWould you kindly deal with them?', '', 'Return to the butler.', 162920, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Mirror Shard Inspected', '', '', ''),
(1660058, 2, 8, 5, 12, 0, 0, 0, 0, 0, 0, 0, 5, 260, 337, 0, 0, 0, 0, 0, 8, 0, 2302045, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Worm-Eaten Apple', 'Find and destroy the kobold warrens around Goldshire.', 'Whispers. They think no one''s noticed,but I sleep with my ear to the floor! Ha!$b$bThey dig and dig and dig. They''ll strike when you least expect it... unless you do something first.$b$bKobolds and kobolds and more kobolds. Under our feet! Watch where you step. Mind your footing!$b$bFind their warrens and set them alight. Crush them. With a big, heavy hammer!$b$b<She laughs to herself, then stares into the middle distance.>', '', 'Return to Clara the Mad.', 162940, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Kobold Warren Destroyed', '', '', ''),
(1660059, 2, 8, 5, 12, 0, 0, 0, 0, 0, 0, 0, 5, 156, 213, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2302050, 1, 2302055, 1, 2302060, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Goldshire''s Generosity', 'Gather Melons, Pumpkins, and Apples from the farms around Goldshire. Then deliver them to Eldor Hammer, leader of the refugees.', 'Welcome.$b$bI am Thorm—Harvend Thorm—mayor of Goldshire, serving on behalf of Lord Bruk and his house.$b$bYou may have noticed the makeshift camp in the shadow of this grand hall. Of late, Goldshire has taken in countless refugees out of Westfall. At times I fear it''s beyond our means...$b$bEven so, I won''t turn away while they go hungry. Walk the village fields and take a little from each harvest to bring to the camp. You have my leave—and, by extension, Lord Bruk''s.', '', 'Deliver the basket of food to Eldor Hammer.', 0, 0, 0, 0, 0, 0, 0, 0, 558961, 558962, 558963, 0, 0, 0, 3, 3, 10, 0, 0, 0, '', '', '', ''),
(1660060, 2, 8, 5, 12, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Stay a While', 'Take a moment from the noise and haste and stay a while to listen to Aliscar Lend.', 'As it turns out, I''m the leading authority around here when it comes to the village''s history. Care for a short lesson?$b$b<The aging sorcerer seems eager, almost desperate, to talk.>$b$b<Perhaps he has something worth sharing.>', '', 'Say goodbye to Aliscar Lend.', 162921, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Listen to Aliscar Lend', '', '', '')
ON DUPLICATE KEY UPDATE `QuestType` = VALUES(`QuestType`), `QuestLevel` = VALUES(`QuestLevel`), `MinLevel` = VALUES(`MinLevel`), `QuestSortID` = VALUES(`QuestSortID`), `QuestInfoID` = VALUES(`QuestInfoID`), `SuggestedGroupNum` = VALUES(`SuggestedGroupNum`), `RequiredFactionId1` = VALUES(`RequiredFactionId1`), `RequiredFactionId2` = VALUES(`RequiredFactionId2`), `RequiredFactionValue1` = VALUES(`RequiredFactionValue1`), `RequiredFactionValue2` = VALUES(`RequiredFactionValue2`), `RewardNextQuest` = VALUES(`RewardNextQuest`), `RewardXPDifficulty` = VALUES(`RewardXPDifficulty`), `RewardMoney` = VALUES(`RewardMoney`), `RewardMoneyDifficulty` = VALUES(`RewardMoneyDifficulty`), `RewardDisplaySpell` = VALUES(`RewardDisplaySpell`), `RewardSpell` = VALUES(`RewardSpell`), `RewardHonor` = VALUES(`RewardHonor`), `RewardKillHonor` = VALUES(`RewardKillHonor`), `StartItem` = VALUES(`StartItem`), `Flags` = VALUES(`Flags`), `RequiredPlayerKills` = VALUES(`RequiredPlayerKills`), `RewardItem1` = VALUES(`RewardItem1`), `RewardAmount1` = VALUES(`RewardAmount1`), `RewardItem2` = VALUES(`RewardItem2`), `RewardAmount2` = VALUES(`RewardAmount2`), `RewardItem3` = VALUES(`RewardItem3`), `RewardAmount3` = VALUES(`RewardAmount3`), `RewardItem4` = VALUES(`RewardItem4`), `RewardAmount4` = VALUES(`RewardAmount4`), `ItemDrop1` = VALUES(`ItemDrop1`), `ItemDropQuantity1` = VALUES(`ItemDropQuantity1`), `ItemDrop2` = VALUES(`ItemDrop2`), `ItemDropQuantity2` = VALUES(`ItemDropQuantity2`), `ItemDrop3` = VALUES(`ItemDrop3`), `ItemDropQuantity3` = VALUES(`ItemDropQuantity3`), `ItemDrop4` = VALUES(`ItemDrop4`), `ItemDropQuantity4` = VALUES(`ItemDropQuantity4`), `RewardChoiceItemID1` = VALUES(`RewardChoiceItemID1`), `RewardChoiceItemQuantity1` = VALUES(`RewardChoiceItemQuantity1`), `RewardChoiceItemID2` = VALUES(`RewardChoiceItemID2`), `RewardChoiceItemQuantity2` = VALUES(`RewardChoiceItemQuantity2`), `RewardChoiceItemID3` = VALUES(`RewardChoiceItemID3`), `RewardChoiceItemQuantity3` = VALUES(`RewardChoiceItemQuantity3`), `RewardChoiceItemID4` = VALUES(`RewardChoiceItemID4`), `RewardChoiceItemQuantity4` = VALUES(`RewardChoiceItemQuantity4`), `RewardChoiceItemID5` = VALUES(`RewardChoiceItemID5`), `RewardChoiceItemQuantity5` = VALUES(`RewardChoiceItemQuantity5`), `RewardChoiceItemID6` = VALUES(`RewardChoiceItemID6`), `RewardChoiceItemQuantity6` = VALUES(`RewardChoiceItemQuantity6`), `POIContinent` = VALUES(`POIContinent`), `POIx` = VALUES(`POIx`), `POIy` = VALUES(`POIy`), `POIPriority` = VALUES(`POIPriority`), `RewardTitle` = VALUES(`RewardTitle`), `RewardTalents` = VALUES(`RewardTalents`), `RewardArenaPoints` = VALUES(`RewardArenaPoints`), `RewardFactionID1` = VALUES(`RewardFactionID1`), `RewardFactionValue1` = VALUES(`RewardFactionValue1`), `RewardFactionOverride1` = VALUES(`RewardFactionOverride1`), `RewardFactionID2` = VALUES(`RewardFactionID2`), `RewardFactionValue2` = VALUES(`RewardFactionValue2`), `RewardFactionOverride2` = VALUES(`RewardFactionOverride2`), `RewardFactionID3` = VALUES(`RewardFactionID3`), `RewardFactionValue3` = VALUES(`RewardFactionValue3`), `RewardFactionOverride3` = VALUES(`RewardFactionOverride3`), `RewardFactionID4` = VALUES(`RewardFactionID4`), `RewardFactionValue4` = VALUES(`RewardFactionValue4`), `RewardFactionOverride4` = VALUES(`RewardFactionOverride4`), `RewardFactionID5` = VALUES(`RewardFactionID5`), `RewardFactionValue5` = VALUES(`RewardFactionValue5`), `RewardFactionOverride5` = VALUES(`RewardFactionOverride5`), `LogTitle` = VALUES(`LogTitle`), `LogDescription` = VALUES(`LogDescription`), `QuestDescription` = VALUES(`QuestDescription`), `AreaDescription` = VALUES(`AreaDescription`), `QuestCompletionLog` = VALUES(`QuestCompletionLog`), `RequiredNpcOrGo1` = VALUES(`RequiredNpcOrGo1`), `RequiredNpcOrGo2` = VALUES(`RequiredNpcOrGo2`), `RequiredNpcOrGo3` = VALUES(`RequiredNpcOrGo3`), `RequiredNpcOrGo4` = VALUES(`RequiredNpcOrGo4`), `RequiredNpcOrGoCount1` = VALUES(`RequiredNpcOrGoCount1`), `RequiredNpcOrGoCount2` = VALUES(`RequiredNpcOrGoCount2`), `RequiredNpcOrGoCount3` = VALUES(`RequiredNpcOrGoCount3`), `RequiredNpcOrGoCount4` = VALUES(`RequiredNpcOrGoCount4`), `RequiredItemId1` = VALUES(`RequiredItemId1`), `RequiredItemId2` = VALUES(`RequiredItemId2`), `RequiredItemId3` = VALUES(`RequiredItemId3`), `RequiredItemId4` = VALUES(`RequiredItemId4`), `RequiredItemId5` = VALUES(`RequiredItemId5`), `RequiredItemId6` = VALUES(`RequiredItemId6`), `RequiredItemCount1` = VALUES(`RequiredItemCount1`), `RequiredItemCount2` = VALUES(`RequiredItemCount2`), `RequiredItemCount3` = VALUES(`RequiredItemCount3`), `RequiredItemCount4` = VALUES(`RequiredItemCount4`), `RequiredItemCount5` = VALUES(`RequiredItemCount5`), `RequiredItemCount6` = VALUES(`RequiredItemCount6`), `ObjectiveText1` = VALUES(`ObjectiveText1`), `ObjectiveText2` = VALUES(`ObjectiveText2`), `ObjectiveText3` = VALUES(`ObjectiveText3`), `ObjectiveText4` = VALUES(`ObjectiveText4`);

DELETE FROM `quest_template_addon` WHERE `ID` IN (1660055, 1660056, 1660057, 1660058, 1660059, 1660060);
INSERT INTO `quest_template_addon` (`ID`, `MaxLevel`, `AllowableClasses`, `PrevQuestID`, `BreadcrumbForQuestId`, `ProvidedItemCount`, `SpecialFlags`)
VALUES
(1660055, 0, 0, 1660000, 1660056, 0, 0),
(1660056, 0, 0, 0, 0, 1, 0),
(1660057, 0, 0, 1660056, 0, 0, 0),
(1660058, 0, 0, 0, 0, 0, 0),
(1660059, 0, 0, 0, 0, 0, 0),
(1660060, 0, 0, 0, 0, 0, 0);

DELETE FROM `quest_offer_reward` WHERE `ID` IN (1660055, 1660056, 1660057, 1660058, 1660059, 1660060);
INSERT INTO `quest_offer_reward` (`ID`, `RewardText`)
VALUES
(1660055, ''),
(1660056, ''),
(1660057, ''),
(1660058, ''),
(1660059, ''),
(1660060, '');

DELETE FROM `quest_request_items` WHERE `ID` IN (1660055, 1660056, 1660057, 1660058, 1660059, 1660060);
INSERT INTO `quest_request_items` (`ID`, `CompletionText`)
VALUES
(1660055, 'Speak with Dulcinea.'),
(1660056, 'Speak with Aldia Crayon, butler to the Spadas, at the family manor.'),
(1660057, 'Return to the butler.'),
(1660058, 'Return to Clara the Mad.'),
(1660059, 'Deliver the basket of food to Eldor Hammer.'),
(1660060, 'Say goodbye to Aliscar Lend.');

DELETE FROM `creature_queststarter` WHERE `quest` IN (1660055, 1660056, 1660057, 1660058, 1660059, 1660060);
INSERT INTO `creature_queststarter` (`id`, `quest`)
VALUES
(161700, 1660055),
(162800, 1660056),
(162802, 1660057),
(162805, 1660058),
(162807, 1660059),
(162806, 1660060);

DELETE FROM `creature_questender` WHERE `quest` IN (1660055, 1660056, 1660057, 1660058, 1660059, 1660060);
INSERT INTO `creature_questender` (`id`, `quest`)
VALUES
(162800, 1660055),
(162802, 1660056),
(162802, 1660057),
(162805, 1660058),
(162801, 1660059),
(162806, 1660060);

-- ---------------------------------------------------------------------------
-- 5. Spawns
-- ---------------------------------------------------------------------------
DELETE FROM `creature` WHERE `guid` IN (9002000, 9002001, 9002002, 9002003, 9002004, 9002005, 9002006, 9002007, 9002008, 9002009, 9002010, 9002011, 9002012, 9002013, 9002014, 9002015, 9002016, 9002017, 9002018, 9002019);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `unit_flags`, `dynamicflags`, `ScriptName`, `VerifiedBuild`, `CreateObject`, `Comment`)
VALUES
(9002000, 162800, 0, 0, 0, 1, 1, 0, -9468, 40, 56.53, 3.34, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Goldshire: inferred placement, market plaza, at the signpost'),
(9002001, 162802, 0, 0, 0, 1, 1, 0, -9284, 456.5, 82.27, 4.71, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Goldshire: inferred placement, Spada Family Manor, in the foyer inside the east door'),
(9002002, 162803, 0, 0, 0, 1, 1, 0, -9273.4, 470, 90.91, 4.71, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Goldshire: inferred placement, Spada Family Manor, abed upstairs'),
(9002003, 162805, 0, 0, 0, 1, 1, 0, -9447.5, -20.5, 57.98, 4.85, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Goldshire: inferred placement, the apple orchard, facing the fruit trees'),
(9002004, 162806, 0, 0, 0, 1, 1, 0, -9497, -34.5, 58.07, 5.58, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Goldshire: inferred placement, the garden gazebo beside the open book'),
(9002005, 162807, 0, 0, 0, 1, 1, 0, -9558.4, 62.8, 62.17, 4.71, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Goldshire: inferred placement, town hall, behind the podium on the dais'),
(9002006, 162801, 0, 0, 0, 1, 1, 0, -9556.5, 13, 58.81, 0, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Goldshire: inferred placement, refugee camp, at the first pavilion'),
(9002007, 162817, 0, 0, 0, 1, 1, 0, -9565, 12, 59.05, 2.29, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Goldshire: inferred placement, refugee camp'),
(9002008, 162818, 0, 0, 0, 1, 1, 0, -9577.5, 20, 59.43, 0, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Goldshire: inferred placement, refugee camp, by the beds'),
(9002009, 162819, 0, 0, 0, 1, 1, 0, -9581, 12, 59.62, 0.73, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Goldshire: inferred placement, refugee camp, by the tent'),
(9002010, 162820, 0, 0, 0, 1, 1, 0, -9583.5, 31.5, 59.02, 5.5, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Goldshire: inferred placement, refugee camp, by the campsite tent'),
(9002011, 162809, 0, 0, 0, 1, 1, 0, -9490, 35.6, 56.65, 0.23, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Goldshire: inferred placement, market, behind the pumpkin stall counter'),
(9002012, 162811, 0, 0, 0, 1, 1, 0, -9462.5, 53, 56.71, 4.57, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Goldshire: inferred placement, market, at the bottle-laden wagon'),
(9002013, 162826, 0, 0, 0, 1, 1, 0, -9460.3, 30.6, 56.79, 1.9, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Goldshire: inferred placement, market, in the food tent by the fishing box'),
(9002014, 162814, 0, 0, 0, 1, 1, 0, -9387, 22.5, 58.97, 2.9, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Goldshire: inferred placement, in front of the flower cart'),
(9002015, 162808, 0, 0, 0, 1, 1, 0, -9552, 50, 60.81, 1.57, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Goldshire: inferred placement, town hall floor, across from the mayor'),
(9002016, 162821, 0, 0, 0, 1, 1, 0, -9500.5, 86.5, 57.008, 1.2, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Goldshire: inferred placement, the melon plot west of the blacksmith'),
(9002017, 162822, 0, 0, 0, 1, 1, 0, -9413, -41, 64.459, 3.9, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Goldshire: inferred placement, the pumpkin garden'),
(9002018, 162823, 0, 0, 0, 1, 1, 0, -9445, -49.5, 60.197, 1.6, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Goldshire: inferred placement, the apple orchard'),
(9002019, 162824, 0, 0, 0, 1, 1, 0, -9506, 112, 57.549, 0.4, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Goldshire: inferred placement, by the barn west of the melon plot');

DELETE FROM `gameobject` WHERE `guid` IN (6911000, 6911001, 6911002, 6911003, 6911004, 6911005, 6911006, 6911007, 6911008, 6911020, 6911021, 6911022, 6911023, 6911024, 6911025, 6911040, 6911041, 6911042, 6911043, 6911044, 6911045, 6911060, 6911061, 6911062, 6911063, 6911064, 6911065, 6911080, 6911081, 6911082, 6911083, 6911084, 6911085, 6911086, 6911087, 6911088, 6911089, 6911090, 6911091, 6911092);
INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `ScriptName`, `Comment`)
VALUES
(6911000, 2300546, 0, 0, 0, 1, 1, -9274.5, 457.8, 82.27, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, Spada Family Manor and grounds'),
(6911001, 2300546, 0, 0, 0, 1, 1, -9279, 467.5, 89.87, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, Spada Family Manor and grounds'),
(6911002, 2300546, 0, 0, 0, 1, 1, -9297, 461, 86.05, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, Spada Family Manor and grounds'),
(6911003, 2300546, 0, 0, 0, 1, 1, -9285.8, 482.8, 77.74, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, Spada Family Manor and grounds'),
(6911004, 2300546, 0, 0, 0, 1, 1, -9306, 490, 77.65, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, Spada Family Manor and grounds'),
(6911005, 2300546, 0, 0, 0, 1, 1, -9283.5, 431.5, 78.7, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, Spada Family Manor and grounds'),
(6911006, 2300546, 0, 0, 0, 1, 1, -9287.5, 465, 82.27, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, Spada Family Manor and grounds'),
(6911007, 2300546, 0, 0, 0, 1, 1, -9283, 495, 77.77, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, Spada Family Manor and grounds'),
(6911008, 2300546, 0, 0, 0, 1, 1, -9262.5, 437.5, 79.99, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, Spada Family Manor and grounds'),
(6911020, 2300579, 0, 0, 0, 1, 1, -9420, 130, 60.03, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, around Goldshire'),
(6911021, 2300579, 0, 0, 0, 1, 1, -9365, 90, 62.43, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, around Goldshire'),
(6911022, 2300579, 0, 0, 0, 1, 1, -9560, 110, 58.98, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, around Goldshire'),
(6911023, 2300579, 0, 0, 0, 1, 1, -9610, 46, 60.86, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, around Goldshire'),
(6911024, 2300579, 0, 0, 0, 1, 1, -9560, -40, 59.84, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, around Goldshire'),
(6911025, 2300579, 0, 0, 0, 1, 1, -9420, -75, 61.64, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, around Goldshire'),
(6911040, 2300548, 0, 0, 0, 1, 1, -9497.5, 91.5, 56.9, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the melon plot'),
(6911041, 2300548, 0, 0, 0, 1, 1, -9503.5, 96, 56.99, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the melon plot'),
(6911042, 2300548, 0, 0, 0, 1, 1, -9497, 99.5, 56.92, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the melon plot'),
(6911043, 2300548, 0, 0, 0, 1, 1, -9503, 101.5, 56.97, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the melon plot'),
(6911044, 2300548, 0, 0, 0, 1, 1, -9498.5, 105, 56.95, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the melon plot'),
(6911045, 2300548, 0, 0, 0, 1, 1, -9504.5, 106, 56.99, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the melon plot'),
(6911060, 2300547, 0, 0, 0, 1, 1, -9402.9, -39, 64.9, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the pumpkin garden'),
(6911061, 2300547, 0, 0, 0, 1, 1, -9410.3, -45.7, 64.53, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the pumpkin garden'),
(6911062, 2300547, 0, 0, 0, 1, 1, -9417.3, -52.5, 64.4, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the pumpkin garden'),
(6911063, 2300547, 0, 0, 0, 1, 1, -9408.7, -53.7, 64.46, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the pumpkin garden'),
(6911064, 2300547, 0, 0, 0, 1, 1, -9407.2, -61.9, 64.46, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the pumpkin garden'),
(6911065, 2300547, 0, 0, 0, 1, 1, -9399, -52.2, 64.42, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the pumpkin garden'),
(6911080, 2300549, 0, 0, 0, 1, 1, -9443, -35.3, 60.22, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the apple orchard'),
(6911081, 2300549, 0, 0, 0, 1, 1, -9443, -37.9, 60.22, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the apple orchard'),
(6911082, 2300549, 0, 0, 0, 1, 1, -9443.3, -43.6, 60.23, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the apple orchard'),
(6911083, 2300549, 0, 0, 0, 1, 1, -9443.2, -46, 60.23, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the apple orchard'),
(6911084, 2300549, 0, 0, 0, 1, 1, -9443.3, -27.1, 60.19, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the apple orchard'),
(6911085, 2300549, 0, 0, 0, 1, 1, -9443.4, -29.6, 60.2, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the apple orchard'),
(6911086, 2300549, 0, 0, 0, 1, 1, -9448.8, -46.9, 60.19, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the apple orchard'),
(6911087, 2300549, 0, 0, 0, 1, 1, -9445.7, -39.8, 60.23, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the apple orchard'),
(6911088, 2300549, 0, 0, 0, 1, 1, -9448.8, -37.8, 60.17, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the apple orchard'),
(6911089, 2300549, 0, 0, 0, 1, 1, -9446, -31, 60.2, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the apple orchard'),
(6911090, 2300549, 0, 0, 0, 1, 1, -9448.9, -28.8, 60.14, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the apple orchard'),
(6911091, 2300549, 0, 0, 0, 1, 1, -9445, -42.3, 60.23, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the apple orchard'),
(6911092, 2300549, 0, 0, 0, 1, 1, -9446.2, -34.5, 60.21, 0, 0, 0, 0, 1, 60, 100, 1, '', 'CoA Goldshire: inferred placement, the apple orchard');

-- ---------------------------------------------------------------------------
-- 6. Scripts
-- ---------------------------------------------------------------------------
DELETE FROM `smart_scripts` WHERE `entryorguid` IN (2300546, 2300579) AND `source_type` = 1;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`)
VALUES
(2300546, 1, 0, 1, 64, 0, 100, 0, 1, 0, 0, 0, 0, 0, 33, 162920, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Mirror Shard - On use - Credit the inspection'),
(2300546, 1, 1, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Mirror Shard - Linked - Despawn until it respawns'),
(2300579, 1, 0, 1, 64, 0, 100, 0, 1, 0, 0, 0, 0, 0, 33, 162940, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Kobold Warren - On use - Credit destroying the warren'),
(2300579, 1, 1, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Kobold Warren - Linked - Despawn until it respawns');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 162806 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`)
VALUES
(162806, 0, 0, 1, 62, 0, 100, 0, 85190, 0, 0, 0, 0, 0, 72, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Aliscar Lend - On Gossip Option 0 Selected - Close Gossip'),
(162806, 0, 1, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 33, 162921, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Aliscar Lend - Linked - Credit listening to him');
