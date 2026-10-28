import zipfile, os, sys
dl = os.path.dirname(os.path.abspath(__file__))
targets = sys.argv[1:]
for z in sorted(os.listdir(dl)):
    if not z.endswith('.zip'): continue
    if targets and not any(t in z for t in targets): continue
    print(f'=== {z} ===')
    zf=zipfile.ZipFile(os.path.join(dl,z))
    for n in zf.namelist():
        if n.lower().endswith('.toc'):
            first=''
            for line in zf.read(n).decode('utf-8-sig','ignore').splitlines():
                if line.strip(): first=line.strip(); break
            print(f'  {n}  -> {first}')
