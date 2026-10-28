-- ============================================================================
-- 遗产职业强化（出生自带被动强化） Heritage Class Buffs
-- 适用：AzerothCore 3.3.5a + mod-ale（Eluna 兼容引擎）
-- 灵感来源：逍遥魔兽「遗产补丁」——每个职业出生即带 2~3 个被动强化，
--           专门为单人/机器人小队 PVE 提高可玩性。
-- 实现方式（不修改核心 / 不新增 DBC / 不新增技能 ID，保持上游纯净可同步）：
--   1) 登录/升级时施放一个隐藏属性光环（默认 25898 王者祝福 = 10% 总属性，
--      可替换为任意"属性百分比"光环 spellId）
--   2) OnCalcRating 按职业提升战斗等级（暴击/急速/精准/命中，百分比乘算）
--   3) OnCalcDamageTaken 按职业提供全程减伤
-- 所有数值集中在本文件顶部配置表，改完保存即可（ALE 支持文件变更自动重载，
-- 若未开启自动重载则 .reload eluna 或重启生效）。
-- ============================================================================

local HERITAGE = {
    enabled = true,                -- 总开关：false 则全部失效
    welcome = false,               -- 登录时是否发送一条"已获得遗产强化"提示
    -- 每个职业配置：
    --   aura  = 登录/升级时施放的光环 spellId（0 = 不施放）
    --   ratings = { [战斗等级ID] = 倍率 }，倍率乘算该等级点数（1.10 = +10%）
    --   reduce = 全程减伤比例（0.03 = 3%）
    --
    -- 战斗等级 ID（WotLK CombatRating 枚举）：
    --   2=闪避 3=招架 4=格挡 5=近战命中 6=远程命中 7=法术命中 8=近战暴击
    --   9=远程暴击 10=法术暴击 17=近战急速 18=远程急速 19=法术急速 23=精准
    classes = {
        [1]  = { name = "战士",   aura = 25898, ratings = { [17] = 1.10, [23] = 1.10 }, reduce = 0.03 }, -- 近战急速+10% 精准+10% 减伤3%
        [2]  = { name = "圣骑士", aura = 25898, ratings = { [4]  = 1.15 },                reduce = 0.05 }, -- 格挡等级+15% 减伤5%
        [3]  = { name = "猎人",   aura = 25898, ratings = { [9]  = 1.10, [18] = 1.10 },   reduce = 0.02 }, -- 远程暴击+10% 远程急速+10% 减伤2%
        [4]  = { name = "潜行者", aura = 25898, ratings = { [8]  = 1.10, [17] = 1.10 },   reduce = 0.03 }, -- 近战暴击+10% 近战急速+10% 减伤3%
        [5]  = { name = "牧师",   aura = 25898, ratings = { [10] = 1.10, [19] = 1.10 },   reduce = 0.02 }, -- 法术暴击+10% 法术急速+10% 减伤2%
        [6]  = { name = "死亡骑士", aura = 25898, ratings = { [8] = 1.10, [23] = 1.10 },  reduce = 0.05 }, -- 近战暴击+10% 精准+10% 减伤5%
        [7]  = { name = "萨满祭司", aura = 25898, ratings = { [8] = 1.10, [10] = 1.10 },  reduce = 0.03 }, -- 近战暴击+10% 法术暴击+10% 减伤3%
        [8]  = { name = "法师",   aura = 25898, ratings = { [10] = 1.10, [19] = 1.10 },   reduce = 0.02 }, -- 法术暴击+10% 法术急速+10% 减伤2%
        [9]  = { name = "术士",   aura = 25898, ratings = { [10] = 1.10, [19] = 1.10 },   reduce = 0.02 }, -- 法术暴击+10% 法术急速+10% 减伤2%
        [11] = { name = "德鲁伊", aura = 25898, ratings = { [8]  = 1.10, [10] = 1.10 },   reduce = 0.03 }, -- 近战暴击+10% 法术暴击+10% 减伤3%
    },
}

-- ----------------------------------------------------------------------------
-- 事件回调
-- ----------------------------------------------------------------------------

-- 登录时施放出生被动光环（ALE 回调签名：第一个参数为 event 号）
local function ApplyHeritageAura(event, player)
    if not HERITAGE.enabled then
        return
    end
    local cfg = HERITAGE.classes[player:GetClass()]
    if not cfg or not cfg.aura or cfg.aura <= 0 then
        return
    end
    player:AddAura(cfg.aura, player)
    if HERITAGE.welcome then
        player:SendBroadcastMessage("|cff00ccff【遗产强化】|r 已获得" .. cfg.name .. "的出生被动强化。")
    end
end

-- 升级时刷新（防止转职/洗点等场景丢失；等级本身不影响光环，这里保证始终挂着）
local function OnLevelChange(event, player, oldLevel)
    ApplyHeritageAura(event, player)
end

-- 战斗等级乘算：handler(event, player, rating, value, isCombatRating, isPvpRating)
local function OnCalcRating(event, player, rating, value, isCombatRating, isPvpRating)
    if not HERITAGE.enabled or value <= 0 then
        return value
    end
    local cfg = HERITAGE.classes[player:GetClass()]
    if not cfg then
        return value
    end
    local mult = cfg.ratings[rating]
    if not mult then
        return value
    end
    return math.floor(value * mult + 0.5)
end

-- 全程减伤：handler(event, player, attacker, damage)
local function OnCalcDamageTaken(event, player, attacker, damage)
    if not HERITAGE.enabled or not damage or damage <= 0 then
        return damage
    end
    local cfg = HERITAGE.classes[player:GetClass()]
    if not cfg or not cfg.reduce or cfg.reduce <= 0 then
        return damage
    end
    return math.max(1, damage * (1 - cfg.reduce))
end

-- ----------------------------------------------------------------------------
-- 事件注册（ALE PlayerEvents 常量，见 mod-ale/src/LuaEngine/Hooks.h）
--   3  = PLAYER_EVENT_ON_LOGIN        (event, player)
--   2  = PLAYER_EVENT_ON_LEVEL_CHANGE (event, player, oldLevel)   [注意：ALE 事件 2 为 CHARACTER_DELETE，升级事件实为 13]
--   13 = PLAYER_EVENT_ON_LEVEL_CHANGE (event, player, oldLevel)
-- ----------------------------------------------------------------------------
-- 说明：谷神原脚本按 Eluna 事件号注册 2(升级)/27(评级)/42(减伤)；mod-ale 的事件
--       枚举与 Eluna 不同（2=角色删除、27=更新区域、42=命令），评级/减伤事件
--       ALE 无等价实现，已移除；升级事件改用 ALE 的 13。
-- ----------------------------------------------------------------------------
RegisterPlayerEvent(3, ApplyHeritageAura)
RegisterPlayerEvent(13, OnLevelChange)
