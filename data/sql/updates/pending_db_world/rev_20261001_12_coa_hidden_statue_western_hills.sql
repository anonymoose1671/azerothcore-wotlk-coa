-- A Quiet Life 200081 (Templar, CoA questcache: "Visit the hidden statue in the western mountains of Deathknell")
-- names no point; no QuestSuperTrack row, atlas sighting or cached statue object exists, so the statue and its
-- credit marker are placed by hand (INFERRED). rev_20260923_09 put them on the road up to the Cain Family Estate.
-- They move to a gap in the western mountains above the village that the author picked in game, as the quest text
-- describes ("hidden away in a gap in the mountain"): at the foot of the gap's north slope, on open ground
-- (surface.check: slope 16, no walls or models), facing the gap's mouth to the south, where players climb in.
UPDATE `gameobject` SET `position_x` = 1692, `position_y` = 1794, `position_z` = 154.45, `orientation` = 4.8367,
    `rotation2` = 0.661803, `rotation3` = -0.749678 WHERE `guid` = 7912409 AND `id` = 9301257;
UPDATE `creature` SET `position_x` = 1692, `position_y` = 1794, `position_z` = 154.45
    WHERE `guid` = 9003728 AND `id` = 685037;
