import os, shutil
SRC = r'E:\缓存\WOW\AddOns'
PACK = r'E:\缓存\WOW\wow-playerbot-server\deliverables\addons-pack\Interface\AddOns'

remove = [
 'Questie','Recount','Omen',
 'WeakAuras','WeakAurasModelPaths','WeakAurasOptions','WeakAurasTutorials',
 'AtlasLoot','AtlasLootFu','AtlasLoot_BurningCrusade','AtlasLoot_Crafting',
 'AtlasLoot_OriginalWoW','AtlasLoot_WorldEvents','AtlasLoot_WrathoftheLichKing',
 'PostalEnhanced','Bartender4',
 'Bagnon','Bagnon_Config','Bagnon_Forever','Bagnon_GuildBank','Bagnon_Tooltips',
]
for r in remove:
    p=os.path.join(PACK,r)
    if os.path.isdir(p):
        shutil.rmtree(p); print('REMOVED', r)

copy_folders = [
 'Questie-335',
 'DBM-Core','DBM-GUI','DBM-StatusBarTimers','DBM-SpellTimers','DBM-VPVV',
 'DBM-ChamberOfAspects','DBM-Coliseum','DBM-EyeOfEternity','DBM-Gruul','DBM-Hyjal',
 'DBM-Icecrown','DBM-Karazhan','DBM-Magtheridon','DBM-MC','DBM-Naxx','DBM-Onyxia',
 'DBM-Outland','DBM-Party-BC','DBM-Party-Classic','DBM-Party-WotLK','DBM-PvP',
 'DBM-Serpentshrine','DBM-Sunwell','DBM-TheEye','DBM-Ulduar','DBM-VoA','DBM-WorldEvents',
 'DBM-ZG','DBM-ZulAman',
 'Details','Omen','WeakAuras','WeakAurasArchive','WeakAurasModelPaths','WeakAurasOptions',
 'Atlas','Atlas_DungeonLocs','Atlas_OutdoorRaids','AtlasLoot','AtlasLoot_BurningCrusade',
 'AtlasLoot_Crafting','AtlasLoot_OriginalWoW','AtlasLoot_WorldEvents','AtlasLoot_WrathoftheLichKing',
 'AtlasLootFu','AtlasQuest',
 'Auctionator','Postal','Pawn','ZygorTalentAdvisor','BlizzMove',
 'ElvUI','ElvUI_AddOnSkins','ElvUI_AuraBarsMovers','ElvUI_CustomMedia','ElvUI_CustomTags',
 'ElvUI_DataTextColors','ElvUI_Enhanced','ElvUI_EnhancedFriendsList','ElvUI_ExtraActionBars',
 'ElvUI_ImprovedSpecSwitch','ElvUI_LocPlus','ElvUI_OptionsUI','ElvUI_ProjectZidras',
 'ElvUI_SwingBar','ElvUI_VisualProcs',
 'LFGForwarder','Decursive','_NPCScan','Immersion','ImprovedLootFrame','MBB','Mendeleev',
 'YssBossLoot','SimpleRaidTargetIcons',
 'Duowan','LearningAid','NPCMark','RatingSummary','TheBurningTrade','RangeDisplay',
]
copied=0
for f in copy_folders:
    s=os.path.join(SRC,f); d=os.path.join(PACK,f)
    if not os.path.isdir(s):
        print('MISSING SOURCE', f); continue
    if os.path.isdir(d): shutil.rmtree(d)
    shutil.copytree(s,d); copied+=1
print('COPIED', copied, 'folders from local')
print('FINAL PACK FOLDERS:', len([x for x in os.listdir(PACK) if os.path.isdir(os.path.join(PACK,x))]))
