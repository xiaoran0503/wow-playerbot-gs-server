import os, shutil, re
PACK=r'E:\缓存\WOW\wow-playerbot-server\deliverables\addons-pack\Interface\AddOns'
DW=r'E:\缓存\WOW\AddOns多玩\AddOns多玩'
BF=r'E:\缓存\WOW\Addons大脚\Addons大脚'

duowan=['Bagnon','Bagnon_Config','Bagnon_Forever','Quartz','TidyPlates','TidyPlates_ThreatPlates',
 'Details','Details_3DModelsPaths','Details_ChartViewer','Details_DataStorage','Details_DeathGraphs',
 'Details_EncounterDetails','Details_SunderCount','Details_TimeLine','Details_TinyThreat',
 'Clique','SnowfallKeyPress','Grid','TradeskillInfo','TradeskillInfoUI','GatherMate','GatherMate_Data',
 'RatingBuster','EventAlert','pw_lossofcontrol','!BugGrabber','BugSack','CombatAlert',
 'MikScrollingBattleText','MSBTOptions','SuperDuperMacro','WhisperPop','Titan','ExtVendor',
 'MerchantAssist','oRA3','TrinketMenu','tdCooldown2','SpellTimer','Accountant_Classic']

bigfoot=['oRA2','oRA2_Leader','oRA2_Optional','oRA2_Participant','RaidAlerter','RepairHelper','SellerHelper',
 'QuickLoot','MailMod','Combuctor','Combuctor_Config','Combuctor_Sets','SpellID','MobAggro',
 'GridClickSets','GridManaBars','GridStatusHots','GridStatusRaidDebuff','GridStatusRaidIconMod','GridStatusRD_WotLK']

def copy(srcbase, name):
    s=os.path.join(srcbase,name)
    if not os.path.isdir(s): return None
    d=os.path.join(PACK,name)
    if os.path.isdir(d): shutil.rmtree(d)
    shutil.copytree(s,d)
    # toc check
    tocs=[x for x in os.listdir(d) if x.lower().endswith('.toc')]
    if not tocs: return (name,'NO_TOC','')
    t=sorted(tocs)[0]
    txt=open(os.path.join(d,t),encoding='utf-8-sig',errors='ignore').read()
    m=re.search(r'##\s*Interface:\s*([0-9, ]+)',txt)
    v=re.search(r'##\s*Version:\s*(.*)',txt)
    return (name, m.group(1).strip() if m else '??', v.group(1).strip() if v else '')

print('--- from 多玩 ---')
for n in duowan:
    r=copy(DW,n); print(r)
print('--- from 大脚 ---')
for n in bigfoot:
    r=copy(BF,n); print(r)
print('TOTAL folders now:', len([x for x in os.listdir(PACK) if os.path.isdir(os.path.join(PACK,x))]))
