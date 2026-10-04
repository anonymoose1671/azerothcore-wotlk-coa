-- Three Totems (Mulgore, Red Cloud Mesa and the Grimtotem camp above it), placed in game with CoAWorldEdit:
-- 30 Grimtotem Marauders and Patrols and one Guard removed to thin the hillsides, eight Offering Bones removed and
-- six moved onto their ledges, one bone added in game, five mobs moved, and the Grimtotem Patrol walks a route
-- through the camp. Worldforged pickups nearby are set on the ground: the Ancestor's Axe, the Cord of Reverence,
-- two Exalted Pendants and the Sun Touched Club moved; a third Pendant and the Grimtotem Club on the cliff removed.
-- Every value is the spawn as it was left in game.
DELETE FROM `creature` WHERE `guid` IN (
    9011028, 9011033, 9011052, 9011034, 9011046, 9011035, 9011061, 9011042, 9011013, 9011012,
    9011038, 9011040, 9011015, 9011014, 9011020, 9011043, 9011021, 9011048, 9011018, 9011039,
    9011019, 9011024, 9011023, 9011022, 9011041, 9011016, 9011025, 9011045, 9011064, 9011070,
    9011103
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

DELETE FROM `creature_addon` WHERE `guid` = 9011069;
INSERT INTO `creature_addon` (`guid`, `path_id`, `mount`, `bytes1`, `bytes2`, `emote`, `visibilityDistanceType`,
    `auras`) VALUES
(9011069, 90110690, 0, 0, 0, 0, 0, NULL);

DELETE FROM `waypoint_data` WHERE `id` = 90110690;
INSERT INTO `waypoint_data` (`id`, `point`, `position_x`, `position_y`, `position_z`, `orientation`, `velocity`,
    `delay`,
    `smoothTransition`, `move_type`, `action`, `action_chance`, `wpguid`) VALUES
(90110690, 1, -3592.003, -953.236, 200.566, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 2, -3577.706, -1066.606, 203.685, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 3, -3576.882, -1099.82, 204.483, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 4, -3571.036, -1127.584, 205.08, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 5, -3581.619, -1158.723, 205.31, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 6, -3568.683, -1196.495, 205.434, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 7, -3544.996, -1199.67, 205.531, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 8, -3514.398, -1201.959, 208.681, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 9, -3491.766, -1191.339, 213.279, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 10, -3486.779, -1176.184, 214.098, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 11, -3470.575, -1179.757, 214.116, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 12, -3469.32, -1192.451, 214.12, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 13, -3489.94, -1195.459, 213.296, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 14, -3503.519, -1198.747, 211.268, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 15, -3525.284, -1201.563, 206.841, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 16, -3569.093, -1195.68, 205.43, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 17, -3580.167, -1169.392, 205.32, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 18, -3577.943, -1143.678, 205.392, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 19, -3573.163, -1135.569, 205.271, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 20, -3573.465, -1119.905, 205.047, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 21, -3576.834, -1106.819, 204.722, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 22, -3577.439, -1064.273, 203.669, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 23, -3574.323, -1044.203, 203.642, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 24, -3585.718, -1017.756, 203.251, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 25, -3595.969, -1000.743, 203.432, NULL, 0, 0, 0, 0, 0, 100, 0),
(90110690, 26, -3592.256, -962.069, 201.47, NULL, 0, 0, 0, 0, 0, 100, 0);
