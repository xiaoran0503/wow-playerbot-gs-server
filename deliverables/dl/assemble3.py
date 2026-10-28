import zipfile, os, shutil, re
dl = os.path.dirname(os.path.abspath(__file__))
PACK = os.path.normpath(os.path.join(dl,'..','addons-pack','Interface','AddOns'))
zf = zipfile.ZipFile(os.path.join(dl,'Xurkon__GatherMate2.zip'))

def cp(prefix, out, exclude_sub=None):
    d = os.path.join(PACK, out)
    shutil.rmtree(d, ignore_errors=True)
    os.makedirs(d, exist_ok=True)
    for n in zf.namelist():
        if not n.startswith(prefix+'/') or n.endswith('/'): continue
        rel = n[len(prefix)+1:]
        if not rel: continue
        if exclude_sub and rel.startswith(exclude_sub+'/'): continue
        t = os.path.join(d, rel.replace('/', os.sep))
        os.makedirs(os.path.dirname(t), exist_ok=True)
        with zf.open(n) as s, open(t,'wb') as f: shutil.copyfileobj(s, f)

cp('GatherMate2-main','GatherMate2', exclude_sub='GatherMate2_Data')
cp('GatherMate2-main/GatherMate2_Data','GatherMate2_Data')
for out, nm in [('GatherMate2','GatherMate2.toc'), ('GatherMate2_Data','GatherMate2_Data.toc')]:
    txt = zf.read('GatherMate2-main/'+(out+'/'+nm if out=='GatherMate2_Data' else nm)).decode('utf-8-sig')
    m = dict(re.findall(r'##\s*([\w-]+)\s*:\s*(.*)', txt))
    print(out, 'v=', m.get('Version'), '| author=', m.get('Author'), '| if=', m.get('Interface'))
