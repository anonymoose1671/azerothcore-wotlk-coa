-- The Repaired Cellar Key 559141 cannot open the Cain manor cellar door 2300524 from the client: the CoA client
-- builds the key's tooltip and use from its own item data, which has no use spell, so the spell the server gives it
-- (rev_20261001_00) never reaches the door and the client answers "The door is locked." (playtest, cache cleared).
-- The server opens it instead: an invisible trigger at the top of the cellar stair opens the door (SmartAI
-- ACTIVATE_GOBJECT, as stock scripted doors) when a player within 5 yd carries the key (SMART_EVENT condition 2,
-- ITEM). Players without the key still find it locked. Trigger template copies the [KC] Visit marker 685037.
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `gossip_menu_id`, `minlevel`, `maxlevel`, `exp`, `faction`, `npcflag`, `speed_walk`, `speed_run`, `detection_range`, `rank`, `BaseAttackTime`, `RangeAttackTime`, `unit_class`, `unit_flags`, `unit_flags2`, `type`, `type_flags`, `lootid`, `AIName`, `MovementType`, `HealthModifier`, `ManaModifier`, `ArmorModifier`, `RegenHealth`, `flags_extra`, `ScriptName`)
VALUES
(9300258, '[KC] Cain Cellar Door Opener', NULL, 0, 1, 1, 0, 35, 0, 1, 1.14286, 20, 0, 2000, 2000, 1, 33555202, 2048, 10, 0, 0, 'SmartAI', 0, 1, 1, 1, 1, 130, '')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `faction` = VALUES(`faction`), `unit_flags` = VALUES(`unit_flags`),
`AIName` = VALUES(`AIName`), `flags_extra` = VALUES(`flags_extra`);
DELETE FROM `creature_template_model` WHERE `CreatureID` = 9300258;
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`) VALUES
(9300258, 0, 11686, 1, 1);
DELETE FROM `creature` WHERE `guid` = 9010907;
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `unit_flags`, `dynamicflags`, `ScriptName`, `VerifiedBuild`, `CreateObject`, `Comment`) VALUES
(9010907, 9300258, 0, 0, 0, 1, 1, 0, 1941.74, 1968.71, 156.2, 2.356, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Cain manor: invisible opener at the cellar door');
DELETE FROM `smart_scripts` WHERE `entryorguid` = 9300258 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(9300258, 0, 0, 0, 10, 0, 100, 0, 2, 5, 6000, 6000, 1, 0, 9, 0, 0, 0, 0, 0, 0, 14, 7916004, 2300524, 0, 0, 0, 0, 0, 0, 'Cain Cellar Door Opener - Key holder within 5 yd - Open the cellar door');
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 22 AND `SourceGroup` = 1 AND `SourceEntry` = 9300258 AND `SourceId` = 0;
INSERT INTO `conditions` (`SourceTypeOrReferenceId`, `SourceGroup`, `SourceEntry`, `SourceId`, `ElseGroup`, `ConditionTypeOrReference`, `ConditionTarget`, `ConditionValue1`, `ConditionValue2`, `ConditionValue3`, `NegativeCondition`, `Comment`) VALUES
(22, 1, 9300258, 0, 0, 2, 0, 559141, 1, 0, 0, 'Cain Cellar Door Opener - only for a player carrying the Repaired Cellar Key');
