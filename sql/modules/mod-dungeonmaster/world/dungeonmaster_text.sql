
SET @TEXT_ID = 197760,
@TEXT= '想下副本？我走遍了全世界，能把你送到任何想去的地方。至于去了你不该去的地方而发生的伤亡，本人概不负责。';



DELETE FROM `npc_text` WHERE `ID` IN (@TEXT_ID);

INSERT INTO `npc_text` (`ID`, `text0_0`) VALUES (@TEXT_ID, @TEXT);