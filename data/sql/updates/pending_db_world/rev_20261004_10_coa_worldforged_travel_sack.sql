-- The realm map labels two different pickups "Travel Sack": the Travel Sack bag 450510 (pickup 95612) and the sack
-- holding Break-time Gloves 515267 (pickup 68403). 2026_09_23_05_worldforged_map stood 68403 on every such marker,
-- so a level 46 item floated in Red Cloud Mesa, Mulgore and Shadowglen and the bag stood nowhere. LootCollector pins
-- loot the bag only in Red Cloud Mesa (-3064.5, -538.9) and the gloves only in Searing Gorge (-6835.7, -1351.4).
-- The bag returns to the realm dump's own spawn beside the Red Cloud Mesa well; the gloves stand on the floor of The
-- Cauldron below the slag pit, checked in game.
DELETE FROM `gameobject` WHERE `guid` IN (6940183, 6941273, 6941274, 6942353, 6942354, 6942355);
INSERT INTO `gameobject` (`guid`, `id`, `map`, `zoneId`, `areaId`, `spawnMask`, `phaseMask`, `position_x`, `position_y`,
    `position_z`, `orientation`, `rotation0`, `rotation1`, `rotation2`, `rotation3`, `spawntimesecs`, `animprogress`,
    `state`, `ScriptName`, `Comment`) VALUES
(6940183, 68403, 0, 0, 0, 1, 1, -6835.666, -1351.153, 169.690, 2.254390, 0, 0, 0.903212, 0.429195, 0, 0, 1,
    'worldforged_pickup', 'Worldforged Break-time Gloves | Searing Gorge, The Cauldron floor'),
(6942353, 95612, 1, 0, 0, 1, 1, -3064.410, -537.670, 26.218, 6.193490, 0, 0, 0.044831, -0.998995, 0, 0, 1,
    'worldforged_pickup', 'Worldforged Travel Sack | Red Cloud Mesa, beside the well');
