-- Blood Is Power 200019 (Bloodmage, "a suspicious Blood Elf rummaging in the abandoned houses nearby") is CoA's own
-- quest, but nothing places it: its text names no zone, CoA's creature cache has no record of its target 9300252,
-- and the client has no QuestSuperTrack point for it. rev_20260923_09 put it in Deathknell by elimination and made
-- the Suspicious Blood Elf's look and spots up (INFERRED), so Irina Valreed no longer offers it and the Blood Elf,
-- its Tome of Blood drop and the quest's map markers go. Other zones' Tome of Blood holders keep their drop.
DELETE FROM `creature` WHERE (`guid`, `id`) IN ((9003722, 9300252), (9003723, 9300252));
DELETE FROM `creature_queststarter` WHERE `id` = 502922 AND `quest` = 200019;
DELETE FROM `creature_questender` WHERE `id` = 502922 AND `quest` = 200019;
DELETE FROM `creature_loot_template` WHERE `Entry` = 9300252 AND `Item` = 661316;
DELETE FROM `creature_questitem` WHERE `CreatureEntry` = 9300252;
DELETE FROM `quest_poi_points` WHERE `QuestID` = 200019;
DELETE FROM `quest_poi` WHERE `QuestID` = 200019;
