--
-- Created by IntelliJ IDEA.
-- User: Silvia
-- Date: 08/03/2021
-- Time: 20:39
-- To change this template use File | Settings | File Templates.
-- Originally created by Honey for Azerothcore
-- requires ElunaLua module
-- 上游来源: modules/Acore_RecruitAFriend/RecruitAFriend.lua
-- 本服汉化说明: 玩家可见字符串(邮件/广播/.raf 命令输出)已译为简体中文;
--               GM 管理命令(.bindraf/.forcebindraf/.raf lookup)为运营端工具,保留英文原文。


-- 本模块允许玩家与好友的账号绑定(战友招募),双方共同获得福利
------------------------------------------------------------------------------------------------
-- 管理员指南: - 核心需编译 ElunaLua 模块
--            - 修改本文件顶部的配置
--            - 将本脚本放入 ../lua_scripts/ 目录(本服已落位 custom/lua_scripts/)
--            - 通过网站 SOAP 调用给定命令来添加/删除绑定(需配合 acore-cms 改造):
--            - 绑定招募关系: .bindraf $新被招募人ID $招募人ID
------------------------------------------------------------------------------------------------
-- 玩家指南: - 作为新玩家(被招募人/RECRUIT): 注册账号时在网站上填写招募人的账号 ID,即可被招募
--           - 作为老玩家(招募人/RECRUITER): 用 ".raf summon $好友角色名" 召唤你的好友
--           - 输入 ".raf help" 可查看自己的账号 ID
--           - 当被招募人达到配置中的目标等级时,招募人将收到奖励邮件。
--           - 同一 IP 可能会被限制或解除绑定(同一家庭/宿舍等情况,敬请谅解)
------------------------------------------------------------------------------------------------

local Config = {}
local Config_maps = {}
local Config_rewards = {}
local Config_amounts = {}
local Config_defaultRewards = {}
local Config_defaultAmounts = {}

-- Eluna 自定义数据库名
Config.customDbName = "ac_eluna"

-- 设为 1 时向控制台打印错误信息; 其他任何值(含 nil)关闭
Config.printErrorsToConsole = 1

-- 绑定账号所需的最低 GM 等级
Config.minGMRankForBind = 3

-- 读取招募数据所需的最低 GM 等级
Config.minGMRankForRead = 2

-- 战友招募有效期上限(秒)。2,592,000 = 30 天
Config.maxRAFduration = 2592000

-- 设为 1 时给被招募人自动挂满休息经验; 其他任何值(含 nil)关闭
Config.grantRested = 1

-- 设为 1 时登录时发送招募提示广播; 其他任何值(含 nil)关闭
Config.displayLoginMessage = 1

-- 被招募人达到该等级后,招募人获得奖励并自动结束招募关系
Config.targetLevel = 58

-- 达到目标等级后是否自动解除招募链接
Config.endOnLevel = 1

-- 设为 1 时, 超过 Config.targetLevel 的付费玩家持续挂满休息经验; 其他任何值(含 nil)关闭
Config.premiumFeature = 0

-- 战友招募相关命令(含召唤请求)的滥用阈值, 超过后踢下线
Config.abuseTreshold = 1000

-- 是否检查召唤人与被召唤人是否处于同一 IP
Config.checkSameIp = 1

-- 设为 1 时, 链接账号共享 IP 即首次违规直接结束招募关系; 其他任何值(含 nil)关闭
Config.endRAFOnSameIP = 0

-- 招募人获奖奖励邮件的正文
Config.mailText = "你好，冒险者！\n你成功将朋友引入了克罗米的世界，为此获得了一份奖励。\n不要停下脚步，后续还有更多好礼等你。\n\n"

-- 修改邮件数据库以防奖励被退回。开启后发件人由玩家改为生物。若此项为 1, Config.senderGUID 必须填生物 entry
Config.preventReturn = 1

-- 发件人玩家 GUID / 生物 entry。若 Config.preventReturn = 1 必须填生物 entry, 否则填玩家 GUID。0 = 无发件人(显示"来自: 未知")。生物 10667 即"克罗米"。
Config.senderGUID = 10667

-- 奖励邮件使用的信纸样式。(41 普通邮件, 61 GM/暴雪客服, 62 拍卖行, 64 情人节, 65 圣诞节) 注意: 62/64/65 自行承担风险。
Config.mailStationery = 41

-- 服务启动/重载时是否自动清除同 IP 的招募链接?
Config.AutoKillSameIPLinks = 1

-- 招募人累计招募达到目标等级的人数对应的奖励。某档位未定义时, 发送默认药水套装
Config_rewards[1] = 56806    -- 迷你雷神, 战团绑定宠物
Config_rewards[3] = 21841    -- 魔化布料包 - 16 格
Config_rewards[5] = 13584    -- 迪亚布罗之石, 战团绑定宠物
Config_rewards[10] = 39656   -- 泰瑞尔的剑柄, 战团绑定宠物

-- 各奖励档位的发放数量
Config_amounts[1] = 1
Config_amounts[3] = 1
Config_amounts[5] = 1
Config_amounts[10] = 1

-- 某档位未在 Config_rewards 中定义时的默认奖励。可自行修改, 不可删除。
Config_defaultRewards[1] = 13454  -- 战斗药剂: 法术强度
Config_defaultRewards[2] = 13452  -- 战斗药剂: 敏捷
Config_defaultRewards[3] = 13453  -- 战斗药剂: 力量
Config_defaultRewards[4] = 5634   -- 自由行动药水

Config_defaultAmounts[1] = 10
Config_defaultAmounts[2] = 10
Config_defaultAmounts[3] = 10
Config_defaultAmounts[4] = 9

-- 以下为允许召唤到达的地图。如需增加可用 table.insert() 添加。
-- 注释掉或删除下方所有 table.insert 即可禁止召唤功能
-- 东部王国
table.insert(Config_maps, 0)
-- 卡利姆多
table.insert(Config_maps, 1)
-- 外域
table.insert(Config_maps, 530)
-- 诺森德
--table.insert(Config_maps, 571)
------------------------------------------
-- 以下行无需调整
------------------------------------------

local PLAYER_EVENT_ON_LOGIN = 3          -- (event, player)
local PLAYER_EVENT_ON_LEVEL_CHANGE = 13  -- (event, player, oldLevel)
local PLAYER_EVENT_ON_COMMAND = 42       -- (event, player, command) - player is nil if command used from console. Can return false

CharDBQuery('CREATE DATABASE IF NOT EXISTS `'..Config.customDbName..'`;');
CharDBQuery('CREATE TABLE IF NOT EXISTS `'..Config.customDbName..'`.`recruit_a_friend_links` (`account_id` INT NOT NULL, `recruiter_account` INT DEFAULT 0, `time_stamp` INT DEFAULT 0, `ip_abuse_counter` INT DEFAULT 0, `kick_counter` INT DEFAULT 0, `complete` TINYINT DEFAULT 0, `comment` varchar(255) DEFAULT "", PRIMARY KEY (`account_id`) );');
CharDBQuery('CREATE TABLE IF NOT EXISTS `'..Config.customDbName..'`.`recruit_a_friend_rewards` (`recruiter_account` INT DEFAULT 0, `reward_level` INT DEFAULT 0, PRIMARY KEY (`recruiter_account`) );');

--sanity check
if Config_defaultRewards[1] == nil or Config_defaultRewards[2] == nil or Config_defaultRewards[3] == nil or Config_defaultRewards[4] == nil then
    PrintError("RAF: The Config_defaultRewards value was removed for at least one flag ([1]-[4] are required.)")
end

if Config.AutoKillSameIPLinks == 1 then
    CharDBQuery('UPDATE `'..Config.customDbName..'`.recruit_a_friend_links SET time_stamp = 0 WHERE ip_abuse_counter > 5 AND time_stamp > 1;')
end

--globals:
RAF_xpPerLevel = {}
RAF_recruiterAccount = {}
RAF_timeStamp = {}
RAF_abuseCounter = {}
RAF_sameIpCounter = {}
RAF_kickCounter = {}
RAF_lastIP = {}
RAF_rewardLevel = {}
RAF_complete = {}

local function RAF_numeralise(n)
    n = tostring(n)
    if string.sub(n, -1) == "1" then
        n = n.."st"
    elseif string.sub(n, -1) == "2" then
        n = n.."nd"
    elseif string.sub(n, -1) == "3" then
        n = n.."rd"
    else
        n = n.."th"
    end
    return n
end

-- unix to date conversion based on http://www.ethernut.de/api/gmtime_8c_source.html
local floor=math.floor

local DSEC=24*60*60 -- secs in a day
local YSEC=365*DSEC -- secs in a year
local LSEC=YSEC+DSEC    -- secs in a leap year
local FSEC=4*YSEC+DSEC  -- secs in a 4-year interval
local BASE_DOW=4    -- 1970-01-01 was a Thursday
local BASE_YEAR=1970    -- 1970 is the base year

local _days={
    -1, 30, 58, 89, 119, 150, 180, 211, 242, 272, 303, 333, 364
}
local _lpdays={}
for i=1,2  do _lpdays[i]=_days[i]   end
for i=3,13 do _lpdays[i]=_days[i]+1 end

local function RAF_gmtime(t)
    local y,j,m,d,w,h,n,s
    local mdays=_days
    s=t
    -- First calculate the number of four-year-interval, so calculation
    -- of leap year will be simple. Btw, because 2000 IS a leap year and
    -- 2100 is out of range, this formula is so simple.
    y=floor(s/FSEC)
    s=s-y*FSEC
    y=y*4+BASE_YEAR         -- 1970, 1974, 1978, ...
    if s>=YSEC then
        y=y+1           -- 1971, 1975, 1979,...
        s=s-YSEC
        if s>=YSEC then
            y=y+1       -- 1972, 1976, 1980,... (leap years!)
            s=s-YSEC
            if s>=LSEC then
                y=y+1   -- 1971, 1975, 1979,...
                s=s-LSEC
            else        -- leap year
                mdays=_lpdays
            end
        end
    end
    j=floor(s/DSEC)
    s=s-j*DSEC
    local m=1
    while mdays[m]<j do m=m+1 end
    m=m-1
    local d=j-mdays[m]
    -- Calculate day of week. Sunday is 0
    w=(floor(t/DSEC)+BASE_DOW)%7
    -- Calculate the time of day from the remaining seconds
    h=floor(s/3600)
    s=s-h*3600
    n=floor(s/60)
    s=s-n*60
    d = RAF_numeralise(d)
    return(({"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"})[m]..', '..d..' '..y..' '..h..':'..n..':'..s)
end

local function RAF_PreventReturn(playerGUID)
    if Config.preventReturn == 1 then
        CharDBExecute('UPDATE `mail` SET `messageType` = 3 WHERE `sender` = '..Config.senderGUID..' AND `receiver` = '..playerGUID..' AND `messageType` = 0;')
    end
end

local function RAF_cleanup()
    --todo: check variables for required cleanups
    --set all non local runtime variables to nil
end

local function RAF_splitString(inputstr, seperator)
    if seperator == nil then
        seperator = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..seperator.."]+)") do
        table.insert(t, str)
    end
    return t
end

local function RAF_hasValue (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

local function RAF_hasIndex (tab, val)
    for index, value in ipairs(tab) do
        if index == val then
            return true
        end
    end
    return false
end

local function RAF_checkAbuse(accountId)
    if RAF_abuseCounter[accountId] == nil then
        RAF_abuseCounter[accountId] = 1
    else
        RAF_abuseCounter[accountId] = RAF_abuseCounter[accountId] + 1
    end

    if RAF_abuseCounter[accountId] > Config.abuseTreshold then
        return true
    end
    return false
end

local function RAF_command(event, player, command, chatHandler)
    local commandArray = {}
    -- split the command variable into several strings which can be compared individually
    commandArray = RAF_splitString(command)

    if commandArray[1] ~= "bindraf" and commandArray[1] ~= "forcebindraf" and commandArray[1] ~= "raf" then
        return
    end

    if commandArray[2] ~= nil then
        commandArray[2] = commandArray[2]:gsub("[';\\, ]", "")
        if commandArray[3] ~= nil then
            commandArray[3] = commandArray[3]:gsub("[';\\, ]", "")
        end
    end

    if commandArray[1] == "bindraf" then

        if player ~= nil then
            if player:GetGMRank() < Config.minGMRankForBind then
                if Config.printErrorsToConsole == 1 then PrintInfo("Account "..player:GetAccountId().." tried the .bindraf command without sufficient rights.") end
                return
            end
        end

        local commandSource
        if player == nil then
            commandSource = "worldserver console"
        else
            commandSource = "account id: "..tostring(player:GetAccountId())
        end
        -- GM/SOAP command to bind from console or ingame commands
        if commandArray[2] ~= nil and commandArray[3] ~= nil then
            local accountId = tonumber(commandArray[2])
            if RAF_recruiterAccount[accountId] == nil then
                RAF_recruiterAccount[accountId] = tonumber(commandArray[3])
                RAF_timeStamp[accountId] = (tonumber(tostring(GetGameTime())))
                CharDBExecute('REPLACE INTO `'..Config.customDbName..'`.`recruit_a_friend_links` VALUES ('..accountId..', '..RAF_recruiterAccount[accountId]..', '..RAF_timeStamp[accountId]..', 0, 0, 0, "");')
                chatHandler:SendSysMessage(commandSource.." has succesfully used the .bindraf command on recruit "..accountId.." and recruiter "..RAF_recruiterAccount[accountId]..".")
            else
                chatHandler:SendSysMessage("The selected account "..accountId.." is already recruited by "..RAF_recruiterAccount[accountId]..".")
            end
        else
            chatHandler:SendSysMessage("Admin/GM Syntax: .bindraf $recruit $recruiter binds the accounts to each other.")
            chatHandler:SendSysMessage("Admin/GM Syntax: .forcebindraf $recruit $recruiter same as .bindraf but ignores past binds. Previously unbound, succesful or timed out doesn't matter.")
        end
        RAF_cleanup()
        return false

    elseif commandArray[1] == "forcebindraf" then

        if player ~= nil then
            if player:GetGMRank() < Config.minGMRankForBind then
                if Config.printErrorsToConsole == 1 then PrintInfo("Account "..player:GetAccountId().." tried the .forcebindraf command without sufficient rights.") end
                return
            end
        end

        local commandSource
        if player == nil then
            commandSource = "worldserver console"
        else
            commandSource = "account id: "..tostring(player:GetAccountId())
        end
        -- GM/SOAP command to force bind from console or ingame commands
        if commandArray[2] ~= nil and commandArray[3] ~= nil then
            local accountId = tonumber(commandArray[2])
            RAF_recruiterAccount[accountId] = tonumber(commandArray[3])
            RAF_timeStamp[accountId] = (tonumber(tostring(GetGameTime())))
            CharDBExecute('REPLACE INTO `'..Config.customDbName..'`.`recruit_a_friend_links` VALUES ('..accountId..', '..RAF_recruiterAccount[accountId]..', '..RAF_timeStamp[accountId]..', 0, 0, 0, "");')
            chatHandler:SendSysMessage(commandSource.." has succesfully used the .forcebindraf command on recruit "..accountId.." and recruiter "..RAF_recruiterAccount[accountId]..".")
        else
            chatHandler:SendSysMessage("Admin/GM Syntax: .bindraf $recruit $recruiter binds the accounts to each other.")
            chatHandler:SendSysMessage("Admin/GM Syntax: .forcebindraf $recruit $recruiter same as .bindraf but ignores past binds. Previously unbound, succesful or timed out doesn't matter.")
        end
        RAF_cleanup()
        return false


    elseif commandArray[1] == "raf" then

        if player ~= nil then
            if RAF_checkAbuse(player:GetAccountId()) == true then
                local recruitId
                player:KickPlayer()
                for index, value in pairs(RAF_recruiterAccount) do
                    if value == player:GetAccountId() then
                        recruitId = index
                    end
                end
                if RAF_kickCounter[recruitId] == nil then
                    RAF_kickCounter[recruitId] = 1
                else
                    RAF_kickCounter[recruitId] = RAF_kickCounter[recruitId] + 1
                    CharDBExecute('UPDATE `'..Config.customDbName..'`.`recruit_a_friend_links` SET `kick_counter` = '..RAF_kickCounter[recruitId]..' WHERE `account_id` = '..recruitId..';')
                    if Config.printErrorsToConsole == 1 then PrintError("RAF: account id "..player:GetAccountId().." was kicked because of too many .raf commands.") end
                end
            end
        end

        -- list all accounts recruited by this account
        if commandArray[2] == "list" then

            if player == nil then
                chatHandler:SendSysMessage("'.raf list' is not meant to be used from the console.")
                return false
            end

            -- print all recruits bound to this account by charname
            local idList
            for index, value in pairs(RAF_recruiterAccount) do
                if value == player:GetAccountId() then
                    if RAF_timeStamp[index] > 1 then
                        if idList == nil then
                            idList = index
                        else
                            idList = idList.." "..index
                        end
                    end
                end
            end
            if idList == nil then
                idList = "无"
            end


            chatHandler:SendSysMessage("你当前招募的账号是："..idList)
            RAF_cleanup()
            return false

        elseif commandArray[2] == "summon" then
            if player == nil then
                chatHandler:SendSysMessage("'.raf summon' is not meant to be used from the console.")
                return false
            end

            if player:IsFlying() then
                chatHandler:SendSysMessage("飞行状态下无法使用 .raf summon。")
                return false
            end

            if commandArray[3] == nil then
                chatHandler:SendSysMessage("'.raf summon' 需要指定目标角色名，用法：'.raf summon $名字'")
                return false
            else
                commandArray[3] = commandArray[3]:gsub("^%l", string.upper)
            end

            -- check if the target is a recruit of the player
            local summonPlayer = GetPlayerByName(commandArray[3])
            if summonPlayer == nil then
                chatHandler:SendSysMessage("未找到目标角色，请检查拼写和大小写。")
                RAF_cleanup()
                return false
            end

            if RAF_recruiterAccount[summonPlayer:GetAccountId()] ~= player:GetAccountId() then
                chatHandler:SendSysMessage("该玩家不是你的招募对象。")
                RAF_cleanup()
                return false
            end

            if RAF_timeStamp[summonPlayer:GetAccountId()] == 0 or RAF_timeStamp[summonPlayer:GetAccountId()] == 1 then
                chatHandler:SendSysMessage("该玩家已不是你的招募对象。")
                RAF_cleanup()
                return false
            end

            -- do the zone/combat checks and possibly summon
            local mapId = player:GetMapId()
            -- allow to proceed if the player is on one of the maps listed above
            if RAF_hasValue(Config_maps, mapId) then
                --allow to proceed if the player is not in combat
                if not player:IsInCombat() then
                    local group = player:GetGroup()
                    if group == nil then
                        chatHandler:SendSysMessage("你必须与招募对象同在一个小队或团队中，才能召唤他。")
                        return false
                    end
                    local groupPlayers = group:GetMembers()
                    for _, v in pairs(groupPlayers) do
                        if v:GetName() == commandArray[3] then
                            if player:GetPlayerIP() == v:GetPlayerIP() and Config.checkSameIp == 1 and RAF_timeStamp[summonPlayer:GetAccountId()] >= 2 then
                                chatHandler:SendSysMessage("检测到疑似滥用行为，已取消本次召唤并记录日志。")
                                if RAF_sameIpCounter[summonPlayer:GetAccountId()] == nil then
                                    RAF_sameIpCounter[summonPlayer:GetAccountId()] = 1
                                    CharDBExecute('UPDATE `'..Config.customDbName..'`.`recruit_a_friend_links` SET ip_abuse_counter = '..RAF_sameIpCounter[summonPlayer:GetAccountId()]..' WHERE `account_id` = '..summonPlayer:GetAccountId()..';')
                                    RAF_cleanup()
                                    return false
                                else
                                    RAF_sameIpCounter[summonPlayer:GetAccountId()] = RAF_sameIpCounter[summonPlayer:GetAccountId()] + 1
                                    CharDBExecute('UPDATE `'..Config.customDbName..'`.`recruit_a_friend_links` SET ip_abuse_counter = '..RAF_sameIpCounter[summonPlayer:GetAccountId()]..' WHERE `account_id` = '..summonPlayer:GetAccountId()..';')
                                    RAF_cleanup()
                                    return false
                                end
                            end
                            v:SummonPlayer(player)
                        end
                    end
                else
                    chatHandler:SendSysMessage("战斗状态下无法召唤。")
                end
                return false
            else
                chatHandler:SendSysMessage("当前位置无法召唤。")
            end
            return false

        elseif commandArray[2] == "unbind" and commandArray[3] == nil then
            if player == nil then
                chatHandler:SendSysMessage("Console can not have recruits to remove.")
                return false
            end

            local accountId = player:GetAccountId()
            if RAF_recruiterAccount[accountId] ~= nil and RAF_timeStamp[accountId] > 1 then
                RAF_timeStamp[accountId] = 0
                CharDBExecute('UPDATE `'..Config.customDbName..'`.`recruit_a_friend_links` SET time_stamp = 0 WHERE `account_id` = '..accountId..';')
                chatHandler:SendSysMessage("你的战友招募链接已手动解除。")
            else
                chatHandler:SendSysMessage("你的账号当前不是（或已不再是）被招募账号。")
            end

            return false

        elseif commandArray[2] == "help" or commandArray[2] == nil then
            if player == nil then
                chatHandler:SendSysMessage("Admin/GM Syntax: .bindraf $recruit $recruiter binds the accounts to each other.")
                chatHandler:SendSysMessage("Admin/GM Syntax: .forcebindraf $recruit $recruiter same as .bindraf but ignores past binds. Previously unbound, succesful or timed out doesn't matter.")
            else
                chatHandler:SendSysMessage("你的账号 ID 是："..player:GetAccountId())
            end

            chatHandler:SendSysMessage("查看你招募的所有账号：.raf list")
            chatHandler:SendSysMessage("召唤你的招募对象：.raf summon $好友角色名")
            chatHandler:SendSysMessage("只有招募人可以召唤被招募人，被招募人不能召唤。你必须与对方同在一个小队/团队中。")
            RAF_cleanup()
            return false

        elseif commandArray[2] == "lookup" then
            if player == nil or player:GetGMRank() >= Config.minGMRankForRead then
                if commandArray[3] == nil then
                    chatHandler:SendSysMessage('Expected syntax: .raf lookup $accountId')
                    return false
                end

                commandArray[3] = tonumber(commandArray[3])
                if RAF_recruiterAccount[commandArray[3]] ~= nil then

                    chatHandler:SendSysMessage('RAF Data for account '..commandArray[3]..':')
                    chatHandler:SendSysMessage('Recruiter account: '..RAF_recruiterAccount[commandArray[3]])

                    if RAF_timeStamp[commandArray[3]] == 0 then
                        chatHandler:SendSysMessage('The RAF link was removed or expired.')
                    elseif RAF_timeStamp[commandArray[3]] == 1 then
                        chatHandler:SendSysMessage('The RAF link was succesful but is over.')
                    elseif RAF_timeStamp[commandArray[3]] == -1 then
                        chatHandler:SendSysMessage('The RAF link is permanently activated for a contributor.')
                    else
                        chatHandler:SendSysMessage('The RAF link is active and was activated at '..RAF_gmtime(RAF_timeStamp[commandArray[3]]))
                    end

                    if RAF_sameIpCounter[commandArray[3]] then
                        chatHandler:SendSysMessage('Same IP counter: '..RAF_sameIpCounter[commandArray[3]])
                    else
                        chatHandler:SendSysMessage('Same IP counter: 0')
                    end

                    if RAF_kickCounter[commandArray[3]] then
                        chatHandler:SendSysMessage('Kick counter: '..RAF_kickCounter[commandArray[3]])
                    else
                        chatHandler:SendSysMessage('Kick counter: 0')
                    end

                    if RAF_rewardLevel[commandArray[3]] ~=nil then
                        chatHandler:SendSysMessage('Reward Level: '..RAF_rewardLevel[commandArray[3]])
                    else
                        chatHandler:SendSysMessage('Reward Level: 0')
                    end
                else
                    chatHandler:SendSysMessage('Account with ID '..commandArray[3]..' has not been recruited.')
                end
                return false
            end
        end
    end
end

local function RAF_login(event, player)
    local accountId = player:GetAccountId()

    -- display login message
    if Config.displayLoginMessage == 1 then
        player:SendBroadcastMessage("本服已开启战友招募系统。输入 .raf 查看帮助。")
    end

    RAF_lastIP[accountId] = player:GetPlayerIP()

    -- check for an existing RAF connection when a RECRUIT or RECRUITER logs in
    local recruiterId = RAF_recruiterAccount[player:GetAccountId()]
    if recruiterId == nil and RAF_hasIndex(RAF_recruiterAccount, player:GetAccountId()) == false then
        return false
    end

    -- check for RAF timeout on login of the RECRUIT, possibly remove the link
    if RAF_timeStamp[accountId] <= 1 then
        if RAF_timeStamp[accountId] == -1 and Config.premiumFeature == 1 then
            if _G.ChallengeModes ~= nil and _G.ChallengeModes:isPlayerEnlisted(player) then
                return false
            end
            player:SetRestBonus(RAF_xpPerLevel[player:GetLevel()])
            return false
        else
            return false
        end
    end

    --reset abuse counter
    RAF_abuseCounter[accountId] = 0

    local targetDuration = RAF_timeStamp[accountId] + Config.maxRAFduration
    if (tonumber(tostring(GetGameTime()))) > targetDuration then
        RAF_timeStamp[accountId] = 0
        CharDBExecute('UPDATE `'..Config.customDbName..'`.`recruit_a_friend_links` SET time_stamp = 0 WHERE `account_id` = '..accountId..';')
        player:SendBroadcastMessage("你的战友招募链接已超时失效。")
        return false
    end

    -- add 1 full level of rested at login while in RAF
    if Config.grantRested == 1 then
        if _G.ChallengeModes == nil or not _G.ChallengeModes:isPlayerEnlisted(player) then
            player:SetRestBonus(RAF_xpPerLevel[player:GetLevel()])
        end
    end

    -- same IP check
    local recruiterId = RAF_recruiterAccount[accountId]
    if RAF_lastIP[accountId] == RAF_lastIP[recruiterId] then
        if Config.endRAFOnSameIP == 1 then
            player:SendBroadcastMessage("你的战友招募链接已被解除。")
            CharDBExecute('UPDATE `'..Config.customDbName..'`.`recruit_a_friend_links` SET time_stamp = 0 WHERE `account_id` = '..accountId..';')
            RAF_timeStamp[accountId] = 0
        else
            player:SendBroadcastMessage("战友招募：检测到疑似滥用行为，已记录日志。")
            if RAF_sameIpCounter[accountId] == nil then
                RAF_sameIpCounter[accountId] = 1
            else
                RAF_sameIpCounter[accountId] = RAF_sameIpCounter[accountId] + 1
            end
            CharDBExecute('UPDATE `'..Config.customDbName..'`.`recruit_a_friend_links` SET ip_abuse_counter = '..RAF_sameIpCounter[accountId]..' WHERE `account_id` = '..accountId..';')
        end
    end

    RAF_cleanup()
    return false
end

local function GrantReward(recruiterId)

    local recruiterCharacter
    if RAF_rewardLevel[recruiterId] == nil then
        RAF_rewardLevel[recruiterId] = 1
        CharDBExecute('REPLACE INTO `'..Config.customDbName..'`.`recruit_a_friend_rewards` VALUES ('..recruiterId..', '..RAF_rewardLevel[recruiterId]..');')
    else
        RAF_rewardLevel[recruiterId] = RAF_rewardLevel[recruiterId] + 1
        CharDBExecute('UPDATE `'..Config.customDbName..'`.`recruit_a_friend_rewards` SET reward_level = '..RAF_rewardLevel[recruiterId]..' WHERE `recruiter_account` = '..recruiterId..';')
    end

    local Data_SQL = CharDBQuery('SELECT `guid` FROM `characters` WHERE `account` = '..recruiterId..' LIMIT 1;')
    if Data_SQL ~= nil then
        recruiterCharacter = Data_SQL:GetUInt32(0)
    else
        if Config.printErrorsToConsole == 1 then PrintError("RAF: No character found on recruiter account with id "..recruiterId..", which was eligable for a RAF reward of level "..RAF_rewardLevel[recruiterId]..".") end
        return
    end

    --reward the recruiter
    local rewardLevel = RAF_rewardLevel[recruiterId]
    if Config_rewards[rewardLevel] == nil then
        --send the default set
        SendMail("战友招募奖励 第"..rewardLevel.."级", Config.mailText, recruiterCharacter, Config.senderGUID, Config.mailStationery, 0, 0, 0, Config_defaultRewards[1], Config_defaultAmounts[1], Config_defaultRewards[2], Config_defaultAmounts[2], Config_defaultRewards[3], Config_defaultAmounts[3], Config_defaultRewards[4], Config_defaultAmounts[4])
    else
        SendMail("战友招募奖励 第"..rewardLevel.."级", Config.mailText, recruiterCharacter, Config.senderGUID, Config.mailStationery, 0, 0, 0, Config_rewards[rewardLevel], Config_amounts[rewardLevel])
    end
    RAF_PreventReturn(recruiterCharacter)
end

local function RAF_levelChange(event, player, oldLevel)

    local accountId = player:GetAccountId()
    -- check for RAF timeout on login of the RECRUIT, possibly remove the link
    if RAF_recruiterAccount[accountId] == nil or RAF_timeStamp[accountId] <= 1 then
        if RAF_timeStamp[accountId] == -1 and Config.premiumFeature == 1 then
            if _G.ChallengeModes ~= nil and _G.ChallengeModes:isPlayerEnlisted(player) then
                return false
            end
            player:SetRestBonus(RAF_xpPerLevel[oldLevel + 1])
            return false
        else
            return false
        end
    end

    if Config.endOnLevel == 1 then
        if oldLevel + 1 >= Config.targetLevel then
            -- set time_stamp to 1 and Grant rewards
            RAF_timeStamp[accountId] = 1
            CharDBExecute('UPDATE `'..Config.customDbName..'`.`recruit_a_friend_links` SET time_stamp = 1 WHERE `account_id` = '..accountId..';')
            GrantReward(RAF_recruiterAccount[accountId])
            player:SendBroadcastMessage("你的战友招募链接已达到等级要求，你的招募人获得了一份奖励。快去带上更多朋友一起来冒险吧！")
            return false
        end
    else
        if oldLevel + 1 >= Config.targetLevel then
            -- grant rewards
            if RAF_complete[accountId] == 0 then
                GrantReward(RAF_recruiterAccount[accountId])
                CharDBExecute('UPDATE `'..Config.customDbName..'`.`recruit_a_friend_links` SET `complete` = 1 WHERE `account_id` = '..accountId..';')
                player:SendBroadcastMessage("你的战友招募链接已达到等级要求，你的招募人获得了一份奖励。快去带上更多朋友一起来冒险吧！")
                return false
            end
        end
    end

    local recruiterId = RAF_recruiterAccount[accountId]
    if recruiterId == nil then
        return false
    end

    -- add 1 full level of rested at levelup while in RAF and not at maxlevel with Player:SetRestBonus( restBonus )
    if Config.grantRested == 1 then
        if _G.ChallengeModes == nil or not _G.ChallengeModes:isPlayerEnlisted(player) then
            player:SetRestBonus(RAF_xpPerLevel[player:GetLevel()])
        end
    end
end

--INIT sequence:
--global table which reads the required XP per level one single time on load from the db instead of one value every levelup event
local RAF_Data_SQL
local RAF_row = 1
local RAF_Data_SQL = WorldDBQuery('SELECT Experience FROM player_xp_for_level WHERE Level <= 80;')
if RAF_Data_SQL ~= nil then
    repeat
        RAF_xpPerLevel[RAF_row] = RAF_Data_SQL:GetUInt32(0)
        RAF_row = RAF_row + 1
    until not RAF_Data_SQL:NextRow()
else
    PrintError("RAF: Error reading player_xp_for_level from tha database.")
end
RAF_Data_SQL = nil
RAF_row = nil

--global table which stores already granted rewards
local RAF_Data_SQL
local RAF_id
RAF_Data_SQL = CharDBQuery('SELECT * FROM `'..Config.customDbName..'`.`recruit_a_friend_rewards`;')
if RAF_Data_SQL ~= nil then
    repeat
        RAF_id = tonumber(RAF_Data_SQL:GetUInt32(0))
        RAF_rewardLevel[RAF_id] = tonumber(RAF_Data_SQL:GetUInt32(1))
    until not RAF_Data_SQL:NextRow()
else
    PrintError("RAF: Found no granted rewards in the recruit_a_friend_rewards table. Possibly there are none yet.")
end

--global table which stores all RAF links
local RAF_Data_SQL
local RAF_id
RAF_Data_SQL = CharDBQuery('SELECT * FROM `'..Config.customDbName..'`.`recruit_a_friend_links`;')

if RAF_Data_SQL ~= nil then
    repeat
        RAF_id = tonumber(RAF_Data_SQL:GetUInt32(0))
        RAF_recruiterAccount[RAF_id] = tonumber(RAF_Data_SQL:GetUInt32(1))
        RAF_timeStamp[RAF_id] = tonumber(RAF_Data_SQL:GetInt32(2))
        RAF_sameIpCounter[RAF_id] = RAF_Data_SQL:GetUInt32(3)
        RAF_kickCounter[RAF_id] = tonumber(RAF_Data_SQL:GetUInt32(4))
        RAF_complete[RAF_id] = tonumber(RAF_Data_SQL:GetUInt32(5))
    until not RAF_Data_SQL:NextRow()
else
    PrintError("RAF: Found no linked accounts in the recruit_a_friend table. Possibly there are none yet.")
end

RegisterPlayerEvent(PLAYER_EVENT_ON_COMMAND, RAF_command)
RegisterPlayerEvent(PLAYER_EVENT_ON_LOGIN, RAF_login)
RegisterPlayerEvent(PLAYER_EVENT_ON_LEVEL_CHANGE, RAF_levelChange)
