import os, zipfile
here = os.path.dirname(os.path.abspath(__file__))
base = os.path.normpath(os.path.join(here,'..','addons-pack'))
out = os.path.normpath(os.path.join(here,'..','wow335-addons-pack.zip'))
if os.path.exists(out): os.remove(out)
zf = zipfile.ZipFile(out,'w',zipfile.ZIP_DEFLATED, compresslevel=6)
for root,dirs,files in os.walk(base):
    for f in files:
        full=os.path.join(root,f)
        rel=os.path.relpath(full,base)
        arc=rel.replace(os.sep,'/')
        zf.write(full,arc)
zf.close()
print('ZIP:',out, os.path.getsize(out),'bytes')
zf=zipfile.ZipFile(out)
tops=sorted(set(n.split('/')[0] for n in zf.namelist()))
print('TOP-LEVEL:',tops)
print('ENTRY COUNT:',len(zf.namelist()))
