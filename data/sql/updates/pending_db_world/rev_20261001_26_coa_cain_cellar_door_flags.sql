-- The Cain manor cellar door 2300524 takes the flags of the stock key-locked doors (Scarlet Monastery 101850-
-- 101854, Workshop Door 90566: 34 = locked + no despawn) instead of locked alone (rev_20260926_10).
UPDATE `gameobject_template_addon` SET `flags` = 34 WHERE `entry` = 2300524;
