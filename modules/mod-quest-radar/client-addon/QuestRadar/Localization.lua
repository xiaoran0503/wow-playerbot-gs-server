-- QuestRadar - Localization.lua
--
-- 中文（简体）语言包。
--
-- 用法的原则只有一条：界面文字一律走 L["原文"]，不再直接写死在控件上。
-- 原文（插件自带的法语/英语叫法）就是查表的键，所以：
--   * 想改某个说法，只改这个文件，不用碰逻辑代码；
--   * 查不到的键会被 __index 原样返回，界面最坏情况是显示原文，
--     绝不会出现空白或报错（这是"汉化后不显示"最常见的成因）。
--
-- 文件本身必须是 UTF-8 无 BOM；有 BOM 客户端会报 "unexpected symbol"。

local L = {}

--------------------------------------------------------------------------------
-- 选项面板（Esc > 界面 > 插件 > QuestRadar）
--------------------------------------------------------------------------------

L["Objectifs de quete sur le minimap. Ces reglages sont aussi accessibles via /qr."] =
    "小地图上的任务目标标记。这些设置也可以用 /qr 命令调整。"

L["Activer QuestRadar"] = "启用 QuestRadar"
L["Affiche ou masque completement les icones d'objectifs."] =
    "完全显示或隐藏任务目标图标。"

L["Limiter aux quetes suivies"] = "只显示已追踪的任务"
L["N'affiche que les quetes cochees dans le suivi d'objectifs. Decoche, affiche toutes les quetes de la zone."] =
    "只显示任务追踪栏里已勾选的任务；取消勾选后显示本区域的全部任务。"

L["Afficher les quetes terminees"] = "显示已完成的任务"
L["Affiche l'icone de rendu (?) pour les quetes pretes a etre rendues."] =
    "对已经可以交的任务显示交任务图标（?）。"

L["Afficher les objectifs hors de portee"] = "显示视野外的目标"
L["Les objectifs trop loin se collent au bord du minimap, legerement attenues."] =
    "距离过远的目标会贴在小地图边缘显示，并略微变淡。"

L["Utiliser le module serveur si present"] = "使用服务端模块（如已安装）"
L["Avec le module mod-quest-radar sur le royaume : une icone par objectif au lieu d'une par quete. Sans lui, aucun effet."] =
    "服务器装有 mod-quest-radar 模块时：每个任务目标显示一个图标，而不是每个任务一个。没装这个模块时此项没有任何作用。"

L["Taille des icones : %.1f"] = "图标大小：%.1f"

--------------------------------------------------------------------------------
-- 聊天框提示（/qr 系列命令）
--------------------------------------------------------------------------------

L["|cffff4040!Astrolabe introuvable|r - Interface\\AddOns\\!Astrolabe doit etre present et active."] =
    "|cffff4040找不到 !Astrolabe 库|r - 需要把 !Astrolabe 放到 Interface\\AddOns\\ 下并启用。"

-- /qr status
L["actif="]            = "已启用="
L["absent"]            = "缺失"
L["echelle="]          = "缩放="
L["carte: continent="] = "地图：大陆="
L[" zone="]            = " 区域="
L["quetes="]           = "任务数="
L["objectifs annonces="] = " 下发目标="
L["icones placees="]   = " 已放置图标="
L["filtre="]           = " 筛选="
L["quetes suivies"]    = "仅已追踪"
L["toutes"]            = "全部"
L["source="]           = "来源="
L["module serveur="]   = " 服务端模块="
L["desactive"]         = "已关闭"
L["detecte"]           = "已检测到"
L["pas de reponse"]    = "无响应"
L["client"]            = "客户端"
L["module"]            = "服务端模块"

L["0 POI: si la carte du monde n affiche pas non plus de pastilles numerotees, "] =
    "0 个目标点：如果打开世界地图也看不到带编号的圆点，"
L["la table quest_poi du monde est vide cote serveur."] =
    "说明服务端的 quest_poi 表是空的。"

-- /qr on|off
L["active."]   = "已启用。"
L["desactive."] = "已关闭。"

-- /qr completed
L["quetes terminees: "] = "已完成任务："
L["affichees"]         = "显示"
L["masquees"]          = "隐藏"

-- /qr tracked
L["seules les quetes suivies sont affichees"] = "现在只显示已追踪的任务"
L["toutes les quetes de la zone sont affichees"] = "现在显示本区域的全部任务"

-- /qr module
L["module serveur: "]   = "服务端模块："
L["utilise si present"] = "已安装则使用"
L["ignore"]             = "忽略"

-- /qr edge
L["objectifs hors de portee (colles au bord): "] = "视野外目标（贴在边缘）："
L["affiches"] = "显示"
L["masques"]  = "隐藏"

-- /qr scale
L["echelle des icones = "] = "图标缩放 = "
L["echelle: une valeur entre 0.5 et 3"] = "缩放：请填 0.5 到 3 之间的数值"

-- 命令帮助。命令关键字本身必须保持英文，客户端只认英文关键字。
L["/qr [on|off] | status | tracked | completed | edge | module | scale <0.5-3>"] =
    "/qr [on|off] | status | tracked | completed | edge | module | scale <0.5-3>（命令关键字请保持英文）"

--------------------------------------------------------------------------------

-- 查不到就返回键本身（原文），界面永远不会变空。
setmetatable(L, { __index = function (_, key) return key end })

QuestRadar = QuestRadar or {}
QuestRadar.L = L
