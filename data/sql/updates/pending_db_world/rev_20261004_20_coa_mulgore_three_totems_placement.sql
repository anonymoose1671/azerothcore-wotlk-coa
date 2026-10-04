-- Three Totems (Mulgore, Red Cloud Mesa and the Grimtotem camp above it), placed in game with CoAWorldEdit:
-- 33 Grimtotem Marauders and Patrols, both door Guards and four Tallstriders removed to thin the camp, eight Offering
-- Bones removed and six moved onto their ledges, one bone added in game and five mobs moved. Worldforged pickups are
-- set on the ground: the Ancestor's Axe, the Cord of Reverence, two Exalted Pendants, the Sun Touched Club and the
-- Grimtotem Bow moved; a third Pendant and the Grimtotem Club on the cliff removed.
-- Every value is the spawn as it was left in game.
-- The patrols follow the map rather than the recorded route: the Grimtotem Patrol walks the plank path (its
-- WC_BenchStone slabs) from the village gate to Malgorm's hut, and a second Patrol walks from the gate down the
-- Grimtotem Mountain Path over its plank crossings to the lower gate totems, and the Patrol at the lowest crossing
-- walks on down into the valley to the hut camp and the signpost. All turn back with an 8 s pause at each end;
-- the navmesh joins their nodes, which are the slabs and gate totems of the ADT and points taken in game. Three
-- Battlefield Scavengers placed in game circle over the path, a fourth sits on the rock above Hard Basin, and the
-- Hyena Spirit stands where it was placed in game.
DELETE FROM `creature` WHERE `guid` IN (
    9011028, 9011033, 9011052, 9011034, 9011046, 9011035, 9011061, 9011042, 9011013, 9011012,
    9011038, 9011040, 9011015, 9011014, 9011020, 9011043, 9011021, 9011048, 9011018, 9011039,
    9011019, 9011024, 9011023, 9011022, 9011041, 9011016, 9011025, 9011045, 9011064, 9011070,
    9011071, 9011103, 9011102, 9011065, 9011066, 9011084, 9011085, 9011086, 9011087
);

DELETE FROM `gameobject` WHERE `guid` IN (
    7916534, 7916544, 7916539, 7916538, 7916537, 7916536, 7916542, 7916541, 7916522,
    6941797, 7916546
);
INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `position_x`, `position_y`,
    `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`,
    `state`, `Comment`) VALUES
(7916546, 2300532, 1, 0, 0, 1, 1, -3500.771, -810.602, 101.397, 1.0705,
    0.1122712, 0.0665758, -0.5056925, -0.8527825, 300, 0, 1,
    'CoA Three Totems: Offering Bone on the upper ledge, placed in game');

UPDATE `gameobject` SET `position_x` = -3483, `position_y` = -838, `position_z` = 84.701, `orientation` = 1.2146,
    `rotation0` = 0, `rotation1` = 0, `rotation2` = -0.5706523, `rotation3` = -0.8211918
    WHERE `guid` = 7916531 AND `id` = 2300532;
UPDATE `gameobject` SET `position_x` = -3456, `position_y` = -869, `position_z` = 73.504, `orientation` = 3.1,
    `rotation0` = 0, `rotation1` = 0, `rotation2` = -0.9997838, `rotation3` = -0.0207949
    WHERE `guid` = 7916545 AND `id` = 2300532;
UPDATE `gameobject` SET `position_x` = -3483.679, `position_y` = -916.532, `position_z` = 100.888,
    `orientation` = 6.1596,
    `rotation0` = 0, `rotation1` = 0, `rotation2` = -0.0617532, `rotation3` = 0.9980915
    WHERE `guid` = 7916532 AND `id` = 2300532;
UPDATE `gameobject` SET `position_x` = -3408.487, `position_y` = -923.89, `position_z` = 96.652, `orientation` = 5.1,
    `rotation0` = 0, `rotation1` = 0, `rotation2` = -0.5576838, `rotation3` = 0.8300536
    WHERE `guid` = 7916533 AND `id` = 2300532;
UPDATE `gameobject` SET `position_x` = -3462.089, `position_y` = -759.489, `position_z` = 126.091,
    `orientation` = 1.1618,
    `rotation0` = 0, `rotation1` = 0, `rotation2` = -0.5487766, `rotation3` = -0.8359692
    WHERE `guid` = 7916535 AND `id` = 2300532;
UPDATE `gameobject` SET `position_x` = -3572.5, `position_y` = -909, `position_z` = 181.119, `orientation` = 4.4,
    `rotation0` = -0.1055302, `rotation1` = -0.076815, `rotation2` = -0.8015797, `rotation3` = 0.5834665
    WHERE `guid` = 7916543 AND `id` = 2300532;
UPDATE `gameobject` SET `position_x` = -3347.371, `position_y` = -1022.166, `position_z` = 105.994,
    `orientation` = 0.9836,
    `rotation0` = -0.6233047, `rotation1` = -0.3339059, `rotation2` = 0.3339047, `rotation3` = 0.6233025
    WHERE `guid` = 6941395 AND `id` = 90220;
UPDATE `gameobject` SET `position_x` = -3049.759, `position_y` = -1138.55, `position_z` = 64.041,
    `orientation` = 6.1886,
    `rotation0` = -0.0102314, `rotation1` = -0.2161818, `rotation2` = -0.0461546, `rotation3` = 0.9752079
    WHERE `guid` = 6941585 AND `id` = 254522;
UPDATE `gameobject` SET `position_x` = -3466.83, `position_y` = -1092.99, `position_z` = 207.478, `orientation` = 0,
    `rotation0` = 0, `rotation1` = 0, `rotation2` = 0, `rotation3` = 1
    WHERE `guid` = 7916521 AND `id` = 2300515;
UPDATE `gameobject` SET `position_x` = -3471.52, `position_y` = -1096.94, `position_z` = 207.432,
    `orientation` = 5.2124,
    `rotation0` = 0, `rotation1` = 0, `rotation2` = -0.5101788, `rotation3` = 0.8600685
    WHERE `guid` = 7916520 AND `id` = 2300515;
UPDATE `gameobject` SET `position_x` = -3552.999, `position_y` = -1210.354, `position_z` = 206.048,
    `orientation` = 4.4873,
    `rotation0` = 0, `rotation1` = 0, `rotation2` = -0.7820465, `rotation3` = 0.6232202
    WHERE `guid` = 6942270 AND `id` = 520700;
UPDATE `gameobject` SET `position_x` = -3641.917, `position_y` = -1032.398, `position_z` = 204.614,
    `orientation` = 0.546,
    `rotation0` = -0.7376661, `rotation1` = -0.2065396, `rotation2` = 0.1733124, `rotation3` = 0.6189936
    WHERE `guid` = 6941796 AND `id` = 520699;

UPDATE `creature` SET `position_x` = -3331.774, `position_y` = -766.01, `position_z` = 51.391, `orientation` = 2.8562
    WHERE `guid` = 9011049;
UPDATE `creature` SET `position_x` = -3516.838, `position_y` = -848.051, `position_z` = 105.246, `orientation` = 5.5305
    WHERE `guid` = 9011036;
UPDATE `creature` SET `position_x` = -3587.285, `position_y` = -1130.135, `position_z` = 205.341, `orientation` = 0.1827
    WHERE `guid` = 9011122;
UPDATE `creature` SET `position_x` = -3590.697, `position_y` = -953.126, `position_z` = 200.305,
    `orientation` = 4.5291, `MovementType` = 2, `wander_distance` = 0
    WHERE `guid` = 9011069;
UPDATE `creature` SET `position_x` = -3628.05, `position_y` = -1035.92, `position_z` = 203.14, `orientation` = 0.1913
    WHERE `guid` = 9011002;

DELETE FROM `creature` WHERE `guid` IN (9011133, 9011134, 9011135, 9011136, 9011137);
INSERT INTO `creature` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `equipment_id`, `position_x`,
    `position_y`, `position_z`, `orientation`, `spawntimesecs`, `wander_distance`, `currentwaypoint`, `curhealth`,
    `curmana`,
    `MovementType`, `npcflag`, `unit_flags`, `dynamicflags`, `ScriptName`, `VerifiedBuild`, `CreateObject`,
    `Comment`) VALUES
(9011133, 161810, 1, 0, 0, 1, 1, 0, -3584.7, -944.6, 198.1, 1.5, 300, 0, 0, 1, 0, 2, 0, 0, 0, '', NULL, 0,
    'CoA Three Totems: Grimtotem Patrol walking from the village gate down the Grimtotem Mountain Path and back'),
(9011134, 161812, 1, 0, 0, 1, 1, 0, -3530.398, -772.371, 142.572, 3.11, 300, 6, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0,
    'CoA Three Totems: Battlefield Scavenger placed in game over the Grimtotem Mountain Path'),
(9011135, 161812, 1, 0, 0, 1, 1, 0, -3489.439, -836.478, 88.281, 5.8, 300, 6, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0,
    'CoA Three Totems: Battlefield Scavenger placed in game over the Grimtotem Mountain Path'),
(9011136, 161812, 1, 0, 0, 1, 1, 0, -3409.096, -927.926, 96.248, 3.13, 300, 6, 0, 1, 0, 1, 0, 0, 0, '', NULL, 0,
    'CoA Three Totems: Battlefield Scavenger placed in game over the Grimtotem Mountain Path'),
(9011137, 161812, 1, 0, 0, 1, 1, 0, -3530.873, -1039.195, 219.807, 4.8477, 300, 0, 0, 1, 0, 0, 0, 0, 0, '', NULL, 0,
    'CoA Three Totems: Battlefield Scavenger perched on the rock above the Hard Basin battlefield, placed in game');

UPDATE `creature` SET `MovementType` = 2, `wander_distance` = 0 WHERE `guid` = 9011062;
UPDATE `creature` SET `position_x` = -3619.486, `position_y` = -959.45, `position_z` = 205.057, `orientation` = 5.2067
    WHERE `guid` = 9011003;

DELETE FROM `creature_addon` WHERE `guid` IN (9011069, 9011133, 9011062, 9011137);
INSERT INTO `creature_addon` (`guid`, `path_id`, `mount`, `bytes1`, `bytes2`, `emote`, `visibilityDistanceType`,
    `auras`) VALUES
(9011069, 90110690, 0, 0, 0, 0, 0, NULL),
(9011133, 90111330, 0, 0, 0, 0, 0, NULL),
(9011062, 90110620, 0, 0, 0, 0, 0, NULL),
(9011137, 0, 0, 1, 0, 0, 0, NULL);

DELETE FROM `waypoint_data` WHERE `id` IN (90110690, 90111330, 90110620);
INSERT INTO `waypoint_data` (`id`, `point`, `position_x`, `position_y`, `position_z`, `orientation`, `velocity`,
    `delay`,
    `smoothTransition`, `move_type`, `action`, `action_chance`, `wpguid`) VALUES
(90110690, 1, -3589.5, -954, 199.4, NULL, 0, 8000, 0, 0, 0, 100, 0),
(90110690, 2, -3590, -956.3, 200.4, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 3, -3594.2, -966.4, 201.35, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 4, -3594.65, -984.15, 203.15, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 5, -3594.4, -992.3, 203.1, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 6, -3594.8, -1003.8, 202.75, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 7, -3592.2, -1014.7, 202.6, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 8, -3582.25, -1022.55, 202.75, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 9, -3577.85, -1031.4, 202.8, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 10, -3574.25, -1041.35, 203.05, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 11, -3574.3, -1050.6, 203.1, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 12, -3577.65, -1060.1, 203.1, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 13, -3577.6, -1068.2, 203.1, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 14, -3577.5, -1078.15, 203.25, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 15, -3577.35, -1092.35, 203.75, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 16, -3577, -1104, 204.1, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 17, -3575.2, -1117.15, 204.6, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 18, -3573.25, -1134.4, 204.65, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 19, -3579.1, -1144.75, 204.75, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 20, -3582.4, -1153.3, 204.8, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 21, -3579.65, -1164.9, 204.75, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 22, -3578.9, -1173.6, 204.8, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 23, -3575.3, -1184.2, 204.8, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 24, -3571, -1193.1, 204.9, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 25, -3559.8, -1197.9, 204.85, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 26, -3548.65, -1200.2, 204.9, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 27, -3538.9, -1201.7, 205.25, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 28, -3519.9, -1203.15, 207.15, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 29, -3508.5, -1200.3, 209.6, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 30, -3499.8, -1195.9, 211.8, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 31, -3484.45, -1184.3, 213.55, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 32, -3472.7, -1185.2, 213.9, NULL, 0, 8000, 0, 0, 0, 100, 0),
(90110690, 33, -3484.45, -1184.3, 213.55, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 34, -3499.8, -1195.9, 211.8, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 35, -3508.5, -1200.3, 209.6, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 36, -3519.9, -1203.15, 207.15, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 37, -3538.9, -1201.7, 205.25, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 38, -3548.65, -1200.2, 204.9, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 39, -3559.8, -1197.9, 204.85, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 40, -3571, -1193.1, 204.9, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 41, -3575.3, -1184.2, 204.8, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 42, -3578.9, -1173.6, 204.8, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 43, -3579.65, -1164.9, 204.75, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 44, -3582.4, -1153.3, 204.8, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 45, -3579.1, -1144.75, 204.75, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 46, -3573.25, -1134.4, 204.65, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 47, -3575.2, -1117.15, 204.6, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 48, -3577, -1104, 204.1, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 49, -3577.35, -1092.35, 203.75, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 50, -3577.5, -1078.15, 203.25, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 51, -3577.6, -1068.2, 203.1, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 52, -3577.65, -1060.1, 203.1, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 53, -3574.3, -1050.6, 203.1, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 54, -3574.25, -1041.35, 203.05, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 55, -3577.85, -1031.4, 202.8, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 56, -3582.25, -1022.55, 202.75, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 57, -3592.2, -1014.7, 202.6, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 58, -3594.8, -1003.8, 202.75, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 59, -3594.4, -992.3, 203.1, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 60, -3594.65, -984.15, 203.15, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 61, -3594.2, -966.4, 201.35, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 62, -3590, -956.3, 200.4, NULL, 0, 0, 0, 0, 0, 100, 0),
(90111330, 1, -3584.7, -944.6, 198.1, NULL, 0, 8000, 0, 0, 0, 100, 0),
(90111330, 2, -3582.9, -940.9, 196.6, NULL, 0, 0, 0, 0, 0, 100, 0),
(90111330, 3, -3571.6, -906.1, 178.1, NULL, 0, 0, 0, 0, 0, 100, 0),
(90111330, 4, -3573.6, -861, 169.8, NULL, 0, 0, 0, 0, 0, 100, 0),
(90111330, 5, -3489.7, -897.9, 103.75, NULL, 0, 0, 0, 0, 0, 100, 0),
(90111330, 6, -3451, -910.65, 112.55, NULL, 0, 0, 0, 0, 0, 100, 0),
(90111330, 7, -3442.65, -900.5, 110.6, NULL, 0, 8000, 0, 0, 0, 100, 0),
(90111330, 8, -3451, -910.65, 112.55, NULL, 0, 0, 0, 0, 0, 100, 0),
(90111330, 9, -3489.7, -897.9, 103.75, NULL, 0, 0, 0, 0, 0, 100, 0),
(90111330, 10, -3573.6, -861, 169.8, NULL, 0, 0, 0, 0, 0, 100, 0),
(90111330, 11, -3571.6, -906.1, 178.1, NULL, 0, 0, 0, 0, 0, 100, 0),
(90111330, 12, -3582.9, -940.9, 196.6, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110620, 1, -3480.545, -899.752, 107.024, NULL, 0, 8000, 0, 0, 0, 100, 0),
(90110620, 2, -3442.65, -900.5, 110.6, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110620, 3, -3409.096, -927.926, 96.248, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110620, 4, -3367.3, -915.1, 70.8, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110620, 5, -3344.3, -842.5, 51, NULL, 0, 8000, 0, 0, 0, 100, 0),
(90110620, 6, -3367.3, -915.1, 70.8, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110620, 7, -3409.096, -927.926, 96.248, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110620, 8, -3442.65, -900.5, 110.6, NULL, 0, 0, 0, 0, 0, 100, 0);
