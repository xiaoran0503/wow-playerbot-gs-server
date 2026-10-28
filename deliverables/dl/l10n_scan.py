import os, re
PACK=r'E:\缓存\WOW\wow-playerbot-server\deliverables\addons-pack\Interface\AddOns'
rows=[]
for addon in sorted(os.listdir(PACK)):
    d=os.path.join(PACK,addon)
    if not os.path.isdir(d): continue
    if addon.startswith('Blizzard_'): continue
    # find zhCN markers anywhere
    zh_files=[]
    has_zhcn_toc=False
    for root,_,files in os.walk(d):
        for f in files:
            fl=f.lower()
            if 'zhcn' in fl or 'zh_cn' in fl:
                zh_files.append(os.path.relpath(os.path.join(root,f),d))
    # check toc for zhCN entry
    tocs=[x for x in os.listdir(d) if x.lower().endswith('.toc')]
    toc_txt=''
    for t in tocs:
        toc_txt+=open(os.path.join(d,t),encoding='utf-8-sig',errors='ignore').read()
    toc_zh = 'zhCN' in toc_txt or 'zhCN' in toc_txt
    # detect any english-facing localization dir
    has_locale = any(('locale' in p.lower() or 'localization' in p.lower()) for p in zh_files)
    rows.append((addon, len(zh_files), 'Y' if toc_zh else '-', zh_files[:3]))
for r in rows:
    print(f"{r[0]:28} zhCN_files={r[1]:2} toc_zhCN={r[2]}  {r[3]}")
