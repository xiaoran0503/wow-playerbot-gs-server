-- Pawn by Vger-Azjol-Nerub
-- www.vgermods.com
-- © 2006-2010 Green Eclipse.  This mod is released under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 license.
-- See Readme.htm for more information.

-- 
-- English resources
------------------------------------------------------------


------------------------------------------------------------
-- "Constants"
------------------------------------------------------------

PawnQuestionTexture = "|TInterface\\AddOns\\Pawn\\Textures\\Question:0|t" -- Texture string that represents a (?).  Don't need to localize this.
PawnUINoScale = "(none)" -- The name that shows up in lists of scales if you have no scales

------------------------------------------------------------
-- Master table of stats
------------------------------------------------------------

-- The master list of all stats that Pawn supports.
-- First column is the friendly translated name of the stat.
-- Second column is the Pawn name of the stat; this can't be translated.
-- Third column is the description of the stat.
-- Fourth column is true if the stat can't be ignored.
-- Fifth column is an optional chunk of text instead of the "1 ___ is worth:" prompt.
-- If only a name is present, the row becomes an uneditable header in the UI and is otherwise ignored.
PawnStats =
{
	{"基础属性"},
	{"力量", "Strength", "主要属性，力量。"},
	{"敏捷", "Agility", "主要属性，敏捷。"},
	{"耐力", "Stamina", "主要属性，耐力。"},
	{"智力", "Intellect", "主要属性，智力。"},
	{"精神", "Spirit", "主要属性，精神。"},
	
	{"插槽"},
	{"红色插槽", "RedSocket", "空的红色插槽，只计该槽的原价值。", true},
	{"黄色插槽", "YellowSocket", "空的黄色插槽，只计该槽的原价值。", true},
	{"蓝色插槽", "BlueSocket", "空的蓝色插槽，只计该槽的原价值。", true},
	{"多彩:属性", "MetaSocket", "空的多彩插槽，只计多彩宝石所带的属性价值，不含特效，计算时忽略多彩宝石是否触发。", true},
	{"多彩:特效", "MetaSocketEffect", "多彩插槽，不管宝石是否镶嵌，只计算多彩宝石的特效价值。", true},
	
	{"武器属性"},
	{"每秒伤害", "Dps", "武器的每秒伤害。(如果你想要给不同类型的武器估分，前往 \"特殊武器属性\" 部分。)"},
	{"速度", "Speed", "武器攻击速度，武器挥动时间间隔。(如果你喜欢快速武器，此数字应该为负数。前往 \"特殊武器属性\" 中的 \"速度基线\" 部分。)"},
	
	{"混合属性"},
	{"命中等级", "HitRating", "命中等级，影响近战远程和法术的命中。"},
	{"爆击等级", "CritRating", "爆击等级，影响近战、远程和法术的爆击几率。"},
	{"急速等级", "HasteRating", "急速等级，影响近战、远程和法术的攻击速度."},
	{"精通等级", "MasteryRating", VgerCore.Color.Salmon .. "大灾变新属性。" .. VgerCore.Color.Reset .. "从你投入点数最多的天赋树中获得的奖励。"},
	
	{"物理攻击属性"},
	{"攻击强度", "Ap", "攻击强度，不包括从力量、敏捷或德鲁伊(野性形态)从武器上获得的攻击强度。"},
	{"远程攻击强度", "Rap", "远程攻击强度。"},
	{"野性攻击强度", "FeralAp", "德鲁伊在野性形态下从武器获得的攻击强度，此项不能与武器每秒伤害同时估分。"},
	{"精准", "ExpertiseRating", "精准属性。"},
	{"护甲穿透", "ArmorPenetration", "护甲穿透等级可以使你的攻击忽略目标的部分护甲。\n\n" .. VgerCore.Color.Salmon .. "大灾变:  " .. VgerCore.Color.Reset .. "护甲穿透将被其他属性替代。"},
	
	{"法术属性"},
	{"法术强度", "SpellPower", "法术强度，同时影响法术伤害和治疗效果。"},
	{"5秒回蓝", "Mp5", "每5秒回蓝效果。\n\n" .. VgerCore.Color.Salmon .. "大灾变:  " .. VgerCore.Color.Reset .. "每1点5秒回蓝将被替换成2点精神。"},
	{"法术穿透", "SpellPenetration", "法术穿透可以忽略目标的部分法术抗性。"},
	
	{"防御属性"},
	{"护甲值", "Armor", "护甲值，无论物品类型。有获得额外护甲技能的职业将指定一个数值来代替基础护甲和额外护甲。"},
	{"基础护甲", "BaseArmor", "布甲、皮甲、锁甲、板甲上的基础护甲值，可通过技能增加，如厚皮、冰霜灵气。\n\n当插件不能计算额外护甲时，以绿字显示的额外护甲将作为基础护甲一样计算所有的护甲值。"},
	{"额外护甲", "BonusArmor", "武器、饰品、戒指上的额外护甲值，不受技能和天赋影响。"},
	{"格挡", "BlockValue", "成功格挡之后可以吸收的部分伤害。\n\n" .. VgerCore.Color.Salmon .. "大灾变:  " .. VgerCore.Color.Reset .. "格挡将被坦克其他属性替代。"},
	{"格挡等级", "BlockRating", "格挡等级增加你的盾牌格挡的几率。"},
	{"防御等级", "DefenseRating", "防御等级。\n\n" .. VgerCore.Color.Salmon .. "大灾变:  " .. VgerCore.Color.Reset .. "防御等级将被坦克其他属性替代。"},
	{"躲闪等级", "DodgeRating", "躲闪等级。"},
	{"招架等级", "ParryRating", "招架等级。"},
	{"韧性等级", "ResilienceRating", "韧性等级。"},
	
	{"稀有属性"},
	{"火焰伤害", "FireSpellDamage", "仅火焰伤害，该属性不会与所有法术伤害属性同时出现。"},
	{"暗影伤害", "ShadowSpellDamage", "仅暗影伤害，该属性不会与所有法术伤害属性同时出现。"},
	{"自然伤害", "NatureSpellDamage", "仅自然伤害害，该属性不会与所有法术伤害属性同时出现。"},
	{"奥术伤害", "ArcaneSpellDamage", "仅奥术伤害，该属性不会与所有法术伤害属性同时出现。"},
	{"冰霜伤害", "FrostSpellDamage", "仅冰霜伤害，该属性不会与所有法术伤害属性同时出现。"},
	{"神圣伤害", "HolySpellDamage", "仅神圣伤害，该属性不会与所有法术伤害属性同时出现。"},
	{"所有抗性", "AllResist", "所有元素抗性."},
	{"火焰抗性", "FireResist", "仅火焰抗性，该属性不会与所有抗性同时出现。"},
	{"暗影抗性", "ShadowResist", "仅暗影抗性，该属性不会与所有抗性同时出现。."},
	{"自然抗性", "NatureResist", "仅自然抗性，该属性不会与所有抗性同时出现。"},
	{"奥术抗性", "ArcaneResist", "仅奥术抗性，该属性不会与所有抗性同时出现。"},
	{"冰霜抗性", "FrostResist", "仅冰霜抗性，该属性不会与所有抗性同时出现。"},
	{"5秒回血", "Hp5", "每5秒回复的生命值，一般只出现在附魔中。"},
	{"生命值", "Health", "生命值，不包括从耐力中获得的生命值，一般只出现在附魔中。"},
	{"法力值", "Mana", "法力值，不包括从智力中获得的法力值，一般只出现在附魔中。"},
	
	{"武器类型"},
	{"单手斧", "IsAxe", "物品类型为单手斧。"},
	{"双手斧", "Is2HAxe", "物品类型为双手斧。"},
	{"弓", "IsBow", "物品类型为弓，或一叠箭。"}, -- *** Cataclysm: ammo removed
	{"驽", "IsCrossbow", "物品类型为驽。"},
	{"匕首", "IsDagger", "物品类型为匕首。"},
	{"拳套", "IsFist", "物品类型为拳套。"},
	{"枪械", "IsGun", "物品类型为枪械，或一堆子弹。"}, -- *** Cataclysm: ammo removed
	{"单手锤", "IsMace", "物品类型为单手锤。"},
	{"双手锤", "Is2HMace", "物品类型为双手锤。"},
	{"长柄武器", "IsPolearm", "物品类型为长柄武器。"},
	{"法杖", "IsStaff", "物品类型为法杖。"},
	{"单手剑", "IsSword", "物品类型为单手剑。"},
	{"双手剑", "Is2HSword", "物品类型为双手剑。"},
	{"投掷武器", "IsThrown", "物品类型为投掷武器。"},
	{"魔杖", "IsWand", "物品类型为魔杖。"},

	{"护甲类型"},
	{"布甲", "IsCloth", "物品类型为布甲。"},
	{"皮甲", "IsLeather", "物品类型为皮甲。"},
	{"锁甲", "IsMail", "物品类型为锁甲。"},
	{"板甲", "IsPlate", "物品类型为板甲。"},
	{"盾牌", "IsShield", "物品类型为盾牌。"},

	{"特殊武器属性"},
	{"伤害下限", "MinDamage", "武器伤害下限。"},
	{"伤害上限", "MaxDamage", "武器伤害上限。"},
	{"近战:每秒伤害", "MeleeDps", "近战武器每秒伤害。"},
	{"近战:伤害下限", "MeleeMinDamage", "近战武器伤害下限。"},
	{"近战:伤害上限", "MeleeMaxDamage", "近战武器伤害上限。"},
	{"近战:攻速", "MeleeSpeed", "近战武器攻击速度。"},
	{"远程:每秒伤害", "RangedDps", "远程武器每秒伤害。"},
	{"远程:伤害下限", "RangedMinDamage", "远程武器伤害下限。"},
	{"远程:伤害上限", "RangedMaxDamage", "远程武器伤害上限。"},
	{"远程:攻速", "RangedSped", "远程武器攻击速度。"},
	{"主手:每秒伤害", "MainHandDps", "主手武器每秒伤害。"},
	{"主手:伤害下限", "MainHandMinDamage", "主手武器伤害下限。"},
	{"主手:伤害上限", "MainHandMaxDamage", "主手武器伤害上限。"},
	{"主手:攻速", "MainHandSpeed", "主手武器攻击速度。"},
	{"副手:每秒伤害", "OffHandDps", "副手武器每秒伤害。"},
	{"副手:伤害下限", "OffHandMinDamage", "副手武器伤害下限。"},
	{"副手:伤害上限", "OffHandMaxDamage", "副手武器伤害上限。"},
	{"副手:攻速", "OffHandSpeed", "副手武器攻击速度。"},
	{"单手:每秒伤害", "OneHandDps", "单手武器每秒伤害，不包括主手或副手武器。"},
	{"单手:伤害下限", "OneHandMinDamage", "单手武器伤害下限，不包括主手或副手武器。"},
	{"单手:伤害上限", "OneHandMaxDamage", "单手武器伤害上限，不包括主手或副手武器。"},
	{"单手:攻速", "OneHandSpeed", "单手武器攻击速度，不包括主手或副手武器。"},
	{"双手:每秒伤害", "TwoHandDps", "双手武器每秒伤害。"},
	{"双手:伤害下限", "TwoHandMinDamage", "双手武器伤害下限。"},
	{"双手:伤害上限", "TwoHandMaxDamage", "双手武器伤害上限。"},
	{"双手:攻速", "TwoHandSpeed", "双手武器攻击速度。"},
	{"速度基线", "SpeedBaseline", "不是实际属性，该数字在乘以均衡标准前要减去速度属性。", "|cffffffff速度基线|r 是:"},
}


------------------------------------------------------------
-- UI strings
------------------------------------------------------------

-- Translation note: All of the strings ending in _Text should be translated; those will show up in the UI.  The strings ending
-- in _Tooltip are only used in tooltips, and can be safely left out.  If you don't want to translate them right now, delete those
-- lines or set them to nil, and Pawn won't show tooltips for those UI elements.


-- Configuration UI
PawnUIFrame_CloseButton_Text = "关闭"
PawnUIHeaders = -- (%s is the name of the current scale)
{
	"管理Pawn均衡标准", -- Scale tab
	"调整%s的均衡值", -- Values tab
	"使用%s对比物品", -- Compare tab
	"为%s选择宝石", -- Gems tab
	"配置Pawn选项", -- Options tab
	"关于Pawn", -- About tab
	"欢迎使用Pawn!", -- Getting Started tab
}

-- Configuration UI, Scale selector
PawnUIFrame_ScaleSelector_Header_Text = "选择一个均衡标准："

-- Configuration UI, Scale tab (this is a new tab; the old Scales tab is now the Values tab)
PawnUIFrame_ScalesTab_Text = "均衡标准"

PawnUIFrame_ScalesWelcomeLabel_Text = "已配置有物品的属性和均衡值，你可以新建或使用已有标准中的均衡值。"

PawnUIFrame_ShowScaleCheck_Label_Text = "显示该均衡标准"
PawnUIFrame_ShowScaleCheck_Tooltip = "选择此项，将该均衡标准所计算的均衡值显示在物品的提示信息上，每个已选的标准都会在提示信息上显示。"
PawnUIFrame_RenameScaleButton_Text = "重命名"
PawnUIFrame_RenameScaleButton_Tooltip = "重命名该均衡标准."
PawnUIFrame_DeleteScaleButton_Text = "删除"
PawnUIFrame_DeleteScaleButton_Tooltip = "删除该均衡标准。\n\n此命令无法恢复!"
PawnUIFrame_ScaleColorSwatch_Label_Text = "更改颜色"
PawnUIFrame_ScaleColorSwatch_Tooltip = "更改在物品提示信息上的字体颜色。"
PawnUIFrame_ScaleTypeLabel_NormalScaleText = "你可以在均衡值面板中调整该均衡标准。"
PawnUIFrame_ScaleTypeLabel_ReadOnlyScaleText = "你必须新建一个副本来编辑该均衡标准。"

PawnUIFrame_ScaleSettingsShareHeader_Text = "分享你的均衡标准"

PawnUIFrame_ImportScaleButton_Text = "导入"
PawnUIFrame_ImportScaleButton_Label_Text = "通过粘贴来新建一个均衡标准。"
PawnUIFrame_ExportScaleButton_Text = "导出"
PawnUIFrame_ExportScaleButton_Label_Text = "与别人分享你的均衡标准。"

PawnUIFrame_ScaleSettingsNewHeader_Text = "新建一个均衡标准"

PawnUIFrame_CopyScaleButton_Text = "复制"
PawnUIFrame_CopyScaleButton_Label_Text = "通过复制此项来新建一个均衡标准。"
PawnUIFrame_NewScaleButton_Text = "空白"
PawnUIFrame_NewScaleButton_Label_Text = "新建一个空白的均衡标准。"
PawnUIFrame_NewScaleFromDefaultsButton_Text = "默认"
PawnUIFrame_NewScaleFromDefaultsButton_Label_Text = "新建一个默认的均衡标准。"

-- Configuration UI, Values tab (previously the Scales tab)
PawnUIFrame_ValuesTab_Text = "均衡值"

PawnUIFrame_ValuesWelcomeLabel_NormalText = "你可以为该均衡标准配置每项属性的均衡值，管理或新建均衡标准，请使用均衡标准面板。"
PawnUIFrame_ValuesWelcomeLabel_NoScalesText = "你未选择均衡标准，请从均衡标准面板新建或通过粘贴新建一个均衡标准。"
PawnUIFrame_ValuesWelcomeLabel_ReadOnlyScaleText = "不能改变你所选择的均衡标准，如果你想改变这些均衡值，请在均衡标准面板通过复制建立此项的副本或新建一个均衡标准。"

PawnUIFrame_ClearValueButton_Text = "移除"
PawnUIFrame_ClearValueButton_Tooltip = "从均衡标准中移除该属性。"

PawnUIFrame_IgnoreStatCheck_Text = "物品不可用"
PawnUIFrame_IgnoreStatCheck_Tooltip = "选择此项，任何不可用的物品将不会计算均衡值。例如：萨满不能装备板甲，为萨满设计的均衡标准可以标记板甲为不可用，此板甲也不会被该标准计算分值。"

PawnUIFrame_ScaleSocketOptionsHeaderLabel_Text = "此均衡标准计算均衡值时:"
PawnUIFrame_ScaleSocketBestRadio_Text = "自动处理插槽"
PawnUIFrame_ScaleSocketBestRadio_Tooltip = "Pawn将根据宝石面板中所选择的宝石来计算均衡值。"
PawnUIFrame_ScaleSocketCorrectRadio_Text = "手动处理插槽"
PawnUIFrame_ScaleSocketCorrectRadio_Tooltip = "Pawn将根据你配置的数字来计算这个标准的均衡值(个人建议)。"

PawnUIFrame_NormalizeValuesCheck_Text = "标准化均衡值 (类似 Wowhead)"
PawnUIFrame_NormalizeValuesCheck_Tooltip = "选择此项，最终评分将像Wowhead和LootzorEnable一样，由物品所有属性的均衡值总和除以最终计算值得到。这有助于稳定像某个标准的均衡值在1附近另一个在5附近的情况，也有助于保持比较小的数字。\n\n如需有关此设置的信息，请参阅自述文件。"

-- Configuration UI, Compare tab
PawnUIFrame_CompareTab_Text = "物品对比"

PawnUIFrame_VersusHeader_Text = "—vs.—" -- Short for "versus."  Appears between the names of the two items.
PawnUIFrame_VersusHeader_NoItem = "(没有物品)" -- Text displayed next to empty item slots.

PawnUIFrame_CompareMissingItemInfo_TextLeft = "1、从左侧列表选择一个均衡标准。\n\n\n\n4、或者将需要对比的两件物品分别拖入两栏。"
PawnUIFrame_CompareMissingItemInfo_TextRight = "2、将物品拖入右栏。\n3、Pawn会自动与你所装备的物品进行对比。"

PawnUIFrame_CompareSocketBonusHeader_Text = "镶孔奖励" -- Heading that appears above the item socket bonuses.

PawnUIFrame_CompareOtherInfoHeader_Text = "其他" -- Heading that appears above the item's level and the following stats:
PawnUIFrame_CompareAsterisk = "未知属性 " .. PawnQuestionTexture
PawnUIFrame_CompareAsterisk_Yes = "是" -- Appears on the Compare tab when an item has special effects (?).

PawnUIFrame_CurrentCompareScaleDropDown_Label_Text = "对比均衡标准"
PawnUIFrame_CurrentCompareScaleDropDown_Tooltip = "对比物品时选择一个新的均衡标准。"

PawnUIFrame_ClearItemsButton_Label = "清空"
PawnUIFrame_ClearItemsButton_Tooltip = "清空所对比的物品。"

PawnUIFrame_CompareSwapButton_Text = "< 对换 >"
PawnUIFrame_CompareSwapButton_Tooltip = "两件物品对换位置。"

-- Configuration UI, Gems tab
PawnUIFrame_GemsTab_Text = "宝石"
PawnUIFrame_GemsHeaderLabel_Text = "选择一个均衡标准，Pawn将自动选择该标准所对应均衡值最高的宝石。|CFFFF0000貌似选择时考虑镶孔奖励，多彩选的也不好。建议在均衡值面板中手动处理插槽的均衡值。|r"

PawnUIFrame_CurrentGemsScaleDropDown_Label_Text = "为此项选择最好的宝石:"
PawnUIFrame_CurrentGemsScaleDropDown_Tooltip = "选择一个均衡标准来计算宝石的均衡值。"

PawnUIFrame_GemQualityDropDown_Label_Text = "品质:"
PawnUIFrame_GemQualityDropDown_Tooltip = "选择宝石的品质让Pawn自动选择。"

PawnUIFrame_FindGemColorHeader_Text = "%s 宝石" -- Red
PawnUIFrame_FindGemColorHeader_Meta_Text = "多彩宝石(不考虑特效)"
PawnUIFrame_FindGemNoGemsHeader_Text = "没有匹配的宝石。"

-- Configuration UI, Options tab
PawnUIFrame_OptionsTab_Text = "选项"
PawnUIFrame_OptionsHeaderLabel_Text = "根据你的偏好来设置Pawn，更改将立即生效。"

PawnUIFrame_TooltipOptionsHeaderLabel_Text = "信息面板选项"
PawnUIFrame_ShowItemLevelsCheck_Text = "显示物品等级"
PawnUIFrame_ShowItemLevelsCheck_Tooltip = "选择此项让Pawn显示你所遇到每个物品的等级。\n\n魔兽世界中的每个物品都有一个表示它有多少属性的隐藏等级。一般来说，同类型的物品(如头盔、披风)会因品质(如绿色、蓝色)、需要等级会有更多或至少更好的属性。"
PawnUIFrame_ShowItemIDsCheck_Text = "显示物品ID"
PawnUIFrame_ShowItemIDsCheck_Tooltip = "选择此项让Pawn显示你所遇到每个物品以及附魔和宝石的ID。\n\n魔兽世界中的每个物品都有一个数字ID与之关联，这个信息一般用于插件开发。"
PawnUIFrame_ShowIconsCheck_Text = "显示库存图标"
PawnUIFrame_ShowIconsCheck_Tooltip = "选择此项，在物品的链接窗口边显示图标。"
PawnUIFrame_ShowExtraSpaceCheck_Text = "均衡值前显示空行"
PawnUIFrame_ShowExtraSpaceCheck_Tooltip = "选择此项，在物品的均衡值前添加一个空行使信息面板简洁明了。"
PawnUIFrame_AlignRightCheck_Text = "Pawn信息右对齐"
PawnUIFrame_AlignRightCheck_Tooltip = "选择此项让你的均衡值(以及物品等级和物品ID)向右边缘对齐。"
PawnUIFrame_AsterisksHeaderLabel_Text = "未知属性显示 " .. PawnQuestionTexture .. " :"
PawnUIFrame_AsterisksAutoRadio_Text = "开启"
PawnUIFrame_AsterisksAutoRadio_Tooltip = "有未知属性的物品显示" .. PawnQuestionTexture .. "图标(比如饰品类)。"
PawnUIFrame_AsterisksAutoNoTextRadio_Text = "开启但不显示警告信息"
PawnUIFrame_AsterisksAutoNoTextRadio_Tooltip = "同开启，但不显示'未知属性不包含在均衡值中'的信息。"
PawnUIFrame_AsterisksOffRadio_Text = "关闭"
PawnUIFrame_AsterisksOffRadio_Tooltip = "不显示" .. PawnQuestionTexture .. "图标或警告信息"

PawnUIFrame_CalculationOptionsHeaderLabel_Text = "计算选项"
PawnUIFrame_DigitsBox_Label_Text = "精确位:"
PawnUIFrame_DigitsBox_Tooltip = "信息面板中均衡值的精确位数，用0-9表示。0表示取整，1表示保留一位小数。"
PawnUIFrame_UnenchantedValuesCheck_Text = "显示物品的原始均衡值"
PawnUIFrame_UnenchantedValuesCheck_Tooltip = "选择此项让Pawn显示物品未修改前的均衡值(包括空槽)，如物品刚拾取或刚从商人处购入的状态。\n如果当前均衡值和原始均衡值不同，原始均衡值将在后面括弧内显示，并用★表示。"
PawnUIFrame_EnchantedValuesCheck_Text = "显示物品的当前均衡值"
PawnUIFrame_EnchantedValuesCheck_Tooltip = "选择此项让Pawn显示物品的当前均衡值，包括所有附魔和宝石，空的插槽不会被计算。\n\n如果当前均衡值和原始均衡值相同，只会显示一个。"
PawnUIFrame_DebugCheck_Text = "显示debug信息"
PawnUIFrame_DebugCheck_Tooltip = "如果你不确定Pawn是否已完整计算物品的均衡值，选择此项后将鼠标悬停在物品上，Pawn会在聊天框列出所有用到的数据。这些信息包括Pawn考虑到的物品属性、Pawn无法识别的部分以及每个均衡标准如何计算部分。\n\n这个选项会将你的聊天框快速填满信息，一旦你查看完毕，请关闭此项。\n\n快捷命令:\n/pawn debug on\n/pawn debug off"

PawnUIFrame_OtherOptionsHeaderLabel_Text = "其他选项"
PawnUIFrame_ButtonPositionHeaderLabel_Text = "显示Pawn按键:"
PawnUIFrame_ButtonRightRadio_Text = "右边显示"
PawnUIFrame_ButtonRightRadio_Tooltip = "在角色属性面板右下显示Pawn按键。"
PawnUIFrame_ButtonLeftRadio_Text = "左边显示"
PawnUIFrame_ButtonLeftRadio_Tooltip = "在角色属性面板左下显示Pawn按键。"
PawnUIFrame_ButtonOffRadio_Text = "隐藏"
PawnUIFrame_ButtonOffRadio_Tooltip = "不在角色属性面板中显示Pawn按键。"

-- Configuration UI, About tab
PawnUIFrame_AboutTab_Text = "关于"
PawnUIFrame_AboutHeaderLabel_Text = "作者：Vger-Azjol-Nerub"
PawnUIFrame_AboutVersionLabel_Text = "版本：%s"
PawnUIFrame_AboutTranslationLabel_Text = "简体中文汉化 by 羊鸣神教" -- Translators: credit yourself here... "Klingon translation by Stovokor"
PawnUIFrame_ReadmeLabel_Text = "第一次接触Pawn?请参阅帮助面板开始真正的基本介绍。你可以在Pawn自带的自述文件中学习更多的进阶教程。"
PawnUIFrame_WebsiteLabel_Text = "Vger的更多插件，前往vgermods.com。\n\nWowhead的属性已经授权。如果你有关于均衡值的问题需要反馈，请直接在Wowhead论坛相应板块上留言。"

-- Configuration UI, Help tab
PawnUIFrame_HelpTab_Text = "帮助"
PawnUIFrame_GettingStartedLabel_Text =
	"Pawn calculates scores for items that let you easily see which one is better for you.  These scores show up at the bottom of all your item tooltips.\n\n\n" ..
	"Each item will get multiple scores: one for each “scale” that is active for your character.  A scale lists the stats that are important to you, and how many points each stat is worth.\n\n\n" ..
	"Pawn comes with scales from Wowhead for each class and spec.  You can turn scales on and off, create your own by assigning point values to each stat, and even share scales on the internet.\n\n\n" ..
	VgerCore.Color.Blue .. "Try out these features once you learn the basics:\n" .. VgerCore.Color.Reset ..
	" • Compare the stats of two items by using Pawn's Compare tab.\n" ..
	" • Right-click on an item link window to see how it compares to your current item.\n" ..
	" • Shift-right-click an item with sockets to have Pawn suggest gems for it.\n" ..
	" • Make a copy of one of your scales on the Scale tab, and customize the stat values on the Values tab.\n" ..
	" • Find more scales for your class on the internet, or build a custom one with Rawr.\n" ..
	" • Check out the readme file to learn more about Pawn's advanced features."
	
-- Inventory button
PawnUI_InventoryPawnButton_Tooltip = "点击显示Pawn界面。"
PawnUI_InventoryPawnButton_Subheader = "已装备物品统计:"

-- Socketing button
PawnUI_SocketingPawnButton_Tooltip = "点击显示Pawn宝石界面。"

-- Item socketing UI
PawnUI_ItemSocketingDescription_Header = "Pawn建议如下宝石:"

-- Interface Options page
PawnInterfaceOptionsFrame_OptionsHeaderLabel_Text = "Pawn选项能在Pawn界面中找到。"
PawnInterfaceOptionsFrame_OptionsSubHeaderLabel_Text = "点击Pawn按键前往。你可以在界面设置页面中打开Pawn，或者绑定一个快捷键。"

-- Bindings UI
BINDING_HEADER_PAWN = "Pawn"
BINDING_NAME_PAWN_TOGGLE_UI = "显示或隐藏Pawn界面" -- Show or hide the Pawn UI
PAWN_TOGGLE_UI_DEFAULT_KEY = "P" -- Default key to assign to this command
BINDING_NAME_PAWN_COMPARE_LEFT = "比较物品(左边)" -- Set the currently hovered item to be the left-side Compare item
PAWN_COMPARE_LEFT_DEFAULT_KEY = "[" -- Default key to assign to this command
BINDING_NAME_PAWN_COMPARE_RIGHT = "比较物品(右边)" -- Set the currently hovered item to be the right-side Compare item
PAWN_COMPARE_RIGHT_DEFAULT_KEY = "]" -- Default key to assign to this command


PawnLocal =
{

	-- General messages
	["NeedNewerVgerCoreMessage"] = "Pawn需要一个新版本的Vger库，请使用Pawn自带的Vger库。",
	
	-- Scale management dialog messages
	["NewScaleEnterName"] = "输入均衡标准的名称:",
	["NewScaleNoQuotes"] = "名称不能包含 \"，请重新输入:",
	["NewScaleDuplicateName"] = "名称已存在，请重新输入:",
	
	["CopyScaleEnterName"] = "输入复制 %s 后的均衡标准名称:", -- %s is the name of the existing scale
	["RenameScaleEnterName"] = "为 %s 输入新名称:", -- %s is the old name of the scale
	["DeleteScaleConfirmation"] = "你确定要删除 %s 吗? 该操作无法撤销。输入 \"%s\" 点确定:", -- First %s is the name of the scale, second %s is DELETE
	
	["ImportScaleMessage"] = "使用 Ctrl+V 粘贴你从网络上复制过来的均衡标准:",
	["ImportScaleTagErrorMessage"] = "Pawn无法识别该均衡标准，你确定数据复制完整了吗?尝试重新粘贴:",
	
	["ExportScaleMessage"] = "使用 Ctrl+C 复制 |cffffffff%s|r 均衡标准，然后使用 Ctrl+V 粘贴至其他地方。", -- %s is name of scale
	["ExportAllScalesMessage"] = "使用 Ctrl+C 复制你的均衡标准，在你电脑中新建个文件使用 Ctrl+V 粘贴后保存用于备份。",
	
	-- Scale selector
	["VisibleScalesHeader"] = "%s的均衡标准", -- %s is name of character
	["HiddenScalesHeader"] = "其他均衡标准",
	
	-- Configuration UI, Values tab
	["Unusable"] = "(无法使用)",
	["NoStatDescription"] = "在左侧列表选择一个属性。",
	["NoScalesDescription"] = "准备开始，导入或新建一个均衡标准。",
	["StatNameText"] = "1 |cffffffff%s|r 的价值:", -- |cffffffff%s|r is the name of the stat, in white
	
	-- Generic string dialogs
	["OKButton"] = "确认",
	["CancelButton"] = "取消",
	["CloseButton"] = "关闭",
	
	-- Debug messages
	["EnchantedStatsHeader"] = "(当前均衡值)",
	["UnenchantedStatsHeader"] = "(原始均衡值)",
	["FailedToGetItemLinkMessage"] = "   无法从信息面板中获取物品链接，可能是插件冲突。",
	["FailedToGetUnenchantedItemMessage"] = "   无法获取物品的原始均衡值，可能是插件冲突。",
	["DidntUnderstandMessage"] = "   (?) 无法识别 \"%s\".",
	["FoundStatMessage"] = "   %d %s", -- 25 Stamina
	
	["ValueCalculationMessage"] = "   %g %s x %g each = %g", -- 25 Stamina x 1 each = 25
	["UnusableStatMessage"] = "   -- %s 无法使用，已停止。", -- IsPlate is unusable, so stopping
	["SocketBonusValueCalculationMessage"] = "   -- 镶孔奖励的价值为:",
	["MissocketWorthwhileMessage"] = "   -- 但最好使用 %s 宝石:", -- Better to use only Red/Blue gems:
	["NormalizationMessage"] = "   ---- 标准化算法：除以 %g", -- Normalized by dividing by 3.5
	["TotalValueMessage"] = "   ---- 总计: %g", -- Total: 25
	
	-- Tooltip annotations
	["ItemIDTooltipLine"] = "物品ID",
	["ItemLevelTooltipLine"] = "物品等级",
	["AverageItemLevelTooltipLine"] = "史诗装备等级",
	["BaseValueWord"] = "★", -- 123.45 (98.76 ★)
	["AsteriskTooltipLine"] = "|TInterface\\AddOns\\Pawn\\Textures\\Question:0|t 未知属性不包含在均衡值中。",
	
	-- Gem stuff
	["GenericGemName"] = "(宝石 %d)", -- (Gem 12345)
	["GenericGemLink"] = "|H物品:%d|h[宝石 %d]|h", -- [Gem 12345]
	["GemColorList1"] = "%d %s", -- 2 Red
	["GemColorList2"] = "%d %s or %s", -- 3 Red or Yellow
	["GemColorList3"] = "任何颜色中的 %d", -- 1 of any color
	
	["GemQualityLevel80Uncommon"] = "80级优秀",
	["GemQualityLevel80Rare"] = "80级精良",
	["GemQualityLevel80Epic"] = "80级史诗",
	["MetaGemQualityLevel80Rare"] = "80级制作",
	["GemQualityLevel85Uncommon"] = "Level 85 uncommon",
	["GemQualityLevel85Rare"] = "Level 85 rare",
	["GemQualityLevel85Epic"] = "Level 85 epic",
	["MetaGemQualityLevel85Rare"] = "Level 85 crafted",
	
	-- Slash commands
	["DebugOnCommand"] = "debug on",
	["DebugOffCommand"] = "debug off",
	["BackupCommand"] = "backup",
	
	["Usage"] = [[
Pawn by Vger-Azjol-Nerub
www.vgermods.com
 
/pawn -- 显示或隐藏Pawn界面
/pawn debug [ on | off ] -- 开启或关闭debug信息
/pawn backup -- 在均衡面板备份你所有的设置
 
For more information on customizing Pawn, please see the help file (Readme.htm) that comes with the mod.
]],

}


------------------------------------------------------------
-- Localized scale names
------------------------------------------------------------

PawnWowheadScale_Provider = "Wowhead均衡标准"
PawnWowheadScale_WarriorArms = "战士:武器"
PawnWowheadScale_WarriorFury = "战士:狂怒"
PawnWowheadScale_WarriorTank = "战士:防护"
PawnWowheadScale_PaladinHoly = "圣骑士:神圣"
PawnWowheadScale_PaladinTank = "圣骑士:防护"
PawnWowheadScale_PaladinRetribution = "圣骑士:惩戒"
PawnWowheadScale_HunterBeastMastery = "猎人:野兽控制"
PawnWowheadScale_HunterMarksman = "猎人:射击"
PawnWowheadScale_HunterSurvival = "猎人:生存"
PawnWowheadScale_RogueAssassination = "潜行者:刺杀"
PawnWowheadScale_RogueCombat = "潜行者:战斗"
PawnWowheadScale_RogueSubtlety = "潜行者:敏锐"
PawnWowheadScale_PriestDiscipline = "牧师:戒律"
PawnWowheadScale_PriestHoly = "牧师:神圣"
PawnWowheadScale_PriestShadow = "牧师:暗影"
PawnWowheadScale_DeathKnightBloodDps = "死亡骑士:鲜血输出"
PawnWowheadScale_DeathKnightBloodTank = "死亡骑士:鲜血坦"
PawnWowheadScale_DeathKnightFrostDps = "死亡骑士:冰霜输出"
PawnWowheadScale_DeathKnightFrostTank = "死亡骑士:冰霜坦"
PawnWowheadScale_DeathKnightUnholyDps = "死亡骑士:邪恶输出"
PawnWowheadScale_ShamanElemental = "萨满祭司:元素"
PawnWowheadScale_ShamanEnhancement = "萨满祭司:增强"
PawnWowheadScale_ShamanRestoration = "萨满祭司:恢复"
PawnWowheadScale_MageArcane = "法师:奥术"
PawnWowheadScale_MageFire = "法师:火焰"
PawnWowheadScale_MageFrost = "法师:冰霜"
PawnWowheadScale_WarlockAffliction = "术士:痛苦"
PawnWowheadScale_WarlockDemonology = "术士:恶魔学识"
PawnWowheadScale_WarlockDestruction = "术士:毁灭"
PawnWowheadScale_DruidBalance = "德鲁伊:平衡"
PawnWowheadScale_DruidFeralDps = "德鲁伊:猎豹"
PawnWowheadScale_DruidFeralTank = "德鲁伊:熊"
PawnWowheadScale_DruidRestoration = "德鲁伊:恢复"

------------------------------------------------------------
-- Tooltip parsing expressions
------------------------------------------------------------

-- Turns a game constant into a regular expression.
function PawnGameConstant(Text)
	return "^" .. PawnGameConstantUnwrapped(Text) .. "$"
end
function PawnGameConstantUnwrapped(Text)
	-- REVIEW: This function seems stupid.
	return gsub(gsub(Text, "%%", "%%%%"), "%-", "%%-")
end

-- These strings indicate that a given line might contain multiple stats, such as complex enchantments
-- (ZG, AQ) and gems.  These are sorted in priority order.  If a string earlier in the table is present, any
-- string later in the table can be ignored.
PawnSeparators =
{
	"，",
	"/",
	" & ",
	" 和 ",
}

-- This string indicates that whatever stats follow it on the same line is the item's socket bonus.
PawnSocketBonusPrefix = "镶孔奖励："

-- Lines that match any of the following patterns will cause all further tooltip parsing to stop.
PawnKillLines =
{
	"^ \n$", -- The blank line before set items before WoW 2.3
	" %(%d+/%d+%)$", -- The (1/8) on set items for all versions of WoW
	"^|cff00e0ffDropped By", -- Mod compatibility: MobInfo-2 (should match mifontLightBlue .. MI_TXT_DROPPED_BY)
}

-- Lines that begin with any of the following strings will not be searched for separator strings.
PawnSeparatorIgnorePrefixes =
{
	'"', -- double quote
	"装备：",
	"使用：",
	"击中时可能：",
}

-- Items that begin with any of the following strings will never be parsed.
PawnIgnoreNames =
{
	"设计图：",
	"公式：",
	"配方：",
	"图样：",
	"图鉴：",
	"食谱：",
	"结构图：",
}

-- This is a list of regular expression substitutions that Pawn performs to normalize stat names before running
-- them through the normal gauntlet of expressions.
PawnNormalizationRegexes =
{
	{"^([%w%s%.]+) %+(%d+)$", "+%2 %1"}, -- "耐力 +5" --> "+5 Stamina"
	{"^(.-)|r.*", "%1"}, -- For removing meta gem requirements
}

-- These regular expressions are used to parse item tooltips.
-- The first string is the regular expression to match.  Stat values should be denoted with "(%d+)".
-- Subsequent strings follow this pattern: Stat, Number, Source
-- Stat is the name of a statistic.
-- Number is either the amount of that stat to include, or the 1-based index into the matches array produced by the regex.
-- If it's an index, it can also be negative to mean that the stat should be subtracted instead of added.  If nil, defaults to 1.
-- Source is either PawnMultipleStatsFixed if Number is the amount of the stat, or PawnMultipleStatsExtract or nil if Number is the matches array index.
-- Note that certain strings don't need to be translated: for example, the game defines
-- ITEM_BIND_ON_PICKUP to be "Binds when picked up" in English, and the correct string
-- in other languages automatically.
PawnMultipleStatsFixed = "_MultipleFixed"
PawnMultipleStatsExtract = "_MultipleExtract"
PawnRegexes =
{
	-- ========================================
	-- Strings that are ignored for compatibility with other mods
	-- ========================================
	{"^Used by outfits:"}, -- Mod compatibility: Outfitter
	
	-- ========================================
	-- Common strings that are ignored (rare ones are at the bottom of the file)
	-- ========================================
	{PawnGameConstant(ITEM_QUALITY0_DESC)}, -- Poor
	{PawnGameConstant(ITEM_QUALITY1_DESC)}, -- Common
	{PawnGameConstant(ITEM_QUALITY2_DESC)}, -- Uncommon
	{PawnGameConstant(ITEM_QUALITY3_DESC)}, -- Rare
	{PawnGameConstant(ITEM_QUALITY4_DESC)}, -- Epic
	{PawnGameConstant(ITEM_QUALITY5_DESC)}, -- Legendary
	{PawnGameConstant(ITEM_QUALITY7_DESC)}, -- Heirloom
	{PawnGameConstant(ITEM_HEROIC)}, -- Heroic (Thrall's Chestguard of Triumph, level 258 version)
	{PawnGameConstant(ITEM_HEROIC_EPIC)}, -- Heroic Epic (Thrall's Chestguard of Triumph, level 258 version, with colorblind mode on)
	{"^" .. ITEM_LEVEL}, -- Item Level 200
	{PawnGameConstant(ITEM_UNSELLABLE)}, -- No sell price
	{PawnGameConstant(ITEM_SOULBOUND)}, -- Soulbound
	{PawnGameConstant(ITEM_BIND_ON_EQUIP)}, -- Binds when equipped
	{PawnGameConstant(ITEM_BIND_ON_PICKUP)}, -- Binds when picked up
	{PawnGameConstant(ITEM_BIND_ON_USE)}, -- Binds when used
	{PawnGameConstant(ITEM_BIND_TO_ACCOUNT)}, -- Binds to account (Polished Spaulders of Valor)
	{"^" .. PawnGameConstantUnwrapped(ITEM_UNIQUE)}, -- Unique; leave off the $ for Unique(20)
	{"^" .. PawnGameConstantUnwrapped(ITEM_BIND_QUEST)}, -- Leave off the $ for MonkeyQuest mod compatibility
	{PawnGameConstant(ITEM_STARTS_QUEST)}, -- This Item Begins a Quest
	{PawnGameConstant(ITEM_CONJURED)}, -- Conjured Item
	{PawnGameConstant(ITEM_PROSPECTABLE)}, -- Prospectable
	{PawnGameConstant(ITEM_MILLABLE)}, -- Millable
	{PawnGameConstant(ITEM_DISENCHANT_NOT_DISENCHANTABLE)}, -- Cannot be disenchanted
	{"^Will receive"}, -- Appears in the trade window when an item is about to be enchanted ("Will receive +8 Stamina")
	{"^Disenchanting requires"}, -- Appears on item tooltips when the Disenchant ability is specified ("Disenchanting requires Enchanting (25)")
	{PawnGameConstant(ITEM_ENCHANT_DISCLAIMER)}, -- Item will not be traded!
	{"^.+ Charges?$"}, -- Brilliant Mana Oil
	{PawnGameConstant(LOCKED)}, -- Locked
	{PawnGameConstant(ENCRYPTED)}, -- Encrypted (Floral Foundations) (does not seem to exist in the game yet)
	{PawnGameConstant(ITEM_SPELL_KNOWN)}, -- Already Known
	{PawnGameConstant(INVTYPE_HEAD)}, -- Head
	{PawnGameConstant(INVTYPE_NECK)}, -- Neck
	{PawnGameConstant(INVTYPE_SHOULDER)}, -- Shoulder
	{PawnGameConstant(INVTYPE_CLOAK), "IsCloth", 1, PawnMultipleStatsFixed}, -- Back (cloaks are cloth even though they don't list it)
	{PawnGameConstant(INVTYPE_ROBE)}, -- Chest
	{PawnGameConstant(INVTYPE_BODY)}, -- Shirt
	{PawnGameConstant(INVTYPE_TABARD)}, -- Tabard
	{PawnGameConstant(INVTYPE_WRIST)}, -- Wrist
	{PawnGameConstant(INVTYPE_HAND)}, -- Hands
	{PawnGameConstant(INVTYPE_WAIST)}, -- Waist
	{PawnGameConstant(INVTYPE_FEET)}, -- Feet
	{PawnGameConstant(INVTYPE_LEGS)}, -- Legs
	{PawnGameConstant(INVTYPE_FINGER)}, -- Finger
	{PawnGameConstant(INVTYPE_TRINKET)}, -- Trinket
	{PawnGameConstant(MAJOR_GLYPH)}, -- Major Glyph
	{PawnGameConstant(MINOR_GLYPH)}, -- Minor Glyph
	{"^装备唯一$"},
	{"^图腾$"},
	{"^圣物$"},
	{"^神像$"},
	{"^圣契$"},
	{"^坐骑$"}, -- 塞纳里奥作战角鹰兽
	{"^职业："},
	{"^种族："},
	{"^需要等级"},
	{"^耐久度"},
	{"^持续时间："},
	{"^冷却时间："},
	{"<.+>"}, -- Made by, Right-click to read, etc. (No ^$; can be prefixed by a color)
	{"^Written by "},
	{"|cff%x%x%x%x%x%xRequires"}, -- Meta gem requirements
	{"^%d+ 容器 .+$"}, -- Bags of all kinds
	{"^.+%(%d+ 秒%)$"}, -- Temporary item buff
	{"^.+%(%d+ 分钟%)$"}, -- Temporary item buff
	{"^附魔要求"}, -- Seen on the enchanter-only ring enchantments when you're not an enchanter, and socketed jewelcrafter-only BoP gems
	
	-- ========================================
	-- Strings that represent statistics that Pawn cares about
	-- ========================================
	{PawnGameConstant(INVTYPE_RANGED), "IsRanged", 1, PawnMultipleStatsFixed}, -- Ranged
	{"^弹药$", "IsRanged", 1, PawnMultipleStatsFixed}, -- Projectile
	{PawnGameConstant(INVTYPE_THROWN), "IsRanged", 1, PawnMultipleStatsFixed}, -- Thrown
	{PawnGameConstant(INVTYPE_WEAPON), "IsOneHand", 1, PawnMultipleStatsFixed}, -- One-Hand
	{PawnGameConstant(INVTYPE_2HWEAPON), "IsTwoHand", 1, PawnMultipleStatsFixed}, -- Two-Hand
	{PawnGameConstant(INVTYPE_WEAPONMAINHAND), "IsMainHand", 1, PawnMultipleStatsFixed}, -- Main Hand
	{PawnGameConstant(INVTYPE_WEAPONOFFHAND), "IsOffHand", 1, PawnMultipleStatsFixed}, -- Off Hand
	{PawnGameConstant(INVTYPE_HOLDABLE)}, -- Held In Off-Hand; no Pawn stat for this
	{"^(%d-) %- (%d-)伤害$", "MinDamage", 1, PawnMultipleStatsExtract, "MaxDamage", 2, PawnMultipleStatsExtract}, -- Standard weapon
	{"^%+?(%d-) %- (%d-) 点火焰伤害$", "MinDamage", 1, PawnMultipleStatsExtract, "MaxDamage", 2, PawnMultipleStatsExtract}, -- Wand
	{"^%+?(%d-) %- (%d-) 点暗影伤害$", "MinDamage", 1, PawnMultipleStatsExtract, "MaxDamage", 2, PawnMultipleStatsExtract}, -- Wand
	{"^%+?(%d-) %- (%d-) 点自然伤害$", "MinDamage", 1, PawnMultipleStatsExtract, "MaxDamage", 2, PawnMultipleStatsExtract}, -- Wand, Thunderfury
	{"^%+?(%d-) %- (%d-) 点奥术伤害$", "MinDamage", 1, PawnMultipleStatsExtract, "MaxDamage", 2, PawnMultipleStatsExtract}, -- Wand
	{"^%+?(%d-) %- (%d-) 点冰霜伤害$", "MinDamage", 1, PawnMultipleStatsExtract, "MaxDamage", 2, PawnMultipleStatsExtract}, -- Wand
	{"^%+?(%d-) %- (%d-) 点神圣伤害$", "MinDamage", 1, PawnMultipleStatsExtract, "MaxDamage", 2, PawnMultipleStatsExtract}, -- Wand, Ashbringer
	{"^%+?(%d-) 武器伤害$", "MinDamage", 1, PawnMultipleStatsExtract, "MaxDamage", 1, PawnMultipleStatsExtract}, -- Weapon enchantments
	{"^装备： %+?(%d-) 武器伤害%。$", "MinDamage", 1, PawnMultipleStatsExtract, "MaxDamage", 1, PawnMultipleStatsExtract}, -- Braided Eternium Chain
	{"^%+?(%d-) 伤害$", "MinDamage", 1, PawnMultipleStatsExtract, "MaxDamage", 1, PawnMultipleStatsExtract}, -- Weapons with no damage range: Crossbow of the Albatross
	{"^瞄准镜 %(%+(%d-) 伤害%)$", "MinDamage", 1, PawnMultipleStatsExtract, "MaxDamage", 1, PawnMultipleStatsExtract}, -- Ranged weapon scopes
	{"^%+?(%d+) [Aa]ll [Ss]tats$", "Strength", 1, PawnMultipleStatsExtract, "Agility", 1, PawnMultipleStatsExtract, "Stamina", 1, PawnMultipleStatsExtract, "Intellect", 1, PawnMultipleStatsExtract, "Spirit", 1, PawnMultipleStatsExtract},
	{"^%+?(%d+) 所有属性$", "Strength", 1, PawnMultipleStatsExtract, "Agility", 1, PawnMultipleStatsExtract, "Stamina", 1, PawnMultipleStatsExtract, "Intellect", 1, PawnMultipleStatsExtract, "Spirit", 1, PawnMultipleStatsExtract}, -- Enchanted Pearl, Enchanted Tear
	{"^%+?(%-?%d+) 力量$", "Strength"},
	{"^潜能$", "Strength", 20, PawnMultipleStatsFixed}, -- weapon enchantment (untested)
	{"^%+?(%-?%d+) 敏捷$", "Agility"},
	{"^%+?(%-?%d+) 耐力$", "Stamina"},
	{"^%+?(%-?%d+) 智力$", "Intellect"}, -- negative Intellect: Kreeg's Mug
	{"^%+?(%-?%d+) 精神$", "Spirit"},
	{"^泰坦神铁武器链$", "HitRating", 28, PawnMultipleStatsFixed}, -- Weapon enchantment; has additional effects
	{"^%+?(%d+)格挡$", "BlockValue"},
	{"^%+(%d+) 格挡值$", "BlockValue"}, -- part of complex warrior helm enchantment
	{"^%+(%d+) 盾牌格挡值$", "BlockValue"}, -- 泰坦神铁护板
	{"^装备： 使你的盾牌格挡值提高(%d+)%。$", "BlockValue"},
	{"^装备： 使你的盾牌格挡值提高(%d+)%点。$", "BlockValue"},
	{"^装备： 使你的格挡等级提高(%d+)%。$", "BlockRating"}, -- 愤怒腰带
	{"^装备： 使你的盾牌格挡等级提高(%d+)%。$", "BlockRating"}, -- Warbringer Chestguard
	{"^%+?(%d+) 格挡等级$", "BlockRating"}, -- Northman's Shield of Blocking
	{"^%+?(%d+) 盾牌格挡等级$", "BlockRating"}, -- enchantment
	{"^装备： 防御等级提高(%d+)%。$", "DefenseRating"}, -- Bulwark of Kings
	{"^防御等级%+(%d)%$", "DefenseRating"},
	{"^%+?(%d+) 防御$", "DefenseRating"}, -- compound paladin enchantment
	{"^%+?(%d+) 防御等级$", "DefenseRating"}, -- Thick Amber; Bloodscale Legguards of Defense
	{"^%+?(%d+) 躲闪等级$", "DodgeRating"}, -- Arctic Ring of Eluding
	{"^装备： 使你的躲闪等级提高(%d+)%。$", "DodgeRating"}, -- Frostwolf Insignia Rank 6
	{"^装备： 使你的招架等级提高(%d+)%。$", "ParryRating"}, -- Draconic Avenger
	{"^%+?(%d+) 招架等级$", "ParryRating"},
	{"^%（每秒伤害([%d%.,]+)）$", "Dps"}, -- Ignore this; DPS is calculated manually
	{"^Adds ([%d%.,]+) damage per second$", "Dps"},
	{"^灼热武器$", "Dps", 4, PawnMultipleStatsFixed}, -- weapon enchantment, 
	{"^装备： 使你的精准等级提高(%d+)%。$", "ExpertiseRating"}, -- Earthwarden
	{"^%+?(%d+) 精准等级$", "ExpertiseRating"}, -- Guardian's Shadow Crystal
	{"^装备： 爆击等级提高(%d+)%。$", "CritRating"},
	{"^装备： 使你的爆击等级提高(%d+)%。$", "CritRating"},
	{"^%+?(%d+) 爆击等级$", "CritRating"}, -- Mantle of Malorne
	{"^%+?(%d+) 爆击等级$", "CritRating"}, -- Enscribed Fire Opal (after normalization)
	{"^%+?(%d+) Critical [Ss]trike [Rr]ating%.?$", "CritRating"}, -- One head enchantment is "20 Critical strike rating." with a dot and lowercase
	{"^瞄准镜 %(%+(%d+) 爆击等级%)$", "CritRating"},
	{"^%+?(%d+) 远程爆击等级$", "CritRating"}, -- Heartseeker Scope (untested); Pawn doesn't distinguish between ranged and hybrid crit rating
	{"^装备： 使你的命中等级提高(%d+)%。$", "HitRating"}, -- Don Julio's Band
	{"^装备： 命中等级提高(%d+)%。$", "HitRating"},
	{"^%+?(%d+) 命中等级$", "HitRating"}, -- 3% hit scope
	{"^稳固$", "HitRating", 10, PawnMultipleStatsFixed}, -- Enchantment (untested); has additional effects
	{"^精确$", "HitRating", 25, PawnMultipleStatsFixed, "CritRating", 25, PawnMultipleStatsFixed}, -- weapon enchantment
	{"^装备： 韧性等级提高(%d+)%。$", "ResilienceRating"},
	{"^%+?(%d+) 韧性等级$", "ResilienceRating"},
	{"^%+?(%d+) 韧性$", "ResilienceRating"},
	{"^Counterweight %(%+(%d+) Haste Rating%)", "HasteRating"},
	{"^装备： 急速等级提高(%d+)%。$", "HasteRating"}, -- Swiftsteel Shoulders
	{"^%+?(%d+) 急速等级$", "HasteRating"}, -- Leggings of the Betrayed
	{"^装备： 使你的精通等级提高(%d+)%.$", "MasteryRating"}, -- Elementium Poleaxe (4.0)
	{"^%+?(%d+) 精通等级$", "MasteryRating"}, -- Fractured Amberjewel (4.0).
	{"^装备： 攻击强度提高(%d+)%点。$", "Ap"},
	{"^%+?(%d+) 攻击强度$", "Ap"},
	{"^%+?(%d+) 远程攻击强度$", "Rap"},
	{"^装备： 远程攻击强度提高(%d+)%点。$", "Rap"},
	{"^装备： 每5秒回复(%d+)点法力值%。$", "Mp5"},
	{"^装备： 每5秒恢复(%d+)点法力值%。$", "Mp5"},
	{"^%+?(%d+) 法力回复$", "Mp5"}, -- Shoulder enchantment, Scryers?
	{"^每5秒回复(%d+)点法力值%。$", "Mp5"},
	{"^%+?(%d+) [mM]ana [pP]er 5 [sS]ec%.?$", "Mp5"}, 
	{"^%+?(%d+) [mM]ana [eE]very 5 [sS]ec%.?$", "Mp5"}, 
	{"^%+?(%d+) [mM]ana [pP]er 5 [sS]econds$", "Mp5"}, -- Royal Shadow Draenite
	{"^%+?(%d+) [mM]ana every 5 [sS]ec%.$", "Mp5"},
	{"^%+?(%d+) [mM]ana every 5 seconds$", "Mp5"},
	{"^%+(%d+) 每5秒回复法力值$", "Mp5"}, -- Magister's armor kit
	{"^装备： 每5秒回复(%d+)点生命值%。$", "Hp5"},
	{"^装备： 每5秒恢复(%d+)点生命值%。$", "Hp5"}, -- Yes, both "every" and "per" are used on items...
	{"^%+?(%d+) [hH]ealth [eE]very 5 [sS]ec%.?$", "Hp5"}, -- Aquamarine Signet of Regeneration
	{"^%+?(%d+) [hH]ealth [pP]er 5 [sS]ec%.?$", "Hp5"}, -- Anglesite Choker of Regeneration
	{"^%+(%d+) 活力$", "Mp5", 1, PawnMultipleStatsExtract, "Hp5", 1, PawnMultipleStatsExtract}, -- Greater Vitality boots enchantment
	{"^%+(%d+) 法力值$", "Mana"}, -- +150 mana enchantment
	{"^%+(%d+) 生命值$", "Health"}, -- +100 health head/leg enchantment
	{"^%+(%d+) 生命值$", "Health"}, -- +150 health enchantment
	{"^(%d+)点护甲$", "AutoArmor"}, -- normal armor
	{"^%+(%d+)护甲值$", "BonusArmor"}, -- cloak armor enchantments
	{"^护甲 %(%+(%d+)%)$", "BonusArmor"}, -- armor kits
	{"^装备： %+(%d+)护甲。$", "BonusArmor"}, -- paladin Royal Seal of Eldre'Thalas
	{"^装备： 法术强度提高(%d+)%点。$", "SpellPower"}, -- Overlaid Chain Spaulders
	{"^%+?(%d+) 法术强度$", "SpellPower"}, -- Reckless Monarch Topaz
	{"^装备： 护甲穿透等级提高(%d+)%。$", "ArmorPenetration"}, -- Onslaught Breastplate, Vereesa's Silver Chain Belt
	{"^装备： 使你的护甲穿透等级提高(%d+)%。$", "ArmorPenetration"}, -- Argent Skeleton Crusher
	{"^%+?(%d+) 护甲穿透等级$", "ArmorPenetration"}, -- Fractured Scarlet Ruby
	{"^装备： 使你的法术穿透提高(%d+)%。$", "SpellPenetration"}, -- Frostfire Robe
	{"^%+?(%d+) 法术穿透$", "SpellPenetration"}, -- Radiant Talasite
	{"^%+(%d+) 火焰伤害$", "FireSpellDamage"},
	{"^%+(%d+) 火焰法术伤害$", "FireSpellDamage"},
	{"^装备： 提高火焰法术和效果所造成的伤害，最多(%d+)%点。$", "FireSpellDamage"},
	{"^Equip: Increases fire spell power by (%d+)%.$", "FireSpellDamage"},
	{"^%+(%d+) 暗影伤害$", "ShadowSpellDamage"},
	{"^%+(%d+) 暗影法术伤害$", "ShadowSpellDamage"},
	{"^装备： 提高暗影法术和效果所造成的伤害，最多(%d+)%点。$", "ShadowSpellDamage"},
	{"^Equip: Increases shadow spell power by (%d+)%.$", "FrostSpellDamage"}, -- Frozen Shadoweave Shoulders
	{"^%+(%d+) 自然伤害$", "NatureSpellDamage"}, -- Netherstalker Legguards of Nature's Wrath
	{"^%+(%d+) 自然法术伤害$", "NatureSpellDamage"},
	{"^装备： 提高自然法术和效果所造成的伤害，最多(%d+)%点。$", "NatureSpellDamage"},
	{"^Equip: Increases nature spell power by (%d+)%.$", "NatureSpellDamage"},
	{"^%+(%d+) 奥术伤害$", "ArcaneSpellDamage"},
	{"^%+(%d+) 奥术法术伤害$", "ArcaneSpellDamage"}, -- Dragon Finger of Arcane Wrath
	{"^装备： 提高火焰法术和效果所造成的伤害，最多(%d+)%点。$", "ArcaneSpellDamage"},
	{"^Equip: Increases arcane spell power by (%d+)%.$", "ArcaneSpellDamage"},
	{"^%+(%d+) 冰霜伤害$", "FrostSpellDamage"},
	{"^%+(%d+) 冰霜法术伤害$", "FrostSpellDamage"}, -- enchantment
	{"^装备： 提高火焰法术和效果所造成的伤害，最多(%d+)%点。$", "FrostSpellDamage"},
	{"^Equip: Increases frost spell power by (%d+)%.$", "FrostSpellDamage"}, -- Frozen Shadoweave Shoulders
	{"^%+(%d+) 神圣伤害$", "HolySpellDamage"},
	{"^%+(%d+) 神圣法术伤害$", "HolySpellDamage"},
	{"^Equip: Increases damage done by Holy spells and effects by up to (%d+)%.$", "HolySpellDamage"}, -- Lightforged Blade
	{"^Equip: Increases the damage done by Holy spells and effects by up to (%d+)%.$", "HolySpellDamage"}, -- Drape of the Righteous
	{"^Equip: Increases holy spell power by (%d+)%.$", "HolySpellDamage"},
	{"^%+?(%d+) 所有抗性$", "AllResist"},
	{"^%+?(%d+) 所有抗性$", "AllResist"}, -- Prismatic Sphere
	{"^%+?(%d+) 火焰抗性$", "FireResist"},
	{"^%+?(%d+) 暗影抗性$", "ShadowResist"},
	{"^%+?(%d+) 自然抗性$", "NatureResist"},
	{"^%+?(%d+) 奥术抗性$", "ArcaneResist"},
	{"^%+?(%d+) 冰霜抗性$", "FrostResist"},
	{"^红色插槽$", "RedSocket", 1, PawnMultipleStatsFixed},
	{"^黄色插槽$", "YellowSocket", 1, PawnMultipleStatsFixed},
	{"^蓝色插槽$", "BlueSocket", 1, PawnMultipleStatsFixed},
	{"^棱彩插槽$", "PrismaticSocket", 1, PawnMultipleStatsFixed}, -- Prismatic / colorless sockets are added by blacksmithing
	{"^多彩插槽$", "MetaSocket", 1, PawnMultipleStatsFixed},
	{"^\"只能镶嵌多彩宝石%.\"$", "MetaSocketEffect", 1, PawnMultipleStatsFixed}, -- Actual meta gems, not the socket

	-- ========================================
	-- Rare strings that are ignored (common ones are at the top of the file)
	-- ========================================
	{'^"'}, -- Flavor text
	{"^在猎豹、熊、巨熊和枭兽形态下的攻击强度提高(%d+)%点。$"}, -- Shows up on weapons for druids
	{"^奥特兰克山谷$"}, -- Stormpike Soldier's Blood
	{"^黑石深渊$"}, -- Dark Brewmaiden's Brew
	{"^刀锋山$"}, -- Felsworn Gas Mask
	{"^黑暗神庙$"}, -- Naj'entus Spine
	{"^厄运之槌$"}, -- Gordok Courtyard Key
	{"^灰熊丘陵$"}, -- Element 115
	{"^海加尔山$"}, -- Tears of the Goddess
	{"^冰冠堡垒$"}, -- (Argent Tournament dailies)
	{"^卡拉赞$"}, -- Torment of the Worgen
	{"^旧希尔斯布莱德丘陵$"}, -- Pack of Incendiary Bombs
	{"^毒蛇神殿$"}, -- Tainted Core
	{"^影月谷$"}, -- Enchanted Illidari Tabard
	{"^斯塔索姆$"}, -- Andonisus, Reaper of Souls
	{"^风暴要塞$"}, -- Cosmic Infuser
	{"^逃离墩霍尔德$"}, -- Pack of Incendiary Bombs
	{"^黑色沼泽$"}, -- Chrono-beacon
	{"^冬拥湖$"}, -- Inflatable Land Mines
	{"^祖阿曼$"}, -- Amani Hex Stick
}

-- These regexes work exactly the same as PawnRegexes, but they're used to parse the right side of tooltips.
-- Unrecognized stats on the right side are always ignored.
-- Two-handed Axes, Maces, and Swords will have their stats converted to the 2H version later.
PawnRightHandRegexes =
{
	{"^速度 ([%d%.,]+)$", "Speed"},
	{"^箭$", "IsBow", 1, PawnMultipleStatsFixed},
	{"^斧$", "IsAxe", 1, PawnMultipleStatsFixed},
	{"^弓$", "IsBow", 1, PawnMultipleStatsFixed},
	{"^子弹$", "IsGun", 1, PawnMultipleStatsFixed},
	{"^弩$", "IsCrossbow", 1, PawnMultipleStatsFixed},
	{"^匕首$", "IsDagger", 1, PawnMultipleStatsFixed},
	{"^拳套$", "IsFist", 1, PawnMultipleStatsFixed},
	{"^枪械$", "IsGun", 1, PawnMultipleStatsFixed},
	{"^锤$", "IsMace", 1, PawnMultipleStatsFixed},
	{"^长柄武器$", "IsPolearm", 1, PawnMultipleStatsFixed},
	{"^法杖$", "IsStaff", 1, PawnMultipleStatsFixed},
	{"^剑$", "IsSword", 1, PawnMultipleStatsFixed},
	{"^投掷武器$", "IsThrown", 1, PawnMultipleStatsFixed},
	{"^魔杖$", "IsWand", 1, PawnMultipleStatsFixed},
	{"^布甲$", "IsCloth", 1, PawnMultipleStatsFixed},
	{"^皮甲$", "IsLeather", 1, PawnMultipleStatsFixed},
	{"^锁甲$", "IsMail", 1, PawnMultipleStatsFixed},
	{"^板甲$", "IsPlate", 1, PawnMultipleStatsFixed},
	{"^盾牌$", "IsShield", 1, PawnMultipleStatsFixed},
}