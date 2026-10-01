-- Cain Family Crypt surface: the three Kobold Desecrators of rev_20261001_10 and the Necrotic Bear 9010083 bunched on
-- the crypt's entrance side (playtest). They spread around the back of the tomb instead: the tomb's roof outline
-- (centre 1791.1, 1953.4, radius 15.1, entrance to the north-east) gives an arc behind it, and each stands on open
-- terrain 2.5-4 yd off its walls (surface.standable), about 12 yd from the next. The kobolds face the tomb; the bear
-- wanders 4 yd instead of 8 so it does not drift into them.
UPDATE `creature` SET `position_x` = 1774.42, `position_y` = 1958.91, `position_z` = 154.725, `orientation` = 5.96
    WHERE `guid` = 9010901 AND `id` = 161751;
UPDATE `creature` SET `position_x` = 1782.03, `position_y` = 1936.57, `position_z` = 156.21, `orientation` = 1.08
    WHERE `guid` = 9010902 AND `id` = 161751;
UPDATE `creature` SET `position_x` = 1804.89, `position_y` = 1942.45, `position_z` = 156.413, `orientation` = 2.47
    WHERE `guid` = 9010903 AND `id` = 161751;
UPDATE `creature` SET `position_x` = 1774.76, `position_y` = 1946.88, `position_z` = 154.217, `orientation` = 0.38,
    `wander_distance` = 4 WHERE `guid` = 9010083 AND `id` = 161743;
