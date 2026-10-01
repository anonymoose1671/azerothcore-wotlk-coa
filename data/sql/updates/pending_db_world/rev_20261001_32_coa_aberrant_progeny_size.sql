-- Aberrant Progeny 161757 (The True Heir of the Cains) drew about 1.6 times its size in CoA footage, where it stands
-- roughly as tall as the player; display 76125 has no scale of its own (1.0), so the model scale goes to 0.6
-- (INFERRED from the footage).
UPDATE `creature_template_model` SET `DisplayScale` = 0.6 WHERE `CreatureID` = 161757 AND `Idx` = 0;
