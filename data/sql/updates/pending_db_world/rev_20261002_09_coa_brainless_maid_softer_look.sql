-- Brainless Maid 161754 gets the author's softer look: a Forsaken woman (display 58 with a preset, like the class
-- trainers) in the Buccaneer's Robes appearance (item display 22298), with long full hair (style 4, the longest
-- Forsaken female hair mesh) in pale blonde (colour 13), keeping skin 3 and face 8 of her old display 1639. The
-- maid behind the manor sits a little higher up the lake shore at the author's spot, still facing the water.
DELETE FROM `creature_template_model` WHERE `CreatureID` = 161754;
INSERT INTO `creature_template_model` (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`) VALUES
(161754, 0, 58, 1, 1);
DELETE FROM `creature_display_preset` WHERE `entry` = 161754;
INSERT INTO `creature_display_preset` (`entry`, `display_id`, `race`, `gender`, `class`, `skin`, `face`, `hair`,
    `haircolor`, `facialhair`, `guild_id`, `item_head`, `item_shoulders`, `item_body`, `item_chest`, `item_waist`,
    `item_legs`, `item_feet`, `item_wrists`, `item_hands`, `item_back`, `item_tabard`) VALUES
(161754, 58, 5, 1, 1, 3, 8, 4, 13, 0, 0, 0, 0, 0, 22298, 0, 0, 0, 0, 0, 0, 0);
UPDATE `creature` SET `position_x` = 1914.03, `position_y` = 2003.58, `position_z` = 157.553
    WHERE `guid` = 9010008 AND `id` = 161754;
