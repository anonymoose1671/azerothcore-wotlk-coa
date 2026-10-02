-- A Quiet Life 200081 (Templar, Deathknell) had no turn-in text. No source records it: CoA's quest cache holds no
-- reward text, and no archive or database export has any for the six A Quiet Life quests. This text is INFERRED,
-- written in Vaelion Grandbell's voice to answer his request ("Tell me what you experience when you return").
DELETE FROM `quest_offer_reward` WHERE `ID` = 200081;
INSERT INTO `quest_offer_reward` (`ID`, `RewardText`) VALUES
(200081, 'So you found it, $N. Few think to look in that gap, and fewer still manage the climb.$B$BWhoever raised that statue after the Third War did so in secret, and the mountain has kept it hidden ever since. Did you feel the stillness there? That calm is what I go looking for each time I make the climb.$B$BA Templar\'s discipline begins in that quiet place. Carry it with you, and take these gauntlets. May they keep your hands as steady as your mind.');
