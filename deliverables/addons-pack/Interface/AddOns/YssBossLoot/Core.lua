	--[[
	更新log
	2023.5.23
		1.玩了这么多年游戏，第一次遇见这么恶心的插件。原插件信息参考价值非常之低，基本就是个娱乐看热闹插件。虽然BOSS掉落随动地图的功能很好。怪不得我对当年这插件一点印象也没有。我分析一下插件作者当年的心路历程：写了个框架，引用个异常混乱的公共ACE掉落数据库，然后自己的插件数据往那一扔也不维护放那不管了。别的同类插件，比如Atlasloot、ClassLoot我看了，人家都是只引用公共数据的副本名称、BOSS名称，以上两个要素和物品挂钩的掉落信息都是单独自己写的数据库。因为公共数据库非常呆，同一个BOSS增写分支难度掉落非常麻烦。如果给Atlasloot插件评分是100，那么这个吊毛插件最多给10分。那10分是给地图显示骷髅头功能的。鼓捣这个插件完全是瞎猫遇见死耗子碰巧单机端可以随意操纵dbc文件和地图关联。
		2.直接笨办法LibBabble-Boss库里BOSS名写死。重整了插件引用库的结构。LibBabble-Boss、LibBabble-Zone、LibInstanceLootData所有文件名、文件夹名和各处被引用的版本号已改掉，否则Yss按字母顺序最后启动，它会先引用其他插件启动的LibBabble-Boss，各类名称改动会失效。数据梳理是沙雕、稳定性也沙雕，为什么会有这么蠢的插件！？
		3.非BOSS掉落图标统一移动到地图左下（BOTTOMLEFT）,因为原中右位置（RIGHT）经常和其他BOSS图标互相遮挡。
		4.卡拉赞
			--午夜更换为猎手阿图门，掉落不在马而是在人身上。
			--歌剧院3种战斗4个BOSS补全。
			--一楼宿舍三个隐藏BOSS补全。
			--补充国际象棋箱子。
		5.太阳之井高地
			--艾瑞达双子写了分支，现在合并显示一个图标。
			--鸡蛋和穆鲁挪到地图二层。
		6.黑暗神殿
			--插件在后续版本地图层数设置下显示是错乱的，重排了各个BOSS所在的层数。这个应该是统一的，因为各种dbc补丁都是按照地图blp图片的顺序来定义层数的。
			--调整了苏普雷姆斯的位置。
		7.十字军的试炼
			--改正了诺森德猛兽的拉丁字符引用，以使掉落显示。
		8.黑曜石圣殿
			--修正维斯匹隆掉落。
			--修正萨塔里奥0~3龙模式额外掉落模式名称不显示错误。
		9.永恒之眼
			--补充了魔网守护者的珍宝掉落内容。
		10.时光之穴：净化斯坦索姆
			--修正了玛尔加尼斯掉落表指向非BOSS掉落的错误。并补充了掉率。
			--补充了非BOSS掉落列表。
		11.所有副本群所含副本添加了前缀，更容易辨识。
		12.血色修道院：墓园
			--添加了万圣节无头骑士掉落信息。
			--添加了铁脊死灵、死灵勇士、永醒的艾希尔掉落信息。
		12.血色修道院：军械库
			--添加单独的小怪血色预备兵掉落列表，因为只有那些小怪掉[血色十字军战袍]。
		13.血色修道院
			--从atlasloot导入了小怪掉落列表。
		14.通灵学院
			--这个副本85级时候关闭并重置了。所以后续大地图基本不对应位置。
			--补充维克图斯头像入口。
			--补充瑟尔林·卡斯迪诺夫教授掉落[外科医生衬衣]信息，在我看来这件物品是这个本最重要的掉落。
			--补充黑暗院长加丁头像入口。
			--血骨傀儡添加观察室钥匙掉落信息。
			--添加死亡骑士达克雷尔和库尔莫克两个召唤BOSS的头像入口和掉落信息。
			--补充小怪掉落信息。
			--找到了这图的老地貌的官图。
			--根据新图微调了若干BOSS的位置。
		15.黑暗深渊
			--修正暮光领主克尔里斯名字。
			--添加小怪掉落列表。
		16.死亡矿井
			--修正矿工约翰森掉落归到小怪中的错误。
			--补充了斯尼德的伐木机头像入口和掉落。
		17.影牙城堡
			--修正情人节药剂师三人组、死亡之誓、地狱战马掉落归于小怪的错误。
			--补充了阿鲁高的虚空行者头像入口和掉落。
			--补充了小怪掉落列表。
		18.哀嚎洞穴
			--修正变异精灵龙掉落归于小怪的错误。
			--这个副本85级时重置简化了一部分。
			--找到了这图的老地貌的官图。
		19.鼠标tooltip显示色彩有了更好的方案。
		20.剃刀高地
			--修正了暴怒的阿迦赛罗斯位置。
		21.诺莫瑞根
			--修正了格鲁比斯位置。
		22.熔火之心
			--添加了小怪掉落列表。
			--添加管理者埃克索图斯信息。这是什么傻逼插件作者。
		23.奥杜尔
			--重写了难度分支。奥杜尔的难度分支显然不是普通/英雄可以概括的。因为困难模式是额外掉落，而且掉落的变化是在副本内根据不同模式的战斗控制的，比如1号是否拆塔、钢铁议会击杀顺序、尤格萨隆帮助守护者数量。
		24.安其拉神殿
			--重写了吉祥三宝掉落分支，这个想法是由奥杜尔得来的。
		25.冰冠堡垒
			--添加了25人小怪掉落。
		26.十字军的试炼
			--重写了难度分支。
			--嘉奖宝箱掉落列表难度分支多达15种。应该是前无古人后无来者的一个掉落事件，后续比如8.3腐蚀装词条组合可能很复杂，但掉落分支不过随机普通英雄史诗4种，如果分阵营就8种而已。这个掉落事件altasloot插件自作聪明的把非本阵营掉落分支隐藏了，按当前的观点看非常愚蠢，因为外观收集系统的关系。
			--对箱子的梳理是因为50箱披风是某些职业的3Xbis，它还是很重要的一个掉落事件。
			--新增难度分支带来一个新问题，增加的难度分支尚不能被插件“启用当前副本难度”功能正确筛选。
		27.沉没的神庙/阿塔哈卡神庙
			--调整了若干个BOSS及小怪的位置和掉落。原插件数据库混乱的基本没法看。
			--这张图大灾变简化了，3+1+1层砍成了只剩1层。找到了旧地貌的官图，可以不迷路了。
		28.斯坦索姆（旧）
			--添加及修正了BOSS位置，掉落信息还没有完全梳理。
		29.黑石深渊
			--弗诺斯达克维尔掉落添加[主建筑师的衬衣]，类似通灵衬衣和血色战袍，这也是这个本最重要的掉落。
		30.没有提及的副本BOSS位置大体上没有太大问题，但是掉落信息大约是无法参考的水平。后续修改随缘吧。
		----
		31.发现并修正一个字体显示问题。没有添加过字体的纯净简中原客户端，掉落列表boss名字和难度会显示问号。这是因为插件主文件Core.lua引用了两处西文字体FRIZQT__.TTF，而游戏客户端原带的这个字体文件是没有补充多国语言的。已按照大脚整合版插件的写法将“Fonts\FRIZQT__.TTF”修改为“STANDARD_TEXT_FONT”。这插件粗糙到令人无法想象。
		32.上面一个问题虽然其蠢无比，但是提供了某些DIY的思路。
		----
		33.删除wowhead窝窝头网站的logo。傻逼网站反向墙了中国IP，傻逼晦气玩意儿。
		34.黑石塔上层
			--添加索拉卡火冠、杰德、古拉鲁克、瓦塔拉克公爵。
		35.黑石塔下层
			--添加尖石统帅、尖石屠夫、尖石首席法师、莫尔·灰蹄、班诺克·巨斧、水晶之牙、军需官兹格雷斯、奴役者基兹鲁尔、霍克·巴什古德
			--维姆萨拉克、霍克·巴什古德、哈雷肯位置修正。
			--添加黑石塔小怪掉落信息。
		36.奥杜尔
			--修正自己的错误：尤格萨隆困难模式额外掉落是1~0灯。（不是2~0灯）
			--尤格萨隆增加3~0灯橙锤任务情况。
			--尤格萨隆增加3~0灯橙锤任务情况。
			--观察者奥尔加隆：这个boss只有困难模式，没有普通模式。
			--插件无法描述的一件事。各个BOSS困难模式据说治疗橙锤碎片掉落几率提升（不是额外增加一件掉落）。尤格萨隆234灯装备上没区别，23灯可能多掉宝珠。
			--有一个特殊的情况是霍迪尔，这个BOSS困难模式是两个箱子，所以据说有几率出一个额外碎片。
		37.怒焰裂谷
			--调整奥格弗林特和祈求者耶戈什的位置。
		]]
local _, YssBossLoot = ...

YssBossLoot.frame = CreateFrame("frame")
YssBossLoot.frame:SetScript("OnEvent", function(self, event, ...) if YssBossLoot[event] then return YssBossLoot[event](YssBossLoot, event, ...) end end)
function YssBossLoot:Print(...) print("|cFF33FF99YssBossLoot|r:", ...) end
YssBossLoot.frame:RegisterEvent("ADDON_LOADED")

local L = LibStub("AceLocale-3.0"):GetLocale("YssBossLoot", true)
local BZ = LibStub("LibBabble-Zone-3.0.01", true):GetUnstrictLookupTable()
local BB = LibStub("LibBabble-Boss-3.0.01", true):GetUnstrictLookupTable()
local AceGUI = LibStub("AceGUI-3.0")
local icon = LibStub("LibDBIcon-1.0")
local lootdata = LibStub("LibInstanceLootData-1.0.01")

--upvalue functions and constants we use in onupdate functions
local GetCursorPosition = GetCursorPosition
local sqrt = sqrt
local sin = math.sin
local cos = math.cos
local pi = math.pi

YssBossLoot.filters = {}

local enableLootTooltip
local dropdowntype = nil --'type', 'zone', 'level'
local lootParent

local LOOT_SCALE = 1
local LOOT_PADDING = 10
local LOOT_MAX_HEIGHT = 573
local LOOT_MIN_HEIGHT = (LOOT_MAX_HEIGHT-LOOT_PADDING)/2
local LOOT_MAX_WIDTH = (250)*2+16
local LOOT_MAX_WIDTH_LAYOUT = (250+16)*2+LOOT_PADDING
local LOOT_MIN_WIDTH = (250+16)

YssBossLoot.LootFrame = CreateFrame("frame", "YssBossLoot_LootFrame")
local LootFrame = YssBossLoot.LootFrame
	LootFrame.items = {}
	LootFrame.types = {}
	LootFrame:Hide()
	LootFrame:SetFrameStrata("DIALOG")
	LootFrame:EnableMouse(true)
	LootFrame:SetWidth(1002)
	LootFrame:SetHeight(668)
	LootFrame:SetScale(.1)
	LootFrame.frames = {} -- put our lootframes here
	LootFrame.contentframes = {} -- put the content widget here so we can drop in our LootWidgets
	LootFrame:SetScript("OnHide", function(self)
		for i, cF in ipairs(self.contentframes) do
			cF:ReleaseChildren()
		end
		YssBossLoot:CancelAllQueries() -- stop any pending item queries
		self:Hide()
	end)
	LootFrame.bg = LootFrame:CreateTexture()
		LootFrame.bg:SetTexture(0,0,0,0.75)
		LootFrame.bg:SetAllPoints(LootFrame)
	LootFrame.hideButton = CreateFrame("Button","YssBossLootHideLootButton",LootFrame,"UIPanelButtonTemplate2")
		LootFrame.hideButton:SetWidth(120)
		LootFrame.hideButton:SetHeight(24)
		LootFrame.hideButton:SetPoint("BOTTOM", LootFrame, "BOTTOM", 0, 5)
		LootFrame.hideButton:SetText(L["Hide Loot"])
		LootFrame.hideButton:SetScript("OnClick", function()
			if UIDROPDOWNMENU_OPEN_MENU == YssBossLoot.FilterMenu then
				CloseDropDownMenus()
			end
			LootFrame.LootHide:Play()
		end)
	LootFrame.BossName = LootFrame:CreateFontString(nil, "OVERLAY")
		LootFrame.BossName:SetFont(STANDARD_TEXT_FONT, 30, "OUTLINE")--STANDARD_TEXT_FONT
		LootFrame.BossName:SetPoint("TOP", LootFrame, "TOP",0,-10)
		LootFrame.BossName:SetText("Boss Name Here")
	FilterButton = CreateFrame('Button',nil,LootFrame,'UIPanelButtonTemplate')
		FilterButton:SetWidth(100)
		FilterButton:SetHeight(20)
		FilterButton:SetPoint("TOP", LootFrame, "TOP",-55,-40)
		FilterButton:SetText(L['Filter'])
		FilterButton:SetScript('OnClick', function(self)
			ToggleDropDownMenu(1, nil, YssBossLoot.FilterMenu, self, 0, 0)
		end)
	YssBossLoot.FilterButton = FilterButton
	LootRefresh = CreateFrame('Button',nil,LootFrame,'UIPanelButtonTemplate')
		LootRefresh:SetWidth(100)
		LootRefresh:SetHeight(20)
		LootRefresh:SetPoint("TOP", LootFrame, "TOP",55,-40)
		LootRefresh:SetText(REFRESH)
		LootRefresh:SetScript('OnClick', function(self)
			YssBossLoot:UpdateLootFrame()
		end)

	local ToggleLootShow = LootFrame:CreateAnimationGroup()
		local LootShow = ToggleLootShow:CreateAnimation("Animation")
			LootShow:SetDuration(.45)
			LootShow:SetOrder(1)
			LootShow:SetScript("OnPlay", function(self)
				enableLootTooltip = false
				LootFrame:SetScale(.05)
				LootFrame:SetAlpha(0)
			end)
			LootShow:SetScript("OnUpdate", function(self)
				local progress = self:GetProgress()
				local scale = (progress+.05)/1.05 -- ensures that our scale will never == 0
				local x = (LootFrame.Xor/scale)*(1-progress)
				local y = (LootFrame.Yor/scale)*(1-progress)
				LootFrame:ClearAllPoints()
				LootFrame:SetScale(scale)
				LootFrame:SetAlpha(progress^(1/2))
				LootFrame:SetPoint("CENTER", lootParent, "CENTER", x, y)
			end)
			LootShow:SetScript("OnFinished", function(self)
				LootFrame:ClearAllPoints()
				LootFrame:SetScale(1)
				enableLootTooltip = true
				LootFrame:SetAlpha(1)
				LootFrame:SetPoint("CENTER", lootParent, "CENTER")
			end)
	ToggleLootShow.LootShow = LootShow
	ToggleLootShow:SetLooping("NONE")
	LootFrame.ToggleLootShow = ToggleLootShow
	LootFrame.LootShow = LootShow
	local ToggleLootHide = LootFrame:CreateAnimationGroup()
		local LootHide = ToggleLootHide:CreateAnimation("Animation")
			LootHide:SetScript("OnPlay", function(self)
				enableLootTooltip = false
				GameTooltip:Hide()
				LootFrame:SetAlpha(1)
			end)
			LootHide:SetDuration(.45)
			LootHide:SetOrder(1)
			LootHide:SetScript("OnUpdate", function(self)
				local progress = self:GetProgress()
				local scale = ((1-progress)+.05)/1.05 -- ensures that our scale will never == 0
				local x = (LootFrame.Xor/scale)*progress
				local y = (LootFrame.Yor/scale)*progress
				LootFrame:SetAlpha((1-progress)^(1/2))
				LootFrame:ClearAllPoints()
				LootFrame:SetScale(scale)
				LootFrame:SetPoint("CENTER", lootParent, "CENTER", x, y)
			end)
			LootHide:SetScript("OnFinished", function(self)
				LootFrame:Hide()
				LootFrame:SetAlpha(1)
			end)
	ToggleLootHide.LootHide = LootHide
	ToggleLootHide:SetLooping("NONE")
	LootFrame.ToggleLootHide = ToggleLootHide
	LootFrame.LootHide = LootHide

local navRightLoot = CreateFrame("Button", nil, LootFrame)
	navRightLoot:SetWidth(64)
	navRightLoot:SetHeight(128)
	navRightLoot:SetPoint("RIGHT", 0, 0)
	navRightLoot:SetNormalTexture([[Interface\Addons\YssBossLoot\Art\arrow]])
	navRightLoot.normalTexture = navRightLoot:GetNormalTexture()
		navRightLoot.normalTexture:SetVertexColor(1, 0.82, 0)
	navRightLoot:SetHighlightTexture([[Interface\Addons\YssBossLoot\Art\arrowhighlight]])
	navRightLoot.highlightTexture = navRightLoot:GetHighlightTexture()
		navRightLoot.highlightTexture:SetVertexColor(1, 0.82, 0)
		navRightLoot.highlightTexture:SetBlendMode("ADD")
	navRightLoot:SetPushedTexture([[Interface\Addons\YssBossLoot\Art\arrowpushed]])
	navRightLoot.pushedTexture = navRightLoot:GetPushedTexture()
		navRightLoot.pushedTexture:SetVertexColor(1, 0.82, 0)
	navRightLoot:SetDisabledTexture([[Interface\Addons\YssBossLoot\Art\arrowpushed]])
	navRightLoot.disabledTexture = navRightLoot:GetDisabledTexture()
navRightLoot:SetScript("OnClick", function()
	LootFrame.subBoss = LootFrame.subBoss + 1
	YssBossLoot:UpdateLootFrame()
	CloseDropDownMenus()
end)
navRightLoot:Hide()

local navLeftLoot = CreateFrame("Button", nil, LootFrame)
	navLeftLoot:SetWidth(64)
	navLeftLoot:SetHeight(128)
	navLeftLoot:SetPoint("LEFT")
	navLeftLoot:SetNormalTexture([[Interface\Addons\YssBossLoot\Art\arrow]])
	navLeftLoot.normalTexture = navLeftLoot:GetNormalTexture()
		navLeftLoot.normalTexture:SetVertexColor(1, 0.82, 0)
		navLeftLoot.normalTexture:SetTexCoord(1, 0, 1, 0)
	navLeftLoot:SetHighlightTexture([[Interface\Addons\YssBossLoot\Art\arrowhighlight]])
	navLeftLoot.highlightTexture = navLeftLoot:GetHighlightTexture()
		navLeftLoot.highlightTexture:SetVertexColor(1, 0.82, 0)
		navLeftLoot.highlightTexture:SetTexCoord(1, 0, 1, 0)
		navLeftLoot.highlightTexture:SetBlendMode("ADD")
	navLeftLoot:SetPushedTexture([[Interface\Addons\YssBossLoot\Art\arrowpushed]])
	navLeftLoot.pushedTexture = navLeftLoot:GetPushedTexture()
		navLeftLoot.pushedTexture:SetVertexColor(1, 0.82, 0)
		navLeftLoot.pushedTexture:SetTexCoord(1, 0, 1, 0)
	navLeftLoot:SetDisabledTexture([[Interface\Addons\YssBossLoot\Art\arrowpushed]])
	navLeftLoot.disabledTexture = navLeftLoot:GetDisabledTexture()
		navLeftLoot.disabledTexture:SetTexCoord(1, 0, 1, 0)
navLeftLoot:SetScript("OnClick", function()
	LootFrame.subBoss = LootFrame.subBoss - 1
	YssBossLoot:UpdateLootFrame()
	CloseDropDownMenus()
end)
navLeftLoot:Hide()

local QueryProgressBar = CreateFrame("StatusBar", nil, LootFrame)
	QueryProgressBar:SetHeight(21)
	QueryProgressBar:SetWidth(488)
	QueryProgressBar:SetPoint("TOP", LootFrame, "BOTTOM", 0, -8)
	local title = QueryProgressBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		title:SetPoint("LEFT", 6, 4)
		title:SetText(RETRIEVING_ITEM_INFO)
	QueryProgressBar.title = title
	local progress = QueryProgressBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		progress:SetHeight(14)
		progress:SetPoint("RIGHT", -5, 3)
	QueryProgressBar.progress = progress
	local leftProgressTexture = QueryProgressBar:CreateTexture(nil, "OVERLAY")
		leftProgressTexture:SetTexture([[Interface\AchievementFrame\UI-Achievement-Header]])
		leftProgressTexture:SetWidth(32)
		leftProgressTexture:SetHeight(48)
		leftProgressTexture:SetPoint("TOPLEFT", -15, 16)
		leftProgressTexture:SetTexCoord(0.423828125, 0.486, 0.56640625, 0.75)
	QueryProgressBar.leftProgressTexture = leftProgressTexture
	local rightProgressTexture = QueryProgressBar:CreateTexture(nil, "OVERLAY")
		rightProgressTexture:SetTexture([[Interface\AchievementFrame\UI-Achievement-Header]])
		rightProgressTexture:SetWidth(32)
		rightProgressTexture:SetHeight(48)
		rightProgressTexture:SetPoint("TOPRIGHT", 15, 16)
		rightProgressTexture:SetTexCoord(0.486, 0.423828125, 0.56640625, 0.75)
	QueryProgressBar.rightProgressTexture = rightProgressTexture
	local middleProgressTexture = QueryProgressBar:CreateTexture(nil, "OVERLAY")
		middleProgressTexture:SetTexture([[Interface\AchievementFrame\UI-Achievement-Header]])
		middleProgressTexture:SetPoint("TOPLEFT", leftProgressTexture, "TOPRIGHT")
		middleProgressTexture:SetPoint("BOTTOMRIGHT", rightProgressTexture, "BOTTOMLEFT")
		middleProgressTexture:SetTexCoord(0.486, 0.889224609375, 0.75, 0.56640625)
	QueryProgressBar.middleProgressTexture = middleProgressTexture
	local bgProgressTexture = QueryProgressBar:CreateTexture(nil, "BACKGROUND")
		bgProgressTexture:SetTexture(0,0,0,.5)
		bgProgressTexture:SetAllPoints(QueryProgressBar)
	QueryProgressBar.bgProgressTexture = bgProgressTexture
	QueryProgressBar:SetStatusBarTexture([[Interface\PaperDollInfoFrame\UI-Character-Skills-Bar]])
	QueryProgressBar:SetStatusBarColor(0, 1, 0)

	local ProgressFade = QueryProgressBar:CreateAnimationGroup()
	local ProgressFadeAnimation = ProgressFade:CreateAnimation("Alpha")
		ProgressFadeAnimation:SetDuration(1)
		ProgressFadeAnimation:SetOrder(1)
		ProgressFadeAnimation:SetChange(-1)
	ProgressFade:SetScript("OnFinished", function()
			QueryProgressBar:Hide()
			QueryProgressBar:SetAlpha(1)
		end)

	LootFrame.wowhead = CreateFrame("Button", nil, LootFrame)
		LootFrame.wowhead:SetHeight(100)
		LootFrame.wowhead:SetWidth(100)
		LootFrame.wowhead:SetNormalTexture("Interface\\AddOns\\YssBossLoot\\Art\\wowhead_logo")
		LootFrame.wowhead:SetHighlightTexture("Interface\\AddOns\\YssBossLoot\\Art\\wowhead_logo_hover")
		LootFrame.wowhead:GetHighlightTexture():SetBlendMode("BLEND")
		LootFrame.wowhead:SetPoint("BOTTOMRIGHT", -10, -10)

		StaticPopupDialogs["YssBossLoot_WoWHead_DIALOG"] = {
			text = "YssBossLoot (C) 2009 by Yssaril\n\nThis add-on provides you with basic boss loot information. For the more information, be sure to visit http://www.wowhead.com",
			button1 = TEXT(OKAY),
			OnAccept = function()
					   end,
			OnHide = function (self) self:SetParent(UIParent) end,
			timeout = 0,
			hideOnEscape = 1
		}

		LootFrame.wowhead:SetScript("OnClick", function()
			local popup = StaticPopup_Show("YssBossLoot_WoWHead_DIALOG")
			popup:SetFrameStrata("TOOLTIP")
			popup:SetParent(LootFrame)
		end)

function YssBossLoot:ADDON_LOADED(event, addon)
	if addon == "YssBossLoot" then
		self.frame:UnregisterEvent("ADDON_LOADED")
		self.ADDON_LOADED = nil
		if IsLoggedIn() then self:PLAYER_LOGIN() else self.frame:RegisterEvent("PLAYER_LOGIN") end
	end
end

function YssBossLoot:PLAYER_LOGIN(event, addon)
	local defaults = {
		['profile'] = {
			displayBosses = true,
			['LibDBIcon'] = {
				['hide'] = true,
			},
			addtooltipinfo = true,
			typechecked = {},
			subtypechecked = {},
			bossframesize = 35,
			bossfontsize = 12,
			threeDskull = nil,
			twoDskull = 1,
			portalBackdrop = true,
			lootscale_mini = 1.5,
			lootscale_large = 1,
			lootscale_quest = 1.25,
			OpentoCurrentInstanceDifficulty = false,
			OpentoCurrentlySelectedGroupDifficulty = false,
		},
		['global'] = {},
	}
	for k, filter in pairs(self.filters) do
		if filter.WriteDefault then
			filter:WriteDefault(defaults)
		end
	end
	self.db = LibStub("AceDB-3.0"):New("YssBossLootDB", defaults)
	self:RegisterModuleOptions('profile', LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db), 'Profile')

	self.db:RegisterCallback("OnProfileChanged", function() YssBossLoot:RefreshBossFrames() end)
	self.db:RegisterCallback("OnProfileCopied", function() YssBossLoot:RefreshBossFrames() end)
	self.db:RegisterCallback("OnProfileReset", function() YssBossLoot:RefreshBossFrames() end)

	self:SetupLDB()

	if self.db.profile.addtooltipinfo then
		self:EnableTooltipInfo()
	end
	
	self.queries = {}

	SLASH_YssBossLoot1 = "/YssBossLoot";
	SLASH_YssBossLoot2 = "/YBL";
	SlashCmdList["YssBossLoot"] = function()
		InterfaceOptionsFrame_OpenToCategory(YssBossLoot.optframe.YBL)
	end

	self.frame:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
	
	if self.delaybossload then
		YssBossLoot:AddBosses(unpack(self.delaybossload))
		self.delaybossload = nil
	end
end

YssBossLoot.cid = 0
function YssBossLoot:COMPANION_LEARNED()
	for id = 1,GetNumCompanions("CRITTER") do
		local cid, name = GetCompanionInfo("CRITTER", id)
		if 29147 == cid then
			self.cid = 29147
			if self.db.profile.threeDskull == nil then
				StaticPopupDialogs["YssBossLoot_3DSkull_DIALOG"] = {
					text = string.format(L["3D_Skull_Detect_MSG"], name),
					button1 = YES,
					button2 = NO,
					OnAccept = function (self)
						YssBossLoot.db.profile.threeDskull = true
						YssBossLoot:RefreshBossFrames()
					end,
					OnCancel = function (self, data, reason)
						YssBossLoot.db.profile.threeDskull = false
					end,
					timeout = 0,
					hideOnEscape = 1,
					noCancelOnEscape = 1,
					whileDead = 1,
				}
				local popup = StaticPopup_Show("YssBossLoot_3DSkull_DIALOG")
				popup:SetFrameStrata("TOOLTIP")
			end
			return self.frame:UnregisterEvent('COMPANION_LEARNED')
		end
	end
end

local bossframecache = {}
local totalFramesGenerated = 0

local function BossFrameOnUpdate(self)
	if self.onupdate > 0 then
		self:SetModelScale(9.2479419708252)
		self:SetPosition(0,0,-15.25)
		self:SetFacing(.1)
		self:SetScript('OnUpdate', nil)
	else
		self:SetCreature(YssBossLoot.cid)
	end
	self.onupdate = self.onupdate + 1
end

local function BossFrameOnShow(self)
	if YssBossLoot.db.profile.threeDskull then
		self:ClearModel()
		self:SetCreature(YssBossLoot.cid)
		self:SetModelScale(1)
		self:SetPosition(0,0,0)
		self:SetFacing(0)
		self.onupdate = 0
		self:SetScript('OnUpdate', BossFrameOnUpdate)
	end
end

local function LootFrameOnEnter()
	SetCursor("INSPECT_CURSOR")
end

local function LootFrameOnLeave()
	ResetCursor()
end

local function CreateLootFrame(rightAlign)
	local widget = {}
	widget.frame = CreateFrame("frame", nil, LootFrame)
	widget.LootText = CreateFrame("button", nil, widget.frame)
		widget.LootText:SetPoint("TOPLEFT", widget.frame, "TOPLEFT")
		widget.LootText:SetPoint("TOPRIGHT", widget.frame, "TOPRIGHT")
		widget.LootText:SetHeight(24)
		widget.LootText.normalfont = widget.LootText:CreateFontString(nil, "OVERLAY")
			widget.LootText.normalfont:SetFont(STANDARD_TEXT_FONT, 20, "OUTLINE")
		widget.LootText:SetFontString(widget.LootText.normalfont)
		widget.LootText:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]], 'ADD')
		widget.LootText:SetText("LootType here")
		widget.LootText:SetScript("OnEnter", LootFrameOnEnter)
		widget.LootText:SetScript("OnLeave", LootFrameOnLeave)
	widget.content = CreateFrame('frame', nil, widget.frame)
		widget.content:SetPoint("TOPLEFT", widget.frame, "TOPLEFT",0,-25)
		widget.content:SetPoint("BOTTOMRIGHT", widget.frame, "BOTTOMRIGHT")
	AceGUI:RegisterAsContainer(widget)
	widget:SetLayout("fill")
	local sf = AceGUI:Create("ScrollFrame")
		if rightAlign then
			sf:SetLayout("YBL_FLOW_RA")
		else
			sf:SetLayout("YBL_FLOW_LA")
		end
		--sf:SetLayout("flow")
		sf.width = "fill"
		sf.height = "fill"
	widget:AddChild(sf)

	widget.Maximize_GROUP = widget.frame:CreateAnimationGroup()
		local Maximize = widget.Maximize_GROUP:CreateAnimation("Animation")
			Maximize:SetDuration(.5)
			Maximize:SetOrder(1)
			Maximize:SetScript("OnPlay", function(self)
				widget.MAXIMIZED = true
			end)
			Maximize:SetScript("OnUpdate", function(self)
				local progress = self:GetProgress()
				widget.frame:SetHeight(widget.HEIGHT+((LOOT_MAX_HEIGHT/LOOT_SCALE-widget.HEIGHT)*progress))
				widget.frame:SetWidth(widget.WIDTH+((LOOT_MAX_WIDTH-widget.WIDTH)*progress))
				for i=1, widget.NUM do
					if i ~= widget.ID then
						widget.FRAMESET[i].frame:SetAlpha((1-progress)^2)
					end
				end
			end)
			Maximize:SetScript("OnFinished", function(self)
				widget.frame:SetHeight(LOOT_MAX_HEIGHT/LOOT_SCALE)
				widget.frame:SetWidth(LOOT_MAX_WIDTH)
				for i=1, widget.NUM do
					if i ~= widget.ID then
						widget.FRAMESET[i].frame:SetAlpha(1)
						widget.FRAMESET[i].frame:Hide()
					end
				end
			end)
			Maximize:SetScript("OnStop", Maximize:GetScript("OnFinished"))
	widget.Minimize_GROUP = widget.frame:CreateAnimationGroup()
		local Minimize = widget.Minimize_GROUP:CreateAnimation("Animation")
			Minimize:SetDuration(.5)
			Minimize:SetOrder(1)
			Minimize:SetScript("OnPlay", function(self)
				for i=1, widget.NUM do
					if i ~= widget.ID then
						widget.FRAMESET[i].frame:Show()
						widget.FRAMESET[i].frame:SetAlpha(0)
					end
				end
				widget.MAXIMIZED = false
			end)
			Minimize:SetScript("OnUpdate", function(self)
				local progress = self:GetProgress()
				widget.frame:SetHeight(LOOT_MAX_HEIGHT/LOOT_SCALE-((LOOT_MAX_HEIGHT/LOOT_SCALE-widget.HEIGHT)*progress))
				widget.frame:SetWidth(LOOT_MAX_WIDTH-((LOOT_MAX_WIDTH-widget.WIDTH)*progress))
				for i=1, widget.NUM do
					if i ~= widget.ID then
						widget.FRAMESET[i].frame:SetAlpha(progress^2)
					end
				end
			end)
			Minimize:SetScript("OnFinished", function(self)
				widget.frame:SetHeight(widget.HEIGHT)
				widget.frame:SetWidth(widget.WIDTH)
				for i=1, widget.NUM do
					if i ~= widget.ID then
						widget.FRAMESET[i].frame:SetAlpha(1)
					end
				end
			end)
			Minimize:SetScript("OnStop", Minimize:GetScript("OnFinished"))
	widget.LootText:SetScript("OnClick", function()
		if widget.MAXIMIZED then
			widget.Maximize_GROUP:Stop()
			widget.Minimize_GROUP:Play()
		else
			widget.Minimize_GROUP:Stop()
			widget.Maximize_GROUP:Play()
		end
	end)
	widget.frame:SetScript("OnHide",function()
		widget.Minimize_GROUP:Stop()
		widget.Maximize_GROUP:Stop()
	end)

	return widget, sf
end

local function LayoutLootFrames(widgets, numLootSets)
	if numLootSets == 1 then
		widgets[1].frame:SetPoint("TOP", LootFrame, "TOP", 0, -60/LOOT_SCALE)
		widgets[1].frame:SetHeight(LOOT_MAX_HEIGHT/LOOT_SCALE)
		widgets[1].frame:SetWidth(LOOT_MAX_WIDTH)
		widgets[1].LootText:Disable()
	elseif numLootSets == 2 then
		widgets[1].frame:SetPoint("TOPLEFT", LootFrame, "TOP", LOOT_MAX_WIDTH_LAYOUT/-2, -60/LOOT_SCALE)
		widgets[1].frame:SetHeight(LOOT_MAX_HEIGHT/LOOT_SCALE)
		widgets[1].frame:SetWidth(LOOT_MIN_WIDTH)
		widgets[1].LootText:Enable()

		widgets[2].frame:SetPoint("TOPRIGHT", LootFrame, "TOP", LOOT_MAX_WIDTH_LAYOUT/2, -60/LOOT_SCALE)
		widgets[2].frame:SetHeight(LOOT_MAX_HEIGHT/LOOT_SCALE)
		widgets[2].frame:SetWidth(LOOT_MIN_WIDTH)
		widgets[2].LootText:Enable()
	elseif numLootSets > 2 then --668, 299
		widgets[1].frame:SetPoint("TOPLEFT", LootFrame, "TOP", LOOT_MAX_WIDTH_LAYOUT/-2, -60/LOOT_SCALE)
		widgets[1].frame:SetHeight(LOOT_MIN_HEIGHT/LOOT_SCALE)
		widgets[1].frame:SetWidth(LOOT_MIN_WIDTH)
		widgets[1].LootText:Enable()

		widgets[2].frame:SetPoint("TOPRIGHT", LootFrame, "TOP", LOOT_MAX_WIDTH_LAYOUT/2, -60/LOOT_SCALE)
		widgets[2].frame:SetHeight(LOOT_MIN_HEIGHT/LOOT_SCALE)
		widgets[2].frame:SetWidth(LOOT_MIN_WIDTH)
		widgets[2].LootText:Enable()

		widgets[3].frame:SetPoint("BOTTOMLEFT", LootFrame, "BOTTOM", LOOT_MAX_WIDTH_LAYOUT/-2, 35/LOOT_SCALE)
		widgets[3].frame:SetHeight(LOOT_MIN_HEIGHT/LOOT_SCALE)
		widgets[3].frame:SetWidth(LOOT_MIN_WIDTH)
		widgets[3].LootText:Enable()
	end
	if numLootSets == 4 then
		widgets[4].frame:SetPoint("BOTTOMRIGHT", LootFrame, "BOTTOM", LOOT_MAX_WIDTH_LAYOUT/2, 35/LOOT_SCALE)
		widgets[4].frame:SetHeight(LOOT_MIN_HEIGHT/LOOT_SCALE)
		widgets[4].frame:SetWidth(LOOT_MIN_WIDTH)
		widgets[4].LootText:Enable()
	end
	for i=1, numLootSets do
		widgets[i].NUM = numLootSets
		widgets[i].ID = i
		widgets[i].MAXIMIZED = false
		widgets[i].FRAMESET = widgets
		widgets[i].HEIGHT = widgets[i].frame:GetHeight()
		widgets[i].WIDTH = widgets[i].frame:GetWidth()
		widgets[i].frame:SetScale(LOOT_SCALE)
		widgets[i].frame:Show()
	end
	for i=numLootSets+1, #widgets do
		widgets[i].frame:Hide()
	end
end

local function LootClickHandler(self, event, link)
	if link then
		HandleModifiedItemClick(link)
	end
end


local altTooltipParent
local function LootEnterHandler(self, event, button, link)
	if enableLootTooltip and link then
		if not UIParent:IsVisible() then
			altTooltipParent = oldTooltipScale or CreateFrame('frame')
			altTooltipParent:SetScale(UIParent:GetScale())
			GameTooltip:SetParent(altTooltipParent)
			GameTooltip:SetFrameStrata("TOOLTIP")
			ShoppingTooltip1:SetParent(altTooltipParent)
			ShoppingTooltip1:SetFrameStrata("TOOLTIP")
			ShoppingTooltip2:SetParent(altTooltipParent)
			ShoppingTooltip2:SetFrameStrata("TOOLTIP")
			ShoppingTooltip3:SetParent(altTooltipParent)
			ShoppingTooltip3:SetFrameStrata("TOOLTIP")
		else
			oldTooltipScale = nil
		end
		--print(GameTooltip:GetEffectiveScale())
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT", button:GetWidth()/-2, 5)
		GameTooltip:SetHyperlink(link)
		GameTooltip:Show()
	end
end

local function LootLeaveHandler()
	if enableLootTooltip then
		GameTooltip:SetParent(UIParent)
		GameTooltip:SetFrameStrata("TOOLTIP")
		ShoppingTooltip1:SetParent(UIParent)
		ShoppingTooltip1:SetFrameStrata("TOOLTIP")
		ShoppingTooltip2:SetParent(UIParent)
		ShoppingTooltip2:SetFrameStrata("TOOLTIP")
		ShoppingTooltip3:SetParent(UIParent)
		ShoppingTooltip3:SetFrameStrata("TOOLTIP")
		GameTooltip:Hide()
	end
end

YssBossLoot.currentLootWidgets = {}
local initialNumUncached = 0
function YssBossLoot:UpdateLoot(NumUncached, item)
	if NumUncached > 0 then
		QueryProgressBar:SetValue(initialNumUncached-NumUncached)
		QueryProgressBar.progress:SetText(initialNumUncached-NumUncached..'/'..initialNumUncached)
		ProgressFade:Stop()
	elseif QueryProgressBar:IsShown() then
		QueryProgressBar:SetValue(initialNumUncached)
		QueryProgressBar.progress:SetText(initialNumUncached-NumUncached..'/'..initialNumUncached)
		ProgressFade:Play()
	end
	if item then
		for i, btn in ipairs(YssBossLoot.currentLootWidgets) do
			if btn.item == item then
				btn:UpdateItem()
			end
		end
		local _, link = GetItemInfo(item)
		for k, filter in pairs(self.filters) do
			filter:AddItem(link)
		end
	end
end

function YssBossLoot:FilterUpdate()
	self:UpdateLootFrame(true)
end

function YssBossLoot:UpdateLootFrame(keepLayout)
	initialNumUncached = 0
	local currentloot, currentlootDesc, currentsortedloot, boss
	local f = LootFrame
	if f.MultiBoss then
		navRightLoot:Show()
		navLeftLoot:Show()
		if f.subBoss == 1 then
			navRightLoot:Enable()
			navLeftLoot:Disable()
		elseif f.subBoss == #f.MultiBoss then
			navRightLoot:Disable()
			navLeftLoot:Enable()
		else
			navRightLoot:Enable()
			navLeftLoot:Enable()
		end
		f.BossName:SetText(BB[f.MultiBoss[f.subBoss]])
		boss = f.MultiBoss[f.subBoss]
	else
		navRightLoot:Hide()
		navLeftLoot:Hide()
		f.BossName:SetText(BB[f.Boss])
		boss = f.Boss
	end

	wipe(self.currentLootWidgets)

	for i, cF in ipairs(f.contentframes) do
		cF:ReleaseChildren()
	end
	self:CancelAllQueries()
	for itemType in pairs(f.types) do
		local c = 0
		for itemSubType in pairs(f.types[itemType]) do
			c = c+1
		end
		if c>1 then
			f.types[itemType] = true
		else
			f.types[itemType] = nil
		end
	end

	local lootdifficulties = lootdata:GetBossDifficulties(f.InstanceType, f.Instance, boss)
	for f_num, difficulty in ipairs(lootdifficulties) do
		if not f.frames[f_num] then
			if f_num/2 == math.floor(f_num/2) then
				f.frames[f_num], f.contentframes[f_num] = CreateLootFrame(false)
			else
				f.frames[f_num], f.contentframes[f_num] = CreateLootFrame(true)
			end
		end
		
		
		f.frames[f_num].LootText:SetText(lootdata:GetDifficultyString(f.InstanceType, difficulty))

		local filtered
		local itemlist = lootdata:GetBossLootByDifficulties(f.InstanceType, f.Instance, boss, difficulty)
		for j, item in pairs(itemlist) do
			local _, link = GetItemInfo(item)
			if link then
				for k, filter in pairs(self.filters) do
					filter:AddItem(link)
				end
			end
		end
		for j, item in pairs(itemlist) do
			local _, link = GetItemInfo(item)
			local droprate = lootdata:GetBossLootDropRate(f.InstanceType, f.Instance, boss, difficulty, item)
			if link then
				filtered = nil
				for k, filter in pairs(self.filters) do
					if filter:isFilterd(link) and filter:isRelevant() then
						filtered = true
					end
				end
				if not filtered then
					local btn = AceGUI:Create("YssBossLoot_LootWidget")
					if not btn:SetItem(item, droprate) and not YssBossLoot.QuerryStopped then
						initialNumUncached = initialNumUncached + 1
						self:QueryItemInfo(item)
					end
					btn:SetCallback("OnClick", LootClickHandler)
					btn:SetCallback("OnEnter", LootEnterHandler)
					btn:SetCallback("OnLeave", LootLeaveHandler)
					f.contentframes[f_num]:AddChild(btn)
					self.currentLootWidgets[#self.currentLootWidgets+1] = btn
				end
			else
				-- Add the button to the container
				local btn = AceGUI:Create("YssBossLoot_LootWidget")
				if not btn:SetItem(item, droprate) and not YssBossLoot.QuerryStopped then
					initialNumUncached = initialNumUncached + 1
					self:QueryItemInfo(item)
				end
				btn:SetCallback("OnClick", LootClickHandler)
				btn:SetCallback("OnEnter", LootEnterHandler)
				btn:SetCallback("OnLeave", LootLeaveHandler)
				f.contentframes[f_num]:AddChild(btn)
				self.currentLootWidgets[#self.currentLootWidgets+1] = btn
			end
		end
	end
	if not keepLayout then
		LayoutLootFrames(f.frames, #lootdifficulties)
		if self.db.profile.OpentoCurrentInstanceDifficulty then
			if IsInInstance() then
				local name, iType, difficulty, difficultyName, maxPlayers, playerDifficulty, isDynamicInstance = GetInstanceInfo()
				if isDynamicInstance and iType == "raid" and playerDifficulty == 1 and difficulty <= 2 then
					difficulty = difficulty + 2
				end
				if f.frames[difficulty] then
					f.frames[difficulty].Maximize_GROUP:Play()
				end
			elseif self.db.profile.OpentoCurrentlySelectedGroupDifficulty then
				if UnitInRaid("player") then
					local difficulty = GetRaidDifficulty()
					if f.frames[difficulty] then
						f.frames[difficulty].Maximize_GROUP:Play()
					end
				elseif GetNumPartyMembers() > 0 then
					local difficulty = GetDungeonDifficulty()
					if f.frames[difficulty] then
						f.frames[difficulty].Maximize_GROUP:Play()
					end
				end
			end
		end
	end
	if initialNumUncached > 0 then
		QueryProgressBar:SetMinMaxValues(0, initialNumUncached)
		QueryProgressBar:SetValue(0)
		QueryProgressBar:Show()
	else
		QueryProgressBar:Hide()
	end
	self:UpdateLoot(initialNumUncached)
end

local function BossFrameOnMouseUp(self, button)
	if WorldMapFrame.bigMap then
		LOOT_SCALE = YssBossLoot.db.profile.lootscale_large
	elseif WorldMapFrame.sizedDown then
		LOOT_SCALE = YssBossLoot.db.profile.lootscale_mini
	else
		LOOT_SCALE = YssBossLoot.db.profile.lootscale_quest
	end

	lootParent = self:GetParent()
	LootFrame:SetParent(lootParent)
	LootFrame:SetFrameStrata("FULLSCREEN_DIALOG")
	local p,_,_,Xor, Yor = self:GetPoint()
	if p == "RIGHT" then
		Xor = 1002 + Xor - (YssBossLoot.db.profile.bossframesize/2)
		Yor = -668 / 2
	end
	LootFrame.Xor = Xor - (1002/2)
	LootFrame.Yor = Yor + (668/2)
	
	LootFrame.InstanceType = self.InstanceType
	LootFrame.Instance = self.Instance
	LootFrame.Boss = self.Boss
	LootFrame.MultiBoss = lootdata:GetMultiSubBosses(self.InstanceType, self.Instance, self.Boss)
	if LootFrame.MultiBoss then
		LootFrame.subBoss = 1
	end
	for k, filter in pairs(YssBossLoot.filters) do
		filter:ClearAll()
	end
	YssBossLoot:UpdateLootFrame()
	LootFrame.LootHide:Stop()
	LootFrame:Show()
	LootFrame.LootShow:Play()
end

function YssBossLoot:NonMapInstance(self, iType, Instance)
	if WorldMapFrame.bigMap then
		LOOT_SCALE = YssBossLoot.db.profile.lootscale_large
	elseif WorldMapFrame.sizedDown then
		LOOT_SCALE = YssBossLoot.db.profile.lootscale_mini
	else
		LOOT_SCALE = YssBossLoot.db.profile.lootscale_quest
	end

	lootParent = WorldMapDetailFrame
	LootFrame:SetParent(lootParent)
	LootFrame:SetFrameStrata("FULLSCREEN_DIALOG")
	LootFrame.Xor = 0
	LootFrame.Yor = 0

	LootFrame.InstanceType = iType
	LootFrame.Instance = Instance
	LootFrame.Boss = Instance
	LootFrame.MultiBoss = lootdata:GetBossList(iType, Instance)
	if LootFrame.MultiBoss then
		LootFrame.subBoss = 1
	end
	for k, filter in pairs(YssBossLoot.filters) do
		filter:ClearAll()
	end
	YssBossLoot:UpdateLootFrame()
	LootFrame.LootHide:Stop()
	LootFrame:Show()
	LootFrame.LootShow:Play()
end

local function SetupBossFrame(self, InstanceType, Instance, Boss)
	local text = BB[Boss] or Boss
	self.name:SetText(text)
	self.InstanceType = InstanceType
	self.Instance = Instance
	self.Boss = Boss
end

local function setupBossAnimation(frame)
	local enlargeGroup = frame:CreateAnimationGroup()
	local enlarge = enlargeGroup:CreateAnimation("Animation")
		enlarge:SetDuration(.25)
		enlarge:SetOrder(1)
		enlarge:SetScript("OnPlay", function(self)
			frame:SetScript('OnSizeChanged', nil)
		end)
		enlarge:SetScript("OnUpdate", function(self)
			local progress = self:GetProgress()
			local newSize = YssBossLoot.db.profile.bossframesize + (YssBossLoot.db.profile.bossframesize * progress)
			frame:SetWidth(newSize)
			frame:SetHeight(newSize)
			frame.SkullBG:SetWidth(newSize*1.5)
			frame.SkullBG:SetHeight(newSize*2)
			frame.Skull:SetWidth(newSize/1.5)
			frame.Skull:SetHeight(newSize/1.5)
			local fontName, fontHeight, fontFlags = frame.name:GetFont()
			frame.name:SetFont(fontName, YssBossLoot.db.profile.bossfontsize + YssBossLoot.db.profile.bossfontsize * progress, fontFlags)
		end)
		enlarge:SetScript("OnFinished", function(self)
			local newSize = YssBossLoot.db.profile.bossframesize * 2
			frame:SetWidth(newSize)
			frame:SetHeight(newSize)
			frame.SkullBG:SetWidth(newSize*1.5)
			frame.SkullBG:SetHeight(newSize*2)
			frame.Skull:SetWidth(newSize/1.5)
			frame.Skull:SetHeight(newSize/1.5)
			local fontName, fontHeight, fontFlags = frame.name:GetFont()
			frame.name:SetFont(fontName, YssBossLoot.db.profile.bossfontsize*  2, fontFlags)
		end)
	enlargeGroup.enlarge = enlarge
	enlargeGroup:SetLooping("NONE")
	frame.enlargeGroup = enlargeGroup

	local reduceGroup = frame:CreateAnimationGroup()
	local reduce = reduceGroup:CreateAnimation("Animation")
		reduce:SetDuration(.25)
		reduce:SetOrder(1)
		reduce:SetScript("OnUpdate", function(self)
			local progress = self:GetProgress()
			local newSize = YssBossLoot.db.profile.bossframesize + (YssBossLoot.db.profile.bossframesize * (1 - progress))
			frame:SetWidth(newSize)
			frame:SetHeight(newSize)
			frame.SkullBG:SetWidth(newSize*1.5)
			frame.SkullBG:SetHeight(newSize*2)
			frame.Skull:SetWidth(newSize/1.5)
			frame.Skull:SetHeight(newSize/1.5)
			local fontName, fontHeight, fontFlags = frame.name:GetFont()
			frame.name:SetFont(fontName, YssBossLoot.db.profile.bossfontsize + YssBossLoot.db.profile.bossfontsize * (1 - progress), fontFlags)
		end)
		reduce:SetScript("OnFinished", function(self)
			frame:SetWidth(YssBossLoot.db.profile.bossframesize)
			frame:SetHeight(YssBossLoot.db.profile.bossframesize)
			frame.SkullBG:SetWidth(YssBossLoot.db.profile.bossframesize*1.5)
			frame.SkullBG:SetHeight(YssBossLoot.db.profile.bossframesize*2)
			frame.Skull:SetWidth(YssBossLoot.db.profile.bossframesize/1.5)
			frame.Skull:SetHeight(YssBossLoot.db.profile.bossframesize/1.5)
			local fontName, fontHeight, fontFlags = frame.name:GetFont()
			frame.name:SetFont(fontName, YssBossLoot.db.profile.bossfontsize, fontFlags)
			frame:SetScript('OnSizeChanged', function() 
				frame:SetScript('OnSizeChanged', BossFrameOnShow)
			end) -- reenable the OnSizeChanged script on the next OnSizeChanged otherwise we catch the last one frome the animation
		end)
	reduceGroup.reduce = reduce
	reduceGroup:SetLooping("NONE")
	frame.reduceGroup = reduceGroup
	frame:EnableMouse(true)
	frame:SetScript('OnEnter', function(self)
		self.reduceGroup.reduce:Stop()
		self.enlargeGroup.enlarge:Play()
	end)
	frame:SetScript('OnLeave', function(self)
		self.enlargeGroup.enlarge:Stop()
		self.reduceGroup.reduce:Play()
	end)

	local rotateBGGroup = frame.SkullBG:CreateAnimationGroup()
	local rotate = rotateBGGroup:CreateAnimation("Animation")
		rotate:SetDuration(5)
		rotate:SetOrder(1)
		rotate:SetScript("OnUpdate", function(self)
			local angle = (1-self:GetProgress())*2*pi
			local s = sin(angle);
			local c = cos(angle);
			frame.SkullBG:SetTexCoord(	0.5-s, 0.5+c,
						0.5+c, 0.5+s,
						0.5-c, 0.5-s,
						0.5+s, 0.5-c);
		end)
	rotateBGGroup.rotate = rotate
	rotateBGGroup:SetLooping("REPEAT")
	frame.rotateBGGroup = rotateBGGroup
end

local function getBossFrame(parent)
	local frame
	if next(bossframecache) then
		frame = bossframecache[#bossframecache]
		bossframecache[#bossframecache] = nil
	else
		totalFramesGenerated = totalFramesGenerated + 1
		frame = CreateFrame("DressUpModel", "YssBossLootBossFrame"..totalFramesGenerated)
		frame:Hide()
		frame:SetWidth(YssBossLoot.db.profile.bossframesize)
		frame:SetHeight(YssBossLoot.db.profile.bossframesize)
		frame:SetToplevel(true)
		frame:SetCreature(0)
		local SkullBG = frame:CreateTexture(nil, 'BACKGROUND')
			SkullBG:SetPoint("CENTER")
			SkullBG:SetWidth(YssBossLoot.db.profile.bossframesize*1.5)
			SkullBG:SetHeight(YssBossLoot.db.profile.bossframesize*2)
			SkullBG:SetTexture("Interface\\Addons\\YssBossLoot\\Art\\SkullBG")
			SkullBG:SetAlpha(.75)
		frame.SkullBG = SkullBG

		local name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			local font, size = name:GetFont()
			name:SetFont(font,size,"OUTLINE")
			name:SetHeight(15)
			name:SetPoint("BOTTOM", frame, "TOP")
			name:SetText("Boss Name Here")
		frame.name = name

		local Skull = frame:CreateTexture(nil, 'OVERLAY')
			Skull:SetPoint("CENTER")
			Skull:SetWidth(YssBossLoot.db.profile.bossframesize/1.5)
			Skull:SetHeight(YssBossLoot.db.profile.bossframesize/1.5)
			Skull:SetTexture("Interface\\Addons\\YssBossLoot\\Art\\skullwhite")
			Skull:SetAlpha(.75)
		frame.Skull = Skull

		frame:SetScript('OnShow', BossFrameOnShow)
		frame:SetScript('OnMouseUp', BossFrameOnMouseUp)
		frame.SetupBossFrame = SetupBossFrame
		setupBossAnimation(frame)
	end
	frame:SetParent(parent)
	frame:SetScript('OnSizeChanged', BossFrameOnShow) -- fix model for new size/scale
	frame:SetFrameLevel(parent:GetFrameLevel()+10)
	frame.onupdate = 0
	if YssBossLoot.db.profile.portalBackdrop then
		frame.SkullBG:Show()
		frame.rotateBGGroup:Play()
	else
		frame.SkullBG:Hide()
		frame.rotateBGGroup:Stop()
	end
	if YssBossLoot.db.profile.threeDskull then
		frame:SetCreature(YssBossLoot.cid)
		frame.Skull:Hide()
	else
		frame:SetCreature(0)
		frame.Skull:Show()
		YssBossLoot:SetTexture(frame.Skull, YssBossLoot.skulls.info[YssBossLoot.db.profile.twoDskull])
	end
	
	frame:Show()
	return frame
end

local function returnBossFrame(frame)
	frame.name:SetText("Boss Name Here")
	frame.rotateBGGroup:Stop()
	frame:Hide()
	frame:ClearAllPoints()
	frame:SetWidth(YssBossLoot.db.profile.bossframesize)
	frame:SetHeight(YssBossLoot.db.profile.bossframesize)
	frame.SkullBG:SetWidth(YssBossLoot.db.profile.bossframesize*1.5)
	frame.SkullBG:SetHeight(YssBossLoot.db.profile.bossframesize*2)
	frame.Skull:SetWidth(YssBossLoot.db.profile.bossframesize/1.5)
	frame.Skull:SetHeight(YssBossLoot.db.profile.bossframesize/1.5)
	local fontName, fontHeight, fontFlags = frame.name:GetFont()
	frame.name:SetFont(fontName, YssBossLoot.db.profile.bossfontsize, fontFlags)
	bossframecache[#bossframecache+1] = frame
	return nil
end

local bossframetogglecache = {}
local function getBossFrameToggle(parent, MapType, Map, level)
	local frame
	if next(bossframetogglecache) then
		frame = bossframetogglecache[#bossframetogglecache]
		bossframetogglecache[#bossframetogglecache] = nil
	else
		frame = CreateFrame("CheckButton", nil, nil, "OptionsBaseCheckButtonTemplate")
		frame:SetWidth(24)
		frame:SetHeight(24)
		frame:SetToplevel(true)
		frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		frame.text:SetPoint("LEFT", frame, "RIGHT", 0, 1)
		frame.text:SetText(L["Show Boss Frames"])
		frame:SetScript("OnCLick", function(self)
			YssBossLoot.db.profile.displayBosses = self:GetChecked()
			YssBossLoot:AddBosses(self:GetParent(parent), self.MapType, self.Map, self.level)
		end)
	end
	frame.MapType = MapType
	frame.Map = Map
	frame.level = level
	frame:SetChecked(YssBossLoot.db.profile.displayBosses)
	frame:SetParent(parent)
	frame:SetFrameLevel(parent:GetFrameLevel()+10)
	frame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 6, 6)
	frame:Show()
	return frame
end

local function returnBossFrameToggle(frame)
	frame:Hide()
	frame:ClearAllPoints()
	bossframetogglecache[#bossframetogglecache+1] = frame
	return nil
end

function YssBossLoot:SetTexture(tex, s)
	local t, x1, x2, y1, y2 = strsplit(":", s)
	tex:SetTexture(t)
	if x1 then
		x1 = tonumber(x1)
		x2 = tonumber(x2)
		y1 = tonumber(y1)
		y2 = tonumber(y2)
		tex:SetTexCoord(x1, x2, y1, y2)
	else
		tex:SetTexCoord(0,1,0,1)
	end
end

YssBossLoot.BossParents = {}
function YssBossLoot:RefreshBossFrames()
	for parent in pairs(self.BossParents) do
		if parent.displayedBosses then
			for b, frame in pairs(parent.displayedBosses) do
				frame:Hide()
				frame:SetWidth(self.db.profile.bossframesize)
				frame:SetHeight(self.db.profile.bossframesize)
				frame.SkullBG:SetWidth(self.db.profile.bossframesize*1.5)
				frame.SkullBG:SetHeight(self.db.profile.bossframesize*2)
				frame.Skull:SetWidth(self.db.profile.bossframesize/1.5)
				frame.Skull:SetHeight(self.db.profile.bossframesize/1.5)
				local fontName, fontHeight, fontFlags = frame.name:GetFont()
				frame.name:SetFont(fontName, self.db.profile.bossfontsize, fontFlags)
				if self.db.profile.threeDskull then
					frame:SetCreature(self.cid)
					frame.Skull:Hide()
					BossFrameOnShow(frame)
				else
					frame:SetCreature(0)
					frame.Skull:Show()
					self:SetTexture(frame.Skull, self.skulls.info[self.db.profile.twoDskull])
				end
				if self.db.profile.portalBackdrop then
					frame.SkullBG:Show()
					frame.rotateBGGroup:Play()
				else
					frame.SkullBG:Hide()
					frame.rotateBGGroup:Stop()
				end
				frame:Show()
			end
		end
	end
	if self.db.profile.LibDBIcon.hide then
		icon:Hide("YssBossLoot")
	else
		icon:Show("YssBossLoot")
	end
end

local initialLoad = true
function YssBossLoot:AddBosses(parent, MapType, Map, level)
	if not self.db then -- something is messing with the map before everything is loaded
		self.delaybossload = {parent, MapType, Map, level}
		return nil
	end

	if initialLoad then
		initialLoad = nil
		self.frame:RegisterEvent('COMPANION_LEARNED')
		self:COMPANION_LEARNED()
	end
	self:ClearBosses(parent)
	if self.db.profile.displayBosses then
		if self.Bosses[MapType] and self.Bosses[MapType][Map] then
			local w, h = parent:GetWidth(), parent:GetHeight()*-1
			local bosstable = self.Bosses[MapType][Map]
			for boss, locations in pairs(bosstable) do
				for l,x,y in string.gmatch(locations, "([^|]+):([^|]+):([^|]+)") do
					if tonumber(l) == level then
						local frame = getBossFrame(parent)
						frame:SetPoint("CENTER", parent, "TOPLEFT", tonumber(x)/10000*w, tonumber(y)/10000*h)
						frame:SetupBossFrame(MapType, Map, boss)
						parent.displayedBosses[boss] = frame
					end
				end
			end
		end
		if lootdata:HasLoot(MapType, Map, "Non Boss Drops") then
			local frame = getBossFrame(parent)
			frame:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 35, 45)
			--frame.name:SetText(BB[boss])
			frame:SetupBossFrame(MapType, Map, "Non Boss Drops")
			parent.displayedBosses["Non Boss Drops"] = frame
		end
	end
	if (self.Bosses[MapType] and self.Bosses[MapType][Map]) or lootdata:HasLoot(MapType, Map, "Non Boss Drops") then
		parent.displayedBossesToggle = getBossFrameToggle(parent, MapType, Map, level)
	end
	self.BossParents[parent] = true
end

function YssBossLoot:ClearBosses(parent)
	if parent.displayedBosses then
		for b, frame in pairs(parent.displayedBosses) do
			parent.displayedBosses[b] = returnBossFrame(frame)
		end
	else
		parent.displayedBosses = {}
	end
	if parent.displayedBossesToggle then
		parent.displayedBossesToggle = returnBossFrameToggle(parent.displayedBossesToggle)
	end
end

YssBossLoot.FilterMenu = CreateFrame("Frame", "YssBossLoot_FilterMenu", YssBossLoot.frame)
YssBossLoot.FilterMenu.onHide = function(...)
	MenuParent = nil
	MenuItem = nil
	MenuEquipSlot = nil
end
YssBossLoot.FilterMenu.HideMenu = function()
    if UIDROPDOWNMENU_OPEN_MENU == YssBossLoot.FilterMenu then
        CloseDropDownMenus()
    end
end

local info, sortedFilters = {}, {}
YssBossLoot.FilterMenu.initialize = function(self, level)
	if not level then return end
    if level == 1 then
		wipe(info)
		wipe(sortedFilters)
		for k in pairs(YssBossLoot.filters) do
			sortedFilters[#sortedFilters+1] = k
		end
		table.sort(sortedFilters)

		for i = 1, #sortedFilters do
			if YssBossLoot.filters[sortedFilters[i]]:isRelevant() then
				-- Create the title of the menu
				info.isTitle = 1
				info.text = L[sortedFilters[i]]
				info.notCheckable = 1
				UIDropDownMenu_AddButton(info, level)

				YssBossLoot.filters[sortedFilters[i]]:GetDropdown(level)
			end
		end
		info.isTitle = nil
		info.disabled = nil
        info.notCheckable = 1

		info.tooltipOnButton = nil
		info.tooltipWhileDisabled = nil
		info.tooltipTitle = nil
		info.tooltipText = nil

		info.text = GREEN_FONT_COLOR_CODE..L["Show All"]
		info.keepShownOnClick = 1
		info.func = function()
			for k, filter in pairs(YssBossLoot.filters) do
				filter:ShowAll()
			end
			ToggleDropDownMenu(1, nil, YssBossLoot.FilterMenu, YssBossLoot.FilterButton, 0, 0)
			ToggleDropDownMenu(1, nil, YssBossLoot.FilterMenu, YssBossLoot.FilterButton, 0, 0)
			YssBossLoot:FilterUpdate()
		end
		UIDropDownMenu_AddButton(info, level)

		info.text = NORMAL_FONT_COLOR_CODE..RESET
		info.keepShownOnClick = 1
		info.func = function()
			for k, filter in pairs(YssBossLoot.filters) do
				filter:ResetFilter()
			end
			ToggleDropDownMenu(1, nil, YssBossLoot.FilterMenu, YssBossLoot.FilterButton, 0, 0)
			ToggleDropDownMenu(1, nil, YssBossLoot.FilterMenu, YssBossLoot.FilterButton, 0, 0)
			YssBossLoot:FilterUpdate()
		end
		UIDropDownMenu_AddButton(info, level)

		info.text = CLOSE
		info.func = self.HideMenu
		UIDropDownMenu_AddButton(info, level)

	elseif level == 2 then
		for k, filter in pairs(YssBossLoot.filters) do
			filter:GetDropdown(level)
		end
	end
end

local defaultHeight = 28
local defaultWidth = 250
AceGUI:RegisterLayout("YBL_FLOW_LA",
	 function(content, children)
	 	local width = content.width or content:GetWidth() or defaultWidth
		local columns = width > defaultWidth and math.ceil(((width-16)/defaultWidth)-.001) or 1
		local rows = math.ceil(#children/columns)
		local count = 1
		for y=1, rows do
			for x=1,columns do
				local child = children[count]
				if child then
					local frame = child.frame
					frame:ClearAllPoints()
					frame:SetPoint("TOPLEFT",content,"TOPLEFT",(x-1)*defaultWidth,-1*(y-1)*defaultHeight)
					count=count+1
				else
					break
				end
			end
		end
		content.obj:LayoutFinished(nil, rows*defaultHeight)
	 end
	)
	
AceGUI:RegisterLayout("YBL_FLOW_RA",
	 function(content, children)
	 	local width = content.width or content:GetWidth() or defaultWidth
		local columns = width > defaultWidth and math.ceil(((width-16)/defaultWidth)-.001) or 1
		local rows = math.ceil(#children/columns)
		local count = 1
		for y=1, rows do
			for x=columns,1,-1 do
				local child = children[count]
				if child then
					local frame = child.frame
					frame:ClearAllPoints()
					frame:SetPoint("TOPRIGHT",content,"TOPRIGHT",-1*(x-1)*defaultWidth,-1*(y-1)*defaultHeight)
					count=count+1
				else
					break
				end
			end
		end
		content.obj:LayoutFinished(nil, rows*defaultHeight)
	 end
	)
--[[ script to find missing translations in babble boss
function YSSTEST()
	local missing = {}
	local types = lootdata:GetInstanceTypeList()
	for i, iType in ipairs(types) do
		local instanceList = lootdata:GetInstanceList(iType)
		for i, instance in ipairs(instanceList) do
			local bosslist = lootdata:GetBossList(iType, instance)
			for i, boss in ipairs(bosslist) do
				if not BB[boss] then
					missing[boss] = instance
				end
				local mainboss = lootdata:IsSubBoss(iType, instance, boss)
				if mainboss and not BB[mainboss] then
					missing[mainboss] = instance
				end
			end
		end
	end
	YssBossLootMissingTranslations = missing
end
]]--
