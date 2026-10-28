import zipfile, os, io, sys
dl = os.path.dirname(os.path.abspath(__file__))
for z in sorted(os.listdir(dl)):
    if not z.endswith('.zip'): continue
    print(f'=== {z} ===')
    zf = zipfile.ZipFile(os.path.join(dl,z))
    # top-level dirs
    tops=set()
    for n in zf.namelist():
        parts=n.split('/')
        tops.add(parts[0]+'/'+(parts[1] if len(parts)>1 else ''))
    # find toc files at depth 2 (root/<addon>/<addon>.toc)
    for n in zf.namelist():
        if n.lower().endswith('.toc'):
            depth=n.rstrip('/').count('/')
            if depth<=2:
                first=''
                for line in zf.read(n).decode('utf-8-sig','ignore').splitlines():
                    if line.strip(): first=line.strip(); break
                print(f'  {n}  -> {first}')
