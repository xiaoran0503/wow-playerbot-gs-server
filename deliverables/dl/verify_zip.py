import zipfile, os, tempfile, shutil, re
here=os.path.dirname(os.path.abspath(__file__))
log=open(os.path.join(here,'verify_zip_result.txt'),'w',encoding='utf-8')
def p(*a): s=' '.join(str(x) for x in a); print(s); log.write(s+'\n'); log.flush()
out = r'E:\缓存\WOW\wow-playerbot-server\deliverables\wow335-addons-pack.zip'
tmp = tempfile.mkdtemp(prefix='addonpack_verify_')
p('EXTRACT TO:', tmp)
with zipfile.ZipFile(out) as zf:
    zf.extractall(tmp)
p('TOP-LEVEL:', sorted(os.listdir(tmp)))
addons = os.path.join(tmp,'Interface','AddOns')
p('Interface\\AddOns exists:', os.path.isdir(addons))
p('AddOn folders:', sorted(os.listdir(addons)))
bad=[]; n=0
for root,_,files in os.walk(tmp):
    for f in files:
        if f.lower().endswith('.toc'):
            n+=1
            txt=open(os.path.join(root,f),encoding='utf-8-sig').read()
            first=[l.strip() for l in txt.splitlines() if l.strip()][0]
            m=re.search(r'## Interface:\s*(\d+)',first)
            if not m or m.group(1) not in ('30300','30400'):
                bad.append((os.path.relpath(os.path.join(root,f),tmp),first))
p('TOC files in extraction:',n,'| non-30300/30400:',bad)
shutil.rmtree(tmp, ignore_errors=True)
p('cleaned temp')
log.close()
