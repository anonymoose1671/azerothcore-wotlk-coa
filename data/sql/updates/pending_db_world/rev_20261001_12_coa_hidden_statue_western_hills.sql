-- A Quiet Life 200081 (Templar, CoA questcache: "Visit the hidden statue in the western mountains of Deathknell")
-- names no point; no QuestSuperTrack row, atlas sighting or cached statue object exists, so the statue and its
-- credit marker are placed by hand (INFERRED). rev_20260923_09 put them on the road up to the Cain Family Estate.
-- They move to a secluded shelf in the western mountains, 87 yd above the village, 290 yd from the estate gate and
-- 140 yd from any other spawn, reachable on foot (terrain no steeper than 45 degrees), on open ground (surface.check:
-- slope 24, no walls, no models within 6 yd); the statue faces down the valley toward the village.
UPDATE `gameobject` SET `position_x` = 1615, `position_y` = 1916, `position_z` = 181.787, `orientation` = 5.3518,
    `rotation2` = 0.44903, `rotation3` = -0.893517 WHERE `guid` = 7912409 AND `id` = 9301257;
UPDATE `creature` SET `position_x` = 1615, `position_y` = 1916, `position_z` = 181.787
    WHERE `guid` = 9003728 AND `id` = 685037;
