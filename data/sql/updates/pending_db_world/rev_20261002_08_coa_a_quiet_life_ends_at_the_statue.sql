-- A Quiet Life 200081 (Templar, Deathknell) is turned in at the Hidden Statue it sends the player to, not back at
-- Vaelion Grandbell (author's call; INFERRED). The statue becomes a quest giver object, like the Ritual Circles.
-- No source records the quest's turn-in text: CoA's quest cache holds no reward text, and no archive or database
-- export has any for the six A Quiet Life quests. This text is INFERRED, written for the statue.
UPDATE `gameobject_template` SET `type` = 2 WHERE `entry` = 9301257;
DELETE FROM `creature_questender` WHERE `id` = 502803 AND `quest` = 200081;
DELETE FROM `gameobject_questender` WHERE `id` = 9301257 AND `quest` = 200081;
INSERT INTO `gameobject_questender` (`id`, `quest`) VALUES (9301257, 200081);
DELETE FROM `quest_offer_reward` WHERE `ID` = 200081;
INSERT INTO `quest_offer_reward` (`ID`, `RewardText`) VALUES
(200081, 'The paladin''s stone face is worn smooth by wind and rain, yet the hidden gap has kept it whole. Whoever raised it after the Third War did so in secret, and few have climbed here since.$B$BYou rest a hand on the cold stone. The wind falls quiet, and for a long moment there is nothing but your breath and the steady beat of your heart.$B$BAt the statue''s feet lies a pair of gauntlets, left for whoever made the climb.');
