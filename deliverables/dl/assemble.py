import zipfile, os, re, shutil
dl = os.path.dirname(os.path.abspath(__file__))
PACK = os.path.normpath(os.path.join(dl,'..','addons-pack','Interface','AddOns'))

def read_toc(zf, name):
    txt = zf.read(name).decode('utf-8-sig','ignore')
    meta={}
    files=[]
    for line in txt.splitlines():
        s=line.strip()
        m=re.match(r'##\s*([\w-]+)\s*:\s*(.*)', s)
        if m: meta[m.group(1)]=m.group(2).strip()
        elif s and not s.startswith('#'):
            files.append(s)
    return meta, files

# (zip, root_prefix_inside_zip, list of addon folder names relative to root, output folder name override or None)
jobs = [
 ('BoatManFall3n__WoW_3.3.5a_Bartender4.zip','WoW_3.3.5a_Bartender4-main',['Bartender4'],None),
 ('RichSteini__Bagnon-3.3.5.zip','Bagnon-3.3.5-main',['Bagnon','Bagnon_Config','Bagnon_Forever','Bagnon_GuildBank','Bagnon_Tooltips','Bagnon_VoidStorage'],None),
 ('buildthehomelab__wow-addon-AtlasLootHD.zip','wow-addon-AtlasLootHD-main',['AtlasLoot','AtlasLootFu','AtlasLoot_BurningCrusade','AtlasLoot_Crafting','AtlasLoot_OriginalWoW','AtlasLoot_WorldEvents','AtlasLoot_WrathoftheLichKing'],None),
 ('jejkas__WeakAura-3.3.5.zip','WeakAura-3.3.5-master',['WeakAuras','WeakAurasModelPaths','WeakAurasOptions','WeakAurasTutorials'],None),
]

# root-is-addon cases: (zip, root prefix, output folder, toc file name)
root_jobs = [
 ('bratmage__PostalEnhanced.zip','PostalEnhanced-main','PostalEnhanced','PostalEnhanced.toc'),
 ('richterlevania3__Recount-3.3.5.zip','Recount-3.3.5-master','Recount','Recount.toc'),
 ('warcrafted-server__TomTom.zip','TomTom-main','TomTom','TomTom.toc'),
]

def copy_folder(zf, prefix, outname):
    dest=os.path.join(PACK,outname)
    if os.path.exists(dest): shutil.rmtree(dest)
    os.makedirs(dest, exist_ok=True)
    members=[n for n in zf.namelist() if n.startswith(prefix+'/') and not n.endswith('/')]
    for n in members:
        rel=n[len(prefix)+1:]
        if not rel: continue
        target=os.path.join(dest, rel.replace('/',os.sep))
        os.makedirs(os.path.dirname(target), exist_ok=True)
        with zf.open(n) as src, open(target,'wb') as f: shutil.copyfileobj(src,f)
    return dest

for z,prefix,folders,ov in jobs:
    zf=zipfile.ZipFile(os.path.join(dl,z))
    for fd in folders:
        copy_folder(zf, prefix+'/'+fd, fd)
        toc=[n for n in zf.namelist() if n.startswith(prefix+'/'+fd+'/') and n.lower().endswith('.toc') and n.count('/')==prefix.count('/')+2][0]
        meta,_=read_toc(zf,toc)
        print(f"[B] {fd} | v={meta.get('Version')} | author={meta.get('Author')} | if={meta.get('Interface')} | req={meta.get('Dependencies') or meta.get('RequiredDeps')}")

for z,prefix,out,tocname in root_jobs:
    zf=zipfile.ZipFile(os.path.join(dl,z))
    copy_folder(zf, prefix, out)
    # remove stray toc with wrong name
    stray=os.path.join(PACK,out, out+'-main.toc')
    if os.path.exists(stray): os.remove(stray)
    meta,_=read_toc(zf, prefix+'/'+tocname)
    print(f"[B] {out} | v={meta.get('Version')} | author={meta.get('Author')} | if={meta.get('Interface')} | req={meta.get('Dependencies') or meta.get('RequiredDeps')}")

# Questie special
z='dimgatz98__Questie-3.3.5a.zip'; prefix='Questie-3.3.5a-main'
zf=zipfile.ZipFile(os.path.join(dl,z))
copy_folder(zf, prefix, 'Questie')
meta335, files335 = read_toc(zf, prefix+'/Questie-335.toc')
# overwrite base Questie.toc with the 335 variant so stock 3.3.5a client loads it
q335 = zf.read(prefix+'/Questie-335.toc').decode('utf-8-sig')
open(os.path.join(PACK,'Questie','Questie.toc'),'w',encoding='utf-8').write(q335)
print(f"[B] Questie | v={meta335.get('Version')} | author={meta335.get('Author')} | if={meta335.get('Interface')} | files_in_toc={len(files335)}")
