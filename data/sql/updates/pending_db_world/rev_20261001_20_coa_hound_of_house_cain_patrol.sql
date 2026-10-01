-- Hound of House Cain 161836 (I'm Home 1660042) sank below ground (issues 5862, 5931): he wandered 3 yd around his
-- grave (ST8718), which lies at the manor's back wall above its cellar, and random movement could take him onto
-- the cellar's walkable floor beneath. He now patrols the back of the house above ground instead: from his grave
-- along the back (west) wall to the north-west corner and back, pausing 6 s at each end. Every point is open
-- terrain (surface.standable, clearance 1.2, no water, slope <= 25), 51.6 yd each way (INFERRED route).
UPDATE `creature` SET `wander_distance` = 0, `MovementType` = 2 WHERE `guid` = 9010012 AND `id` = 161836;
DELETE FROM `creature_addon` WHERE `guid` = 9010012;
INSERT INTO `creature_addon` (`guid`, `path_id`, `mount`, `bytes1`, `bytes2`, `emote`, `visibilityDistanceType`, `auras`) VALUES
(9010012, 90100120, 0, 0, 0, 0, 0, '');
DELETE FROM `waypoint_data` WHERE `id` = 90100120;
INSERT INTO `waypoint_data` (`id`, `point`, `position_x`, `position_y`, `position_z`, `orientation`, `velocity`, `delay`, `smoothTransition`, `move_type`, `action`, `action_chance`, `wpguid`) VALUES
(90100120, 1, 1942.72, 1985.06, 156.079, NULL, 0, 6000, 0, 0, 0, 100, 0),
(90100120, 2, 1942, 1990.5, 156.454, NULL, 0, 0, 0, 0, 0, 100, 0),
(90100120, 3, 1937, 1994.0, 155.77, NULL, 0, 0, 0, 0, 0, 100, 0),
(90100120, 4, 1932, 1993.5, 156.384, NULL, 0, 0, 0, 0, 0, 100, 0),
(90100120, 5, 1927, 1996.0, 156.976, NULL, 0, 0, 0, 0, 0, 100, 0),
(90100120, 6, 1922, 1996.5, 158.057, NULL, 0, 0, 0, 0, 0, 100, 0),
(90100120, 7, 1917, 2001.0, 158.013, NULL, 0, 0, 0, 0, 0, 100, 0),
(90100120, 8, 1912, 2002.5, 158.049, NULL, 0, 0, 0, 0, 0, 100, 0),
(90100120, 9, 1907, 1997.5, 158.128, NULL, 0, 0, 0, 0, 0, 100, 0),
(90100120, 10, 1902, 1996.0, 156.864, NULL, 0, 6000, 0, 0, 0, 100, 0),
(90100120, 11, 1907, 1997.5, 158.128, NULL, 0, 0, 0, 0, 0, 100, 0),
(90100120, 12, 1912, 2002.5, 158.049, NULL, 0, 0, 0, 0, 0, 100, 0),
(90100120, 13, 1917, 2001.0, 158.013, NULL, 0, 0, 0, 0, 0, 100, 0),
(90100120, 14, 1922, 1996.5, 158.057, NULL, 0, 0, 0, 0, 0, 100, 0),
(90100120, 15, 1927, 1996.0, 156.976, NULL, 0, 0, 0, 0, 0, 100, 0),
(90100120, 16, 1932, 1993.5, 156.384, NULL, 0, 0, 0, 0, 0, 100, 0),
(90100120, 17, 1937, 1994.0, 155.77, NULL, 0, 0, 0, 0, 0, 100, 0),
(90100120, 18, 1942, 1990.5, 156.454, NULL, 0, 0, 0, 0, 0, 100, 0),
(90100120, 19, 1947, 1993.0, 156.986, NULL, 0, 0, 0, 0, 0, 100, 0);
