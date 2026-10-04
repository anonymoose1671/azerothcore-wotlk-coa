-- An Exalted Pendant 2300515 sparkled and stayed clickable for the whole of Death and Dishonor 1660032 because its
-- chest questId (Data8) names the quest. Without it, a pendant is active only while the player still needs one.
UPDATE `gameobject_template` SET `Data8` = 0 WHERE `entry` = 2300515;
