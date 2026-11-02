--
-- Raid Progression Tracker Module
-- Per-character boss kill tracking across dungeons, raids and world bosses.
--

CREATE TABLE IF NOT EXISTS `raid_progression_tracker` (
  `player_guid`     INT UNSIGNED      NOT NULL,
  `content_type`    TINYINT UNSIGNED  NOT NULL DEFAULT 0,  -- 0=dungeon, 1=raid, 2=world boss (extensible)
  `map_id`          SMALLINT UNSIGNED NOT NULL,
  `boss_entry`      INT UNSIGNED      NOT NULL,
  `difficulty`      TINYINT UNSIGNED  NOT NULL,
  `kill_count`      INT UNSIGNED      NOT NULL DEFAULT 0,
  `first_kill_time` INT UNSIGNED      NOT NULL DEFAULT 0,
  `last_kill_time`  INT UNSIGNED      NOT NULL DEFAULT 0,
  PRIMARY KEY (`player_guid`, `boss_entry`, `difficulty`),
  KEY `idx_type_map_diff` (`content_type`, `map_id`, `difficulty`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
