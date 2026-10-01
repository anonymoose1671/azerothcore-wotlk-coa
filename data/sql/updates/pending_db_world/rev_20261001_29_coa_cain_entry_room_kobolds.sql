-- Cain Family Crypt: the three Kobold Desecrators of the lowest hall (z 124; 9010130 and 9010131 from
-- rev_20260926_10, 9010904 from rev_20261001_14) move up to the first room inside the entrance (z 141.4): one at the
-- foot of the entry stairs and one at each end of the room, at positions and facings taken in game with .gps
-- (playtest). The lowest hall keeps the relatives' remains.
-- The Ghoul 9010051 by the candle table on the green rug in the manor's east hall goes (playtest: three ghouls
-- inside); six remain for The Friends We Make Along the Way 1660029 (needs 5).
UPDATE `creature` SET `position_x` = 1799.7672, `position_y` = 1967.7028, `position_z` = 141.4438,
    `orientation` = 2.9006 WHERE `guid` = 9010130 AND `id` = 161751;
UPDATE `creature` SET `position_x` = 1782.4592, `position_y` = 1972.5784, `position_z` = 141.4452,
    `orientation` = 4.491 WHERE `guid` = 9010131 AND `id` = 161751;
UPDATE `creature` SET `position_x` = 1768.4216, `position_y` = 1981.9938, `position_z` = 141.4457,
    `orientation` = 5.6337 WHERE `guid` = 9010904 AND `id` = 161751;
DELETE FROM `creature` WHERE `guid` = 9010051 AND `id` = 161752;
