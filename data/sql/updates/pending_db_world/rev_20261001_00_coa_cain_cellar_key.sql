-- Repaired Cellar Key (559141) opens the Cain manor cellar door (2300524, lock 1903). A key lock opens only
-- when the key itself is the cast item (Spell::CanOpenLock), so the key needs the stock key use spell
-- 3366 Opening (OPEN_LOCK on the targeted object), as The Scarlet Key 7146 and other stock keys carry.
UPDATE `item_template` SET `spellid_1` = 3366, `spelltrigger_1` = 0, `spellcharges_1` = 0, `spellcooldown_1` = -1,
    `spellcategory_1` = 0, `spellcategorycooldown_1` = -1 WHERE `entry` = 559141;
