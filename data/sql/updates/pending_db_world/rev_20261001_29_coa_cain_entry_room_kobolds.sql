-- Cain Family Crypt: the three Kobold Desecrators of the lowest hall (z 124; 9010130 and 9010131 from
-- rev_20260926_10, 9010904 from rev_20261001_14) move up to the first room inside the entrance (z 150, the room the
-- entry stairs open into): one at the foot of the stairs and one at each end of the room (surface.standable on
-- the crypt floor, clearance 0.9), facing the room's centre (playtest). The lowest hall keeps the relatives' remains.
-- The Ghoul 9010051 by the candle table on the green rug in the manor's east hall goes (playtest: three ghouls
-- inside); six remain for The Friends We Make Along the Way 1660029 (needs 5).
UPDATE `creature` SET `position_x` = 1798, `position_y` = 1966, `position_z` = 150.95, `orientation` = 2.18
    WHERE `guid` = 9010130 AND `id` = 161751;
UPDATE `creature` SET `position_x` = 1786, `position_y` = 1971, `position_z` = 150.064, `orientation` = 6.13
    WHERE `guid` = 9010131 AND `id` = 161751;
UPDATE `creature` SET `position_x` = 1803, `position_y` = 1962, `position_z` = 150.102, `orientation` = 2.33
    WHERE `guid` = 9010904 AND `id` = 161751;
DELETE FROM `creature` WHERE `guid` = 9010051 AND `id` = 161752;
