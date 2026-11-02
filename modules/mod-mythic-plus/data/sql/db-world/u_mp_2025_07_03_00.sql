DELETE FROM `command` WHERE `name` IN ('mythic', 'mythic reload', 'mythic info');
INSERT IGNORE INTO `command` (`name`, `security`, `help`) VALUES
('mythic', 0, 'Syntax: .mythic $subcommand
Type .mythic to see the list of possible subcommands.');
INSERT IGNORE INTO `command` (`name`, `security`, `help`) VALUES
('mythic reload', 3, 'Reloads specific tables related to Mythic Plus');
INSERT IGNORE INTO `command` (`name`, `security`, `help`) VALUES
('mythic info', 0, 'Prints current Mythic Plus information');
