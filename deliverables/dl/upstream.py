import urllib.request, json, ssl, time
ctx=ssl.create_default_context(); ctx.check_hostname=False; ctx.verify_mode=ssl.CERT_NONE
def get(url,tries=5):
    for i in range(tries):
        try:
            req=urllib.request.Request(url,headers={'User-Agent':'abp','Accept':'application/vnd.github+json'})
            return json.loads(urllib.request.urlopen(req,timeout=40,context=ctx).read())
        except Exception as e:
            last=e; time.sleep(3)
    return {'error':str(last)}
repos=['dimgatz98/Questie-3.3.5a','weird-wrath-mods/Omen','buildthehomelab/wow-addon-AtlasLootHD',
 'warcrafted-server/TomTom','YoharJB/OmniCC_WOTLK','bkader/TidyPlates_WoTLK','Xurkon/GatherMate2',
 'jejkas/WeakAura-3.3.5','BoatManFall3n/WoW_3.3.5a_Bartender4','RichSteini/Bagnon-3.3.5']
for rp in repos:
    info=get(f'https://api.github.com/repos/{rp}')
    tags=get(f'https://api.github.com/repos/{rp}/tags?per_page=3')
    tagnames=[t.get('name') for t in tags] if isinstance(tags,list) else []
    print(f"{rp} | pushed={info.get('pushed_at','?')[:10]} | default={info.get('default_branch','?')} | tags={tagnames}")
