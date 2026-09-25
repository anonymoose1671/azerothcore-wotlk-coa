-- Conquest of Azeroth retires the stock class trainers (user direction 2026-09-24: "Remove base class (non
-- coa class) class trainers unless they are involved in non-base class quests. If they are involved in
-- non-coa class quests, keep them but strip their title/role, also make sure they don't overlap with other
-- npcs."). CoA's own class trainers (classes 12-32, migrations 05-17) replace them.
--
-- WHERE EACH VALUE COMES FROM
--   stock class trainer  a template creature_default_trainer links to a Type 0 trainer 1-17 or 31-34 in the
--     stock world (the ten stock classes); pet, riding, profession and weapon trainers and the Books of
--     Ascension are not class trainers. 293 templates; the ct packages 06-11 already deleted 10 of their
--     spawns. Inventory, involvements and classification: research/trainers-guards-markers/
--     retire-trainers.json (retire-trainers-research, 2026-09-24), checked against the scratch world.
--   portal trainers stay  the 13 mage Portal Trainers (Type 0 trainers 18-30) are left as they are: CoA
--     kept them. Its creaturecache (mode conquest-of-azeroth) still titles 9 of them 'Portal Trainer'
--     (2485, 2489, 2492, 4165, 5957, 5958, 16654, 27703, 27705; SOURCED-CACHE); the other 4 (16755, 19340,
--     20791, 29156) have no cache record and stay with them (INFERRED). Only stock mages can train there
--     (Trainer.cpp:216-219).
--   base-class quest  AllowableClasses holds stock class bits only, or is 0 with a stock class QuestSortID
--     (8249). No quest of these trainers in the quest tables has a CoA class bit or sort.
--   kept (19)  a trainer that starts or ends a non-class quest (quest tables, DERIVED); Mathrengyl
--     Bearwalker, who is already CoA's Primalist trainer; and four that CoA's own non-class quests need
--     although those quests are not in the quest tables yet (questcache, modes conquest-of-azeroth and
--     season-10-freepick, SOURCED-CACHE): Grif Wildheart 1231 ends 28561 "Commission for Grif Wildheart",
--     Thotar 3171 ends 28583 "Commission for Thotar", Dazalar 3601 ends 28428 "Commission for Dazalar"
--     (each CompletedText "Take the commission to <name> at <town>"), and Quithas 16652 is objective 2
--     (ObjectiveText2 "Quithas", count 1) of 254018 "Secrets to Keep". CoA's creaturecache keeps all four.
--     Migration 05 already took the trainer flags, title, default trainer and train options from 17 of
--     them; this file takes the trainer role from Vindicator Aesom, whose role 05 did not cover. His title
--     "Triumvirate of the Hand" is not a trainer title (Vindicator Kuros beside him carries it too), so it
--     stays (user, 2026-09-24). They stay where they stand, except Thotar, who moves to the turn-in point of
--     his quests (section 1). After the retirement none of them is within 1.5 yd of another creature or
--     1.0 yd of an object (Rukua 137653 beside Emissary Valustraa and Dink 7312 beside Bink are deleted
--     here).
--   deleted (468 spawns of 264 templates)  every other spawn, matched on guid and entry:
--     255 world spawns and 213 placeholders of the idle Arena Tournament event 31. Their
--     creature_addon, game_event_creature, game_event_npcflag and game_event_npc_vendor rows go only once
--     the spawn is gone (the loaders report addon and event rows: ObjectMgr.cpp:1292, GameEventMgr.cpp:521;
--     event vendor rows of a missing guid are applied to entry 0, GameEventMgr.cpp:300-317); their five
--     waypoint paths go only when no creature or template addon still uses them. Pools, formations, linked
--     respawns, spawn groups, movement overrides, guid SmartAI and vehicle accessories hold none of them.
--     Moves of these spawns by migrations 02, 03, 05 and 11 become moot; no later file re-inserts them.
--   orphaned class quests  58 stock class quests would stay offered to stock
--     classes (CoA classes cannot take stock class quests: QuestDef.cpp loads the class mask as written)
--     with no spawned ender left. The creature and gameobject giver rows of 56 of them are deleted by
--     exact (id, quest). That also ends the RewardNextQuest offers that lead to them: Player::GetNextQuest
--     offers the next quest only from the rewarding NPC's own giver rows (PlayerQuest.cpp:231-258). The
--     other two start from items. Simple Parchment 6497 (2383) has no loot, vendor, create-info or spell
--     source. Elegant Letter 17126 (6681) is created only by spell 21100 Conjure Elegant Letter (Spell.dbc),
--     which the rogue trainers' and Morgan Stern 4794's gossip SmartAI casts. After the retirement only
--     Morgan Stern (Theramore) is left, so his option (4576, 4) '<Take the letter>' goes with its conditions
--     and locale rows; his SmartAI rows then have no gossip select to answer.
--
-- No creature, template, quest or gossip id is created. Every statement is keyed exactly and re-runs to the
-- same state.

-- ---------------------------------------------------------------------------
-- 1. Vindicator Aesom loses the paladin trainer role; Thotar stands at his CoA turn-in point
-- ---------------------------------------------------------------------------
UPDATE `creature_template` SET `npcflag` = `npcflag` & ~48, `subname` = 'Triumvirate of the Hand' WHERE `entry` = 17844;
DELETE FROM `creature_default_trainer` WHERE `CreatureId` = 17844;
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 15 AND `SourceGroup` = 7517 AND `SourceEntry` = 0;
DELETE FROM `gossip_menu_option_locale` WHERE `MenuID` = 7517 AND `OptionID` = 0;
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 7517 AND `OptionID` = 0;

-- Thotar 3171: CoA stands him 6.5 yd deeper in the Razor Hill burrow, at the turn-in point of his quests 6062,
-- 6068-6070, 6082 and 6083 (SuperTrack 566, SOURCED-CLIENT). surface.check: Trollburrow.wmo floor 11.628,
-- headroom 3.8, slope 0.1, no problems; 4.1 yd from Harruk 3620 on the same floor; Gar'Thok is 3.0 yd away in
-- plan but 5.9 yd higher, on the upper floor. Faces the burrow entrance like Harruk.
UPDATE `creature` SET `position_x` = 272.0, `position_y` = -4709.57, `position_z` = 11.627, `orientation` = 1.27
    WHERE `guid` = 7293 AND `id` = 3171;

-- ---------------------------------------------------------------------------
-- 2. The retired trainers leave the world
-- ---------------------------------------------------------------------------
-- Eastern Kingdoms / Alterac Mountains: Fahrad 6707 (Rogue)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (14786, 6707)
);
-- Eastern Kingdoms / Coldridge Valley: Alamar Grimm 460 (Warlock); Branstock Khalder 837 (Priest); Thorgas
--   Grimson 895 (Hunter); Thran Khorman 912 (Warrior); Solm Hargrin 916 (Rogue)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (1024, 460), (1023, 837), (407, 895), (406, 912), (421, 916)
);
-- Eastern Kingdoms / Deathknell: David Trias 2122 (Rogue); Dark Cleric Duesten 2123 (Priest); Isabella 2124
--   (Mage); Maximillion 2126 (Warlock)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (28466, 2122), (28469, 2123), (28463, 2124), (28467, 2126)
);
-- Eastern Kingdoms / Dun Morogh: Maxan Anvol 1226 (Priest); Magis Sparkmantle 1228 (Mage); Granis Swiftaxe 1229
--   (Warrior); Azar Stronghammer 1232 (Paladin); Hogral Bakkan 1234 (Rogue); Gimrizz Shadowcog 5612 (Warlock)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (206, 1226), (192, 1228), (196, 1229), (194, 1232), (188, 1234), (218, 5612)
);
-- Eastern Kingdoms / Eastern Plaguelands: Amal'thazad 29194 (Death Knight); Lady Alistra 29195 (Death Knight);
--   Lord Thorval 29196 (Death Knight); Highlord Darion Mograine 31084 (Death Knight)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (125641, 29194), (125642, 29195), (125712, 29196), (130468, 31084)
);
-- Eastern Kingdoms / Elwynn Forest: Zaldimar Wefhellt 328 (Mage); Priestess Josetta 377 (Priest); Maximillian
--   Crowe 906 (Warlock); Lyria Du Lac 913 (Warrior); Keryn Sylvius 917 (Rogue); Brother Wilhelm 927 (Paladin)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (80344, 328), (80347, 377), (80353, 906), (80333, 913), (79645, 917), (80325, 927)
);
-- Eastern Kingdoms / Ironforge: Kelstrum Stonebreaker 1901 (Warrior); Kelv Sternhammer 5113 (Warrior); Bilban
--   Tosslespanner 5114 (Warrior); Daera Brightspear 5115 (Hunter); Olmin Burningbeard 5116 (Hunter); Regnus
--   Thundergranite 5117 (Hunter); Theodrus Frostbeard 5141 (Priest); Braenna Flintcrag 5142 (Priest); Toldren
--   Deepiron 5143 (Priest); Juli Stormkettle 5145 (Mage); Nittlebur Sparkfizzle 5146 (Mage); Valgar Highforge
--   5147 (Paladin); Beldruk Doombrow 5148 (Paladin); Brandur Ironhammer 5149 (Paladin); Hulfdan Blackbeard 5165
--   (Rogue); Ormyr Flinteye 5166 (Rogue); Fenthwick 5167 (Rogue); Thistleheart 5171 (Warlock); Briarthorn 5172
--   (Warlock); Alexander Calder 5173 (Warlock); Dink 7312 (Mage); High Priest Rohan 11406 (Priest); Farseer
--   Javad 23127 (Shaman)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (83, 1901), (2019, 5113), (84, 5114), (2020, 5115), (87, 5116), (82, 5117), (1780, 5141), (1770, 5142),
    (1772, 5143), (1779, 5145), (1782, 5146), (1778, 5147), (1769, 5148), (1781, 5149), (1810, 5165), (1806, 5166),
    (1809, 5167), (1804, 5171), (1807, 5172), (1803, 5173), (1774, 7312), (1777, 11406), (1815, 23127)
);
-- Eastern Kingdoms / Loch Modan: Dargh Trueaim 10930 (Hunter)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (8277, 10930)
);
-- Eastern Kingdoms / Northshire Valley: Khelden Bremen 198 (Mage); Drusilla La Salle 459 (Warlock); Llane
--   Beshere 911 (Warrior); Jorik Kerridan 915 (Rogue)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (79962, 198), (79966, 459), (79964, 911), (79986, 915)
);
-- Eastern Kingdoms / Silverpine Forest: Champion Cyssa Dawnrose 20406 (Paladin)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (32066, 20406)
);
-- Eastern Kingdoms / Stormwind City: Maginor Dumas 331 (Mage); High Priestess Laurena 376 (Priest); Demisette
--   Cloyce 461 (Warlock); Ander Germaine 914 (Warrior); Osborne the Night Man 918 (Rogue); Lord Grayson
--   Shadowbreaker 928 (Paladin); Wu Shen 5479 (Warrior); Ilsa Corbin 5480 (Warrior); Brother Benjamin 5484
--   (Priest); Brother Joshua 5489 (Priest); Arthur the Faithful 5491 (Paladin); Katherine the Pure 5492
--   (Paladin); Ursula Deline 5495 (Warlock); Sandahl 5496 (Warlock); Elsharin 5498 (Mage); Sheldras Moontree
--   5504 (Druid); Theridran 5505 (Druid); Maldryn 5506 (Druid); Einris Brightspear 5515 (Hunter); Ulfir
--   Ironbeard 5516 (Hunter); Thorfin Stoneshield 5517 (Hunter); Nara Meideros 11397 (Priest); Lord Tony Romano
--   13283 (Rogue); Farseer Umbrua 20407 (Shaman)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (26835, 331), (1079, 376), (26838, 461), (79780, 914), (79788, 918), (5000, 928), (79779, 5479), (79778, 5480),
    (37556, 5484), (37571, 5489), (37585, 5491), (37586, 5492), (90460, 5495), (90461, 5496), (90463, 5498),
    (90465, 5504), (90466, 5505), (90467, 5506), (37608, 5515), (37609, 5516), (37610, 5517), (90480, 11397),
    (79787, 13283), (79860, 20407)
);
-- Eastern Kingdoms / Stranglethorn Vale: Kragg 1404 (Hunter); Ian Strom 1411 (Rogue)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (364, 1404), (644, 1411)
);
-- Eastern Kingdoms / Swamp of Sorrows: Malosh 985 (Warrior); Haromm 986 (Shaman); Ogromm 987 (Hunter); Kartosh
--   988 (Warlock)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (34156, 985), (34147, 986), (31949, 987), (32091, 988)
);
-- Eastern Kingdoms / Tirisfal Glades: Rupert Boch 2127 (Warlock); Cain Firesong 2128 (Mage); Dark Cleric Beryl
--   2129 (Priest); Marion Call 2130 (Rogue); Austil de Mon 2131 (Warrior); Kaal Soulreaper 4563 (Warlock);
--   Luther Pickman 4564 (Warlock); Richard Kerwin 4565 (Warlock); Kaelystia Hatebringer 4566 (Mage); Pierce
--   Shackleton 4567 (Mage); Carolyn Ward 4582 (Rogue); Miles Dexter 4583 (Rogue); Gregory Charles 4584 (Rogue);
--   Christoph Walker 4593 (Warrior); Angela Curthas 4594 (Warrior); Baltus Fowler 4595 (Warrior); Aelthalyste
--   4606 (Priest); Father Lankester 4607 (Priest); Father Lazarus 4608 (Priest); Derek the Undying 23103 (Mage)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (33752, 2127), (28476, 2128), (28477, 2129), (28479, 2130), (33720, 2131), (41834, 4563), (38071, 4564),
    (31863, 4565), (31869, 4566), (38416, 4567), (38095, 4582), (31885, 4583), (31889, 4584), (31897, 4593),
    (41841, 4594), (38128, 4595), (31866, 4606), (41835, 4607), (31865, 4608), (41829, 23103)
);
-- Ebon Hold (DK start) / Plaguelands: The Scarlet Enclave: Lady Alistra 28471 (Death Knight); Lord Thorval 28472
--   (Death Knight); Amal'thazad 28474 (Death Knight)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (128505, 28471), (128506, 28472), (128507, 28474)
);
-- Kalimdor / Ashenvale: Danlaar Nightstride 3963 (Hunter); Alenndaar Lapidaar 8308 (Hunter)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (32703, 3963), (32678, 8308)
);
-- Kalimdor / Darnassus: Arias'ta Bladesinger 4087 (Warrior); Sildanair 4089 (Warrior); Jandria 4091 (Priest);
--   Lariia 4092 (Priest); Jeen'ra Nightrunner 4138 (Hunter); Jocaste 4146 (Hunter); Syurna 4163 (Rogue); Dorion
--   4205 (Hunter); Erion Shadewhisper 4214 (Rogue); Anishar 4215 (Rogue); Denatharion 4218 (Druid); Fylerian
--   Nightwing 4219 (Druid); Darnath Bladesinger 7315 (Warrior); Priestess Alathea 11401 (Priest); Rukua 35281
--   (Paladin)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (49851, 4087), (49856, 4089), (49903, 4091), (49934, 4092), (46217, 4138), (46221, 4146), (46312, 4163),
    (46415, 4205), (46469, 4214), (46470, 4215), (46474, 4218), (46475, 4219), (46809, 7315), (46567, 11401),
    (137653, 35281)
);
-- Kalimdor / Durotar: Tarshaw Jaggedscar 3169 (Warrior); Kaplak 3170 (Rogue); Dhugru Gorelust 3172 (Warlock);
--   Swart 3173 (Shaman); Tai'jin 3706 (Priest); Un'Thuwa 5880 (Mage); Zayus 5994 (Priest); X'yera 6014 (Priest);
--   Ur'kyo 6018 (Priest)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (7291, 3169), (8422, 3170), (6389, 3172), (8419, 3173), (10429, 3706), (6398, 5880), (3615, 5994), (3473, 6014),
    (3472, 6018)
);
-- Kalimdor / Dustwallow Marsh: Brother Karman 8140 (Paladin); Captain Evencane 8141 (Warrior); Horace Alder
--   27704 (Mage)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (30655, 8140), (30650, 8141), (1846, 27704)
);
-- Kalimdor / Felwood: Kaerbrus 5501 (Hunter); Golhine the Hooded 9465 (Druid)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (39666, 5501), (39665, 9465)
);
-- Kalimdor / Feralas: Jannos Lighthoof 8142 (Druid)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (51301, 8142)
);
-- Kalimdor / Moonglade: Loganaar 12042 (Druid)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (42415, 12042)
);
-- Kalimdor / Mulgore: Krang Stonehoof 3063 (Warrior); Gennia Runetotem 3064 (Druid); Yaw Sharpmane 3065
--   (Hunter); Narm Skychaser 3066 (Shaman)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (26902, 3063), (26903, 3064), (26905, 3065), (26906, 3066)
);
-- Kalimdor / Orgrimmar: Grol'dar 3324 (Warlock); Mirket 3325 (Warlock); Zevrost 3326 (Warlock); Gest 3327
--   (Rogue); Ormok 3328 (Rogue); Kardris Dreamseeker 3344 (Shaman); Ormak Grimshot 3352 (Hunter); Grezz Ragefist
--   3353 (Warrior); Sorek 3354 (Warrior); Shenthul 3401 (Rogue); Sian'tsu 3403 (Shaman); Xor'juul 3406 (Hunter);
--   Sian'dur 3407 (Hunter); Zel'mak 3408 (Warrior); Pephredo 5882 (Mage); Enyo 5883 (Mage); Master Pyreanor
--   23128 (Paladin)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (3461, 3324), (3452, 3325), (6596, 3326), (3454, 3327), (6593, 3328), (4663, 3344), (7449, 3352), (7971, 3353),
    (7443, 3354), (6594, 3401), (4665, 3403), (7972, 3406), (6620, 3407), (6610, 3408), (3471, 5882), (3616, 5883),
    (6503, 23128)
);
-- Kalimdor / Red Cloud Mesa: Harutt Thunderhorn 3059 (Warrior); Lanka Farshot 3061 (Hunter); Meela Dawnstrider
--   3062 (Shaman)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (26897, 3059), (26899, 3061), (26900, 3062)
);
-- Kalimdor / Shadowglen: Shanda 3595 (Priest); Ayanna Everstride 3596 (Hunter); Mardant Strongoak 3597 (Druid)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (46181, 3595), (46182, 3596), (46183, 3597)
);
-- Kalimdor / Teldrassil: Kyra Windblade 3598 (Warrior); Jannok Breezesong 3599 (Rogue); Laurna Morninglight 3600
--   (Priest); Kal 3602 (Druid)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (46184, 3598), (46185, 3599), (46186, 3600), (46189, 3602)
);
-- Kalimdor / The Barrens: Babagaya Shadowcleft 23534 (Warlock)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (20943, 23534)
);
-- Kalimdor / Thunder Bluff: Siln Skychaser 3030 (Shaman); Tigor Skychaser 3031 (Shaman); Beram Skychaser 3032
--   (Shaman); Turak Runetotem 3033 (Druid); Sheal Runetotem 3034 (Druid); Kym Wildmane 3036 (Druid); Kary
--   Thunderhorn 3038 (Hunter); Holt Thunderhorn 3039 (Hunter); Urek Thunderhorn 3040 (Hunter); Torm Ragetotem
--   3041 (Warrior); Sark Ragetotem 3042 (Warrior); Ker Ragetotem 3043 (Warrior); Miles Welsh 3044 (Priest);
--   Malakai Cross 3045 (Priest); Father Cobb 3046 (Priest); Archmage Shymm 3047 (Mage); Thurston Xane 3049
--   (Mage)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (26656, 3030), (26658, 3031), (26659, 3032), (26661, 3033), (26662, 3034), (26753, 3036), (26755, 3038),
    (26756, 3039), (26758, 3040), (26759, 3041), (26768, 3042), (26770, 3043), (26771, 3044), (26772, 3045),
    (26773, 3046), (26774, 3047), (26776, 3049)
);
-- Kalimdor / Valley of Trials: Jen'shan 3154 (Hunter); Rwag 3155 (Rogue); Nartok 3156 (Warlock); Shikrik 3157
--   (Shaman); Mai'ah 5884 (Mage)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (7649, 3154), (7284, 3155), (4800, 3156), (7281, 3157), (4798, 5884)
);
-- Northrend / Crystalsong Forest: Warcaster Fanoraithe 28956 (Mage); Jessa Weaver 28958 (Mage)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (98417, 28956), (98820, 28958)
);
-- Outland/BC isles / Ammen Vale: Keilnei 16499 (Hunter); Valaatu 16500 (Mage); Aurelon 16501 (Paladin); Kore
--   16503 (Warrior); Firmanvaar 17089 (Shaman)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (84585, 16499), (84581, 16500), (57212, 16501), (84574, 16503), (59513, 17089)
);
-- Outland/BC isles / Azuremyst Isle: Tuluun 17212 (Shaman); Ruada 17480 (Warrior); Semid 17481 (Mage); Guvan
--   17482 (Priest); Tullas 17483 (Paladin)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (61721, 17212), (62994, 17480), (62995, 17481), (62996, 17482), (84577, 17483)
);
-- Outland/BC isles / Eversong Woods: Celoenus 16266 (Warlock); Garridel 16269 (Mage); Hannovia 16270 (Hunter);
--   Noellene 16275 (Paladin); Ponaris 16276 (Priest); Tannaria 16279 (Rogue)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (56976, 16266), (56978, 16269), (56979, 16270), (56983, 16275), (56984, 16276), (56987, 16279)
);
-- Outland/BC isles / Silvermoon City: Alamma 16646 (Warlock); Talionia 16647 (Warlock); Zanien 16648 (Warlock);
--   Inethven 16653 (Mage); Harene Plainwalker 16655 (Druid); Aldrae 16658 (Priest); Lotheolan 16659 (Priest);
--   Belestra 16660 (Priest); Tana 16672 (Hunter); Oninath 16673 (Hunter); Zandine 16674 (Hunter); Osselan 16679
--   (Paladin); Ithelis 16680 (Paladin); Champion Bachi 16681 (Paladin); Zelanis 16684 (Rogue); Elara 16685
--   (Rogue); Nerisen 16686 (Rogue)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (57639, 16646), (57640, 16647), (57641, 16648), (57646, 16653), (57648, 16655), (57650, 16658), (57651, 16659),
    (57652, 16660), (57662, 16672), (57663, 16673), (57664, 16674), (57669, 16679), (57670, 16680), (57671, 16681),
    (57673, 16684), (57674, 16685), (57675, 16686)
);
-- Outland/BC isles / Sunstrider Isle: Julia Sunstriker 15279 (Mage); Jesthenis Sunstriker 15280 (Paladin);
--   Summoner Teli'Larien 15283 (Warlock); Matron Arena 15284 (Priest); Pathstalker Kariel 15285 (Rogue); Ranger
--   Sallina 15513 (Hunter)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (54985, 15279), (54986, 15280), (54989, 15283), (54990, 15284), (54991, 15285), (55431, 15513)
);
-- Outland/BC isles / The Exodar: Shalannius 16721 (Druid); Deremiis 16738 (Hunter); Edirah 16749 (Mage); Caedmos
--   16756 (Priest); Baatun 16761 (Paladin); Ahonan 16771 (Warrior); Behomat 17120 (Warrior); Kavaan 17121
--   (Paladin); Vord 17122 (Hunter); Sulaa 17219 (Shaman); Kazi 17504 (Warrior); Killac 17505 (Hunter); Jol 17509
--   (Paladin); Izmir 17510 (Priest); Fallat 17511 (Priest); Harnan 17513 (Mage); Bati 17514 (Mage); Hobahken
--   17519 (Shaman); Gurrag 17520 (Shaman)
DELETE FROM `creature` WHERE (`guid`, `id`) IN (
    (57708, 16721), (57737, 16738), (57742, 16749), (85628, 16756), (57748, 16761), (85590, 16771), (85589, 17120),
    (59520, 17121), (59521, 17122), (61958, 17219), (63005, 17504), (63006, 17505), (63007, 17509), (85624, 17510),
    (85626, 17511), (63009, 17513), (63010, 17514), (63013, 17519), (63014, 17520)
);
-- Arena Tournament (event 31) placeholders: a line of stock class trainers in each starting area
DELETE FROM `creature` WHERE `id` = 26324 AND `guid` IN (
    95051, 95128, 95226, 95286, 95361, 95410, 95496, 95554, 95608, 95667, 95748, 95812, 95883, 95933, 95999, 96044,
    96118, 96199, 96236, 96330, 96371, 96437, 96507, 96571
);
DELETE FROM `creature` WHERE `id` = 26325 AND `guid` IN (
    95070, 95123, 95228, 95273, 95329, 95407, 95476, 95562, 95607, 95675, 95749, 95819, 95884, 95921, 96076, 96122,
    96196, 96228, 96325, 96367, 96433, 96518, 96577
);
DELETE FROM `creature` WHERE `id` = 26326 AND `guid` IN (
    95073, 95122, 95243, 95288, 95340, 95406, 95493, 95533, 95612, 95676, 95707, 95815, 95879, 95920, 96007, 96064,
    96105, 96187, 96226, 96335, 96394, 96434, 96519, 96580
);
DELETE FROM `creature` WHERE `id` = 26327 AND `guid` IN (
    95072, 95131, 95234, 95280, 95336, 95411, 95498, 95561, 95621, 95678, 95708, 95823, 95888, 95902, 96008, 96061,
    96126, 96188, 96229, 96329, 96395, 96441, 96523, 96576
);
DELETE FROM `creature` WHERE `id` = 26328 AND `guid` IN (
    95060, 95125, 95236, 95274, 95330, 95409, 95497, 95556, 95618, 95688, 95706, 95814, 95880, 95903, 96009, 96041,
    96124, 96184, 96240, 96323, 96391, 96435, 96524, 96578
);
DELETE FROM `creature` WHERE `id` = 26329 AND `guid` IN (
    95067, 95129, 95213, 95281, 95371, 95404, 95475, 95532, 95619, 95689, 95756, 95816, 95877, 95896, 96010, 96067,
    96106, 96180, 96230, 96332, 96389, 96442, 96525, 96575
);
DELETE FROM `creature` WHERE `id` = 26330 AND `guid` IN (
    95069, 95126, 95210, 95283, 95369, 95390, 95495, 95551, 95620, 95691, 95758, 95808, 95878, 95897, 96014, 96046,
    96128, 96189, 96237, 96328, 96396, 96440, 96512, 96581
);
DELETE FROM `creature` WHERE `id` = 26331 AND `guid` IN (
    95068, 95130, 95206, 95284, 95370, 95412, 95494, 95555, 95690, 95757, 95809, 95881, 95898, 96016, 96071, 96120,
    96185, 96239, 96336, 96400, 96513, 96574
);
DELETE FROM `creature` WHERE `id` = 26332 AND `guid` IN (
    95071, 95127, 95209, 95282, 95348, 95417, 95489, 95528, 95611, 95687, 95755, 95811, 95882, 95899, 96015, 96045,
    96102, 96186, 96257, 96333, 96397, 96432, 96511, 96582
);

-- ---------------------------------------------------------------------------
-- 3. Rows that belonged to those spawns
-- ---------------------------------------------------------------------------
DELETE FROM `creature_addon` WHERE `guid` IN (
    82, 83, 84, 87, 188, 192, 194, 196, 206, 218, 364, 406, 407, 421, 644, 1023, 1024, 1079, 1769, 1770, 1772, 1774,
    1777, 1778, 1779, 1780, 1781, 1782, 1803, 1804, 1806, 1807, 1809, 1810, 1815, 1846, 2019, 2020, 3452, 3454,
    3461, 3471, 3472, 3473, 3615, 3616, 4663, 4665, 4798, 4800, 5000, 6389, 6398, 6503, 6593, 6594, 6596, 6610,
    6620, 7281, 7284, 7291, 7443, 7449, 7649, 7971, 7972, 8277, 8419, 8422, 10429, 14786, 20943, 26656, 26658,
    26659, 26661, 26662, 26753, 26755, 26756, 26758, 26759, 26768, 26770, 26771, 26772, 26773, 26774, 26776, 26835,
    26838, 26897, 26899, 26900, 26902, 26903, 26905, 26906, 28463, 28466, 28467, 28469, 28476, 28477, 28479, 30650,
    30655, 31863, 31865, 31866, 31869, 31885, 31889, 31897, 31949, 32066, 32091, 32678, 32703, 33720, 33752, 34147,
    34156, 37556, 37571, 37585, 37586, 37608, 37609, 37610, 38071, 38095, 38128, 38416, 39665, 39666, 41829, 41834,
    41835, 41841, 42415, 46181, 46182, 46183, 46184, 46185, 46186, 46189, 46217, 46221, 46312, 46415, 46469, 46470,
    46474, 46475, 46567, 46809, 49851, 49856, 49903, 49934, 51301, 54985, 54986, 54989, 54990, 54991, 55431, 56976,
    56978, 56979, 56983, 56984, 56987, 57212, 57639, 57640, 57641, 57646, 57648, 57650, 57651, 57652, 57662, 57663,
    57664, 57669, 57670, 57671, 57673, 57674, 57675, 57708, 57737, 57742, 57748, 59513, 59520, 59521, 61721, 61958,
    62994, 62995, 62996, 63005, 63006, 63007, 63009, 63010, 63013, 63014, 79645, 79778, 79779, 79780, 79787, 79788,
    79860, 79962, 79964, 79966, 79986, 80325, 80333, 80344, 80347, 80353, 84574, 84577, 84581, 84585, 85589, 85590,
    85624, 85626, 85628, 90460, 90461, 90463, 90465, 90466, 90467, 90480, 95051, 95060, 95067, 95068, 95069, 95070,
    95071, 95072, 95073, 95122, 95123, 95125, 95126, 95127, 95128, 95129, 95130, 95131, 95206, 95209, 95210, 95213,
    95226, 95228, 95234, 95236, 95243, 95273, 95274, 95280, 95281, 95282, 95283, 95284, 95286, 95288, 95329, 95330,
    95336, 95340, 95348, 95361, 95369, 95370, 95371, 95390, 95404, 95406, 95407, 95409, 95410, 95411, 95412, 95417,
    95475, 95476, 95489, 95493, 95494, 95495, 95496, 95497, 95498, 95528, 95532, 95533, 95551, 95554, 95555, 95556,
    95561, 95562, 95607, 95608, 95611, 95612, 95618, 95619, 95620, 95621, 95667, 95675, 95676, 95678, 95687, 95688,
    95689, 95690, 95691, 95706, 95707, 95708, 95748, 95749, 95755, 95756, 95757, 95758, 95808, 95809, 95811, 95812,
    95814, 95815, 95816, 95819, 95823, 95877, 95878, 95879, 95880, 95881, 95882, 95883, 95884, 95888, 95896, 95897,
    95898, 95899, 95902, 95903, 95920, 95921, 95933, 95999, 96007, 96008, 96009, 96010, 96014, 96015, 96016, 96041,
    96044, 96045, 96046, 96061, 96064, 96067, 96071, 96076, 96102, 96105, 96106, 96118, 96120, 96122, 96124, 96126,
    96128, 96180, 96184, 96185, 96186, 96187, 96188, 96189, 96196, 96199, 96226, 96228, 96229, 96230, 96236, 96237,
    96239, 96240, 96257, 96323, 96325, 96328, 96329, 96330, 96332, 96333, 96335, 96336, 96367, 96371, 96389, 96391,
    96394, 96395, 96396, 96397, 96400, 96432, 96433, 96434, 96435, 96437, 96440, 96441, 96442, 96507, 96511, 96512,
    96513, 96518, 96519, 96523, 96524, 96525, 96571, 96574, 96575, 96576, 96577, 96578, 96580, 96581, 96582, 98417,
    98820, 125641, 125642, 125712, 128505, 128506, 128507, 130468, 137653
) AND `guid` NOT IN (SELECT `guid` FROM `creature`);
DELETE FROM `game_event_creature` WHERE `eventEntry` = 31 AND `guid` IN (
    95051, 95060, 95067, 95068, 95069, 95070, 95071, 95072, 95073, 95122, 95123, 95125, 95126, 95127, 95128, 95129,
    95130, 95131, 95206, 95209, 95210, 95213, 95226, 95228, 95234, 95236, 95243, 95273, 95274, 95280, 95281, 95282,
    95283, 95284, 95286, 95288, 95329, 95330, 95336, 95340, 95348, 95361, 95369, 95370, 95371, 95390, 95404, 95406,
    95407, 95409, 95410, 95411, 95412, 95417, 95475, 95476, 95489, 95493, 95494, 95495, 95496, 95497, 95498, 95528,
    95532, 95533, 95551, 95554, 95555, 95556, 95561, 95562, 95607, 95608, 95611, 95612, 95618, 95619, 95620, 95621,
    95667, 95675, 95676, 95678, 95687, 95688, 95689, 95690, 95691, 95706, 95707, 95708, 95748, 95749, 95755, 95756,
    95757, 95758, 95808, 95809, 95811, 95812, 95814, 95815, 95816, 95819, 95823, 95877, 95878, 95879, 95880, 95881,
    95882, 95883, 95884, 95888, 95896, 95897, 95898, 95899, 95902, 95903, 95920, 95921, 95933, 95999, 96007, 96008,
    96009, 96010, 96014, 96015, 96016, 96041, 96044, 96045, 96046, 96061, 96064, 96067, 96071, 96076, 96102, 96105,
    96106, 96118, 96120, 96122, 96124, 96126, 96128, 96180, 96184, 96185, 96186, 96187, 96188, 96189, 96196, 96199,
    96226, 96228, 96229, 96230, 96236, 96237, 96239, 96240, 96257, 96323, 96325, 96328, 96329, 96330, 96332, 96333,
    96335, 96336, 96367, 96371, 96389, 96391, 96394, 96395, 96396, 96397, 96400, 96432, 96433, 96434, 96435, 96437,
    96440, 96441, 96442, 96507, 96511, 96512, 96513, 96518, 96519, 96523, 96524, 96525, 96571, 96574, 96575, 96576,
    96577, 96578, 96580, 96581, 96582
) AND `guid` NOT IN (SELECT `guid` FROM `creature`);
DELETE FROM `game_event_npcflag` WHERE `eventEntry` = 17 AND `guid` = 1803
    AND `guid` NOT IN (SELECT `guid` FROM `creature`);
DELETE FROM `game_event_npc_vendor` WHERE `eventEntry` = 17 AND `guid` = 1803
    AND `guid` NOT IN (SELECT `guid` FROM `creature`);
DELETE FROM `game_event_npcflag` WHERE `eventEntry` = 17 AND `guid` = 26771
    AND `guid` NOT IN (SELECT `guid` FROM `creature`);
DELETE FROM `game_event_npc_vendor` WHERE `eventEntry` = 17 AND `guid` = 26771
    AND `guid` NOT IN (SELECT `guid` FROM `creature`);
-- Paths walked only by High Priest Rohan (1777), Horace Alder (1846), Brother Benjamin (37556), Lord Thorval
--   29196 (125712), Lord Thorval 28472 (128506)
DELETE FROM `waypoint_data` WHERE `id` IN (17770, 18460, 375560, 1257120, 1285060)
    AND `id` NOT IN (SELECT `path_id` FROM `creature_addon`)
    AND `id` NOT IN (SELECT `path_id` FROM `creature_template_addon`);

-- ---------------------------------------------------------------------------
-- 4. Stock class quests left without an ender lose their givers
-- ---------------------------------------------------------------------------
-- Marshal McBride 197: 3100, 3102, 3104, 3105
-- Sten Stoutarm 658: 3106, 3108, 3109, 3110, 3112, 3113, 3115
-- Grimand Elmore 1416: 7648
-- Shadow Priest Sarvis 1569: 3096, 3097, 3098, 3099
-- Conservator Ilthalaine 2079: 3117, 3119, 3120
-- Grull Hawkwind 2980: 3091, 3092, 3093
-- Lanka Farshot 3061, a retired trainer: 6067
-- Gornek 3143: 3082, 3083, 3084, 3086, 3087, 3088, 3089, 3090
-- Jen'shan 3154, a retired trainer: 6067
-- Thotar 3171: 6065, 6081
-- Sian'dur 3407, a retired trainer: 6067
-- Dazalar 3601: 6103
-- Carendin Halgar 5675: 10788
-- Gan'rul Bloodeye 5875: 10788
-- Duthorian Rall 6171: 7638
-- Mennet Carkad 6467: 2378
-- Onin MacHammar 6886: 2239
-- Taskmaster Fizzule 7233: 2478
-- Uthel'nay 7311: 1883
-- Dendrite Starblaze 11802: 31, 5932, 6130
-- Ancient Equine Spirit 14566: 7644
-- Magistrix Erona 15278: 8328, 8563, 8564, 9392, 9393, 9676
-- Telenus 16271: 6067
-- Spirit of the Vale 17087: 9451
-- Temper 17205: 9468
-- Keltus Darkleaf 17224: 9618
-- Jol 17509, a retired trainer: 9600
-- Highlord Darion Mograine 29173: 13165
-- Highlord Darion Mograine 31084, a retired trainer: 13165
DELETE FROM `creature_queststarter` WHERE (`id`, `quest`) IN (
    (197, 3100), (197, 3102), (197, 3104), (197, 3105), (658, 3106), (658, 3108), (658, 3109), (658, 3110),
    (658, 3112), (658, 3113), (658, 3115), (1416, 7648), (1569, 3096), (1569, 3097), (1569, 3098), (1569, 3099),
    (2079, 3117), (2079, 3119), (2079, 3120), (2980, 3091), (2980, 3092), (2980, 3093), (3061, 6067), (3143, 3082),
    (3143, 3083), (3143, 3084), (3143, 3086), (3143, 3087), (3143, 3088), (3143, 3089), (3143, 3090), (3154, 6067),
    (3171, 6065), (3171, 6081), (3407, 6067), (3601, 6103), (5675, 10788), (5875, 10788), (6171, 7638),
    (6467, 2378), (6886, 2239), (7233, 2478), (7311, 1883), (11802, 31), (11802, 5932), (11802, 6130),
    (14566, 7644), (15278, 8328), (15278, 8563), (15278, 8564), (15278, 9392), (15278, 9393), (15278, 9676),
    (16271, 6067), (17087, 9451), (17205, 9468), (17224, 9618), (17509, 9600), (29173, 13165), (31084, 13165)
);
-- Voidstone 181698: 9619
DELETE FROM `gameobject_queststarter` WHERE `id` = 181698 AND `quest` = 9619;
-- RewardNextQuest offers that now find no giver row: 30 -> 31, 2238 -> 2239, 5930 -> 5932, 6082 -> 6081, 6102 ->
--   6103, 6129 -> 6130, 7643 -> 7644, 9450 -> 9451, 9460 -> 9618, 9529 -> 9619, 9598 -> 9600, 9599 -> 9600,
--   12801 -> 13165

-- ---------------------------------------------------------------------------
-- 5. Morgan Stern no longer hands out the Elegant Letter of the orphaned rogue quest 6681
-- ---------------------------------------------------------------------------
DELETE FROM `conditions` WHERE `SourceTypeOrReferenceId` = 15 AND `SourceGroup` = 4576 AND `SourceEntry` = 4;
DELETE FROM `gossip_menu_option_locale` WHERE `MenuID` = 4576 AND `OptionID` = 4;
DELETE FROM `gossip_menu_option` WHERE `MenuID` = 4576 AND `OptionID` = 4;
