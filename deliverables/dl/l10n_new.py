import os, re
PACK=r'E:\缓存\WOW\wow-playerbot-server\deliverables\addons-pack\Interface\AddOns'
new=['Bagnon','Bagnon_Config','Bagnon_Forever','Quartz','TidyPlates','TidyPlates_ThreatPlates',
 'Details','Details_3DModelsPaths','Details_ChartViewer','Details_DataStorage','Details_DeathGraphs',
 'Details_EncounterDetails','Details_SunderCount','Details_TimeLine','Details_TinyThreat',
 'Clique','SnowfallKeyPress','Grid','TradeskillInfo','TradeskillInfoUI','GatherMate','GatherMate_Data',
 'RatingBuster','EventAlert','pw_lossofcontrol','!BugGrabber','BugSack','CombatAlert',
 'MikScrollingBattleText','MSBTOptions','SuperDuperMacro','WhisperPop','Titan','ExtVendor',
 'MerchantAssist','oRA3','TrinketMenu','tdCooldown2','SpellTimer','Accountant_Classic',
 'oRA2','oRA2_Leader','oRA2_Optional','oRA2_Participant','RaidAlerter','RepairHelper','SellerHelper',
 'QuickLoot','MailMod','Combuctor','Combuctor_Config','Combuctor_Sets','SpellID','MobAggro',
 'GridClickSets','GridManaBars','GridStatusHots','GridStatusRaidDebuff','GridStatusRaidIconMod','GridStatusRD_WotLK']
for a in new:
    d=os.path.join(PACK,a)
    if not os.path.isdir(d): print(a,'MISSING'); continue
    zh=[]; libs=False
    for root,_,files in os.walk(d):
        for f in files:
            fl=f.lower()
            if 'zhcn' in fl: zh.append(f)
            if fl in ('libstub.lua','aceaddon-3.0.lua'): libs=True
    # toc zhCN reference
    tocs=[x for x in os.listdir(d) if x.lower().endswith('.toc')]
    toc_zh=any('zhCN' in open(os.path.join(d,t),encoding='utf-8-sig',errors='ignore').read() for t in tocs)
    print(f"{a:28} zhCNfiles={len(zh):2} toc_zhCN={'Y' if toc_zh else '-':1}")
