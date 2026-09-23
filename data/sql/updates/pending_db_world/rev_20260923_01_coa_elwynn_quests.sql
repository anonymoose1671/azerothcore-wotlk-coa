-- Conquest of Azeroth quests in Elwynn Forest that this world has never carried, outside the
-- Goldshire storyline: the Ascension 17000 series (Maclure, Bouden, the Tower of Azora, Guard Thomas,
-- the Smudged Note, Ridgepoint Tower, Mirror Lake), the Bandit's Bastion quests (100071-100074) and
-- Agent Serina Vale's mineral dig (254038-254108).
--
-- WHERE EACH VALUE COMES FROM
--   quests, objects, items, reward items  the realm's own client cache (data-cache-945cd3b8b0ce4a496586).
--     Every quest and reward item already exists in item_template, so no item is written here.
--   object positions  SOURCED where the archive atlas saw them (Maclure Supplies, the Supply Cache, one
--     Mirror Lake Harvest, one crate of Stolen Goods, the Crocolisk Egg); the rest are INFERRED on terrain.
--   quest givers  SOURCED where the quest text names them; the rest INFERRED from the voice of the text.
--   new NPCs  Guard Jacob, Esyra and Sinter Wive come from the creature cache. Agent Serina Vale (996114 in
--     Goldshire, 996115 at the Bastion) is in no source; two entries keep each copy's quests apart. Displays
--     the client cannot resolve use stock stand-ins. All their positions are INFERRED.
--   drop chances  INFERRED (spider silk 50%, Mother Fang 100%, mana gem 66%, gnoll weapons 40%).
--   credits  Slimy Solution: the vial spell hitting a murloc corpse credits it and removes the corpse.
--     Unexpected Results: the enchanted fragment credits once per beast per ten minutes. Final Dig: a new
--     gossip option on Innkeeper Farley, shown only with the quest, gives him away; the line is authored.
--   not restored  quests 254039 and 254040 are in no source, so 254041 and 254095 follow 254038 directly.
--
-- Spawn guid blocks: creature 9002200-9002499, gameobject 6911200-6911499. Quest 17005 starts from the
-- Smudged Note that rev_20260922_00_coa_northshire_quests.sql spawns.

-- ---------------------------------------------------------------------------
-- 1. Creatures
-- ---------------------------------------------------------------------------
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `minlevel`, `maxlevel`, `exp`, `faction`, `npcflag`, `rank`, `unit_class`, `unit_flags`, `type`, `lootid`, `AIName`, `MovementType`, `HealthModifier`, `ManaModifier`, `ArmorModifier`, `RegenHealth`, `flags_extra`)
VALUES
(157000, 'Guard Jacob', NULL, 30, 30, 0, 12, 2, 0, 1, 0, 7, 0, '', 0, 1.36, 1, 1, 1, 0),
(900017, 'Esyra', 'Apprentice of Azora', 10, 10, 0, 12, 2, 0, 8, 0, 7, 0, '', 0, 0.96, 1, 1, 1, 0),
(996119, 'Defias Sentry', NULL, 9, 10, 0, 17, 0, 0, 1, 0, 7, 996119, '', 0, 0.92448, 1, 1, 1, 0),
(996114, 'Agent Serina Vale', NULL, 20, 20, 0, 35, 2, 0, 1, 0, 7, 0, '', 0, 1, 1, 1, 1, 0),
(996115, 'Agent Serina Vale', NULL, 20, 20, 0, 35, 2, 0, 1, 0, 7, 0, '', 0, 1, 1, 1, 1, 0),
(764542, 'Sinter Wive', NULL, 15, 15, 0, 35, 2, 0, 1, 0, 7, 0, '', 0, 1, 1, 1, 1, 0),
(300220, '[KC] Slimy Murloc Spittle', NULL, 1, 1, 0, 35, 0, 0, 1, 33555202, 10, 0, '', 0, 1, 1, 1, 1, 130),
(996120, '[KC] Find the Mole', NULL, 1, 1, 0, 35, 0, 0, 1, 33555202, 10, 0, '', 0, 1, 1, 1, 1, 130),
(996121, '[KC] Test Minerals Potency', NULL, 1, 1, 0, 35, 0, 0, 1, 33555202, 10, 0, '', 0, 1, 1, 1, 1, 130)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `subname` = VALUES(`subname`), `minlevel` = VALUES(`minlevel`), `maxlevel` = VALUES(`maxlevel`), `exp` = VALUES(`exp`), `faction` = VALUES(`faction`), `npcflag` = VALUES(`npcflag`), `rank` = VALUES(`rank`), `unit_class` = VALUES(`unit_class`), `unit_flags` = VALUES(`unit_flags`), `type` = VALUES(`type`), `lootid` = VALUES(`lootid`), `AIName` = VALUES(`AIName`), `MovementType` = VALUES(`MovementType`), `HealthModifier` = VALUES(`HealthModifier`), `ManaModifier` = VALUES(`ManaModifier`), `ArmorModifier` = VALUES(`ArmorModifier`), `RegenHealth` = VALUES(`RegenHealth`), `flags_extra` = VALUES(`flags_extra`);

DELETE FROM `creature_template_model` WHERE `CreatureID` IN (157000, 300220, 764542, 900017, 996114, 996115, 996119, 996120, 996121);
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`)
VALUES
(157000, 0, 1984, 1, 1),
(900017, 0, 3768, 1, 1),
(996119, 0, 5035, 1, 1),
(996114, 0, 5783, 1, 1),
(996115, 0, 5783, 1, 1),
(764542, 0, 1659, 1, 1),
(300220, 0, 11686, 1, 1),
(996120, 0, 11686, 1, 1),
(996121, 0, 11686, 1, 1);

DELETE FROM `creature_equip_template` WHERE `CreatureID` = 996119;
INSERT INTO `creature_equip_template` (`CreatureID`, `ID`, `ItemID1`, `ItemID2`, `ItemID3`)
VALUES
(996119, 1, 1896, 0, 0);

UPDATE `creature_template` SET `npcflag` = `npcflag` | 2 WHERE `entry` IN (250, 66, 11916, 955, 958, 11072);
UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `entry` IN (118, 822);

-- ---------------------------------------------------------------------------
-- 2. World objects
-- ---------------------------------------------------------------------------
INSERT INTO `gameobject_template` (`entry`, `type`, `displayId`, `name`, `castBarCaption`, `size`, `Data0`, `Data1`, `Data2`, `Data3`, `Data4`, `Data5`, `Data6`, `Data7`, `Data8`, `Data9`, `Data10`, `Data11`, `Data12`, `Data13`, `Data14`, `Data15`, `Data16`, `Data17`, `Data18`, `Data19`, `Data20`, `Data21`, `Data22`, `Data23`)
VALUES
(96000, 3, 36, 'Maclure Supplies', '', 1, 43, 96000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(96002, 3, 31, 'Supply Cache', '', 1, 43, 96002, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(96003, 3, 3012, 'Mirror Lake Harvest', 'Reclaiming', 1, 43, 96003, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(5055563, 3, 286, 'Stolen Goods', '', 1, 43, 5055563, 0, 1, 0, 0, 0, 0, 100073, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
(25428, 3, 3851, 'Crocolisk Egg', 'Looting', 1, 57, 25428, 0, 1, 0, 0, 0, 0, 254051, 0, 1, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
ON DUPLICATE KEY UPDATE `type` = VALUES(`type`), `displayId` = VALUES(`displayId`), `name` = VALUES(`name`), `castBarCaption` = VALUES(`castBarCaption`), `size` = VALUES(`size`), `Data0` = VALUES(`Data0`), `Data1` = VALUES(`Data1`), `Data2` = VALUES(`Data2`), `Data3` = VALUES(`Data3`), `Data4` = VALUES(`Data4`), `Data5` = VALUES(`Data5`), `Data6` = VALUES(`Data6`), `Data7` = VALUES(`Data7`), `Data8` = VALUES(`Data8`), `Data9` = VALUES(`Data9`), `Data10` = VALUES(`Data10`), `Data11` = VALUES(`Data11`), `Data12` = VALUES(`Data12`), `Data13` = VALUES(`Data13`), `Data14` = VALUES(`Data14`), `Data15` = VALUES(`Data15`), `Data16` = VALUES(`Data16`), `Data17` = VALUES(`Data17`), `Data18` = VALUES(`Data18`), `Data19` = VALUES(`Data19`), `Data20` = VALUES(`Data20`), `Data21` = VALUES(`Data21`), `Data22` = VALUES(`Data22`), `Data23` = VALUES(`Data23`);

-- ---------------------------------------------------------------------------
-- 3. Quests
-- ---------------------------------------------------------------------------
INSERT INTO `quest_template` (`ID`, `QuestType`, `QuestLevel`, `MinLevel`, `QuestSortID`, `QuestInfoID`, `SuggestedGroupNum`, `RequiredFactionId1`, `RequiredFactionId2`, `RequiredFactionValue1`, `RequiredFactionValue2`, `RewardNextQuest`, `RewardXPDifficulty`, `RewardMoney`, `RewardMoneyDifficulty`, `RewardDisplaySpell`, `RewardSpell`, `RewardHonor`, `RewardKillHonor`, `StartItem`, `Flags`, `RequiredPlayerKills`, `RewardItem1`, `RewardAmount1`, `RewardItem2`, `RewardAmount2`, `RewardItem3`, `RewardAmount3`, `RewardItem4`, `RewardAmount4`, `ItemDrop1`, `ItemDropQuantity1`, `ItemDrop2`, `ItemDropQuantity2`, `ItemDrop3`, `ItemDropQuantity3`, `ItemDrop4`, `ItemDropQuantity4`, `RewardChoiceItemID1`, `RewardChoiceItemQuantity1`, `RewardChoiceItemID2`, `RewardChoiceItemQuantity2`, `RewardChoiceItemID3`, `RewardChoiceItemQuantity3`, `RewardChoiceItemID4`, `RewardChoiceItemQuantity4`, `RewardChoiceItemID5`, `RewardChoiceItemQuantity5`, `RewardChoiceItemID6`, `RewardChoiceItemQuantity6`, `POIContinent`, `POIx`, `POIy`, `POIPriority`, `RewardTitle`, `RewardTalents`, `RewardArenaPoints`, `RewardFactionID1`, `RewardFactionValue1`, `RewardFactionOverride1`, `RewardFactionID2`, `RewardFactionValue2`, `RewardFactionOverride2`, `RewardFactionID3`, `RewardFactionValue3`, `RewardFactionOverride3`, `RewardFactionID4`, `RewardFactionValue4`, `RewardFactionOverride4`, `RewardFactionID5`, `RewardFactionValue5`, `RewardFactionOverride5`, `LogTitle`, `LogDescription`, `QuestDescription`, `AreaDescription`, `QuestCompletionLog`, `RequiredNpcOrGo1`, `RequiredNpcOrGo2`, `RequiredNpcOrGo3`, `RequiredNpcOrGo4`, `RequiredNpcOrGoCount1`, `RequiredNpcOrGoCount2`, `RequiredNpcOrGoCount3`, `RequiredNpcOrGoCount4`, `RequiredItemId1`, `RequiredItemId2`, `RequiredItemId3`, `RequiredItemId4`, `RequiredItemId5`, `RequiredItemId6`, `RequiredItemCount1`, `RequiredItemCount2`, `RequiredItemCount3`, `RequiredItemCount4`, `RequiredItemCount5`, `RequiredItemCount6`, `ObjectiveText1`, `ObjectiveText2`, `ObjectiveText3`, `ObjectiveText4`)
VALUES
(17000, 2, 9, 5, 12, 0, 0, 0, 0, 0, 0, 0, 4, 350, 375, 0, 0, 0, 0, 0, 8, 0, 1397884, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Stolen Supplies', 'Return the Stolen Supplies to Pa Maclure.', 'Damn Defias have come through and ransacked our supplies! What did we ever do to them? Other than feed them before they decided to turn on us of course. Well I won''t stand for it!$B$BYou can find their encampent not far East of here at Jarod''s Landing. Give them hell and then return those supplies and I''ll see you compensated appropriately.', '', 'Return to Pa Maclure at the Maclure Vinyards.', 0, 0, 0, 0, 0, 0, 0, 0, 157000, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, '', '', '', ''),
(17001, 2, 9, 6, 12, 0, 0, 0, 0, 0, 0, 0, 5, 375, 375, 0, 0, 0, 0, 0, 8, 0, 1397885, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Extravagant Order', 'Return 4 Gem Encrusted Spider Silk to Tharynn Bouden.', 'Ah, Hero, may I have a moment? You see, I''ve come across a grand business opportunity and could use your expertise. I''ve gotten recent reports of a spider infestation—disgusting things—in the Jasperlode Mines. Bad news for the Kobolds, but a great opportunity for us!$B$BApparently the spiders produce a very unique, and very valuable type of silk—Gem Encrusted Spider Silk! I''ve hypothesized it has something to do with feasting on the kobold miners located in and around the mine, but it''s just a theory. Anyway, if you could bring me 4 of these Gem Encrusted Spider Silks I could reward you handsomely!', '', 'Return 4 Gem Encrusted Spider Silk to Tharynn Bouden.', 0, 0, 0, 0, 0, 0, 0, 0, 157001, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, '', '', '', ''),
(17002, 2, 10, 7, 12, 0, 0, 0, 0, 0, 0, 0, 5, 300, 187, 0, 0, 0, 0, 0, 8, 0, 157003, 4, 1397885, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'The Master''s Orders', 'Recover 10 Depleted Mana Gems and return to the Tower of Azora.', 'Hi there! I just got assigned to help with a research project, and I think this might be my big chance to show the master I am ready for more responsibility.  We are studying magical depletion, and for that, we need samples of spent arcane matter. I think you can collect them from the Defias Rogue Wizards near Stone Cairn Lake. They''re dangerous, but I heard they''ve been overcasting their spells lately, which makes them perfect for what we need.  Would you be willing to bring back ten of their Depleted Mana Gems? I''ll make sure you''re rewarded. And if this goes well... maybe I''ll get to try casting something bigger than Mage Armor!', '', 'Recover 10 Depleted Mana Gems and return to the Tower of Azora.', 0, 0, 0, 0, 0, 0, 0, 0, 157002, 0, 0, 0, 0, 0, 10, 0, 0, 0, 0, 0, '', '', '', ''),
(17003, 2, 10, 7, 12, 0, 0, 0, 0, 0, 0, 0, 5, 300, 187, 0, 0, 0, 0, 157006, 8, 0, 157005, 1, 1397885, 1, 0, 0, 0, 0, 157006, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Slimy Solution', 'Retrieve 10 Slimy Murloc Spittle Samples and return to the Tower of Azora.', 'Hi! Sorry if this sounds a little strange, but would you be willing to help with a research assignment?  The master has begun to study magical residue in... well, spit. Murloc spit, to be precise. He wants to see how lingering arcane energy reacts in biological material. I know, kind of gross, but fascinating, right?  There are Murloc Lurkers and Foragers near Eastvale Lodging Camp, both north and south of the lake. If you can gather ten samples of their spittle and bring them back, I will make sure you''re properly rewarded. I even prepared a vial for collection.', '', 'Retrieve 10 Slimy Murloc Spittle Samples and return to the Tower of Azora.', 300220, 0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Slimy Murloc Spittle Collected', '', '', ''),
(17004, 2, 10, 7, 12, 0, 0, 0, 0, 0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 8, 0, 1397885, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 157009, 1, 157010, 1, 157011, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Disarming the Gnolls', 'Retrieve 6 Gnoll Blades and 10 Gnoll Axes and return to Guard Thomas at the east Elwynn bridge.', 'As if the murloc infestation weren''t bad enough, we also have gnolls gnawing at our borders. If it''s not one problem, it''s another!$B$BDo the kingdom and the people of Elwynn justice and disarm this threat before it even has a chance to become a real problem. Bring me 6 Gnoll Blades from the gnoll runts and 10 Gnoll Axes from their outrunners.$B$BYou can find their encampment along the North and Northwestern ends of Stone Cairn Lake. If you do this, the Stormwind Army will be sure to reward you accordingly.', '', 'Retrieve 6 Gnoll Blades and 10 Gnoll Axes and retun to Guard Thomas at the east Elwynn bridge.', 0, 0, 0, 0, 0, 0, 0, 0, 157007, 157008, 0, 0, 0, 0, 6, 10, 0, 0, 0, 0, '', '', '', ''),
(17005, 2, 10, 7, 12, 0, 0, 0, 0, 0, 0, 0, 4, 350, 375, 0, 0, 0, 0, 157012, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Last Memento', 'Return the Smudged Note to Imelda in Stormwind.', 'My dearest Imelda. Even though you have moved to Stormwind, I hope you know that no distance could ever keep us apart. My love for you is that of infinite burning suns. You shall forever own a piece of my heart. Never forget.$B$B-Ethan$B$BI should attempt to return this note to Imelda. She will probably want to know how Ethan felt.', '', 'Return the Smudged Note to Imelda in Stormwind.', 0, 0, 0, 0, 0, 0, 0, 0, 157012, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, '', '', '', ''),
(17006, 2, 10, 7, 12, 0, 0, 0, 0, 0, 0, 0, 5, 300, 375, 0, 0, 0, 0, 0, 8, 0, 1397885, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'King''s Justice', 'Slay 8 Defias Bandits and return the Supply Cache to Guard Jacob at Ridgepoint Tower.', 'Hero, I''ve got a problem. Our scouts have reported that a shipment that was en route to Lakeshire was intercepted by the Defias. I need you to retrieve that shipment and give the Defias what''s coming to them.$B$BI don''t believe they''ve yet had time to move the shipment to one of their safehouses. It seems a small band of Defias is guarding the shipment just East of here.$B$BI unfortunately can''t spare the men, but if you kill 8 Defias bandits and return to me with the shipment I will make sure you are compensated appropriately.', '', 'Slay 8 Defias Bandits and return the Supply Cache to Guard Jacob at Ridgepoint Tower.', 116, 0, 0, 0, 8, 0, 0, 0, 157013, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, '', '', '', ''),
(17007, 2, 10, 7, 12, 0, 0, 0, 0, 0, 0, 0, 2, 150, 150, 0, 0, 0, 0, 157013, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Delivery to Lakeshire', 'Deliver the Supply Cache to Magistrate Solomon in Lakeshire.', 'Uh, one moment, Hero. Listen, I hate to ask another favor of you, but I simply can''t spare any men at the moment. Could you be so generous as to deliver this supply cache to Lakeshire.$B$BI think Magistrate Solomon will want to hear of what you did for his people and I''m sure he''ll see you rewarded for your good deeds.', '', 'Deliver the Supply Cache to Magistrate Solomon in Lakeshire.', 0, 0, 0, 0, 0, 0, 0, 0, 157013, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, '', '', '', ''),
(17008, 2, 10, 7, 12, 0, 0, 0, 0, 0, 0, 0, 5, 0, 187, 0, 0, 0, 0, 0, 0, 0, 157015, 5, 1397885, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Reclaim the Harvest', 'Retrieve 8 Mirror Lake Apples and return them to Sergeant De Vries in Westbrook Garrison.', 'It''s a shame, $N. The Defias have overrun the Mirror Lake Orchard and are hijacking the harvest. I remember my mother making her famous Mirror Lake apple pie for me when I was a child. It''s something I wish I could share with the rest of the men here at the garrison.$B$BSay, you look like a well traveled $R. Do you think you could venture to the Mirror Lake Orchard to the northeast of the garrison and gather enough apples there for me to make some pies? I''ll even whip a few up for you! Oh, and feel free to give the Defias our regards.', '', 'Retrieve 8 Mirror Lake Apples and return them to Sergeant De Vries in Westbrook Garrison.', 0, 0, 0, 0, 0, 0, 0, 0, 157014, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, '', '', '', ''),
(100071, 2, 8, 4, 12, 0, 0, 0, 0, 0, 0, 0, 5, 130, 135, 0, 0, 0, 0, 0, 0, 0, 1397885, 1, 500813, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Defias Disruption', 'Thin the ranks of the Defias at the Bandit Bastion, east of Goldshire.', 'Oh, um... are you one of those brave types? The ones who deal with danger and monsters and... all that?  It’s just that things have not been the same here lately. The taproom’s quieter, the roads feel emptier, and even the usual loud sorts have stopped passing through. I keep trying to tell myself it is just a slow season, but... I do not think that''s it.  I heard a rumor, just a rumor, that some of those Defias bandits have built up a camp somewhere east of here. People are saying they''ve been stopping travelers, stealing supplies, or maybe worse. I do not really know for sure, but... maybe if someone went out there and gave them a reason to think twice, things might calm down a bit?  That might bring folks back.', '', 'Return to Melika Isenstrider at Goldshire in Elwynn Forest.', 116, 474, 0, 0, 6, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', ''),
(100073, 2, 8, 5, 12, 0, 0, 0, 0, 0, 0, 0, 5, 0, 90, 0, 0, 0, 0, 0, 0, 0, 1397885, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 500814, 1, 500815, 1, 500816, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Supply Run', 'Recover 4 Stolen Supply Crates from the Bandit Bastion, east of Goldshire.', 'Listen, I have a bit of a follow up for you, if you''re still feeling up to the task.  There’s talk that the Defias have gathered in a proper hideout east of here. It’s a large encampment, far more organized than the usual rabble.  Some local merchants were hit in a raid not long ago. Crates of supplies were taken. Useful things like tools, cloth, even some rare spirits. The sort of goods folks rely on around here.  It’s not without risk, but if someone were to head in and recover what was lost, I know a few people who would be grateful. I would see to it that you''re rewarded for your effort.', '', 'Return to Remy "Two Times" at Goldshire in Elwynn Forest.', 0, 0, 0, 0, 0, 0, 0, 0, 5055564, 0, 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, '', '', '', ''),
(100074, 2, 8, 5, 12, 0, 0, 0, 0, 0, 0, 0, 5, 130, 135, 0, 0, 0, 0, 5055565, 0, 0, 1397884, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'A Betrayal Within', 'Return to Marshal Dughan.', 'You''ve found what looks like a genuine Alliance document, carried by a man dressed as a soldier stationed deep in a Defias outpost. The contents point to collusion between Alliance forces and local bandits.  This should not be happening. Someone loyal needs to see this.  Deliver the document to an appropriate Alliance official. With any luck, they will know what to do with it.', '', 'Return to Marshal Dughan at Goldshire in Elwynn Forest.', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', ''),
(254038, 2, 7, 6, 12, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 0, 8, 0, 375250, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Start Digging', 'Meet Serina at the rendezvous point near Bandits’ Bastion.', 'You don''t seem to be from around here. This place is getting noisy. Too many eyes, too many questions. I don’t like repeating myself, and I don’t trust half the people within earshot.     Meet me near the Bandit''s Bastion, so I can go over the details.', '', 'Report to Agent Serina Vale near The Bandit''s Bastion in Elwynn Forest.', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', ''),
(254041, 2, 8, 5, 12, 0, 0, 0, 0, 0, 0, 0, 4, 175, 202, 0, 0, 0, 0, 0, 8, 0, 1252803, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Report To The General', 'Bring this information to General Marcus Jonathan', 'General Marcus Johnson will want to know about what you found here.  Bring this report to him, you should find him as you enter Stormwind. ', '', 'Report to General Marcus Johnathan at Valley of Heroes in Stormwind.', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', ''),
(254051, 2, 15, 10, 12, 0, 0, 0, 0, 0, 0, 0, 5, 375, 202, 0, 0, 0, 0, 0, 0, 0, 1397885, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Save The Crocs', 'Sinter Wive wants you to retrieve the Crocolisk Egg from the Trogg "Poachers" on the island to the North.', 'I have been watchin’ a nest by the river for days now. One of the crocs finally laid, just one perfect egg. Beautiful thing. Spotted shell, warm to the touch. I was hopin’ to move it somewhere safe, give it a real shot at hatching.  Then those filthy troggs showed up. Grunting and stomping through the brush, one of ‘em grabbed the egg like it was a rock and ran off screamin’.  They do not know what they are holding. They will eat it or smash it or boil it in mud if we do not get it back fast. You are faster than me, and you are not afraid to get dirty.  Bring that egg back. I will owe you one.', '', 'Report to Sinter Wive in Loch Modan.', 0, 0, 0, 0, 0, 0, 0, 0, 1252808, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, '', '', '', ''),
(254095, 2, 7, 6, 12, 0, 0, 0, 0, 0, 0, 0, 5, 0, 202, 0, 0, 0, 0, 354526, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Arcane Insight', 'Deliver the mineral fragment to the Tower of Azora and seek magical insight into its properties and potential use.', 'I don''t recognize this mineral. That worries me. When gold’s involved, people talk. But this? This has everyone quiet.    The mages at the Tower of Azora may be able to tell us more. They deal in things not found on trade routes.    Take the fragment to them. And be careful what you say, I don’t want this spreading before we know what we’re standing in.', '', 'Deliver the Mineral Fragment to a Mage at the Tower of Azora in Elwynn Forest.', 0, 0, 0, 0, 0, 0, 0, 0, 354526, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, '', '', '', ''),
(254098, 2, 8, 6, 12, 0, 0, 0, 0, 0, 0, 0, 5, 0, 202, 0, 0, 0, 0, 354525, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Mixed Reagents', 'Get the Bundle of Samples to Dawn Brightstar.', 'Now that we have both samples, I need them prepared properly and for that, we’ll need Dawn Brightstar.  She handles our volatile components and has a much steadier hand than I do.  Take the spider legs and the filled vial to her inside the tower. Don’t spill anything and don’t let her talk you into trying anything. She gets... curious.', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 354525, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, '', '', '', ''),
(254099, 2, 8, 6, 12, 0, 0, 0, 0, 0, 0, 0, 5, 0, 202, 0, 0, 0, 0, 354524, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Test the Mix', 'Drink the "Enriched" Mineral Water to check for any ill affects.', 'Hmm.. It doesn''t seem to react at all. Think at this dosage level the mineral has no reaction.  You look like a strong and healthy individual mind taking a sip? It is perfectly safe! I think..  Report your findings to Theocritus.', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', '', '', ''),
(254106, 2, 8, 6, 12, 0, 0, 0, 0, 0, 0, 0, 5, 0, 202, 0, 0, 0, 0, 354527, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Enchant the Mineral', 'Bring Mineral Fragment to Kitta Firewind.', 'So amounts found in Jasperlode Mine are definately not enough for anything, even after prolonged exposure and appear to be safe.  But given Defias is mining for it, there must be something more to it. Bring the Mineral Fragment to Kitta Firewind inside Tower of Azora to see if she can enchant it for us to see if mineral reacts in any way to magic.', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 354527, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, '', '', '', ''),
(254107, 2, 9, 6, 12, 0, 0, 0, 0, 0, 0, 0, 5, 0, 202, 0, 0, 0, 0, 354047, 0, 0, 375250, 100, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Unexpected Results', 'Test the Enchanted Mineral Fragment.', 'Be very, very careful while handling this. Mineral appears to be highly unstable when exposed to magic.   We need to test its full potential.  Go outside of Tower of Azora and test it on local wild life.', '', 'Report your findings back to Agent Serina Vale at Goldshire in Elwynn Forest.', 996121, 0, 0, 0, 5, 0, 0, 0, 354047, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 'Test Minerals Potency', '', '', ''),
(254108, 2, 9, 6, 12, 0, 0, 0, 0, 0, 0, 0, 5, 0, 202, 0, 0, 0, 0, 0, 0, 0, 375250, 250, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 72, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Final Dig', 'Find Defias mole inside Lion''s Pride Inn.', 'While you were out looking into the uses for the mineral. I managed to put back together who might be the mole for Defias in Lion''s Pride Inn from all the Charred Documents we recovered earlier.  Based on said documents it should be someone working in the Inn, someone who has extended history with them.   We just need to question few people inside and see who slips up.', '', 'Report back to Agent Serina Vale at Goldshire in Elwynn Forest.', 996120, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Find the Mole', '', '', '')
ON DUPLICATE KEY UPDATE `QuestType` = VALUES(`QuestType`), `QuestLevel` = VALUES(`QuestLevel`), `MinLevel` = VALUES(`MinLevel`), `QuestSortID` = VALUES(`QuestSortID`), `QuestInfoID` = VALUES(`QuestInfoID`), `SuggestedGroupNum` = VALUES(`SuggestedGroupNum`), `RequiredFactionId1` = VALUES(`RequiredFactionId1`), `RequiredFactionId2` = VALUES(`RequiredFactionId2`), `RequiredFactionValue1` = VALUES(`RequiredFactionValue1`), `RequiredFactionValue2` = VALUES(`RequiredFactionValue2`), `RewardNextQuest` = VALUES(`RewardNextQuest`), `RewardXPDifficulty` = VALUES(`RewardXPDifficulty`), `RewardMoney` = VALUES(`RewardMoney`), `RewardMoneyDifficulty` = VALUES(`RewardMoneyDifficulty`), `RewardDisplaySpell` = VALUES(`RewardDisplaySpell`), `RewardSpell` = VALUES(`RewardSpell`), `RewardHonor` = VALUES(`RewardHonor`), `RewardKillHonor` = VALUES(`RewardKillHonor`), `StartItem` = VALUES(`StartItem`), `Flags` = VALUES(`Flags`), `RequiredPlayerKills` = VALUES(`RequiredPlayerKills`), `RewardItem1` = VALUES(`RewardItem1`), `RewardAmount1` = VALUES(`RewardAmount1`), `RewardItem2` = VALUES(`RewardItem2`), `RewardAmount2` = VALUES(`RewardAmount2`), `RewardItem3` = VALUES(`RewardItem3`), `RewardAmount3` = VALUES(`RewardAmount3`), `RewardItem4` = VALUES(`RewardItem4`), `RewardAmount4` = VALUES(`RewardAmount4`), `ItemDrop1` = VALUES(`ItemDrop1`), `ItemDropQuantity1` = VALUES(`ItemDropQuantity1`), `ItemDrop2` = VALUES(`ItemDrop2`), `ItemDropQuantity2` = VALUES(`ItemDropQuantity2`), `ItemDrop3` = VALUES(`ItemDrop3`), `ItemDropQuantity3` = VALUES(`ItemDropQuantity3`), `ItemDrop4` = VALUES(`ItemDrop4`), `ItemDropQuantity4` = VALUES(`ItemDropQuantity4`), `RewardChoiceItemID1` = VALUES(`RewardChoiceItemID1`), `RewardChoiceItemQuantity1` = VALUES(`RewardChoiceItemQuantity1`), `RewardChoiceItemID2` = VALUES(`RewardChoiceItemID2`), `RewardChoiceItemQuantity2` = VALUES(`RewardChoiceItemQuantity2`), `RewardChoiceItemID3` = VALUES(`RewardChoiceItemID3`), `RewardChoiceItemQuantity3` = VALUES(`RewardChoiceItemQuantity3`), `RewardChoiceItemID4` = VALUES(`RewardChoiceItemID4`), `RewardChoiceItemQuantity4` = VALUES(`RewardChoiceItemQuantity4`), `RewardChoiceItemID5` = VALUES(`RewardChoiceItemID5`), `RewardChoiceItemQuantity5` = VALUES(`RewardChoiceItemQuantity5`), `RewardChoiceItemID6` = VALUES(`RewardChoiceItemID6`), `RewardChoiceItemQuantity6` = VALUES(`RewardChoiceItemQuantity6`), `POIContinent` = VALUES(`POIContinent`), `POIx` = VALUES(`POIx`), `POIy` = VALUES(`POIy`), `POIPriority` = VALUES(`POIPriority`), `RewardTitle` = VALUES(`RewardTitle`), `RewardTalents` = VALUES(`RewardTalents`), `RewardArenaPoints` = VALUES(`RewardArenaPoints`), `RewardFactionID1` = VALUES(`RewardFactionID1`), `RewardFactionValue1` = VALUES(`RewardFactionValue1`), `RewardFactionOverride1` = VALUES(`RewardFactionOverride1`), `RewardFactionID2` = VALUES(`RewardFactionID2`), `RewardFactionValue2` = VALUES(`RewardFactionValue2`), `RewardFactionOverride2` = VALUES(`RewardFactionOverride2`), `RewardFactionID3` = VALUES(`RewardFactionID3`), `RewardFactionValue3` = VALUES(`RewardFactionValue3`), `RewardFactionOverride3` = VALUES(`RewardFactionOverride3`), `RewardFactionID4` = VALUES(`RewardFactionID4`), `RewardFactionValue4` = VALUES(`RewardFactionValue4`), `RewardFactionOverride4` = VALUES(`RewardFactionOverride4`), `RewardFactionID5` = VALUES(`RewardFactionID5`), `RewardFactionValue5` = VALUES(`RewardFactionValue5`), `RewardFactionOverride5` = VALUES(`RewardFactionOverride5`), `LogTitle` = VALUES(`LogTitle`), `LogDescription` = VALUES(`LogDescription`), `QuestDescription` = VALUES(`QuestDescription`), `AreaDescription` = VALUES(`AreaDescription`), `QuestCompletionLog` = VALUES(`QuestCompletionLog`), `RequiredNpcOrGo1` = VALUES(`RequiredNpcOrGo1`), `RequiredNpcOrGo2` = VALUES(`RequiredNpcOrGo2`), `RequiredNpcOrGo3` = VALUES(`RequiredNpcOrGo3`), `RequiredNpcOrGo4` = VALUES(`RequiredNpcOrGo4`), `RequiredNpcOrGoCount1` = VALUES(`RequiredNpcOrGoCount1`), `RequiredNpcOrGoCount2` = VALUES(`RequiredNpcOrGoCount2`), `RequiredNpcOrGoCount3` = VALUES(`RequiredNpcOrGoCount3`), `RequiredNpcOrGoCount4` = VALUES(`RequiredNpcOrGoCount4`), `RequiredItemId1` = VALUES(`RequiredItemId1`), `RequiredItemId2` = VALUES(`RequiredItemId2`), `RequiredItemId3` = VALUES(`RequiredItemId3`), `RequiredItemId4` = VALUES(`RequiredItemId4`), `RequiredItemId5` = VALUES(`RequiredItemId5`), `RequiredItemId6` = VALUES(`RequiredItemId6`), `RequiredItemCount1` = VALUES(`RequiredItemCount1`), `RequiredItemCount2` = VALUES(`RequiredItemCount2`), `RequiredItemCount3` = VALUES(`RequiredItemCount3`), `RequiredItemCount4` = VALUES(`RequiredItemCount4`), `RequiredItemCount5` = VALUES(`RequiredItemCount5`), `RequiredItemCount6` = VALUES(`RequiredItemCount6`), `ObjectiveText1` = VALUES(`ObjectiveText1`), `ObjectiveText2` = VALUES(`ObjectiveText2`), `ObjectiveText3` = VALUES(`ObjectiveText3`), `ObjectiveText4` = VALUES(`ObjectiveText4`);

DELETE FROM `quest_template_addon` WHERE `ID` IN (17000, 17001, 17002, 17003, 17004, 17005, 17006, 17007, 17008, 100071, 100073, 100074, 254038, 254041, 254051, 254095, 254098, 254099, 254106, 254107, 254108);
INSERT INTO `quest_template_addon` (`ID`, `MaxLevel`, `AllowableClasses`, `PrevQuestID`, `ProvidedItemCount`, `SpecialFlags`)
VALUES
(17000, 0, 0, 0, 0, 0),
(17001, 0, 0, 0, 0, 0),
(17002, 0, 0, 0, 0, 0),
(17003, 0, 0, 0, 1, 0),
(17004, 0, 0, 0, 0, 0),
(17005, 0, 0, 0, 1, 0),
(17006, 0, 0, 0, 0, 0),
(17007, 0, 0, 17006, 1, 0),
(17008, 0, 0, 0, 0, 0),
(100071, 0, 0, 0, 0, 0),
(100073, 0, 0, 0, 0, 0),
(100074, 0, 0, 0, 1, 0),
(254038, 0, 0, 0, 0, 0),
(254041, 0, 0, 254038, 0, 0),
(254051, 0, 0, 0, 0, 0),
(254095, 0, 0, 254038, 1, 0),
(254098, 0, 0, 254095, 1, 0),
(254099, 0, 0, 254098, 1, 2),
(254106, 0, 0, 254099, 1, 0),
(254107, 0, 0, 254106, 1, 0),
(254108, 0, 0, 254107, 0, 0);

DELETE FROM `quest_offer_reward` WHERE `ID` IN (17000, 17001, 17002, 17003, 17004, 17005, 17006, 17007, 17008, 100071, 100073, 100074, 254038, 254041, 254051, 254095, 254098, 254099, 254106, 254107, 254108);
INSERT INTO `quest_offer_reward` (`ID`, `RewardText`)
VALUES
(17000, ''),
(17001, ''),
(17002, ''),
(17003, ''),
(17004, ''),
(17005, ''),
(17006, ''),
(17007, ''),
(17008, ''),
(100071, ''),
(100073, ''),
(100074, ''),
(254038, ''),
(254041, ''),
(254051, ''),
(254095, ''),
(254098, ''),
(254099, ''),
(254106, ''),
(254107, ''),
(254108, '');

DELETE FROM `quest_request_items` WHERE `ID` IN (17000, 17001, 17002, 17003, 17004, 17005, 17006, 17007, 17008, 100071, 100073, 100074, 254038, 254041, 254051, 254095, 254098, 254099, 254106, 254107, 254108);
INSERT INTO `quest_request_items` (`ID`, `CompletionText`)
VALUES
(17000, 'Return to Pa Maclure at the Maclure Vinyards.'),
(17001, 'Return 4 Gem Encrusted Spider Silk to Tharynn Bouden.'),
(17002, 'Recover 10 Depleted Mana Gems and return to the Tower of Azora.'),
(17003, 'Retrieve 10 Slimy Murloc Spittle Samples and return to the Tower of Azora.'),
(17004, 'Retrieve 6 Gnoll Blades and 10 Gnoll Axes and retun to Guard Thomas at the east Elwynn bridge.'),
(17005, 'Return the Smudged Note to Imelda in Stormwind.'),
(17006, 'Slay 8 Defias Bandits and return the Supply Cache to Guard Jacob at Ridgepoint Tower.'),
(17007, 'Deliver the Supply Cache to Magistrate Solomon in Lakeshire.'),
(17008, 'Retrieve 8 Mirror Lake Apples and return them to Sergeant De Vries in Westbrook Garrison.'),
(100071, 'Return to Melika Isenstrider at Goldshire in Elwynn Forest.'),
(100073, 'Return to Remy "Two Times" at Goldshire in Elwynn Forest.'),
(100074, 'Return to Marshal Dughan at Goldshire in Elwynn Forest.'),
(254038, 'Report to Agent Serina Vale near The Bandit''s Bastion in Elwynn Forest.'),
(254041, 'Report to General Marcus Johnathan at Valley of Heroes in Stormwind.'),
(254051, 'Report to Sinter Wive in Loch Modan.'),
(254095, 'Deliver the Mineral Fragment to a Mage at the Tower of Azora in Elwynn Forest.'),
(254098, ''),
(254099, ''),
(254106, ''),
(254107, 'Report your findings back to Agent Serina Vale at Goldshire in Elwynn Forest.'),
(254108, 'Report back to Agent Serina Vale at Goldshire in Elwynn Forest.');

-- ---------------------------------------------------------------------------
-- 4. Who offers and who takes them back
-- ---------------------------------------------------------------------------
DELETE FROM `creature_queststarter` WHERE `quest` IN (17000, 17001, 17002, 17003, 17004, 17005, 17006, 17007, 17008, 100071, 100073, 100074, 254038, 254041, 254051, 254095, 254098, 254099, 254106, 254107, 254108);
INSERT INTO `creature_queststarter` (`id`, `quest`)
VALUES
(250, 17000),
(66, 17001),
(900017, 17002),
(900017, 17003),
(261, 17004),
(157000, 17006),
(157000, 17007),
(955, 17008),
(6778, 100071),
(241, 100073),
(996114, 254038),
(996115, 254041),
(764542, 254051),
(996115, 254095),
(313, 254098),
(958, 254099),
(313, 254106),
(11072, 254107),
(996114, 254108);

DELETE FROM `gameobject_queststarter` WHERE `quest` = 17005;
INSERT INTO `gameobject_queststarter` (`id`, `quest`)
VALUES
(96001, 17005);

DELETE FROM `creature_questender` WHERE `quest` IN (17000, 17001, 17002, 17003, 17004, 17005, 17006, 17007, 17008, 100071, 100073, 100074, 254038, 254041, 254051, 254095, 254098, 254099, 254106, 254107, 254108);
INSERT INTO `creature_questender` (`id`, `quest`)
VALUES
(250, 17000),
(66, 17001),
(900017, 17002),
(900017, 17003),
(261, 17004),
(11916, 17005),
(157000, 17006),
(344, 17007),
(955, 17008),
(6778, 100071),
(241, 100073),
(240, 100074),
(996115, 254038),
(466, 254041),
(764542, 254051),
(313, 254095),
(958, 254098),
(313, 254099),
(11072, 254106),
(996114, 254107),
(996114, 254108);

-- ---------------------------------------------------------------------------
-- 5. Loot
-- ---------------------------------------------------------------------------
DELETE FROM `creature_loot_template` WHERE (`Entry`, `Item`) IN ((43, 157001), (471, 157001), (474, 157002), (97, 157007), (478, 157008), (996119, 5055565));
INSERT INTO `creature_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`, `Comment`)
VALUES
(43, 157001, 0, 50, 1, 1, 0, 1, 1, 'Mine Spider - Gem Encrusted Spider Silk (creaturecache questItem1)'),
(471, 157001, 0, 100, 1, 1, 0, 1, 1, 'Mother Fang - Gem Encrusted Spider Silk (creaturecache questItem1)'),
(474, 157002, 0, 66, 1, 1, 0, 1, 1, 'Defias Rogue Wizard - Depleted Mana Gem (creaturecache questItem3)'),
(97, 157007, 0, 40, 1, 1, 0, 1, 1, 'Riverpaw Runt - Gnoll Sword (creaturecache questItem2)'),
(478, 157008, 0, 40, 1, 1, 0, 1, 1, 'Riverpaw Outrunner - Gnoll Axe (creaturecache questItem2)'),
(996119, 5055565, 0, 100, 0, 1, 0, 1, 1, 'Defias Sentry - Tattered Orders (inferred carrier)');

DELETE FROM `creature_questitem` WHERE (`CreatureEntry`, `Idx`) IN ((43, 0), (471, 0), (474, 2), (97, 1), (478, 1));
INSERT INTO `creature_questitem` (`CreatureEntry`, `Idx`, `ItemId`)
VALUES
(43, 0, 157001),
(471, 0, 157001),
(474, 2, 157002),
(97, 1, 157007),
(478, 1, 157008);

DELETE FROM `gameobject_loot_template` WHERE `Entry` IN (25428, 96000, 96002, 96003, 5055563);
INSERT INTO `gameobject_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`, `Comment`)
VALUES
(96000, 157000, 0, 100, 1, 1, 0, 1, 1, 'CoA Elwynn: quest item from Maclure Supplies'),
(96002, 157013, 0, 100, 1, 1, 0, 1, 1, 'CoA Elwynn: quest item from Supply Cache'),
(96003, 157014, 0, 100, 1, 1, 0, 1, 1, 'CoA Elwynn: quest item from Mirror Lake Harvest'),
(5055563, 5055564, 0, 100, 1, 1, 0, 1, 1, 'CoA Elwynn: quest item from Stolen Goods'),
(25428, 1252808, 0, 100, 1, 1, 0, 1, 1, 'CoA Elwynn: quest item from Crocolisk Egg');

DELETE FROM `gameobject_questitem` WHERE `GameObjectEntry` IN (25428, 96000, 96002, 96003, 5055563);
INSERT INTO `gameobject_questitem` (`GameObjectEntry`, `Idx`, `ItemId`)
VALUES
(96000, 0, 157000),
(96002, 0, 157013),
(96003, 0, 157014),
(5055563, 0, 5055564),
(25428, 0, 1252808);

-- ---------------------------------------------------------------------------
-- 6. Spawns
-- ---------------------------------------------------------------------------
DELETE FROM `creature` WHERE `guid` IN (9002200, 9002201, 9002202, 9002203, 9002204, 9002205, 9002206, 9002207, 9002208, 9002209, 9002210, 9002211, 9002212, 9002213, 9002214, 9002215, 9002216, 9002217, 9002218);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `unit_flags`, `dynamicflags`, `ScriptName`, `VerifiedBuild`, `CreateObject`, `Comment`)
VALUES
(9002200, 157000, 0, 0, 0, 1, 1, 0, -9761.05, -1373.04, 59.11, 0.97, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Elwynn: inferred placement, Ridgepoint Tower, between the two guards on the north-west approach'),
(9002201, 900017, 0, 0, 0, 1, 1, 0, -9561, -709.5, 64.7386, 4.84, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Elwynn: inferred placement, Tower of Azora ground floor, beside the Servants of Azora'),
(9002202, 996114, 0, 0, 0, 1, 1, 0, -9458.5, -18, 56.882, 3.1, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Elwynn: inferred placement, Goldshire, outside between the moved Lion''s Pride Inn and the orchard fence'),
(9002203, 996115, 0, 0, 0, 1, 1, 0, -9694, -405, 51.1, 3.53, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Elwynn: inferred placement, rendezvous on the north rim of the Bandit''s Bastion'),
(9002204, 764542, 0, 0, 0, 1, 1, 0, -5206, -3518, 303.9, 5.5, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Elwynn: inferred placement, Loch Modan west shore, beside Sinter Wive''s Rope'),
(9002205, 996119, 0, 0, 0, 1, 1, 1, -9790, -484, 30.6, 1.794, 180, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Elwynn: inferred placement, Bandit''s Bastion farm building, carries the Tattered Orders'),
(9002206, 116, 0, 0, 0, 1, 1, 1, -9760, -430, 33.04, 3.882, 180, 5, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Elwynn: inferred placement, Bandit''s Bastion camp'),
(9002207, 116, 0, 0, 0, 1, 1, 1, -9790, -445, 30.07, 4.426, 180, 5, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Elwynn: inferred placement, Bandit''s Bastion camp'),
(9002208, 116, 0, 0, 0, 1, 1, 1, -9803, -445, 29.92, 5.152, 180, 5, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Elwynn: inferred placement, Bandit''s Bastion camp'),
(9002209, 116, 0, 0, 0, 1, 1, 1, -9830, -490, 29.71, 0.675, 180, 5, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Elwynn: inferred placement, Bandit''s Bastion camp'),
(9002210, 116, 0, 0, 0, 1, 1, 1, -9812, -492, 30.91, 1.055, 180, 5, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Elwynn: inferred placement, Bandit''s Bastion camp'),
(9002211, 116, 0, 0, 0, 1, 1, 1, -9795, -515, 31.2, 1.571, 180, 5, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Elwynn: inferred placement, Bandit''s Bastion camp'),
(9002212, 116, 0, 0, 0, 1, 1, 1, -9840, -455, 30.86, 6.129, 180, 5, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Elwynn: inferred placement, Bandit''s Bastion camp'),
(9002213, 116, 0, 0, 0, 1, 1, 1, -9745.8, -426.5, 44.49, 0.346, 180, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Elwynn: inferred placement, Bandit''s Bastion gate lookout'),
(9002214, 474, 0, 0, 0, 1, 1, 1, -9786, -451, 30.53, 4.027, 180, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Elwynn: inferred placement, Bandit''s Bastion camp'),
(9002215, 474, 0, 0, 0, 1, 1, 1, -9796, -466, 29.05, 1.326, 180, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Elwynn: inferred placement, Bandit''s Bastion camp'),
(9002216, 474, 0, 0, 0, 1, 1, 1, -9790, -510, 32.16, 1.675, 180, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Elwynn: inferred placement, Bandit''s Bastion camp'),
(9002217, 474, 0, 0, 0, 1, 1, 1, -9838, -480, 30.26, 0.396, 180, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Elwynn: inferred placement, Bandit''s Bastion camp'),
(9002218, 474, 0, 0, 0, 1, 1, 1, -9765, -437, 32.33, 3.836, 180, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Elwynn: inferred placement, Bandit''s Bastion camp');

DELETE FROM `gameobject` WHERE `guid` IN (6911200, 6911201, 6911202, 6911203, 6911204, 6911205, 6911206, 6911207, 6911208, 6911209, 6911210, 6911211, 6911212, 6911213, 6911214, 6911215, 6911216, 6911217, 6911218, 6911219, 6911220, 6911221, 6911222);
INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `ScriptName`, `Comment`)
VALUES
(6911200, 96000, 0, 0, 0, 1, 1, -9949.9, -132.053, 25.369, 0, 0, 0, 0, 1, 2, 100, 1, '', 'CoA Elwynn: observed atlas position, Jerod''s Landing'),
(6911201, 96002, 0, 0, 0, 1, 1, -9767, -1560.54, 41.485, 0, 0, 0, 0, 1, 2, 100, 1, '', 'CoA Elwynn: observed atlas position, Defias camp east of Ridgepoint Tower'),
(6911202, 96003, 0, 0, 0, 1, 1, -9482.9, 441.862, 53.107, 0, 0, 0, 0, 1, 120, 100, 1, '', 'CoA Elwynn: observed atlas position, Mirror Lake Orchard'),
(6911203, 96003, 0, 0, 0, 1, 1, -9491, 567, 52.79, 0, 0, 0, 0, 1, 120, 100, 1, '', 'CoA Elwynn: inferred orchard node, Mirror Lake Orchard'),
(6911204, 96003, 0, 0, 0, 1, 1, -9440, 507, 55.49, 0, 0, 0, 0, 1, 120, 100, 1, '', 'CoA Elwynn: inferred orchard node, Mirror Lake Orchard'),
(6911205, 96003, 0, 0, 0, 1, 1, -9527, 501, 51.02, 0, 0, 0, 0, 1, 120, 100, 1, '', 'CoA Elwynn: inferred orchard node, Mirror Lake Orchard'),
(6911206, 96003, 0, 0, 0, 1, 1, -9527, 402, 51.88, 0, 0, 0, 0, 1, 120, 100, 1, '', 'CoA Elwynn: inferred orchard node, Mirror Lake Orchard'),
(6911207, 96003, 0, 0, 0, 1, 1, -9482, 489, 51.74, 0, 0, 0, 0, 1, 120, 100, 1, '', 'CoA Elwynn: inferred orchard node, Mirror Lake Orchard'),
(6911208, 96003, 0, 0, 0, 1, 1, -9527, 453, 53.2, 0, 0, 0, 0, 1, 120, 100, 1, '', 'CoA Elwynn: inferred orchard node, Mirror Lake Orchard'),
(6911209, 96003, 0, 0, 0, 1, 1, -9476, 402, 51.85, 0, 0, 0, 0, 1, 120, 100, 1, '', 'CoA Elwynn: inferred orchard node, Mirror Lake Orchard'),
(6911210, 96003, 0, 0, 0, 1, 1, -9452, 468, 52.61, 0, 0, 0, 0, 1, 120, 100, 1, '', 'CoA Elwynn: inferred orchard node, Mirror Lake Orchard'),
(6911211, 96003, 0, 0, 0, 1, 1, -9500, 525, 54.5, 0, 0, 0, 0, 1, 120, 100, 1, '', 'CoA Elwynn: inferred orchard node, Mirror Lake Orchard'),
(6911212, 96003, 0, 0, 0, 1, 1, -9464, 531, 54.83, 0, 0, 0, 0, 1, 120, 100, 1, '', 'CoA Elwynn: inferred orchard node, Mirror Lake Orchard'),
(6911213, 96003, 0, 0, 0, 1, 1, -9509, 426, 52.99, 0, 0, 0, 0, 1, 120, 100, 1, '', 'CoA Elwynn: inferred orchard node, Mirror Lake Orchard'),
(6911214, 5055563, 0, 0, 0, 1, 1, -9757.68, -442.04, 32.669, 3.633, 0, 0, 0.969966, -0.243239, 120, 100, 1, '', 'CoA Elwynn: observed atlas position, Bandit''s Bastion'),
(6911215, 5055563, 0, 0, 0, 1, 1, -9798, -472, 28.9, 1.279, 0, 0, 0.596794, 0.802394, 120, 100, 1, '', 'CoA Elwynn: inferred crate beside the camp''s stores, Bandit''s Bastion'),
(6911216, 5055563, 0, 0, 0, 1, 1, -9817.5, -441, 29.71, 5.532, 0, 0, 0.366824, -0.93029, 120, 100, 1, '', 'CoA Elwynn: inferred crate beside the camp''s stores, Bandit''s Bastion'),
(6911217, 5055563, 0, 0, 0, 1, 1, -9800.5, -452, 29.52, 5.215, 0, 0, 0.50906, -0.860731, 120, 100, 1, '', 'CoA Elwynn: inferred crate beside the camp''s stores, Bandit''s Bastion'),
(6911218, 5055563, 0, 0, 0, 1, 1, -9779, -508, 32.26, 1.906, 0, 0, 0.815157, 0.57924, 120, 100, 1, '', 'CoA Elwynn: inferred crate beside the camp''s stores, Bandit''s Bastion'),
(6911219, 5055563, 0, 0, 0, 1, 1, -9788, -480, 30.6, 1.942, 0, 0, 0.825451, 0.564474, 120, 100, 1, '', 'CoA Elwynn: inferred crate beside the camp''s stores, Bandit''s Bastion'),
(6911220, 5055563, 0, 0, 0, 1, 1, -9791.5, -434.5, 29.59, 4.586, 0, 0, 0.750351, -0.66104, 120, 100, 1, '', 'CoA Elwynn: inferred crate beside the camp''s stores, Bandit''s Bastion'),
(6911221, 5055563, 0, 0, 0, 1, 1, -9808, -436, 29.85, 5.176, 0, 0, 0.525747, -0.850641, 120, 100, 1, '', 'CoA Elwynn: inferred crate beside the camp''s stores, Bandit''s Bastion'),
(6911222, 25428, 0, 0, 0, 1, 1, -4983.2, -3483.83, 305.486, 0, 0, 0, 0, 1, 120, 100, 1, '', 'CoA Elwynn: observed atlas position, trogg island in north Loch Modan');

-- ---------------------------------------------------------------------------
-- 7. Scripts
-- ---------------------------------------------------------------------------
-- The stock blocks of the murlocs, the beasts and Innkeeper Farley are rewritten whole: their
-- existing rows are kept verbatim and the quest rows are added after them.
DELETE FROM `smart_scripts` WHERE `entryorguid` IN (46, 118, 295, 524, 732, 822, 1922) AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`)
VALUES
(46, 0, 0, 0, 2, 0, 100, 1, 0, 40, 0, 0, 0, 0, 11, 3368, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Murloc Forager - Between 0-40% Health - Cast ''Drink Minor Potion'' (Phase 1)'),
(46, 0, 1, 2, 8, 0, 100, 0, 966240, 0, 0, 0, 0, 0, 33, 300220, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Murloc Forager - On Spellhit Collect Slimy Murloc Spittle - Quest Credit'),
(46, 0, 2, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Murloc Forager - Linked - Despawn the milked corpse'),
(118, 0, 0, 0, 8, 0, 100, 0, 350249, 0, 600000, 600000, 0, 0, 33, 996121, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Prowler - On Spellhit Enchanted Mineral - Credit testing the mineral, once per beast'),
(295, 0, 0, 1, 62, 0, 100, 512, 1291, 0, 0, 0, 0, 0, 72, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Innkeeper Farley - On Gossip Option 0 Selected - Close Gossip'),
(295, 0, 1, 0, 61, 0, 100, 512, 0, 0, 0, 0, 0, 0, 134, 24751, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Innkeeper Farley - On Gossip Option 0 Selected - Invoker Cast ''Trick or Treat'''),
(295, 0, 2, 3, 62, 0, 100, 0, 1291, 4, 0, 0, 0, 0, 33, 996120, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Innkeeper Farley - On Gossip Option 4 Selected - Credit finding the mole'),
(295, 0, 3, 4, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 2, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Innkeeper Farley - Linked - Say Line 2'),
(295, 0, 4, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 72, 0, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Innkeeper Farley - Linked - Close Gossip'),
(524, 0, 0, 0, 4, 0, 10, 1, 0, 0, 0, 0, 0, 0, 11, 6268, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Rockhide Boar - On Aggro - Cast ''Rushing Charge'''),
(524, 0, 1, 0, 8, 0, 100, 0, 350249, 0, 600000, 600000, 0, 0, 33, 996121, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Rockhide Boar - On Spellhit Enchanted Mineral - Credit testing the mineral, once per beast'),
(732, 0, 0, 0, 67, 0, 100, 0, 3900, 6900, 3900, 6900, 0, 5, 11, 7159, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Murloc Lurker - On Behind Target - Cast ''Backstab'' (No Repeat)'),
(732, 0, 1, 2, 8, 0, 100, 0, 966240, 0, 0, 0, 0, 0, 33, 300220, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Murloc Lurker - On Spellhit Collect Slimy Murloc Spittle - Quest Credit'),
(732, 0, 2, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Murloc Lurker - Linked - Despawn the milked corpse'),
(822, 0, 0, 0, 8, 0, 100, 0, 350249, 0, 600000, 600000, 0, 0, 33, 996121, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Young Forest Bear - On Spellhit Enchanted Mineral - Credit testing the mineral, once per beast'),
(1922, 0, 0, 1, 1, 0, 100, 0, 120000, 600000, 120000, 600000, 0, 0, 4, 1018, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Gray Forest Wolf - Out of Combat - Play Sound 1018'),
(1922, 0, 1, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 5, 393, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Gray Forest Wolf - Out of Combat - Play Emote 393'),
(1922, 0, 2, 0, 8, 0, 100, 0, 350249, 0, 600000, 600000, 0, 0, 33, 996121, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Gray Forest Wolf - On Spellhit Enchanted Mineral - Credit testing the mineral, once per beast');

DELETE FROM `creature_text` WHERE `CreatureID` = 295 AND `GroupID` = 2;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Language`, `Probability`, `comment`)
VALUES
(295, 2, 0, 'Defias? Never had any dealings with... well, not since the old masons'' guild days. Can I get you anything else?', 12, 0, 100, 'Innkeeper Farley - gives himself away (authored, no source)');

DELETE FROM `gossip_menu_option` WHERE `MenuID` = 1291 AND `OptionID` = 4;
INSERT INTO `gossip_menu_option` (`MenuID`, `OptionID`, `OptionIcon`, `OptionText`, `OptionBroadcastTextID`, `OptionType`, `OptionNpcFlag`, `ActionMenuID`, `ActionPoiID`, `BoxCoded`, `BoxMoney`, `BoxText`, `BoxBroadcastTextID`)
VALUES
(1291, 4, 0, 'What do you know about the Defias?', 0, 1, 1, 0, 0, 0, 0, '', 0);

DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 15 AND `SourceGroup` = 1291 AND `SourceEntry` = 4;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `ErrorType`, `ErrorTextId`, `ScriptName`, `Comment`)
VALUES
(15, 1291, 4, 0, 0, 9, 0, 254108, 0, 0, 0, 0, 0, '', 'Innkeeper Farley - mole question only while Final Dig is taken');
