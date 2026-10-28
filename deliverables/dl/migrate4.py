import os, shutil, re
PACK=r'E:\缓存\WOW\wow-playerbot-server\deliverables\addons-pack\Interface\AddOns'
DW=r'E:\缓存\WOW\AddOns多玩\AddOns多玩'

remove=['MikScrollingBattleText','MSBTOptions','EventAlert','RaidAlerter','RepairHelper','SellerHelper',
 'MailMod','Combuctor','Combuctor_Config','Combuctor_Sets','SpellTimer','MobAggro','ExtVendor','CombatAlert',
 'oRA2','oRA2_Leader','oRA2_Optional','oRA2_Participant','NPCMark']
for r in remove:
    p=os.path.join(PACK,r)
    if os.path.isdir(p): shutil.rmtree(p); print('REMOVED',r)

add=['TinyTip','Ex_AutoEquip','Mapster','whoaThickFrames','AttackTimer','TotemTimers','PallyPower','Bagnon_Tooltips']
for n in add:
    s=os.path.join(DW,n)
    if not os.path.isdir(s): print('MISSING SRC',n); continue
    d=os.path.join(PACK,n)
    if os.path.isdir(d): shutil.rmtree(d)
    shutil.copytree(s,d)
    tocs=[x for x in os.listdir(d) if x.lower().endswith('.toc')]
    t=sorted(tocs)[0] if tocs else '(none)'
    if tocs:
        txt=open(os.path.join(d,t),encoding='utf-8-sig',errors='ignore').read()
        m=re.search(r'##\s*Interface:\s*([0-9, ]+)',txt)
        print(f'COPIED {n} | {t} | if={m.group(1).strip() if m else "??"}')
    else:
        print(f'COPIED {n} | NO TOC')

print('FINAL folders:', len([x for x in os.listdir(PACK) if os.path.isdir(os.path.join(PACK,x))]))
