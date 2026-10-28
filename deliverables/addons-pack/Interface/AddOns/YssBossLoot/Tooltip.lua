
local _, YssBossLoot = ...

local lootdata = LibStub("LibInstanceLootData-1.0.01")

local r2,g2,b2 = 0.12,	1,		0	--0.64,0.19,0.79DH职业颜色--大脚颜色1,0.75,0--DK职业颜色0.77,0.12,0.23 --our tooltip text color
local r3,g3,b3 = 0,		0.51,	1
local r4,g4,b4 = 0.64,	0.19,	0.79
local r5,g5,b5 = 1, 	0.5,	0
local r6,g6,b6 = 0.9,	0.8,	0.5
--[[
		/* wow item quality */
	.wow-item-0, .wow-item-0 a { color: #9d9d9d !important; } /* poor (gray)垃圾 */--157 157 157 -0.62 0.62 0.62
	.wow-item-1, .wow-item-1 a { color: #ffffff !important; } /* common (white)普通 */--255 255 255 -1 1 1
	.wow-item-2, .wow-item-2 a { color: #1eff00 !important; } /* uncommon (green)优秀 */--30 255 0 -0.12 1 0
	.wow-item-3, .wow-item-3 a { color: #0081ff !important; } /* rare (blue)精良 */--0 129 255 -0 0.51 1
	.wow-item-4, .wow-item-4 a { color: #c600ff !important; } /* epic (purple)史诗 */--198 0 255 -0.78 0 1
	.wow-item-5, .wow-item-5 a { color: #ff8000 !important; } /* legendary (orange)传说 */--255 128 0 -1 0.5 0
	.wow-item-6, .wow-item-6 a { color: #e5cc80 !important; } /* artifact (gold)远古 */--229 204 128  -0.9 0.8 0.5
	.wow-item-7, .wow-item-7 a { color: #e5cc80 !important; } /* heirloom (gold)传家宝 */--229 204 128  -0.9 0.8 0.5
]]
local L = LibStub("AceLocale-3.0"):GetLocale("YssBossLoot", true)
local BZ = LibStub("LibBabble-Zone-3.0.01", true):GetUnstrictLookupTable()
local BB = LibStub("LibBabble-Boss-3.0.01", true):GetUnstrictLookupTable()
local AceGUI = LibStub("AceGUI-3.0")
local icon = LibStub("LibDBIcon-1.0")
local lootdata = LibStub("LibInstanceLootData-1.0.01")

local stringCache = {}
setmetatable(stringCache, {__mode = "kv"})
local origs = {}
local function OnTooltipSetItem(tooltip, ...)
	local name, link = tooltip:GetItem()
	if link then
		local itemID = string.match(link, "item:(%d+)")
		if stringCache[itemID] then
			local diffstr, instance, boss, droprate = string.match(stringCache[itemID], "([^|]+)|([^|]+)|([^|]+)|([^|]*)")
			tooltip:AddDoubleLine(diffstr, BZ[instance], r4,g4,b4, r3,g3,b3)
			tooltip:AddDoubleLine(BB[boss], droprate, r5,g5,b5, r6,g6,b6)
		else
			local iType, instance, boss, difficulty, droprate = lootdata:FindItem(itemID)
			if iType then
				local diffstr = lootdata:GetDifficultyString(iType, difficulty)
			--[[ --炫技式写法，又不生效，有个几把毛用？极个别BOSS是甚至有两级子BOSS，菜逼代码引用公共库，你TM这种写法能引明白？草，真是讨厌。
				 --直接笨办法LibBabble-Boss库里BOSS名写死。
				 --LibBabble-Boss、LibBabble-Zone、LibInstanceLootData所有文件名和各处被引用的版本号改掉。
				 --否则Yss按顺序最后启动，它会先引用其他插件启动的LibBabble-Boss，自定义名称会失效。菜逼代码，菜的抠脚。
				 local multiboss = lootdata:IsSubBoss(iType, instance, boss)
				if multiboss and multiboss ~= boss then
					boss = multiboss..": "..boss
				end
			]]
				if tonumber(difficulty) == 0 then
					diffstr = L["Instance:"]
				end
				tooltip:AddDoubleLine(diffstr, BZ[instance], r4,g4,b4, r3,g3,b3)
				if tonumber(droprate) <= 0 then
					droprate = ''
				else
					droprate = droprate.."%"
				end
				tooltip:AddDoubleLine(BB[boss], droprate, r5,g5,b5, r6,g6,b6)
				stringCache[itemID] = string.format("%s|%s|%s|%s", diffstr, instance, boss, droprate)
			end
		end
	end
	if origs[tooltip] then return origs[tooltip](tooltip, ...) end
end

function YssBossLoot:EnableTooltipInfo()
	for _,tooltip in pairs{GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2,AtlasLootTooltip} do
		if tooltip then
			origs[tooltip] = tooltip:GetScript("OnTooltipSetItem")
			tooltip:SetScript("OnTooltipSetItem", OnTooltipSetItem)
		end
	end
end

function YssBossLoot:DisableTooltipInfo()
	for _,tooltip in pairs{GameTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2,AtlasLootTooltip} do
		if tooltip and origs[tooltip] then
			tooltip:SetScript("OnTooltipSetItem", origs[tooltip])
			origs[tooltip] = nil
		end
	end
end
