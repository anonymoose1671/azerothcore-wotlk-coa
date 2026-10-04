-- The Cruel Carrion Spirit wears the Ghost Visual 22650 like the Hyena Spirit. Its spawn's own addon row, which
-- carries its flight path, overrides the template's, so both carry the aura.
DELETE FROM `creature_template_addon` WHERE `entry` = 161834;
INSERT INTO `creature_template_addon` (`entry`, `path_id`, `mount`, `bytes1`, `bytes2`, `emote`, `visibilityDistanceType`,
    `auras`) VALUES
(161834, 0, 0, 0, 1, 0, 0, '22650');
UPDATE `creature_addon` SET `auras` = '22650' WHERE `guid` = 9011005;
