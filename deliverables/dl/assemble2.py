import zipfile, os, re, shutil
dl = os.path.dirname(os.path.abspath(__file__))
PACK = os.path.normpath(os.path.join(dl,'..','addons-pack','Interface','AddOns'))
def read_toc(zf, name):
    txt=zf.read(name).decode('utf-8-sig','ignore'); meta={}
    for line in txt.splitlines():
        m=re.match(r'##\s*([\w-]+)\s*:\s*(.*)', line.strip())
        if m: meta[m.group(1)]=m.group(2).strip()
    return meta
def copy_folder(zf, prefix, outname):
    dest=os.path.join(PACK,outname)
    if os.path.exists(dest): shutil.rmtree(dest)
    os.makedirs(dest, exist_ok=True)
    for n in zf.namelist():
        if n.startswith(prefix+'/') and not n.endswith('/'):
            rel=n[len(prefix)+1:]
            if not rel: continue
            t=os.path.join(dest, rel.replace('/',os.sep))
            os.makedirs(os.path.dirname(t), exist_ok=True)
            with zf.open(n) as s, open(t,'wb') as f: shutil.copyfileobj(s,f)

jobs=[
 ('YoharJB__OmniCC_WOTLK.zip','OmniCC_WOTLK-main',['OmniCC','OmniCC_Config']),
 ('bkader__TidyPlates_WoTLK.zip','TidyPlates_WoTLK-main',['TidyPlates','TidyPlates_Graphite','TidyPlates_Grey','TidyPlates_Neon','TidyPlates_Quatre','TidyPlates_ThreatPlates']),
]
for z,prefix,folders in jobs:
    zf=zipfile.ZipFile(os.path.join(dl,z))
    for fd in folders:
        copy_folder(zf, prefix+'/'+fd, fd)
        metaname=[n for n in zf.namelist() if n.startswith(prefix+'/'+fd+'/') and n.lower().endswith('.toc') and n.count('/')==prefix.count('/')+2][0]
        m=read_toc(zf,metaname)
        print(f"[B] {fd} | v={m.get('Version')} | author={m.get('Author')} | if={m.get('Interface')} | req={m.get('Dependencies')}")
# Omen root-is-addon
zf=zipfile.ZipFile(os.path.join(dl,'weird-wrath-mods__Omen.zip'))
copy_folder(zf,'Omen-main','Omen')
m=read_toc(zf,'Omen-main/Omen.toc')
print(f"[B] Omen | v={m.get('Version')} | author={m.get('Author')} | if={m.get('Interface')} | req={m.get('Dependencies')}")
