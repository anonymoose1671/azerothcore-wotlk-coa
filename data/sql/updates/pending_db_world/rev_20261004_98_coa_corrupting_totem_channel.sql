-- Death by Laughter (1660034): the player channels Corrupting Totem for 10 s at a totem; a completed channel alters it.
-- The cast bar reads "Corrupting Totem", as on CoA, instead of the generic "Channeling".
UPDATE `gameobject_template` SET `Data10` = 256716, `castBarCaption` = 'Corrupting Totem'
    WHERE `entry` IN (2300527, 2300533, 2300534);

DELETE FROM `spell_script_names` WHERE `spell_id` = 256716 AND `ScriptName` = 'spell_coa_corrupting_totem';
INSERT INTO `spell_script_names` (`spell_id`, `ScriptName`) VALUES
(256716, 'spell_coa_corrupting_totem');

DELETE FROM `smart_scripts` WHERE `entryorguid` IN (2300527, 2300533, 2300534) AND `source_type` = 1;
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(2300527, 1, 0, 1, 8, 0, 100, 0, 256716, 0, 0, 0, 0, 0, 33, 161849, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Aquiline Totem - On Corrupting Totem Channelled - Quest Credit Totems altered'),
(2300527, 1, 1, 2, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 12, 161850, 4, 60000, 1, 0, 0, 8, 0, 0, 0, 0, -3547.5, -1207, 205.527, 4, 'Aquiline Totem - Linked - Summon its guardian spirit to attack the invoker'),
(2300527, 1, 2, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 41, 0, 60, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aquiline Totem - Linked - Fade for 60 seconds'),
(2300533, 1, 0, 1, 8, 0, 100, 0, 256716, 0, 0, 0, 0, 0, 33, 161849, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Owlish Totem - On Corrupting Totem Channelled - Quest Credit Totems altered'),
(2300533, 1, 1, 2, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 12, 161851, 4, 60000, 1, 0, 0, 8, 0, 0, 0, 0, -3582.5, -1121, 205.775, 3.8, 'Owlish Totem - Linked - Summon its guardian spirit to attack the invoker'),
(2300533, 1, 2, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 41, 0, 60, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Owlish Totem - Linked - Fade for 60 seconds'),
(2300534, 1, 0, 1, 8, 0, 100, 0, 256716, 0, 0, 0, 0, 0, 33, 161849, 0, 0, 0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 'Taurine Totem - On Corrupting Totem Channelled - Quest Credit Totems altered'),
(2300534, 1, 1, 2, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 12, 161852, 4, 60000, 1, 0, 0, 8, 0, 0, 0, 0, -3500.5, -1204, 212.906, 5.5, 'Taurine Totem - Linked - Summon its guardian spirit to attack the invoker'),
(2300534, 1, 2, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 41, 0, 60, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Taurine Totem - Linked - Fade for 60 seconds');
