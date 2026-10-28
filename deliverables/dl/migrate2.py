import os, shutil, glob
SRC=r'E:\缓存\WOW\AddOns'
PACK=r'E:\缓存\WOW\wow-playerbot-server\deliverables\addons-pack\Interface\AddOns'

# remove ElvUI* and disallowed downloads
remove_exact=['TomTom','OmniCC','OmniCC_Config','GatherMate2','GatherMate2_Data']
for f in os.listdir(PACK):
    if f.startswith('ElvUI') or f.startswith('TidyPlates'):
        remove_exact.append(f)
for r in remove_exact:
    p=os.path.join(PACK,r)
    if os.path.isdir(p): shutil.rmtree(p); print('REMOVED',r)

# copy newly requested local folders
copy=['ExplorerCoords','Focuser','GearScoreLite','MySlot','NiceDamage','Parrot','SpellReplay','TradeTabs']
for f in copy:
    s=os.path.join(SRC,f); d=os.path.join(PACK,f)
    if not os.path.isdir(s): print('MISSING',f); continue
    if os.path.isdir(d): shutil.rmtree(d)
    shutil.copytree(s,d); print('COPIED',f)

final=sorted([x for x in os.listdir(PACK) if os.path.isdir(os.path.join(PACK,x))])
print('FINAL COUNT', len(final))
print(final)
