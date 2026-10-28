import os, re, sys
SRC = r'E:\缓存\WOW\AddOns'
copy_folders = [
 # Questie
 'Questie-335',
 # DBM family
 'DBM-Core','DBM-GUI','DBM-StatusBarTimers','DBM-SpellTimers','DBM-VPVV',
 'DBM-ChamberOfAspects','DBM-Coliseum','DBM-EyeOfEternity','DBM-Gruul','DBM-Hyjal',
 'DBM-Icecrown','DBM-Karazhan','DBM-Magtheridon','DBM-MC','DBM-Naxx','DBM-Onyxia',
 'DBM-Outland','DBM-Party-BC','DBM-Party-Classic','DBM-Party-WotLK','DBM-PvP',
 'DBM-Serpentshrine','DBM-Sunwell','DBM-TheEye','DBM-Ulduar','DBM-VoA','DBM-WorldEvents',
 'DBM-ZG','DBM-ZulAman',
 # combat / threat / auras
 'Details','Omen','WeakAuras','WeakAurasArchive','WeakAurasModelPaths','WeakAurasOptions',
 # Atlas family
 'Atlas','Atlas_DungeonLocs','Atlas_OutdoorRaids','AtlasLoot','AtlasLoot_BurningCrusade',
 'AtlasLoot_Crafting','AtlasLoot_OriginalWoW','AtlasLoot_WorldEvents','AtlasLoot_WrathoftheLichKing',
 'AtlasLootFu','AtlasQuest',
 # misc
 'Auctionator','Postal','Pawn','ZygorTalentAdvisor','BlizzMove',
 # ElvUI family
 'ElvUI','ElvUI_AddOnSkins','ElvUI_AuraBarsMovers','ElvUI_CustomMedia','ElvUI_CustomTags',
 'ElvUI_DataTextColors','ElvUI_Enhanced','ElvUI_EnhancedFriendsList','ElvUI_ExtraActionBars',
 'ElvUI_ImprovedSpecSwitch','ElvUI_LocPlus','ElvUI_OptionsUI','ElvUI_ProjectZidras',
 'ElvUI_SwingBar','ElvUI_VisualProcs',
 # quality of life
 'LFGForwarder','Decursive','_NPCScan','Immersion','ImprovedLootFrame','MBB','Mendeleev',
 'YssBossLoot','SimpleRaidTargetIcons',
 # Duowan family
 'Duowan','LearningAid','NPCMark','RatingSummary','TheBurningTrade','RangeDisplay',
]
report=[]
for f in copy_folders:
    d=os.path.join(SRC,f)
    if not os.path.isdir(d):
        report.append((f,'MISSING','')); continue
    tocs=[x for x in os.listdir(d) if x.lower().endswith('.toc')]
    # prefer exact <folder>.toc
    primary=None
    if f+'.toc' in tocs: primary=f+'.toc'
    elif tocs: primary=sorted(tocs)[0]
    if not primary:
        report.append((f,'NO_TOC',str(tocs))); continue
    txt=open(os.path.join(d,primary),encoding='utf-8-sig').read()
    m=re.search(r'##\s*Interface:\s*([0-9, ]+)', txt)
    v=re.search(r'##\s*Version:\s*(.*)',txt)
    a=re.search(r'##\s*Author:\s*(.*)',txt)
    iface=m.group(1).strip() if m else '??'
    ok = any(x.strip() in ('30300','30400') for x in iface.split(','))
    report.append((f, primary, iface, 'OK' if ok else 'BAD', (v.group(1).strip() if v else ''), (a.group(1).strip()[:30] if a else '')))
for r in report:
    print(' | '.join(str(x) for x in r))
print('TOTAL', len(report))
