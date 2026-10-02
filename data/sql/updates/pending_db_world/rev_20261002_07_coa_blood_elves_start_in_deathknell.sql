-- Blood elves start in Deathknell beside the Undead, at the Undead start, instead of on Sunstrider Isle. Death
-- Knights keep Ebon Hold.
UPDATE `playercreateinfo` SET `map` = 0, `zone` = 85, `position_x` = 1676.71, `position_y` = 1678.31,
`position_z` = 121.67, `orientation` = 2.70526 WHERE `race` = 10 AND `class` <> 6;
