-- Three more Kobold Desecrators 161751 inside the Cain Family Crypt, in the chambers that stood empty: the lower
-- hall's north end, the west chamber and the small bone chamber north of the lower hall (on its floor at 125.15; a
-- collision slab 6.5 yd above it is not floor). Each is 12.7-14.8 yd from the four already
-- there and 6+ yd from the relatives' remains, so the passages stay clear (surface.standable on
-- Deathknell_Cainfamilycrypt.wmo); they face the crypt's centre (INFERRED).
DELETE FROM `creature` WHERE `guid` IN (9010904, 9010905, 9010906);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `equipment_id`, `position_x`, `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curhealth`, `curmana`, `MovementType`, `npcflag`, `unit_flags`, `dynamicflags`, `ScriptName`, `VerifiedBuild`, `CreateObject`, `Comment`) VALUES
(9010904, 161751, 0, 0, 0, 1, 1, 0, 1772, 1979, 124.202, 4.96, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Cain crypt: Kobold Desecrator; lower hall, north end'),
(9010905, 161751, 0, 0, 0, 1, 1, 0, 1766, 1953, 132.544, 0.17, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Cain crypt: Kobold Desecrator; west chamber'),
(9010906, 161751, 0, 0, 0, 1, 1, 0, 1787.6, 1982, 125.154, 4.37, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0, 'CoA Cain crypt: Kobold Desecrator; bone chamber north of the lower hall');
