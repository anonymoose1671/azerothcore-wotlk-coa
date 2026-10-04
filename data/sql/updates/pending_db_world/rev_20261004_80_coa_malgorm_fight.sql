-- Malgorm Hollowhoof becomes a fight (npc_coa_malgorm_hollowhoof in src/server/coa/AscensionThreeTotems.cpp) in place
-- of calling the village to arms. Playtesters recall a charge that ran on until it struck a wall, knocking players back
-- for heavy damage; CoA's Charge 256743-256746, Shield Wall 256752 and Enraged Regeneration 256755 build it, and the
-- rest is INFERRED: a line telegraph before the charge, a circle-telegraphed War Stomp, and once, at half health, a
-- shielded, regenerating intermission that ends only when he charges into a wall, which stuns him and opens him to
-- extra damage. The lines are invented from the Three Totems quests.
UPDATE `creature_template` SET `AIName` = '', `ScriptName` = 'npc_coa_malgorm_hollowhoof' WHERE `entry` = 161816;
DELETE FROM `smart_scripts` WHERE `entryorguid` = 161816 AND `source_type` = 0;

DELETE FROM `creature_text` WHERE `CreatureID` = 161816;
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Probability`, `comment`) VALUES
(161816, 0, 0, 'You wear the skin of my warriors, but not their loyalty. Nauchol sent you, didn''t he?', 14, 100, 'Malgorm - aggro, disguised'),
(161816, 1, 0, 'An outsider, in my hall? Three Totems bows to one hoof. Mine.', 14, 100, 'Malgorm - aggro'),
(161816, 2, 0, 'Kneel, as the rebels knelt!', 14, 100, 'Malgorm - War Stomp'),
(161816, 3, 0, 'Morriga thought steel could unseat me too. Ask her mate how that ended.', 14, 100, 'Malgorm - intermission'),
(161816, 4, 0, 'I spared my daughter once. I will not spare you!', 14, 100, 'Malgorm - low health'),
(161816, 5, 0, 'Leave the body for the vultures, like the rest of them.', 12, 100, 'Malgorm - kills a player'),
(161816, 6, 0, 'The rites... give me... the rites...', 12, 100, 'Malgorm - death');
