-- Conquest of Azeroth: guards no longer direct players to stock class trainers.
--
-- User request (2026-09-24): "Remove the guard directions for non-coa classes from guards."
--
-- WHERE EACH VALUE COMES FROM
--   option and POI keys  SOURCED-DB: research/trainers-guards-markers/guard-directions.md (+ .json), re-derived on
--     coa_grd. Every per-class option names a stock class (Druid, Hunter, Mage, Paladin, Priest, Rogue, Shaman,
--     Warlock, Warrior); none names a Death Knight or a CoA class, and no guard menu has a CoA-class submenu.
--   core path  SOURCED-CORE: a GOSSIP_OPTION_GOSSIP option sends its ActionPoiID as a map flag and then opens its
--     ActionMenuID (PlayerGossip.cpp:302-313). Guard directions exist only as these rows: guards.cpp holds only
--     the Shattrath combat AIs, the only script SendPointOfInterest is culling_of_stratholme.cpp:1240's wave POIs
--     (1000+), and no smart_scripts row sends (action 98) or handles (event 62) these menus.
--   root options  DERIVED: each "Class Trainer" / "A class trainer" option leads to a submenu that holds only per-
--     class options, so after they go it would open an empty menu; the root option goes with them. Every root menu
--     keeps 5 or more other options (Dalaran 10082 keeps 2), so none falls back to menu 0
--     (PlayerGossip.cpp:40-42).
--   points at CoA trainers  DERIVED: 16 of the deleted points lie within 10 yd of a CoA class trainer, mostly ones
--     the 20260923 capital migrations placed at the stock trainer spots (closest: Undercity Priest POI 332, 3.3 yd
--     from Sun Cleric Lightspeaker Shaylan 650327; among them Darnassus Druid POI 98, 9.5 yd from Mathrengyl
--     Bearwalker 4217, whom migration 05 retitled Primalist). Every option names a stock class, so they go with
--     the rest; after this file guards give no directions to any CoA trainer. No CoA source records a guard
--     direction to a CoA class.
--   points of interest  SOURCED-DB: the 98 ids below are used by no other gossip option, script or table; the
--     gossip loader would zero an unknown ActionPoiID anyway (ObjectMgr.cpp:10349-10352).
--   kept  the submenus, leaf menus and npc_text rows (unreachable, stock, harmless); Dalaran menu 10097 with its
--     quarter options and POIs 129/130 (other Dalaran menus send those POIs); every other direction.
--
-- Counts: 136 gossip_menu_option keys (+ their locale rows), 98 points_of_interest ids (+ locale rows).
-- Exact-key deletes only; re-applying the file is a no-op.

-- ---------------------------------------------------------------------------
-- 1. The "Class Trainer" option of each guard and city directory menu
-- ---------------------------------------------------------------------------
-- 435/14 Stormwind: Stormwind City Guard 68, City Patroller 1976, Harbor Guard 29712 -> submenu 401
-- 721/9 Thunder Bluff: Bluffwatcher 3084 -> submenu 740
-- 1951/12 Orgrimmar: Orgrimmar Grunt 3296 -> submenu 1949
-- 2121/11 Ironforge: Ironforge Guard 5595 -> submenu 2144
-- 2352/9 Darnassus: Darnassus Sentinel 4262 -> submenu 2343
-- 10265/9 Darnassus: no user (orphan copy of 2352) -> submenu 2343
-- 2849/12 Undercity: Undercity Guardian 5624 -> submenu 2848
-- 10769/12 Undercity: Kor'kron Overseer 36213 -> submenu 10768
-- 3285/4 Razor Hill: Razor Hill Grunt 5953 -> submenu 3283
-- 3331/4 Bloodhoof Village: Bloodhoof Braves 3212, 3215, 3217-3224 -> submenu 3329
-- 3356/4 Brill: Brill Deathguards 1496, 1652, 1735, 1738, 1742-1746, 2209, 2210, 5725 -> submenu 3354
-- 3506/5 Goldshire: Stormwind Guard 1423 -> submenu 3519
-- 3533/5 Kharanos: Ironforge Mountaineer 727 -> submenu 3545
-- 3580/5 Dolanaar: Teldrassil Sentinel 3571 -> submenu 3564
-- 7633/9 Silvermoon City: Silvermoon City Guardian 16222 -> submenu 7649
-- 7777/9 The Exodar: Exodar Peacekeeper 16733 -> submenu 7787
-- 8129/5 Azure Watch: Azuremyst Peacekeeper 18038 -> submenu 8137
-- 8185/4 Falconwing Square: Silvermoon Guardian 16221 -> submenu 8196
DELETE FROM `gossip_menu_option_locale` WHERE (`MenuID`, `OptionID`) IN (
    (435, 14), (721, 9), (1951, 12), (2121, 11), (2352, 9), (10265, 9), (2849, 12), (10769, 12), (3285, 4),
    (3331, 4), (3356, 4), (3506, 5), (3533, 5), (3580, 5), (7633, 9), (7777, 9), (8129, 5), (8185, 4));
DELETE FROM `gossip_menu_option` WHERE (`MenuID`, `OptionID`) IN (
    (435, 14), (721, 9), (1951, 12), (2121, 11), (2352, 9), (10265, 9), (2849, 12), (10769, 12), (3285, 4),
    (3331, 4), (3356, 4), (3506, 5), (3533, 5), (3580, 5), (7633, 9), (7777, 9), (8129, 5), (8185, 4));

-- ---------------------------------------------------------------------------
-- 2. Dalaran directory (menu 10043 "Trainers" -> 10082)
-- ---------------------------------------------------------------------------
-- Users: Archivist Betha 30726, Grezla the Hag 32683 and 15 Dalaran citizens 32676-32681, 32685-32693 (menu 10043
--     "Trainers" -> 10082).
-- 10082/1 "Class Trainer" -> menu 10097 "Dalaran's only class trainers are mages".
-- 10082/3 "Portal Trainer" -> menu 10081 "The city's mage and portal trainers", POI 150.
DELETE FROM `gossip_menu_option_locale` WHERE (`MenuID`, `OptionID`) IN (
    (10082, 1), (10082, 3));
DELETE FROM `gossip_menu_option` WHERE (`MenuID`, `OptionID`) IN (
    (10082, 1), (10082, 3));

-- ---------------------------------------------------------------------------
-- 3. Per-class options of the class-trainer submenus
-- ---------------------------------------------------------------------------
-- 401 Stormwind: 0 Druid (POI 32), 1 Hunter (POI 33), 2 Mage (POI 34), 3 Paladin (POI 35), 4 Priest (POI 35), 5
--     Rogue (POI 36), 6 Shaman (POI 37), 7 Warlock (POI 38), 8 Warrior (POI 39)
DELETE FROM `gossip_menu_option_locale` WHERE `MenuID` = 401 AND `OptionID` IN (0, 1, 2, 3, 4, 5, 6, 7, 8);
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 401 AND `OptionID` IN (0, 1, 2, 3, 4, 5, 6, 7, 8);

-- 740 Thunder Bluff: 0 Druid (POI 285), 1 Hunter (POI 286), 2 Mage (POI 287), 3 Priest (POI 287), 4 Shaman (POI
--     288), 5 Warrior (POI 286)
DELETE FROM `gossip_menu_option_locale` WHERE `MenuID` = 740 AND `OptionID` IN (0, 1, 2, 3, 4, 5);
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 740 AND `OptionID` IN (0, 1, 2, 3, 4, 5);

-- 1949 Orgrimmar: 0 Hunter (POI 300), 1 Mage (POI 301), 2 Priest (POI 302), 3 Shaman (POI 303), 4 Rogue (POI 304),
--     5 Warlock (POI 305), 6 Warrior (POI 306), 7 Paladin (POI 303)
DELETE FROM `gossip_menu_option_locale` WHERE `MenuID` = 1949 AND `OptionID` IN (0, 1, 2, 3, 4, 5, 6, 7);
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 1949 AND `OptionID` IN (0, 1, 2, 3, 4, 5, 6, 7);

-- 2144 Ironforge: 0 Hunter (POI 61), 1 Mage (POI 62), 2 Paladin (POI 62), 3 Priest (POI 62), 4 Rogue (POI 63), 5
--     Warlock (POI 64), 6 Warrior (POI 61), 7 Shaman (POI 65)
DELETE FROM `gossip_menu_option_locale` WHERE `MenuID` = 2144 AND `OptionID` IN (0, 1, 2, 3, 4, 5, 6, 7);
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 2144 AND `OptionID` IN (0, 1, 2, 3, 4, 5, 6, 7);

-- 2343 Darnassus: 0 Druid (POI 98), 1 Hunter (POI 99), 2 Mage (POI 265), 3 Paladin (POI 266), 4 Priest (POI 267),
--     5 Rogue (POI 100), 6 Warrior (POI 101)
DELETE FROM `gossip_menu_option_locale` WHERE `MenuID` = 2343 AND `OptionID` IN (0, 1, 2, 3, 4, 5, 6);
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 2343 AND `OptionID` IN (0, 1, 2, 3, 4, 5, 6);

-- 2848 Undercity: 0 Mage (POI 331), 1 Paladin (POI 330), 2 Priest (POI 332), 3 Rogue (POI 333), 4 Warlock (POI
--     334), 5 Warrior (POI 335)
DELETE FROM `gossip_menu_option_locale` WHERE `MenuID` = 2848 AND `OptionID` IN (0, 1, 2, 3, 4, 5);
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 2848 AND `OptionID` IN (0, 1, 2, 3, 4, 5);

-- 10768 Undercity: 0 Mage (POI 331), 1 Paladin (POI 330), 2 Priest (POI 332), 3 Rogue (POI 333), 4 Warlock (POI
--     334), 5 Warrior (POI 335)
DELETE FROM `gossip_menu_option_locale` WHERE `MenuID` = 10768 AND `OptionID` IN (0, 1, 2, 3, 4, 5);
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 10768 AND `OptionID` IN (0, 1, 2, 3, 4, 5);

-- 3283 Razor Hill: 0 Hunter (POI 405), 1 Mage (POI 406), 2 Priest (POI 407), 3 Rogue (POI 408), 4 Shaman (POI
--     409), 5 Warlock (POI 410), 6 Warrior (POI 411)
DELETE FROM `gossip_menu_option_locale` WHERE `MenuID` = 3283 AND `OptionID` IN (0, 1, 2, 3, 4, 5, 6);
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 3283 AND `OptionID` IN (0, 1, 2, 3, 4, 5, 6);

-- 3329 Bloodhoof Village: 0 Druid (POI 421), 1 Hunter (POI 422), 2 Shaman (POI 423), 3 Warrior (POI 424)
DELETE FROM `gossip_menu_option_locale` WHERE `MenuID` = 3329 AND `OptionID` IN (0, 1, 2, 3);
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 3329 AND `OptionID` IN (0, 1, 2, 3);

-- 3354 Brill: 0 Mage (POI 433), 1 Paladin, 2 Priest (POI 434), 3 Rogue (POI 435), 4 Warlock (POI 436), 5 Warrior
--     (POI 437)
DELETE FROM `gossip_menu_option_locale` WHERE `MenuID` = 3354 AND `OptionID` IN (0, 1, 2, 3, 4, 5);
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 3354 AND `OptionID` IN (0, 1, 2, 3, 4, 5);

-- 3519 Goldshire: 0 Druid, 1 Hunter, 2 Mage (POI 2), 3 Paladin (POI 3), 4 Priest (POI 4), 5 Rogue (POI 5), 6
--     Shaman, 7 Warlock (POI 6), 8 Warrior (POI 7)
DELETE FROM `gossip_menu_option_locale` WHERE `MenuID` = 3519 AND `OptionID` IN (0, 1, 2, 3, 4, 5, 6, 7, 8);
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 3519 AND `OptionID` IN (0, 1, 2, 3, 4, 5, 6, 7, 8);

-- 3545 Kharanos: 0 Hunter (POI 78), 1 Mage (POI 79), 2 Paladin (POI 80), 3 Priest (POI 81), 4 Rogue (POI 82), 5
--     Warlock (POI 83), 6 Warrior (POI 84)
DELETE FROM `gossip_menu_option_locale` WHERE `MenuID` = 3545 AND `OptionID` IN (0, 1, 2, 3, 4, 5, 6);
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 3545 AND `OptionID` IN (0, 1, 2, 3, 4, 5, 6);

-- 3564 Dolanaar: 0 Druid (POI 113), 1 Hunter (POI 114), 2 Priest (POI 115), 3 Rogue (POI 116), 4 Warrior (POI 117)
DELETE FROM `gossip_menu_option_locale` WHERE `MenuID` = 3564 AND `OptionID` IN (0, 1, 2, 3, 4);
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 3564 AND `OptionID` IN (0, 1, 2, 3, 4);

-- 7649 Silvermoon City: 0 Druid (POI 361), 1 Hunter (POI 362), 2 Mage (POI 363), 3 Paladin (POI 364), 4 Priest
--     (POI 365), 5 Rogue (POI 366), 6 Warlock (POI 367)
DELETE FROM `gossip_menu_option_locale` WHERE `MenuID` = 7649 AND `OptionID` IN (0, 1, 2, 3, 4, 5, 6);
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 7649 AND `OptionID` IN (0, 1, 2, 3, 4, 5, 6);

-- 7787 The Exodar: 0 Druid (POI 198), 1 Hunter (POI 199), 2 Mage (POI 200), 3 Paladin (POI 201), 4 Priest (POI
--     202), 5 Shaman (POI 203), 6 Warrior (POI 204)
DELETE FROM `gossip_menu_option_locale` WHERE `MenuID` = 7787 AND `OptionID` IN (0, 1, 2, 3, 4, 5, 6);
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 7787 AND `OptionID` IN (0, 1, 2, 3, 4, 5, 6);

-- 8137 Azure Watch: 0 Druid, 1 Hunter (POI 221), 2 Mage (POI 222), 3 Paladin (POI 223), 4 Priest (POI 224), 5
--     Shaman (POI 225), 6 Warrior (POI 226)
DELETE FROM `gossip_menu_option_locale` WHERE `MenuID` = 8137 AND `OptionID` IN (0, 1, 2, 3, 4, 5, 6);
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 8137 AND `OptionID` IN (0, 1, 2, 3, 4, 5, 6);

-- 8196 Falconwing Square: 0 Druid, 1 Hunter (POI 385), 2 Mage (POI 386), 3 Paladin (POI 387), 4 Priest (POI 388),
--     5 Rogue (POI 389), 6 Warlock (POI 390)
DELETE FROM `gossip_menu_option_locale` WHERE `MenuID` = 8196 AND `OptionID` IN (0, 1, 2, 3, 4, 5, 6);
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 8196 AND `OptionID` IN (0, 1, 2, 3, 4, 5, 6);

-- ---------------------------------------------------------------------------
-- 4. Map points only those options sent
-- ---------------------------------------------------------------------------
DELETE FROM `points_of_interest_locale` WHERE `ID` IN (
    2, 3, 4, 5, 6, 7, 32, 33, 34, 35, 36, 37, 38, 39, 61, 62, 63, 64, 65, 78, 79, 80, 81, 82, 83, 84, 98, 99,
    100, 101, 113, 114, 115, 116, 117, 150, 198, 199, 200, 201, 202, 203, 204, 221, 222, 223, 224, 225, 226,
    265, 266, 267, 285, 286, 287, 288, 300, 301, 302, 303, 304, 305, 306, 330, 331, 332, 333, 334, 335, 361,
    362, 363, 364, 365, 366, 367, 385, 386, 387, 388, 389, 390, 405, 406, 407, 408, 409, 410, 411, 421, 422,
    423, 424, 433, 434, 435, 436, 437);
DELETE FROM `points_of_interest` WHERE `ID` IN (
    2, 3, 4, 5, 6, 7, 32, 33, 34, 35, 36, 37, 38, 39, 61, 62, 63, 64, 65, 78, 79, 80, 81, 82, 83, 84, 98, 99,
    100, 101, 113, 114, 115, 116, 117, 150, 198, 199, 200, 201, 202, 203, 204, 221, 222, 223, 224, 225, 226,
    265, 266, 267, 285, 286, 287, 288, 300, 301, 302, 303, 304, 305, 306, 330, 331, 332, 333, 334, 335, 361,
    362, 363, 364, 365, 366, 367, 385, 386, 387, 388, 389, 390, 405, 406, 407, 408, 409, 410, 411, 421, 422,
    423, 424, 433, 434, 435, 436, 437);
