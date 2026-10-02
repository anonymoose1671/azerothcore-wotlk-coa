-- Necrotic Bears 161743 on the Cain estate move toward the estate's edges, so its field, paths and lake shore
-- stay clear (playtest). Each wandering bear's whole 5 yd wander circle, plus 1.5 yd, is walkable terrain (slope
-- <= 35 degrees, no building, water or 4 yd height step) and at least 6 yd from the stone and pebble paths; bears
-- stay 20+ yd apart, in the same area, and 30+ yd from the quest camp. 9010083 behind the tomb keeps its place but stands still: even 2 yd of
-- wander there reaches the slope.
UPDATE `creature` SET `position_x` = 1801.9, `position_y` = 1936.4, `position_z` = 157.016, `wander_distance` = 5
    WHERE `guid` = 9010080 AND `id` = 161743;
UPDATE `creature` SET `position_x` = 1961.3, `position_y` = 1931.9, `position_z` = 156.075, `wander_distance` = 5
    WHERE `guid` = 9010081 AND `id` = 161743;
UPDATE `creature` SET `position_x` = 1976.8, `position_y` = 1952.1, `position_z` = 155.416, `wander_distance` = 5
    WHERE `guid` = 9010082 AND `id` = 161743;
UPDATE `creature` SET `wander_distance` = 0, `MovementType` = 0 WHERE `guid` = 9010083 AND `id` = 161743;
UPDATE `creature` SET `position_x` = 1878, `position_y` = 1900, `position_z` = 158.877, `wander_distance` = 5
    WHERE `guid` = 9010084 AND `id` = 161743;
UPDATE `creature` SET `position_x` = 1909.8, `position_y` = 1984, `position_z` = 158.127, `wander_distance` = 5
    WHERE `guid` = 9010085 AND `id` = 161743;
UPDATE `creature` SET `position_x` = 1826, `position_y` = 1889, `position_z` = 157.475, `wander_distance` = 5
    WHERE `guid` = 9010086 AND `id` = 161743;
UPDATE `creature` SET `position_x` = 1965, `position_y` = 1970, `position_z` = 155.685, `wander_distance` = 5
    WHERE `guid` = 9010087 AND `id` = 161743;
