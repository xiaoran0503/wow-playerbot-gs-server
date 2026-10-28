import urllib.request, json, ssl, time, sys, os
ctx = ssl.create_default_context(); ctx.check_hostname=False; ctx.verify_mode=ssl.CERT_NONE
OUT = os.path.dirname(os.path.abspath(__file__))
def get(url, tries=8, timeout=90):
    last=None
    for i in range(tries):
        try:
            req=urllib.request.Request(url, headers={'User-Agent':'abp'})
            with urllib.request.urlopen(req, timeout=timeout, context=ctx) as r:
                return r.read()
        except Exception as e:
            last=e; print(f'   retry {i+1} {type(e).__name__}', flush=True); time.sleep(4+i*3)
    raise last

repos = [a.strip() for a in open(os.path.join(OUT,'repos.txt'),encoding='utf-8') if a.strip() and not a.startswith('#')]
for rp in repos:
    safe = rp.replace('/','__')
    dest = os.path.join(OUT, safe+'.zip')
    if os.path.exists(dest) and os.path.getsize(dest)>10000:
        print(f'CACHED {rp} {os.path.getsize(dest)}', flush=True); continue
    try:
        info=json.loads(get(f'https://api.github.com/repos/{rp}'))
        branch=info.get('default_branch','main')
        data=get(f'https://github.com/{rp}/archive/refs/heads/{branch}.zip')
        open(dest,'wb').write(data)
        print(f'OK {rp} branch={branch} bytes={len(data)}', flush=True)
    except Exception as e:
        print(f'FAIL {rp} {type(e).__name__}: {e}', flush=True)
