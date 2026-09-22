-- Conquest of Azeroth added eight quests to Northshire that this world has never carried. They run from
-- the abbey down into a Secret Inquisitorial Dungeon and up above the waterfall into Shadewell Spring,
-- and none of their quests, NPCs, objects or items exist here. This restores them.
--
-- WHERE EACH VALUE COMES FROM
--   quests, creatures, objects, items  the realm's own client cache, dataset release
--     data-cache-945cd3b8b0ce4a496586, cachedata/by-mode/conquest-of-azeroth/*.tsv.gz, fetched and
--     checksum-verified by apps/coa-world-content/archive.py. Names, models, health modifiers, quest
--     text, objectives, required targets, required items and rewards are copied, not invented.
--   object positions  the archive atlas addon-sighting layer, which carries real world coordinates.
--     Each of the four placed on terrain sits 1.2 to 5.5 yards above the heightmap, as an object should;
--     the Abbess's Staff sits 167 yards below it, which is how we know it is inside the dungeon interior.
--   creature positions  INFERRED. No source holds them. They are placed on the heightmap inside the
--     sub-area the quest text names, using the CoA area ids the extracted terrain carries: Shadewell
--     Spring 10305 for the murlocs and the estate, the dungeon box for the Censor, the abbey for the
--     Spadas. Every inferred spawn is marked in its Comment column.
--   quest givers  INFERRED except one. Quest 1660000 names them itself: "Speak with Seminarian Moroi,
--     brother of Bianca Spada", so Bianca starts it and Moroi ends it. The rest are assigned to Moroi
--     because he is the seminarian the storyline follows. No source records a giver for any of them.
--
-- NOT A CHAIN. NextQuestInChain is 0 on all eight in the cache and none carries a POI, so no PrevQuestID,
-- NextQuestID or breadcrumb is written. They are offered together.
--
-- The Wayward Theologian is the questline miniboss. The cache carries the fight as four entries: 161713
-- the elite at 5.76x health, 161904 an elite duplicate at 1.0x, and 161908/161909 invisible markers of the
-- kind CoA uses for zone effects. That matches the reported fight, where the boss splits into low-health
-- mirror images around the ruined estate and cannot be harmed until they are cleared. The split is scripted
-- below from that shape. The spells it casts are in no source we hold and are not invented here.
--
-- Spawn guid blocks are fresh: creature 9001000+, gameobject 6910000+. Everything below 6901527 is spoken
-- for, and the Worldforged module deletes 6900001-6901526 outright.

-- ---------------------------------------------------------------------------
-- 1. Items
-- ---------------------------------------------------------------------------
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `name`, `displayid`, `Quality`, `Flags`, `BuyPrice`, `SellPrice`, `InventoryType`, `ItemLevel`, `RequiredLevel`, `maxcount`, `stackable`, `bonding`, `description`)
VALUES
(559130, 0, 0, 'Lost Page I', 138854, 1, 2048, 0, 0, 0, 1, 0, 1, 1, 4, ''),
(559131, 0, 0, 'Lost Page II', 138854, 1, 2048, 0, 0, 0, 1, 0, 1, 1, 4, ''),
(559160, 0, 0, 'Prophet''s Oracular Orb', 137929, 1, 2048, 0, 0, 0, 1, 0, 3, 3, 4, '<The blind surface of the eye shimmers with visions of an uncertain future: shadows of demons, a foreign sky, a frozen wasteland… and fire. A single ember, igniting a blaze that sets the world aflame.>'),
(559176, 2, 7, 'Tempered Steel Sword', 15733, 2, 0, 11503, 55, 13, 7, 3, 1, 1, 1, ''),
(559182, 4, 1, 'Cloak of the Seven Virtues', 38432, 3, 0, 1534, 30, 16, 3, 3, 0, 1, 1, '')
ON DUPLICATE KEY UPDATE `class` = VALUES(`class`), `subclass` = VALUES(`subclass`), `name` = VALUES(`name`), `displayid` = VALUES(`displayid`), `Quality` = VALUES(`Quality`), `Flags` = VALUES(`Flags`), `BuyPrice` = VALUES(`BuyPrice`), `SellPrice` = VALUES(`SellPrice`), `InventoryType` = VALUES(`InventoryType`), `ItemLevel` = VALUES(`ItemLevel`), `RequiredLevel` = VALUES(`RequiredLevel`), `maxcount` = VALUES(`maxcount`), `stackable` = VALUES(`stackable`), `bonding` = VALUES(`bonding`), `description` = VALUES(`description`);

-- ---------------------------------------------------------------------------
-- 2. Creatures
-- ---------------------------------------------------------------------------
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `minlevel`, `maxlevel`, `exp`, `faction`, `npcflag`, `rank`, `unit_class`, `unit_flags`, `type`, `lootid`, `AIName`, `MovementType`, `HealthModifier`, `ManaModifier`, `ArmorModifier`, `RegenHealth`, `flags_extra`)
VALUES
(161700, 'Bianca Spada', NULL, 5, 6, 0, 35, 2, 0, 1, 0, 7, 0, '', 0, 0.96, 1, 1, 1, 0),
(161701, 'Moroi Spada', 'Seminarian of Northshire Abbey', 5, 6, 0, 35, 2, 0, 1, 0, 7, 0, '', 0, 0.98, 1, 1, 1, 0),
(161716, 'Shadewell Murloc', NULL, 4, 5, 0, 14, 0, 0, 1, 0, 7, 0, '', 0, 0.93, 1, 1, 1, 0),
(161717, 'Shadewell Murloc Oracle', NULL, 5, 6, 0, 14, 0, 0, 1, 0, 7, 0, '', 0, 0.93, 1, 1, 1, 0),
(161736, 'Defias Plunderer', NULL, 5, 6, 0, 14, 0, 0, 1, 0, 7, 0, '', 0, 0.93, 1, 1, 1, 0),
(161707, 'Shadewell Spider', NULL, 4, 5, 0, 14, 0, 0, 1, 0, 1, 0, '', 0, 0.93, 1, 1, 1, 0),
(161712, 'Accursed Censor', NULL, 7, 7, 0, 14, 0, 1, 1, 0, 6, 0, '', 0, 2.79, 1, 1, 1, 0),
(161713, 'Wayward Theologian', NULL, 7, 7, 0, 14, 0, 1, 1, 0, 7, 0, 'SmartAI', 0, 5.76, 1, 1, 1, 0),
(161904, 'Wayward Theologian', NULL, 6, 6, 0, 14, 0, 1, 1, 0, 7, 0, '', 0, 1.0, 1, 1, 1, 0),
(161703, '[KC] Hidden Path', NULL, 1, 1, 0, 35, 0, 0, 1, 33555202, 10, 0, '', 0, 1, 1, 1, 1, 130),
(161704, '[KC] Ruined Estate', NULL, 1, 1, 0, 35, 0, 0, 1, 33555202, 10, 0, '', 0, 1, 1, 1, 1, 130),
(161714, '[KC] Dungeon Entrance', NULL, 1, 1, 0, 35, 0, 0, 1, 33555202, 10, 0, '', 0, 1, 1, 1, 1, 130),
(161715, '[KC] Purify Relics', NULL, 1, 1, 0, 35, 0, 0, 1, 33555202, 10, 0, '', 0, 1, 1, 1, 1, 130),
(161824, '[KC] Purify Staff', NULL, 1, 1, 0, 35, 0, 0, 1, 33555202, 10, 0, '', 0, 1, 1, 1, 1, 130),
(161825, '[KC] Purify Idol', NULL, 1, 1, 0, 35, 0, 0, 1, 33555202, 10, 0, '', 0, 1, 1, 1, 1, 130),
(161826, '[KC] Purify Jewel', NULL, 1, 1, 0, 35, 0, 0, 1, 33555202, 10, 0, '', 0, 1, 1, 1, 1, 130)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `subname` = VALUES(`subname`), `minlevel` = VALUES(`minlevel`), `maxlevel` = VALUES(`maxlevel`), `exp` = VALUES(`exp`), `faction` = VALUES(`faction`), `npcflag` = VALUES(`npcflag`), `rank` = VALUES(`rank`), `unit_class` = VALUES(`unit_class`), `unit_flags` = VALUES(`unit_flags`), `type` = VALUES(`type`), `lootid` = VALUES(`lootid`), `AIName` = VALUES(`AIName`), `MovementType` = VALUES(`MovementType`), `HealthModifier` = VALUES(`HealthModifier`), `ManaModifier` = VALUES(`ManaModifier`), `ArmorModifier` = VALUES(`ArmorModifier`), `RegenHealth` = VALUES(`RegenHealth`), `flags_extra` = VALUES(`flags_extra`);

DELETE FROM `creature_template_model` WHERE `CreatureID` IN (161700, 161701, 161716, 161717, 161736, 161707, 161712, 161713, 161904, 161703, 161704, 161714, 161715, 161824, 161825, 161826);
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`)
VALUES
(161700, 0, 652000, 1, 1),
(161701, 0, 652001, 1, 1),
(161716, 0, 757, 1, 1),
(161717, 0, 1079, 1, 1),
(161736, 0, 4418, 1, 1),
(161707, 0, 955, 1, 1),
(161712, 0, 7555, 1, 1),
(161713, 0, 652003, 1, 1),
(161904, 0, 652003, 1, 1),
(161703, 0, 11686, 1, 1),
(161704, 0, 11686, 1, 1),
(161714, 0, 11686, 1, 1),
(161715, 0, 11686, 1, 1),
(161824, 0, 11686, 1, 1),
(161825, 0, 11686, 1, 1),
(161826, 0, 11686, 1, 1);

-- ---------------------------------------------------------------------------
-- 3. World objects
-- ---------------------------------------------------------------------------
INSERT INTO `gameobject_template` (`entry`, `type`, `displayId`, `name`, `size`, `Data0`, `Data1`, `Data2`, `Data3`)
VALUES
(2300500, 3, 300450, 'Lost Page I', 1.0, 1689, 2300500, 0, 1),
(2300517, 3, 300450, 'Lost Page VI', 1.0, 1689, 2300517, 0, 1),
(2300501, 0, 300449, 'Dungeon Door', 1.0, 0, 0, 524288, 0),
(2300521, 10, 87111, 'Abbess''s Staff', 1.25, 0, 2300521, 0, 0),
(96001, 2, 164, 'Smudged Note', 0.75, 0, 0, 0, 0)
ON DUPLICATE KEY UPDATE `type` = VALUES(`type`), `displayId` = VALUES(`displayId`), `name` = VALUES(`name`), `size` = VALUES(`size`), `Data0` = VALUES(`Data0`), `Data1` = VALUES(`Data1`), `Data2` = VALUES(`Data2`), `Data3` = VALUES(`Data3`);

-- ---------------------------------------------------------------------------
-- 4. Quests
-- ---------------------------------------------------------------------------
INSERT INTO `quest_template` (`ID`, `QuestType`, `QuestLevel`, `MinLevel`, `QuestSortID`, `QuestInfoID`, `RewardNextQuest`, `RewardXPDifficulty`, `RewardMoney`, `RewardSpell`, `RewardDisplaySpell`, `StartItem`, `Flags`, `RewardItem1`, `RewardAmount1`, `RewardChoiceItemID1`, `RewardChoiceItemQuantity1`, `RequiredNpcOrGo1`, `RequiredNpcOrGoCount1`, `RequiredNpcOrGo2`, `RequiredNpcOrGoCount2`, `RequiredNpcOrGo3`, `RequiredNpcOrGoCount3`, `RequiredNpcOrGo4`, `RequiredNpcOrGoCount4`, `RequiredItemId1`, `RequiredItemCount1`, `RequiredItemId2`, `RequiredItemCount2`, `LogTitle`, `LogDescription`, `QuestDescription`, `QuestCompletionLog`, `ObjectiveText1`, `ObjectiveText2`, `ObjectiveText3`, `ObjectiveText4`)
VALUES
(1660000, 2, 6, 3, 9, 0, 0, 3, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'Bookworm', 'Speak with Seminarian Moroi, brother of Bianca Spada.', '<A woman greets you, visibly agitated. A sharp mix of anger and worry flashes in her eyes.>$b$bSorry, I didn’t mean to make a scene, but… that blasted brother of mine, always buried in his books! I’ve been out here forever, yelling my lungs out, and nothing. The guards have already warned me about “disturbing the abbey’s peace” one more time.$b$bWould you mind going in there and dragging him out by the ears if you have to? Our mother’s on her deathbed, and I’ve traveled a long way to fetch him so he can say goodbye. The ungrateful wretch.', '', '', '', '', ''),
(1660001, 2, 6, 3, 9, 0, 0, 4, 15, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 559130, 1, 559131, 1, 'Knowledge Corrupts', 'Recover the missing pages from Moroi’s unclassified manuscript, scattered throughout the abbey.', 'Go on, take a look.$b$b<Moroi gestures toward the book holding his attention: a thin, battered manuscript, not unlike its reader.>$b$bI stumbled across it in the library; it’s not listed in the abbey’s records. I think it’s some sort of chronicle about an old abbess accused of heresy. In my haste, I’ve misplaced several pages. I’ve been trying to piece them back together, but some are still missing.$b$bCould you have a look around the abbey and recover the pages I lost? This is a banned book; if anyone finds out I’ve been poking my nose where it doesn’t belong, they’ll ship me back home… to my sister.$b$bDo me a mercy, will you?', 'Return to Moroi.', '', '', '', ''),
(1660002, 2, -1, 3, 9, 0, 0, 4, 0, 0, 0, 0, 8, 0, 0, 0, 0, 161714, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'The Ruins of Northshire', 'Locate the cellar entrance to the Secret Inquisitorial Dungeon.', 'A visit to the dungeon where the abbess was tried might shed some light…$b$bAccording to the book, the now-abandoned town of Northshire held a secret entrance to the Inquisitorial Dungeon.$b$bI’ll mark it on your map, but tread carefully. No one’s set foot in that place for years… I’d rather not imagine what vermin have claimed its ruins.', 'Speak with the spectral priestess.', 'Secret Inquisitorial Dungeon entrance found', '', '', ''),
(1660003, 2, -1, 3, 9, 0, 0, 5, 0, 0, 0, 0, 8, 5571, 1, 0, 0, 161715, 1, 161824, 1, 161825, 1, 161826, 1, 0, 0, 0, 0, 'Accursed Sisterhood', 'Purify the belongings of the former abbess, scattered throughout the Secret Inquisitorial Dungeon.', 'The way is shut. The abbess cursed those who judged her, binding them to wander as restless spirits.$b$bThose who died are still chained by her power. The dignity and belongings they stripped from her became shackles. A simple prayer. A sincere plea. That would be enough...$b$bThey’ll find no rest until someone purifies the abbess’s relics, scattered throughout the dungeon.$b$bBut the Dead guard them well. And so, the way remains shut.', 'Speak with Sister Alma.', 'Abbess’ Journal Purified', 'Abbess’s Staff Purified', 'Heretical Idol Purified', 'Jewel Purified'),
(1660004, 2, 6, 3, 9, 0, 0, 7, 35, 0, 0, 0, 8, 559182, 1, 0, 0, 161703, 1, 161704, 1, 161713, 1, 0, 0, 0, 0, 0, 0, 'Words that Shepherd Madness', 'Find the hidden path leading to the top of the waterfall and confront the sins of the former abbess of Northshire.', 'Sitis was... a storm. Her teachings were unorthodox; dangerous, even. Many students left the Church because of her.$b$bSo when the inquisitorial court summoned me to testify, I agreed to speak against her.$b$bI had learned she was holding secret gatherings with her closest circle at an old manor above the waterfall. In those meetings, Sitis spoke of the Light, of life, of death...$b$bAnd of the nature of the Shadow.$b$bHer heresy still stains that land. But beware if you go there; she had no shortage of followers, and the Inquisition never caught them all...', 'Return to Moroi and report what you’ve discovered about the former abbess and her crimes.', 'Hidden Path found', 'Ruined Estate discovered', 'Wayward Theologian confronted', ''),
(1660005, 2, 6, 3, 9, 0, 0, 6, 20, 0, 0, 0, 8, 0, 0, 0, 0, 161736, 5, 161716, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'The Threat Swept Downstream', 'Defeat the Defias lurking in the ruined tower and thin the ranks of the Shadewell murlocs atop the waterfall, across the rope bridge.', 'I need… help.$b$b<The soldier’s voice comes ragged, choked with pain. Each grimace is a fresh wound.>$b$bI was ordered to find the murloc village, to cut off their threat. But, as you can see, the road has not been kind to me. And worse yet: the only path to the upper river runs straight through that tower.$b$b<He nods weakly toward the looming, ruined structure.>$b$bYou, though… you might succeed where I could not.$b$bDeal with the Defias infesting the tower, thin the ranks of the murlocs above the falls, and you’ll be doing me a favor the whole kingdom will thank you for.', 'Return to the injured guard.', 'Defias Plunderer slain', 'Shadewell Murloc slain', '', ''),
(1660036, 2, 6, 3, 9, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 559160, 3, 0, 0, 'Oracular Idol', 'Collect three Prophet’s Oracular Orbs from the murloc oracles roaming the Shadewell Spring.', '<After the spasms and convulsions of a brutal death, the murloc slumps into the wet earth, dropping a sphere that rolls to a stop at your boots.>$b$b<On closer inspection, you realize it’s no common jewel at all; it’s an eyeball. Its slick surface reflects vague images that do not match the world around you. It’s as if… it’s as if it shows you what’s yet to come.>$b$b<Perhaps you should strike down the other oracles and examine their strange, blind eyes.>', 'Find someone at the Abbey to share your discovery with.', '', '', '', ''),
(1660038, 2, -1, 3, 9, 0, 0, 3, 0, 0, 0, 0, 8, 0, 0, 559176, 1, 161712, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 'The Saddest Among Us', 'Defeat the Cursed Censor in the Secret Inquisitorial Dungeon.', 'Slave to the hunger of the flames, always demanding more books to devour. When there were no more blasphemies left, they turned on the sacred texts instead.$b$bThe fire burns in his hollow sockets; there are no more tears left to shed.$b$bOnly death can release the Cursed Censor…', 'Return to Sister Alma.', '', '', '', '')
ON DUPLICATE KEY UPDATE `QuestType` = VALUES(`QuestType`), `QuestLevel` = VALUES(`QuestLevel`), `MinLevel` = VALUES(`MinLevel`), `QuestSortID` = VALUES(`QuestSortID`), `QuestInfoID` = VALUES(`QuestInfoID`), `RewardNextQuest` = VALUES(`RewardNextQuest`), `RewardXPDifficulty` = VALUES(`RewardXPDifficulty`), `RewardMoney` = VALUES(`RewardMoney`), `RewardSpell` = VALUES(`RewardSpell`), `RewardDisplaySpell` = VALUES(`RewardDisplaySpell`), `StartItem` = VALUES(`StartItem`), `Flags` = VALUES(`Flags`), `RewardItem1` = VALUES(`RewardItem1`), `RewardAmount1` = VALUES(`RewardAmount1`), `RewardChoiceItemID1` = VALUES(`RewardChoiceItemID1`), `RewardChoiceItemQuantity1` = VALUES(`RewardChoiceItemQuantity1`), `RequiredNpcOrGo1` = VALUES(`RequiredNpcOrGo1`), `RequiredNpcOrGoCount1` = VALUES(`RequiredNpcOrGoCount1`), `RequiredNpcOrGo2` = VALUES(`RequiredNpcOrGo2`), `RequiredNpcOrGoCount2` = VALUES(`RequiredNpcOrGoCount2`), `RequiredNpcOrGo3` = VALUES(`RequiredNpcOrGo3`), `RequiredNpcOrGoCount3` = VALUES(`RequiredNpcOrGoCount3`), `RequiredNpcOrGo4` = VALUES(`RequiredNpcOrGo4`), `RequiredNpcOrGoCount4` = VALUES(`RequiredNpcOrGoCount4`), `RequiredItemId1` = VALUES(`RequiredItemId1`), `RequiredItemCount1` = VALUES(`RequiredItemCount1`), `RequiredItemId2` = VALUES(`RequiredItemId2`), `RequiredItemCount2` = VALUES(`RequiredItemCount2`), `LogTitle` = VALUES(`LogTitle`), `LogDescription` = VALUES(`LogDescription`), `QuestDescription` = VALUES(`QuestDescription`), `QuestCompletionLog` = VALUES(`QuestCompletionLog`), `ObjectiveText1` = VALUES(`ObjectiveText1`), `ObjectiveText2` = VALUES(`ObjectiveText2`), `ObjectiveText3` = VALUES(`ObjectiveText3`), `ObjectiveText4` = VALUES(`ObjectiveText4`);

DELETE FROM `quest_template_addon` WHERE `ID` IN (1660000, 1660001, 1660002, 1660003, 1660004, 1660005, 1660036, 1660038);
INSERT INTO `quest_template_addon` (`ID`, `MaxLevel`, `AllowableClasses`, `SpecialFlags`)
VALUES
(1660000, 0, 0, 0),
(1660001, 0, 0, 0),
(1660002, 0, 0, 0),
(1660003, 0, 0, 0),
(1660004, 0, 0, 0),
(1660005, 0, 0, 0),
(1660036, 0, 0, 0),
(1660038, 0, 0, 0);

DELETE FROM `quest_offer_reward` WHERE `ID` IN (1660000, 1660001, 1660002, 1660003, 1660004, 1660005, 1660036, 1660038);
INSERT INTO `quest_offer_reward` (`ID`, `RewardText`)
VALUES
(1660000, ''),
(1660001, ''),
(1660002, ''),
(1660003, ''),
(1660004, ''),
(1660005, ''),
(1660036, ''),
(1660038, '');

DELETE FROM `quest_request_items` WHERE `ID` IN (1660000, 1660001, 1660002, 1660003, 1660004, 1660005, 1660036, 1660038);
INSERT INTO `quest_request_items` (`ID`, `CompletionText`)
VALUES
(1660000, ''),
(1660001, 'Return to Moroi.'),
(1660002, 'Speak with the spectral priestess.'),
(1660003, 'Speak with Sister Alma.'),
(1660004, 'Return to Moroi and report what you’ve discovered about the former abbess and her crimes.'),
(1660005, 'Return to the injured guard.'),
(1660036, 'Find someone at the Abbey to share your discovery with.'),
(1660038, 'Return to Sister Alma.');

-- ---------------------------------------------------------------------------
-- 5. Who offers and who takes them back
-- ---------------------------------------------------------------------------
DELETE FROM `creature_queststarter` WHERE `quest` IN (1660000, 1660001, 1660002, 1660003, 1660004, 1660005, 1660036, 1660038);
INSERT INTO `creature_queststarter` (`id`, `quest`)
VALUES
(161700, 1660000),
(161701, 1660001),
(161701, 1660002),
(161701, 1660003),
(161701, 1660004),
(161701, 1660005),
(161701, 1660036),
(161701, 1660038);

DELETE FROM `creature_questender` WHERE `quest` IN (1660000, 1660001, 1660002, 1660003, 1660004, 1660005, 1660036, 1660038);
INSERT INTO `creature_questender` (`id`, `quest`)
VALUES
(161701, 1660000),
(161701, 1660001),
(161701, 1660002),
(161701, 1660003),
(161701, 1660004),
(161701, 1660005),
(161701, 1660036),
(161701, 1660038);

-- ---------------------------------------------------------------------------
-- 6. Loot
-- ---------------------------------------------------------------------------
DELETE FROM `creature_loot_template` WHERE `Entry` = 161717;
INSERT INTO `creature_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`, `Comment`)
VALUES
(161717, 559160, 0, 100, 1, 1, 0, 1, 1, 'CoA Northshire: Shadewell Murloc Oracle drops the Prophet''s Oracular Orb (creaturecache questItem1)');

DELETE FROM `gameobject_loot_template` WHERE `Entry` IN (2300500, 2300517);
INSERT INTO `gameobject_loot_template` (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`, `LootMode`, `GroupId`, `MinCount`, `MaxCount`, `Comment`)
VALUES
(2300500, 559130, 0, 100, 1, 1, 0, 1, 1, 'CoA Northshire: Lost Page I'),
(2300517, 559131, 0, 100, 1, 1, 0, 1, 1, 'CoA Northshire: Lost Page II, from the page object CoA labels VI');

DELETE FROM `creature_questitem` WHERE `CreatureEntry` = 161717;
INSERT INTO `creature_questitem` (`CreatureEntry`, `Idx`, `ItemId`)
VALUES
(161717, 0, 559160);

DELETE FROM `gameobject_questitem` WHERE `GameObjectEntry` IN (2300500, 2300517);
INSERT INTO `gameobject_questitem` (`GameObjectEntry`, `Idx`, `ItemId`)
VALUES
(2300500, 0, 559130),
(2300517, 0, 559131);

-- ---------------------------------------------------------------------------
-- 7. Spawns
-- ---------------------------------------------------------------------------
DELETE FROM `creature` WHERE `guid` BETWEEN 9001000 AND 9001199;
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `unit_flags`, `dynamicflags`, `ScriptName`, `VerifiedBuild`, `CreateObject`, `Comment`)
VALUES
(9001000, 161701, 0, 0, 0, 1, 1, 0, -8901.4, -214.8, 80.553, 0, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, abbey, beside the lost pages'),
(9001001, 161700, 0, 0, 0, 1, 1, 0, -8896.2, -221.6, 80.906, 0, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, abbey, beside her brother'),
(9001002, 161712, 0, 0, 0, 1, 1, 0, -8641.0, -401.0, 55.2, 0, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, dungeon interior, at the staff height'),
(9001003, 161716, 0, 0, 0, 1, 1, 0, -8540.0, -478.0, 140.04, 0, 300, 4, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Northshire: derived placement, in the spring pool'),
(9001004, 161716, 0, 0, 0, 1, 1, 0, -8517.0, -462.0, 140.04, 0, 300, 4, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Northshire: derived placement, in the spring pool'),
(9001005, 161716, 0, 0, 0, 1, 1, 0, -8505.0, -484.0, 140.04, 0, 300, 4, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Northshire: derived placement, in the spring pool'),
(9001006, 161716, 0, 0, 0, 1, 1, 0, -8553.0, -468.0, 140.04, 0, 300, 4, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Northshire: derived placement, in the spring pool'),
(9001007, 161716, 0, 0, 0, 1, 1, 0, -8523.0, -492.0, 140.04, 0, 300, 4, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Northshire: derived placement, in the spring pool'),
(9001008, 161716, 0, 0, 0, 1, 1, 0, -8522.0, -454.0, 142.879, 0, 300, 6, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, spring shore'),
(9001009, 161716, 0, 0, 0, 1, 1, 0, -8511.0, -460.0, 140.537, 0, 300, 6, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, spring shore'),
(9001010, 161716, 0, 0, 0, 1, 1, 0, -8547.0, -490.0, 140.539, 0, 300, 6, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, spring shore'),
(9001011, 161716, 0, 0, 0, 1, 1, 0, -8612.0, -484.0, 143.351, 0, 300, 6, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, downstream toward the falls'),
(9001012, 161716, 0, 0, 0, 1, 1, 0, -8607.0, -484.0, 141.631, 0, 300, 6, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, downstream toward the falls'),
(9001013, 161717, 0, 0, 0, 1, 1, 0, -8533.0, -460.0, 139.596, 0, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, oracle on the rocks above the pool'),
(9001014, 161717, 0, 0, 0, 1, 1, 0, -8501.0, -470.0, 140.537, 0, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, oracle on the rocks above the pool'),
(9001015, 161717, 0, 0, 0, 1, 1, 0, -8610.0, -483.0, 141.483, 0, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, oracle at the falls edge'),
(9001016, 161736, 0, 0, 0, 1, 1, 0, -8809.3, -385.3, 74.13, 0, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, ruined tower, entrance'),
(9001017, 161736, 0, 0, 0, 1, 1, 0, -8822.3, -396.3, 74.386, 0, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, ruined tower, round the back'),
(9001018, 161736, 0, 0, 0, 1, 1, 0, -8815.3, -390.3, 93.0, 0, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, ruined tower, stairwell'),
(9001019, 161736, 0, 0, 0, 1, 1, 0, -8815.3, -388.3, 105.0, 0, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, ruined tower, top'),
(9001020, 161736, 0, 0, 0, 1, 1, 0, -8801.3, -402.3, 74.4, 0, 300, 12, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, ruined tower, patrolling the yard'),
(9001021, 161736, 0, 0, 0, 1, 1, 0, -8831.3, -379.3, 73.337, 0, 300, 12, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, ruined tower, patrolling the yard'),
(9001022, 161707, 0, 0, 0, 1, 1, 0, -8813.9, -300.4, 74.761, 0, 300, 8, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, Old Northshire Village ruins'),
(9001023, 161707, 0, 0, 0, 1, 1, 0, -8806.9, -305.4, 73.669, 0, 300, 8, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, Old Northshire Village ruins'),
(9001024, 161707, 0, 0, 0, 1, 1, 0, -8819.9, -294.4, 76.11, 0, 300, 8, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, Old Northshire Village ruins'),
(9001025, 161707, 0, 0, 0, 1, 1, 0, -8787.3, -294.0, 74.226, 0, 300, 8, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, Old Northshire Village ruins'),
(9001026, 161707, 0, 0, 0, 1, 1, 0, -8780.3, -299.0, 74.584, 0, 300, 8, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, Old Northshire Village ruins'),
(9001027, 161707, 0, 0, 0, 1, 1, 0, -8793.3, -288.0, 75.234, 0, 300, 8, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, Old Northshire Village ruins'),
(9001028, 161713, 0, 0, 0, 1, 1, 0, -8572.0, -487.0, 140.59, 0, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, ruined estate, top of the waterfall'),
(9001029, 161714, 0, 0, 0, 1, 1, 0, -8775.58, -278.45, 80.4, 0, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Northshire: derived placement, at the Dungeon Door, credits the cellar entrance'),
(9001030, 161703, 0, 0, 0, 1, 1, 0, -8649.0, -479.0, 141.757, 0, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, hidden path up to the falls'),
(9001031, 161704, 0, 0, 0, 1, 1, 0, -8574.0, -491.0, 140.506, 0, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, ruined estate, credits the discovery'),
(9001032, 161715, 0, 0, 0, 1, 1, 0, -8644.0, -398.0, 55.2, 0, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, dungeon interior, journal credit'),
(9001033, 161824, 0, 0, 0, 1, 1, 0, -8638.85, -404.45, 55.2, 0, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Northshire: derived placement, dungeon interior, at the Abbess''s Staff'),
(9001034, 161825, 0, 0, 0, 1, 1, 0, -8635.0, -399.0, 55.2, 0, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, dungeon interior, idol credit'),
(9001035, 161826, 0, 0, 0, 1, 1, 0, -8646.0, -408.0, 55.2, 0, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Northshire: inferred placement, dungeon interior, jewel credit');

DELETE FROM `gameobject` WHERE `guid` BETWEEN 6910000 AND 6910099;
INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `position_x`, `position_y`, `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`, `state`, `ScriptName`, `Comment`)
VALUES
(6910000, 2300500, 0, 0, 0, 1, 1, -8912.93, -209.89, 82.99, 2.6, 0, 0, 0.963558, 0.267499, 120, 100, 1, '', 'CoA Northshire: observed atlas position for Lost Page I'),
(6910001, 2300517, 0, 0, 0, 1, 1, -8912.76, -208.82, 82.99, 5.45, 0, 0, 0.404647, -0.914473, 120, 100, 1, '', 'CoA Northshire: observed atlas position for Lost Page VI'),
(6910002, 2300501, 0, 0, 0, 1, 1, -8775.58, -278.45, 79.17, 1.5708, 0, 0, 0.707108, 0.707105, 120, 100, 1, '', 'CoA Northshire: observed atlas position for Dungeon Door'),
(6910003, 2300521, 0, 0, 0, 1, 1, -8638.85, -404.45, 54.72, 1.2, 0, 0, 0.564642, 0.825336, 120, 100, 1, '', 'CoA Northshire: observed atlas position for Abbess''s Staff'),
(6910004, 96001, 0, 0, 0, 1, 1, -8906.66, -705.67, 70.67, 4.1, 0, 0, 0.887362, -0.461073, 120, 100, 1, '', 'CoA Northshire: observed atlas position for Smudged Note');

-- ---------------------------------------------------------------------------
-- 8. The Wayward Theologian splits
-- ---------------------------------------------------------------------------
-- At 30% health the boss becomes untouchable and three mirror images appear around the ruined estate.
-- Clearing them drops the shield and the fight resumes. The reported fight also hung a rope so melee
-- could reach the images on the upper floors; that is client-side geometry and is not restored here.
DELETE FROM `smart_scripts` WHERE `entryorguid` = 161713 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`)
VALUES
(161713, 0, 0, 1, 2, 0, 100, 0, 1, 30, 0, 0, 0, 0, 18, 33554432, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Wayward Theologian - Between 1-30% Health - Become untouchable'),
(161713, 0, 1, 2, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 12, 161904, 3, 30000, 0, 0, 0, 8, 0, 0, 0, 0, -8578.0, -493.0, 0, 0, 'Wayward Theologian - Linked - Summon a mirror image'),
(161713, 0, 2, 3, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 12, 161904, 3, 30000, 0, 0, 0, 8, 0, 0, 0, 0, -8566.0, -481.0, 0, 0, 'Wayward Theologian - Linked - Summon a mirror image'),
(161713, 0, 3, 4, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 12, 161904, 3, 30000, 0, 0, 0, 8, 0, 0, 0, 0, -8572.0, -499.0, 0, 0, 'Wayward Theologian - Linked - Summon a mirror image'),
(161713, 0, 4, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Wayward Theologian - Linked - Announce the split'),
(161713, 0, 5, 6, 40, 0, 100, 0, 1, 0, 0, 0, 0, 0, 19, 33554432, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Wayward Theologian - On no summons left - Become attackable again'),
(161713, 0, 6, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Wayward Theologian - Linked - Announce the return'),
(161713, 0, 7, 0, 6, 0, 100, 0, 0, 0, 0, 0, 0, 0, 33, 161713, 0, 0, 0, 0, 0, 18, 30, 0, 0, 0, 0, 0, 0, 0, 'Wayward Theologian - On death - Credit the confrontation');

-- ---------------------------------------------------------------------------
-- 9. Discovery and purify credit
-- ---------------------------------------------------------------------------
-- The three discovery objectives are granted by walking to the marker, which is what "found" and
-- "discovered" mean in their objective text. The staff is granted by using the object the atlas places.
-- The journal, idol and jewel have no object in any source we hold, so their markers are spawned but
-- nothing credits them yet; quest 1660003 cannot be completed until those three are placed in game.
DELETE FROM `smart_scripts` WHERE `entryorguid` IN (161714, 161703, 161704) AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`)
VALUES
(161714, 0, 0, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 0, 33, 161714, 0, 0, 0, 0, 0, 20, 12, 0, 0, 0, 0, 0, 0, 0, '[KC] marker - On player within 12 yards - Credit the cellar entrance'),
(161703, 0, 0, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 0, 33, 161703, 0, 0, 0, 0, 0, 20, 12, 0, 0, 0, 0, 0, 0, 0, '[KC] marker - On player within 12 yards - Credit the hidden path'),
(161704, 0, 0, 0, 25, 0, 100, 0, 0, 0, 0, 0, 0, 0, 33, 161704, 0, 0, 0, 0, 0, 20, 12, 0, 0, 0, 0, 0, 0, 0, '[KC] marker - On player within 12 yards - Credit the ruined estate');

DELETE FROM `smart_scripts` WHERE `entryorguid` = 2300521 AND `source_type` = 1;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`)
VALUES
(2300521, 1, 0, 0, 70, 0, 100, 0, 0, 0, 0, 0, 0, 0, 33, 161824, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Abbess''s Staff - On use - Credit purifying the staff');

UPDATE `gameobject_template` SET `AIName` = 'SmartGameObjectAI' WHERE `entry` = 2300521;

DELETE FROM `creature_text` WHERE `CreatureID` = 161713;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Probability`, `comment`)
VALUES
(161713, 0, 0, 'The word is many! Strike at one and the rest endure!', 16, 100, 'Wayward Theologian - split'),
(161713, 1, 0, 'The echoes fade... and I remain.', 16, 100, 'Wayward Theologian - reform');
