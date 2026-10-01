-- Three Kobold Desecrators 161751 above the Cain Family Crypt, around its entrance: CoA footage shows two or three
-- at the tomb's mouth on the way down to Restless Family Members; until now they were only inside. The mouth is
-- the atlas sighting of the Casket Lid (1797.64, 1965.46, 156.30); spots 4-8 yd from it on standable ground
-- (surface.standable), facing it (INFERRED).
DELETE FROM `creature` WHERE `guid` IN (9010901, 9010902, 9010903);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `unit_flags`, `dynamicflags`, `ScriptName`, `VerifiedBuild`, `CreateObject`, `Comment`) VALUES
(9010901, 161751, 0, 0, 0, 1, 1, 0, 1800.47, 1968.29, 156.131, 3.93, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Cain crypt: Kobold Desecrator at the crypt mouth, north-east side'),
(9010902, 161751, 0, 0, 0, 1, 1, 0, 1794.81, 1962.63, 156.076, 0.79, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Cain crypt: Kobold Desecrator at the crypt mouth, south-west side'),
(9010903, 161751, 0, 0, 0, 1, 1, 0, 1805.64, 1965.46, 156.163, 3.14, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Cain crypt: Kobold Desecrator, 8 yd from the crypt mouth');
