import urllib.request, urllib.parse, json, ssl
ctx = ssl.create_default_context(); ctx.check_hostname=False; ctx.verify_mode=ssl.CERT_NONE
def get(url):
    req=urllib.request.Request(url, headers={'User-Agent':'abp','Accept':'application/vnd.github+json'})
    return json.loads(urllib.request.urlopen(req, timeout=40, context=ctx).read())
import sys
mode=sys.argv[1]
if mode=='refs':
    repo=sys.argv[2]
    brs=get(f'https://api.github.com/repos/{repo}/branches?per_page=100')
    print('BRANCHES:', [b['name'] for b in brs])
    tgs=get(f'https://api.github.com/repos/{repo}/tags?per_page=100')
    print('TAGS:', [t['name'] for t in tgs][:40])
elif mode=='search':
    q=sys.argv[2]
    r=get(f'https://api.github.com/search/repositories?q={urllib.parse.quote(q)}&per_page=15')
    for it in r.get('items',[]):
        print(f"{it['full_name']}  stars={it['stargazers_count']}  pushed={it['pushed_at'][:10]}  :: {(it['description'] or '')[:90]}")
