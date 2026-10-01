-- Aberrant Progeny 161757 (The True Heir of the Cains), from CoA footage described by the playtester: it breathes
-- fire in a frontal cone (Flame Breath 256748, 3 s cast, 15 yd), turning to its target first and then holding its
-- aim so the cone can be dodged. At 30% health it vanishes (an invisible model, untargetable, still in combat so the
-- fight goes on) and a few seconds later four copies of it rise around the summoning circle, each speaking and
-- casting Fel Explosion 256749 (15 s cast, 15 yd); each copy knocks the players back as it dies (Fel Explosion
-- 256750, knockback 35 yd). When all four are dead the Progeny returns to finish the fight, and near death it says
-- "Sad... ness...". On a reset it clears any copies and shows itself again. The spells are CoA's own (Spell.dbc
-- 256748-256750, beside CoA's other quest spells); timings and the copy count are INFERRED from the footage. The
-- copies (9300259) are a separate entry so they never split again and never give quest credit.
UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `entry` = 161757;
INSERT INTO `creature_template` (`entry`, `name`, `subname`, `gossip_menu_id`, `minlevel`, `maxlevel`, `exp`, `faction`, `npcflag`, `speed_walk`, `speed_run`, `detection_range`, `rank`, `BaseAttackTime`, `RangeAttackTime`, `unit_class`, `unit_flags`, `unit_flags2`, `type`, `type_flags`, `lootid`, `AIName`, `MovementType`, `HealthModifier`, `ManaModifier`, `ArmorModifier`, `RegenHealth`, `flags_extra`, `ScriptName`)
VALUES
(9300259, 'Aberrant Progeny', NULL, 0, 7, 7, 0, 14, 0, 1, 1.14286, 20, 0, 2000, 2000, 1, 0, 2048, 3, 0, 0, 'SmartAI', 0, 1, 1, 1, 1, 0, '')
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `minlevel` = VALUES(`minlevel`), `maxlevel` = VALUES(`maxlevel`),
`faction` = VALUES(`faction`), `type` = VALUES(`type`), `AIName` = VALUES(`AIName`), `HealthModifier` = VALUES(`HealthModifier`);
DELETE FROM `creature_template_model` WHERE `CreatureID` = 9300259;
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`) VALUES
(9300259, 0, 76125, 0.6, 1);
DELETE FROM `creature_text` WHERE `CreatureID` IN (161757, 9300259);
INSERT INTO `creature_text` (`CreatureID`, `GroupID`, `ID`, `Text`, `Type`, `Probability`, `comment`)
VALUES
(161757, 0, 0, 'Sad... ness...', 12, 100, 'Aberrant Progeny - near death (CoA footage)'),
(9300259, 0, 0, 'Wh... y...?', 12, 50, 'Aberrant Progeny copy - summoned (CoA footage)'),
(9300259, 0, 1, 'Play... with... me...', 12, 50, 'Aberrant Progeny copy - summoned (CoA footage)');
DELETE FROM `smart_scripts` WHERE (`entryorguid` IN (161757, 9300259) AND `source_type` = 0) OR (`entryorguid` = 16175700 AND `source_type` = 9);
INSERT INTO `smart_scripts` (`entryorguid`, `source_type`, `id`, `link`, `event_type`, `event_phase_mask`, `event_chance`, `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`, `event_param5`, `event_param6`, `action_type`, `action_param1`, `action_param2`, `action_param3`, `action_param4`, `action_param5`, `action_param6`, `target_type`, `target_param1`, `target_param2`, `target_param3`, `target_param4`, `target_x`, `target_y`, `target_z`, `target_o`, `comment`) VALUES
(161757, 0, 0, 0, 4, 0, 100, 0, 0, 0, 0, 0, 0, 0, 22, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny - On Aggro - Set Phase 1'),
(161757, 0, 1, 21, 0, 1, 100, 0, 6000, 8000, 14000, 16000, 0, 0, 66, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny - In Combat - Face the victim'),
(161757, 0, 2, 3, 2, 1, 100, 1, 0, 30, 0, 0, 0, 0, 22, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny - At 30% Health - Set Phase 2'),
(161757, 0, 3, 4, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 18, 33554432, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny - Linked - Become Untargetable'),
(161757, 0, 4, 5, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 3, 0, 11686, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny - Linked - Vanish'),
(161757, 0, 5, 6, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny - Linked - Set Passive'),
(161757, 0, 6, 7, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 103, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny - Linked - Root'),
(161757, 0, 7, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 80, 16175700, 1, 2, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny - Linked - Split into four copies'),
(161757, 0, 8, 0, 82, 2, 100, 0, 9300259, 0, 0, 0, 0, 0, 63, 1, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny - Copy Dies - Count It'),
(161757, 0, 9, 10, 77, 2, 100, 0, 1, 4, 0, 0, 0, 0, 19, 33554432, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny - Four Copies Dead - Become Targetable'),
(161757, 0, 10, 11, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny - Linked - Reappear'),
(161757, 0, 11, 12, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 8, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny - Linked - Set Aggressive'),
(161757, 0, 12, 13, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 103, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny - Linked - Unroot'),
(161757, 0, 13, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 22, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny - Linked - Set Phase 1'),
(161757, 0, 14, 0, 2, 1, 100, 1, 0, 5, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny - At 5% Health - Say Line 0'),
(161757, 0, 15, 16, 25, 0, 100, 0, 0, 0, 0, 0, 0, 0, 3, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny - On Reset - Reappear'),
(161757, 0, 16, 17, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 19, 33554432, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny - Linked - Become Targetable'),
(161757, 0, 17, 18, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 103, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny - Linked - Unroot'),
(161757, 0, 18, 19, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 8, 2, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny - Linked - Set Aggressive'),
(161757, 0, 19, 20, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 63, 1, 0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny - Linked - Reset the copy count'),
(161757, 0, 20, 22, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 22, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny - Linked - Set Phase 0'),
(161757, 0, 21, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 11, 256748, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny - Linked - Cast Flame Breath where it faces'),
(161757, 0, 22, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 41, 0, 0, 0, 0, 0, 0, 9, 9300259, 0, 60, 0, 0, 0, 0, 0, 'Aberrant Progeny - Linked - Clear any copies'),
(16175700, 9, 0, 0, 0, 0, 100, 0, 3000, 3000, 0, 0, 0, 0, 12, 9300259, 4, 30000, 1, 0, 0, 8, 0, 0, 0, 0, 1935.89, 1957.86, 148.652, 3.14, 'Aberrant Progeny - Split - Summon copy 1'),
(16175700, 9, 1, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 12, 9300259, 4, 30000, 1, 0, 0, 8, 0, 0, 0, 0, 1931.89, 1961.86, 148.653, 4.71, 'Aberrant Progeny - Split - Summon copy 2'),
(16175700, 9, 2, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 12, 9300259, 4, 30000, 1, 0, 0, 8, 0, 0, 0, 0, 1927.89, 1957.86, 148.653, 0.0, 'Aberrant Progeny - Split - Summon copy 3'),
(16175700, 9, 3, 0, 0, 0, 100, 0, 0, 0, 0, 0, 0, 0, 12, 9300259, 4, 30000, 1, 0, 0, 8, 0, 0, 0, 0, 1931.89, 1953.86, 148.653, 1.57, 'Aberrant Progeny - Split - Summon copy 4'),
(9300259, 0, 0, 1, 54, 0, 100, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny copy - Just Summoned - Say Line 0'),
(9300259, 0, 1, 2, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 103, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny copy - Linked - Root'),
(9300259, 0, 2, 0, 61, 0, 100, 0, 0, 0, 0, 0, 0, 0, 11, 256749, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny copy - Linked - Cast Fel Explosion'),
(9300259, 0, 3, 0, 0, 0, 100, 0, 16000, 16000, 16000, 16000, 0, 0, 11, 256749, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny copy - In Combat - Cast Fel Explosion'),
(9300259, 0, 4, 0, 6, 0, 100, 0, 0, 0, 0, 0, 0, 0, 11, 256750, 2, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 'Aberrant Progeny copy - On Death - Fel Explosion knockback');
