import urllib.request, json, ssl, sys
ctx = ssl.create_default_context(); ctx.check_hostname=False; ctx.verify_mode=ssl.CERT_NONE
def get(url):
    req=urllib.request.Request(url, headers={'User-Agent':'abp','Accept':'application/vnd.github+json'})
    return urllib.request.urlopen(req, timeout=40, context=ctx).read()
repo=sys.argv[1]; ref=sys.argv[2] if len(sys.argv)>2 else 'main'
# root tree
data=json.loads(get(f'https://api.github.com/repos/{repo}/git/trees/{ref}'))
for t in data['tree']:
    print(t['type'], t['path'])
print('=== raw Questie.toc ===')
print(get(f'https://raw.githubusercontent.com/{repo}/{ref}/Questie.toc').decode('utf-8','ignore')[:800])
