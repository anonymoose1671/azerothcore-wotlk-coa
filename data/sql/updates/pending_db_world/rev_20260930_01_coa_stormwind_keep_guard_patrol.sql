-- Stormwind Keep: the Royal Guard patrol 105270 (guard 10527) turned around inside the fountain at the top of the
-- keep steps (playtest); it now turns on the keep terrace before the grass bed and the fountain
UPDATE `waypoint_data` SET `position_x` = -8482.5, `position_y` = 385, `position_z` = 115.86
WHERE `id` = 105270 AND `point` IN (6, 8);
UPDATE `waypoint_data` SET `position_x` = -8481.9, `position_y` = 384.3, `position_z` = 115.86
WHERE `id` = 105270 AND `point` = 7;
