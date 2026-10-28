import os, re, sys
PACK = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','addons-pack','Interface','AddOns'))
rows=[]
bad=[]
for addon in sorted(os.listdir(PACK)):
    adir=os.path.join(PACK,addon)
    if not os.path.isdir(adir): continue
    tocs=[f for f in os.listdir(adir) if f.lower().endswith('.toc')]
    for toc in tocs:
        p=os.path.join(adir,toc)
        txt=open(p,encoding='utf-8-sig').read()
        m=dict(re.findall(r'##\s*([\w-]+)\s*:\s*(.*)',txt))
        iface=m.get('Interface','')
        ok = iface.strip() in ('30300','30400') or iface.strip().startswith(('30300','30400'))
        rows.append((addon, toc, iface.strip(), m.get('Version',''), m.get('Author','')[:40], ok))
        if not ok: bad.append((addon,toc,iface))
print(f'{"ADDON":32} {"TOC":34} {"IFACE":10} OK  VERSION / AUTHOR')
for r in rows:
    print(f'{r[0]:32} {r[1]:34} {r[2]:10} {"Y" if r[5] else "N"}  {r[3]} / {r[4]}')
print('\nTOTAL toc files:', len(rows), '| non-30300/30400:', len(bad))
for b in bad: print('  BAD:', b)
