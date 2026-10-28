import sys, os, io, zipfile, urllib.request, json, re, ssl, time

ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

def gh_get(url, tries=5):
    last=None
    for i in range(tries):
        try:
            req = urllib.request.Request(url, headers={'User-Agent':'addon-pack-builder','Accept':'application/vnd.github+json'})
            with urllib.request.urlopen(req, timeout=60, context=ctx) as r:
                return r.read()
        except Exception as e:
            last=e; time.sleep(3+i*2)
    raise last

def scan(owner_repo, ref=None):
    # get default branch
    info = json.loads(gh_get(f'https://api.github.com/repos/{owner_repo}'))
    branch = ref or info.get('default_branch','main')
    zipurl = f'https://github.com/{owner_repo}/archive/refs/heads/{branch}.zip'
    data = gh_get(zipurl)
    zf = zipfile.ZipFile(io.BytesIO(data))
    tocs = []
    for n in zf.namelist():
        if n.lower().endswith('.toc'):
            first = ''
            for line in zf.read(n).decode('utf-8','ignore').splitlines():
                if line.strip():
                    first = line.strip(); break
            tocs.append((n, first))
    return branch, info.get('default_branch'), tocs, len(data)

if __name__ == '__main__':
    owner_repo = sys.argv[1]
    ref = sys.argv[2] if len(sys.argv)>2 else None
    try:
        branch, dflt, tocs, size = scan(owner_repo, ref)
        print(f'REPO {owner_repo} default={dflt} fetched_ref={branch} bytes={size}')
        for n, first in tocs:
            print(f'  TOC {n}\n      -> {first}')
    except Exception as e:
        print(f'REPO {owner_repo} ERROR {type(e).__name__}: {e}')
