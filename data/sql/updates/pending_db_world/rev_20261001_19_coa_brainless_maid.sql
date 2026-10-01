-- Brainless Maid 161754 (An Unspeakable Secret 1660026), from CoA footage described by the playtester: a Forsaken
-- woman in a simple brownish-red dress, sitting and gazing at the water, who speaks when engaged. Her CoA display
-- is not in the client; the stand-in 1200 gives way to the Forsaken Selina Weston 1639 (maroon robe-dress)
-- (INFERRED). Both spawns (ST8684 and the Questie point behind the manor) sit on the lake shore and face the
-- water, 4-6 yd to the north-east (surface.liquid, depth 0.8). SmartAI on AGGRO (4), say (12).
DELETE FROM `creature_template_model` WHERE `CreatureID` = 161754;
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`) VALUES
(161754, 0, 1639, 1, 1);
DELETE FROM `creature_template_addon` WHERE `entry` = 161754;
INSERT INTO `creature_template_addon` (`entry`, `path_id`, `mount`, `bytes1`, `bytes2`, `emote`, `visibilityDistanceType`, `auras`) VALUES
(161754, 0, 0, 1, 0, 0, 0, '');
UPDATE `creature` SET `orientation` = 0.79 WHERE `id` = 161754 AND `guid` IN (9010008, 9010009);
UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `entry` = 161754;
DELETE FROM `creature_text` WHERE `CreatureID` = 161754;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Probability`, `comment`)
VALUES
(161754, 0, 0, 'My Lady Priscilla... I think she needs me... What was it I came here to do?', 12, 100, 'Brainless Maid - aggro (CoA footage)');
DELETE FROM `smart_scripts` WHERE `entryorguid` = 161754 AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(161754, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Brainless Maid - On Aggro - Say Line 0');
