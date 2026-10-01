-- A Quiet Life 200081 (Templar, CoA questcache: "Visit the hidden statue in the western mountains of Deathknell")
-- names no point; no QuestSuperTrack row, atlas sighting or cached statue object exists, so the statue and its
-- credit marker are placed by hand (rev_20260923_09). That spot lay on the road up to the Cain Family Estate
-- (TIRISFALLSTONEROAD01 weight 0.8). Both move 12 yd west into the slope, 4.9 yd off the road (surface.standable,
-- slope 16) (INFERRED).
UPDATE `gameobject` SET `position_x` = 1836.01, `position_y` = 1781.97, `position_z` = 123.36
    WHERE `guid` = 7912409 AND `id` = 9301257;
UPDATE `creature` SET `position_x` = 1836.01, `position_y` = 1781.97, `position_z` = 123.36
    WHERE `guid` = 9003728 AND `id` = 685037;
