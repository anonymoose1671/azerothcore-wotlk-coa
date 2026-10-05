-- Three Totems mobs carry and use what players saw on CoA: a Grimtotem Marauder swings one axe and a Grimtotem Patrol
-- two, both use Heroic Strike and the Marauder charges; the Cruel Carrion Spirit knocks you off your feet and uses
-- Heroic Strike, as does the Owlish Totem's spirit. The axe is the one-handed axe 1905 of the stock Grimtotem
-- Mercenary; the spells are the low-level creature ones (Heroic Strike 25710 adds 11 weapon damage, Charge 22120 a
-- normal hit, Knockdown 5164 a 2 s stun), so a level 3-4 mob hits like a player's first rank. The Patrol shows its
-- second axe without off-hand swings, keeping its damage.
DELETE FROM `creature_equip_template` WHERE `CreatureID` IN (161809, 161810) AND `ID` = 1;
INSERT INTO `creature_equip_template` (`CreatureID`, `ID`, `ItemID1`, `ItemID2`, `ItemID3`, `VerifiedBuild`) VALUES
(161809, 1, 1905, 0, 0, 0),
(161810, 1, 1905, 1905, 0, 0);

UPDATE `creature` SET `equipment_id` = 1 WHERE `id` IN (161809, 161810);

UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `entry` IN (161810, 161834, 161851);

DELETE FROM `smart_scripts` WHERE `entryorguid` = 161809 AND `source_type` = 0 AND `id` IN (1, 2);
DELETE FROM `smart_scripts` WHERE `entryorguid` IN (161810, 161834, 161851) AND `source_type` = 0;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`,
    `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `event_param6`,
    `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`,
    `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`,
    `target_o`, `comment`) VALUES
(161809, 0, 1, 0, 0, 0, 100, 0, 5000, 8000, 9000, 13000, 0, 0, 11, 25710, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Grimtotem Marauder - In Combat - Cast Heroic Strike'),
(161809, 0, 2, 0, 9, 0, 100, 0, 8, 25, 15000, 20000, 0, 0, 11, 22120, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Grimtotem Marauder - Victim 8-25 yd - Cast Charge'),
(161810, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 9000, 13000, 0, 0, 11, 25710, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Grimtotem Patrol - In Combat - Cast Heroic Strike'),
(161834, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 9000, 13000, 0, 0, 11, 25710, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cruel Carrion Spirit - In Combat - Cast Heroic Strike'),
(161834, 0, 1, 0, 0, 0, 100, 0, 6000, 9000, 12000, 16000, 0, 0, 11, 5164, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Cruel Carrion Spirit - In Combat - Cast Knockdown'),
(161851, 0, 0, 0, 0, 0, 100, 0, 5000, 8000, 9000, 13000, 0, 0, 11, 25710, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Owlish Totem - In Combat - Cast Heroic Strike');
