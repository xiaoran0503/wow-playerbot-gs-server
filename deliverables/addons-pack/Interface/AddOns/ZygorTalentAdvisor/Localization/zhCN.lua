if GetLocale()~="zhCN" then return end

local COLOR_TIP_MOUSE = "|cffeedd99"
ZygorTalentAdvisor_L("main", "zhCN", function() return {
	['name'] = "|cffffff88Z|cffffee66y|cffffdd44g|cffffcc22o|cffffbb00r|r |cffffaa00天赋顾问|r",
	['name_plain'] = "Zygor天赋顾问",
	['desc'] = "建议您在每个等级上投入哪些天赋点，以便您最优化地进行升级。",

	['opt_build_header'] = "玩家天赋",
	['opt_build'] = "选择一个天赋方案：",
	['opt_build_desc'] = "随着进展，顾问将继续建议您选择天赋，以确保该天赋方案最适合您。",
	['opt_petbuild_header'] = "宠物天赋",
	['opt_petbuild'] = "选择一个宠物天赋方案：",
	['opt_petbuild_desc'] = "为您当前的宠物选择一个天赋方案。请注意宠物类型不同，您必须选择适合的天赋方案。",
	['opt_build_none'] = "|cffbbbbbb没有目标天赋方案",
	['opt_force'] = "允许该方案",
	['opt_force_desc'] = "允许该天赋方案。默认情况下，最好避免组合不兼容或损坏的天赋方案。通过强制选择，您将自行对结果负责——您可能会得到一个荒谬的天赋方案。",
	['opt_talentframe'] = "天赋界面特色",
	['opt_hints'] = "显示建议气泡",
	['opt_hints_desc'] = "显示建议的天赋升级气泡：\n|cff00ff00+1|r ... |cff00ff00+5|r - 将该天赋提升#点，\n|cffffff00V|r - 天赋已正确升级，\n|cffff0000X|r - 天赋超出推荐等级，请将其移除点数，否则将破坏天赋方案。",
	['opt_preview'] = "显示目标天赋等级",
	['opt_preview_desc'] = "根据选择的天赋方案，将最终的天赋等级显示为天赋等级框中的数字：\n|cff00ff000|cff888888/|cff0088ff2|r - 将该天赋升级至2级，\n|cff00ff002|cff888888/|cff00ff002|r - 达到建议等级，\n|cffffdd003|cff888888/|cffff00002|r - 您已超出建议等级（除非您处于预览模式）。",
	['opt_popup'] = "当有新的天赋点可用时该怎么办？",
	['opt_popup_desc'] = "天赋顾问可以弹出您的天赋界面或其自己的建议窗口，每当有可用的天赋点时，甚至可以自动学习建议的天赋。",
	['opt_popup_0'] = "无",
	['opt_popup_1'] = "打开天赋界面 |cffaaaaaa（手动学习）|r",
	['opt_popup_2'] = "打开建议窗口 |cffaaaaaa（一键学习）|r",
	['opt_popup_3'] = "自动学习 |cffffdd00（谨慎！）|r",
	['opt_popup_dock'] = "将建议窗口停靠到天赋界面上",
	['opt_popup_dock_desc'] = "当停靠时，建议窗口将随着天赋界面一起出现和消失。\n当不停靠时，它会独立显示并可以移动到任何地方。\n注意：您可以将建议窗口拖出天赋界面的一侧来取消停靠，或者再次将其停靠回去。",


	['opt_petbuild_ferocity'] = "|cffff8888凶暴|r",
	['opt_petbuild_tenacity'] = "|cffffff88坚韧|r",
	['opt_petbuild_cunning'] = "|cffff88ff狡诈|r",

	['status_badtalent0'] = "您已在天赋“%s”中花费了%d点天赋点，而在选择的天赋方案中并未使用该天赋。",
	['status_badtalent'] = "您已在天赋“%s”中花费了%d点天赋点，而在选择的天赋方案中该天赋只达到了%d级。",
	['status_oootalent'] = "您的天赋“%s”目前处于%d级，而不是%d级。",

	['status_green'] = "此天赋方案适合您的角色|cff88ff88正确|r。",
	['status_green_pet'] = "此天赋方案适合您的宠物|cff88ff88正确|r。",
	['status_yellow'] = "您当前的天赋与所选的天赋方案匹配，只是|cffeeff44顺序不对|r。您有足够的天赋点来继续该方案。",
	['status_orange'] = "|cffffbb00警告：|r 您当前的天赋与所选的天赋方案匹配，但是|cffffee44顺序不对|r，您还需要%d个天赋点才能再次优化天赋方案。",
	['status_red'] = "|cffff0000错误：|r 此天赋方案与您当前的天赋|cffff5555不匹配|r。如果您想使用该方案，请重置天赋，或者勾选“允许该方案”选项以覆盖安全措施。",
	['status_red_forced'] = "|cffff0000警告：|r 此天赋方案与您当前的天赋|cffff5555不匹配|r，但是我们将尽力使其达到最佳状态。",
	['status_black_nopet'] = "|cffff0000错误：|r 您没有激活宠物。无法使用宠物天赋方案。",
	['status_black_badpet'] = "|cffff0000错误：|r 此天赋方案与%s不兼容。请选择%s类型的天赋方案，或者更换您的宠物。",
	['status_black_badblizzard'] = "此天赋方案包含损坏的暴雪式数据。",
	['status_black_brokenbuild'] = "|cffff0000错误：|r |cffffaaaa此天赋方案包含无法识别的天赋。它已损坏，无法使用。|r\n%s",
	['status_black_builderror'] = "|cffff0000错误：|r |cffffaaaa此天赋方案需要在天赋“%s”中花费%d点天赋点，而实际只有%d点！它已损坏，无法使用。|r",
	['status_black_smallbuild'] = "|cffff0000错误：|r 此天赋方案中只有%d个天赋，而您已经花费了%d个天赋点。该方案要么不完整，要么是“起始”方案，不再适用。",
	['status_black_complete'] = "此天赋方案已完成。\n继续前进，变得更强大吧。",
	['status_black_different'] = "这是一个不同的天赋方案，但是您的角色天赋方案已经完成。\n要切换到此方案，您需要重置天赋或使用双天赋。",
	['status_black_exceeded'] = "您的投资天赋点数超过了该天赋方案的总点数。\n这要么是一个“起始”方案，要么是一个不完整的方案。",

	-- popout
	['preview_button'] = "预览",
	['preview_button_done'] = "已预览",
	['preview_button_tooltip'] = "点击使用天赋预览模式，预览建议的天赋。",
	['learn_button_tooltip'] = "点击接受建议的天赋。",
	['configure_button'] = "配置",
	['configure_button_tooltip'] = "点击设置目标天赋方案或配置天赋顾问。",

	['window_header_buildlabel'] = "天赋方案：",
	['window_header_build'] = "|cffffffff%s|r",
	['window_header_buildnone'] = "无",

	['window_suggestion_nobuild'] = "点击下面的“配置”按钮设置目标天赋方案。",
	['window_suggestion_normal'] = "建议天赋：",
	['window_suggestion_none'] = "目前无法提供建议。",
	['window_suggestion_nopoints'] = "您没有可用的天赋点。",
	['window_status_orange'] = "警告：您偏离了建议的天赋方案路径！|n您需要比现有天赋点数多%d点。",
	['window_status_red'] = "警告：该天赋方案与您的天赋|cffff7777不兼容|r。",

	--[[
	['window_suggheader1_normal'] = "You have %d talent point(s) available!",
	['window_suggheader1_normal_pet'] = "Your pet has %d talent point(s) available!",
	['window_suggintro_normal'] = "Zygor Talent Advisor suggests that you take the following talent:",

	['window_header_preview'] = "You have %d talent point(s) available!",
	['window_header_preview_pet'] = "Your pet has %d talent point(s) available!",
	['window_intro_preview'] = "Zygor Talent Advisor suggests that you take the following talent:",

	['window_headerdone_preview'] = "All talent points assigned!",
	['window_introdone_preview'] = "Since you're using the talent preview mode, click below to learn your new talents.",

	['window_headernone'] = "You have no talent points available.",
	['window_headernone_pet'] = "Your pet has no talent points available.",
	--]]

	['warning_learn1_orange'] = "|cffffbb00注意：|r\n对于所选的天赋方案“|cff5588ff%s|r”，建议您在此时学习|cffffff55%s|r天赋。\n您选择的天赋的确包含在该方案中，但目前并不推荐在此时学习。按顺序学习天赋可能导致不太理想的进展。\n您确定要现在学习|cffff5555%s|r吗？",
	['warning_learn1_red0'] = "|cffff0000警告！|r\n对于所选的天赋方案“|cff5588ff%s|r”，您应该|cffff7777永远不要|r学习这个天赋！\nZygor天赋顾问将无法再帮助您完成此方案。\n您确定要学习它吗？",
	['warning_learn1_red'] = "|cffff0000警告！|r\n对于所选的天赋方案“|cff5588ff%s|r”，您应该|cffff7777永远不要|r超过%s级的|cffffff55%s|r天赋。\nZygor天赋顾问将无法再帮助您完成此方案。\n您确定要这样做吗？",
	['warning_preview_green'] = CONFIRM_LEARN_PREVIEW_TALENTS.."|n\n|cff00ff00注意：|r这些天赋与“|cff5588ff%s|r”方案计划完全匹配，可以安全学习。",
	['warning_preview_orange'] = "|cffffbb00注意：|r预览中选择的天赋与所选的天赋方案“|cff5588ff%s|r”的建议天赋不完全匹配。\n如果您学习它们，您将不得不再获得%d |1个天赋点；更多天赋点；以继续执行该方案计划。\n您确定要学习所选择的天赋吗？",
	['warning_preview_red'] = "|cffff0000警告！|r预览中选择的天赋|cffff7777将阻止您|r完成所选的天赋方案“|cff5588ff%s|r”。\nZygor天赋顾问将无法再帮助您完成此方案。\n您确定要学习它们吗？",

	['warning_bulklearn'] = "|cffffff88Z|cffffee66y|cffffdd44g|cffffcc22o|cffffbb00r|r |cffffaa00天赋顾问|r为所选的天赋方案“|cff5588ff%s|r”建议以下天赋：\n\n%s\n"..CONFIRM_LEARN_PREVIEW_TALENTS,

	['tutorial_ZTA1_title'] = "Zygor天赋顾问：基础知识",
	['tutorial_ZTA1_text'] = "您选择的天赋对《魔兽世界》中的角色是至关重要的。然而，了解在早期应该专注哪些天赋，并将哪些留到以后同样重要。\n\nZygor天赋顾问可以逐级指导您，以实现特别优化的天赋方案。",
	['tutorial_ZTA2_title'] = "Zygor天赋顾问：天赋时间",
	['tutorial_ZTA_text'] = "您有可用的天赋点数，但您尚未选择天赋方案。您可以在选项 - 界面 - 插件 - Zygor天赋顾问中找到天赋设置。",
	['tutorial_ZTA3_title'] = "Zygor天赋顾问：建议",
	['tutorial_ZTA3_text'] = "您有可用的天赋点数，顾问为您提供了如何花费它们的建议。打开天赋窗口（按“N”键）并查看提示气泡：|cff55ff55+1|r，|cff55ff55+2|r，等等。",

	['minimap_tooltip'] = COLOR_TIP_MOUSE.."点击|r显示天赋建议\n"..COLOR_TIP_MOUSE.."右键点击|r配置",
	['minimap_tooltip_hunter'] = COLOR_TIP_MOUSE.."点击|r显示天赋建议\n"..COLOR_TIP_MOUSE.."按住Shift点击|r显示宠物天赋建议\n"..COLOR_TIP_MOUSE.."右键点击|r配置",

	['opt_mapbutton'] = "显示小地图按钮",
	['opt_mapbutton_desc'] = "在小地图旁显示Zygor天赋顾问按钮",

	['pattern_talentgained'] = "^您获得了（%d）点天赋点",
	['pattern_talentgained_pet'] = "^您的宠物学会了一个新的天赋",

	['error_bulklearn_nobuild'] = "您尚未选择天赋方案。",
	['error_bulklearn_nosuggestion'] = "目前无法提供建议。",

	['msg_learned'] = "已学习建议的天赋。",
	['msg_learned_verbose'] = "已学习建议的天赋：",
	['msg_learned_verbose_talent'] = "  %s",

	['opt_report'] = "创建错误报告",
	['opt_report_desc'] = "为调试目的创建该插件的当前状态的详细报告。",

	['talenttooltip'] = "“|cff5588ff%s|r”方案的等级：  %s",

	['popout_button_tip'] = "选择一个目标天赋方案，并让顾问为您建议天赋，无论何时您有可用的天赋点数。",

	['binding_popout'] = "显示建议窗口",

	['glyphtype_1'] = "主要 ",
	['glyphtype_2'] = "次要 ",
} end)
