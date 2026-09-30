-- Northshire vineyards: 35 of the 70 Defias Thugs removed (playtest: far too dense with the CoA Defias
-- Trainees); the kept Thugs and Trainees stand at least 18 yd apart. The Northshire Defias stay hostile
-- but only engage within 5-8 yd (detection 6 before the level adjustment and the 5 yd floor).
UPDATE `creature_template` SET `detection_range` = 6 WHERE `entry` IN (38, 103, 537, 9300100);
DELETE FROM `smart_scripts` WHERE `source_type` = 0 AND `entryorguid` IN (
-80149, -80152, -80153, -80155, -80162, -80168, -80169, -80174, -80182, -80183, -80185, -80186, -80188,
-80189, -80190, -80193, -80195, -80196, -80201, -80208, -80210, -80211, -80213, -80226, -80230, -80231,
-80237, -80246, -80251, -80253, -80254, -80255, -80256, -80257, -80259);
DELETE FROM `creature_addon` WHERE `guid` IN (
80149, 80152, 80153, 80155, 80162, 80168, 80169, 80174, 80182, 80183, 80185, 80186, 80188, 80189, 80190,
80193, 80195, 80196, 80201, 80208, 80210, 80211, 80213, 80226, 80230, 80231, 80237, 80246, 80251, 80253,
80254, 80255, 80256, 80257, 80259);
-- Mirror Lake Orchard: 4 of the Spada manor Defias moved there earlier removed, and one Cutpurse (gen_elwynn);
-- 12 Defias -> 7 (playtest: ~40-50% less dense).
DELETE FROM `creature` WHERE `id` IN (116, 474) AND `guid` IN (80384, 80386, 80387, 80412);
DELETE FROM `creature` WHERE `id` = 38 AND `guid` IN (
80149, 80152, 80153, 80155, 80162, 80168, 80169, 80174, 80182, 80183, 80185, 80186, 80188, 80189, 80190,
80193, 80195, 80196, 80201, 80208, 80210, 80211, 80213, 80226, 80230, 80231, 80237, 80246, 80251, 80253,
80254, 80255, 80256, 80257, 80259);
