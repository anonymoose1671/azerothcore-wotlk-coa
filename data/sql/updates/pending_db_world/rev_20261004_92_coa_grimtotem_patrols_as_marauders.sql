-- The five Grimtotem Patrols of Three Totems (Mulgore, Red Cloud Mesa) become Grimtotem Marauders 161809: neutral, with
-- the Marauders' aggro lines. Only these spawns change; each keeps its guid, so its route, wander and animation stay.
UPDATE `creature` SET `id` = 161809 WHERE `id` = 161810 AND `guid` IN (9011060, 9011062, 9011068, 9011069, 9011133);
