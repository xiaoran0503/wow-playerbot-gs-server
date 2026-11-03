/*
 * Copyright (C) 2016+ AzerothCore <www.azerothcore.org>, released under GNU AGPL v3 license:
 * https://github.com/azerothcore/azerothcore-wotlk/blob/master/LICENSE-AGPL3
 */

#include "RegisterHtml.h"

namespace Acore::Register::Html
{
    std::string IndexPage()
    {
        return R"html(<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>GM 后台管理</title>
<style>
:root{--bg:#0f1419;--panel:#1a2027;--panel2:#222b34;--bd:#2f3a44;--tx:#e6edf3;--tx2:#9aa7b1;--acc:#3b82f6;--acc2:#2563eb;--ok:#22c55e;--warn:#eab308;--err:#ef4444}
*{box-sizing:border-box;margin:0;padding:0}
body{font-family:-apple-system,"Segoe UI","Microsoft YaHei",sans-serif;background:var(--bg);color:var(--tx);font-size:14px}
#login{max-width:380px;margin:10vh auto;background:var(--panel);border:1px solid var(--bd);border-radius:12px;padding:32px}
#login h1{font-size:20px;margin-bottom:20px}
#app{display:none}
header{background:var(--panel);border-bottom:1px solid var(--bd);padding:12px 20px;display:flex;align-items:center;justify-content:space-between}
header h1{font-size:16px;font-weight:600}
nav{display:flex;gap:4px;padding:10px 20px;background:var(--panel2);border-bottom:1px solid var(--bd);flex-wrap:wrap}
nav button{background:transparent;border:1px solid transparent;color:var(--tx2);padding:7px 14px;border-radius:8px;cursor:pointer;font-size:13px}
nav button.on{background:var(--acc2);color:#fff;border-color:var(--acc)}
main{padding:20px;max-width:1280px;margin:0 auto}
.card{background:var(--panel);border:1px solid var(--bd);border-radius:12px;padding:18px;margin-bottom:16px}
.card h2{font-size:15px;margin-bottom:14px;font-weight:600}
input,select,button.btn{padding:8px 12px;border-radius:8px;border:1px solid var(--bd);background:var(--panel2);color:var(--tx);font-size:13px}
input:focus,select:focus{outline:1px solid var(--acc);border-color:var(--acc)}
button.btn{background:var(--acc2);border-color:var(--acc);color:#fff;cursor:pointer}
button.btn:hover{background:var(--acc)}
button.btn.ghost{background:transparent;color:var(--tx2)}
button.btn.danger{background:#7f1d1d;border-color:#b91c1c}
.frm{display:flex;flex-wrap:wrap;gap:10px;align-items:flex-end;margin-bottom:14px}
.frm label{display:flex;flex-direction:column;gap:4px;font-size:12px;color:var(--tx2)}
table{width:100%;border-collapse:collapse;font-size:13px}
th,td{text-align:left;padding:8px 10px;border-bottom:1px solid var(--bd)}
th{color:var(--tx2);font-weight:600;font-size:12px}
tr:hover td{background:var(--panel2)}
.pill{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px}
.pill.gm{background:#312e81;color:#c7d2fe}
.pill.on{background:#14532d;color:#86efac}
.pill.off{background:#3f3f46;color:#a1a1aa}
.q0{color:#9ca3af}.q1{color:#e5e7eb}.q2{color:#22c55e}.q3{color:#3b82f6}.q4{color:#a855f7}.q5{color:#f97316}
.msg{padding:10px 14px;border-radius:8px;margin-bottom:12px;display:none}
.msg.ok{background:#14532d;color:#86efac;display:block}
.msg.err{background:#7f1d1d;color:#fca5a5;display:block}
.mono{font-family:ui-monospace,Consolas,monospace}
.hint{color:var(--tx2);font-size:12px;margin-top:6px}
.pager{display:flex;gap:8px;align-items:center;margin-top:12px}
#logout{cursor:pointer;color:var(--tx2)}
</style>
</head>
<body>
<div id="login">
  <h1>GM 后台登录</h1>
  <div id="loginMsg" class="msg"></div>
  <div class="frm" style="flex-direction:column;align-items:stretch">
    <label>账号<input id="u" type="text" autocomplete="username"></label>
    <label>密码<input id="p" type="password" autocomplete="current-password"></label>
    <button class="btn" onclick="doLogin()">登录</button>
  </div>
  <div class="hint">使用 gmlevel ≥ 2 的游戏账号登录</div>
</div>

<div id="app">
  <header><h1>GM 后台管理</h1><span id="logout" onclick="logout()">退出</span></header>
  <nav>
    <button data-v="accounts" class="on" onclick="switchView('accounts')">账号</button>
    <button data-v="characters" onclick="switchView('characters')">角色</button>
    <button data-v="items" onclick="switchView('items')">物品发放</button>
    <button data-v="gold" onclick="switchView('gold')">金币发放</button>
    <button data-v="online" onclick="switchView('online')">在线状态</button>
    <button data-v="bans" onclick="switchView('bans')">封禁</button>
    <button data-v="events" onclick="switchView('events')">服务器活动</button>
    <button data-v="maintain" onclick="switchView('maintain')">维护</button>
  </nav>
  <main id="main"></main>
</div>

<script>
let TOKEN = localStorage.getItem('gm_token') || '';
const $ = id => document.getElementById(id);
const esc = s => (s==null?'':String(s)).replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
const moneyStr = copper => { const g=Math.floor(copper/10000), s=Math.floor(copper%10000/100), c=copper%100; return (g?g+'金':'')+(s?s+'银':'')+(c?c+'铜':'')||'0铜'; };

async function api(path, params={}) {
  const qs = new URLSearchParams(params).toString();
  const res = await fetch('/api'+path+(qs?'?'+qs:''), {
    headers: TOKEN ? {Authorization:'Bearer '+TOKEN} : {}
  });
  return res.json();
}

function showMsg(el, txt, ok) {
  const m = $(el); m.textContent = txt; m.className = 'msg '+(ok?'ok':'err');
  setTimeout(()=>{m.className='msg'}, 4000);
}

async function doLogin() {
  const r = await api('/login', {username:$('u').value, password:$('p').value});
  if (r.ok) {
    TOKEN = r.token; localStorage.setItem('gm_token', TOKEN);
    $('login').style.display='none'; $('app').style.display='block';
    switchView('accounts');
  } else showMsg('loginMsg', r.msg||'登录失败', false);
}

function logout() {
  TOKEN=''; localStorage.removeItem('gm_token');
  $('app').style.display='none'; $('login').style.display='block';
}

function switchView(v) {
  document.querySelectorAll('nav button').forEach(b=>b.classList.toggle('on', b.dataset.v===v));
  const m = $('main');
  if (v==='accounts') renderAccounts(m);
  else if (v==='characters') renderCharacters(m);
  else if (v==='items') renderItems(m);
  else if (v==='gold') renderGold(m);
  else if (v==='online') renderOnline(m);
  else if (v==='bans') renderBans(m);
  else if (v==='events') renderEvents(m);
  else if (v==='maintain') renderMaintain(m);
}

// ===== 账号 =====
async function renderAccounts(m) {
  m.innerHTML = `<div class="card"><h2>账号管理</h2>
    <div class="frm">
      <label>搜索（用户名/ID）<input id="accKw" placeholder="留空=全部"></label>
      <button class="btn" onclick="loadAccounts()">查询</button>
    </div>
    <div id="accList"></div></div>`;
  loadAccounts();
}
async function loadAccounts() {
  const r = await api('/accounts', {kw:$('accKw')?.value||''});
  const rows = (r.rows||[]).map(a=>`<tr>
    <td>${a.id}</td><td>${esc(a.username)}</td><td>${esc(a.email)}</td>
    <td><span class="pill gm">${a.gmlevel}</span></td>
    <td>${a.expansion}</td>
    <td><span class="pill ${a.online?'on':'off'}">${a.online?'在线':'离线'}</span></td>
    <td class="mono">${esc(a.last_ip)}</td>
    <td>${esc(a.last_login)}</td>
    <td><button class="btn" onclick="setGm(${a.id},'${esc(a.username)}')">改权限</button></td></tr>`).join('');
  $('accList').innerHTML = `<div class="msg" id="accMsg"></div><table><thead><tr>
    <th>ID</th><th>账号</th><th>邮箱</th><th>GM等级</th><th>版本</th><th>状态</th><th>IP</th><th>最后登录</th><th></th>
    </tr></thead><tbody>${rows}</tbody></table>`;
}
function setGm(id, name) {
  const lv = prompt(`设置账号「${name}」的 GM 权限等级 (0-3)：`, '0');
  if (lv===null) return;
  execCmd(`account set gmlevel ${name} ${lv} -1`, 'accMsg');
}
async function execCmd(cmd, msgEl) {
  const r = await api('/command', {cmd});
  showMsg(msgEl, (r.ok?'成功：':'失败：')+(r.output||''), r.ok);
}

// ===== 角色 =====
async function renderCharacters(m) {
  m.innerHTML = `<div class="card"><h2>角色管理</h2>
    <div class="frm">
      <label>账号ID<input id="chrAcc" type="number"></label>
      <label>角色名<input id="chrName"></label>
      <button class="btn" onclick="loadCharacters()">查询</button>
    </div>
    <div id="chrList"></div></div>`;
  loadCharacters();
}
async function loadCharacters() {
  const r = await api('/characters', {account:$('chrAcc')?.value||0, name:$('chrName')?.value||''});
  const rows = (r.rows||[]).map(c=>`<tr>
    <td>${c.guid}</td><td>${c.account}</td><td>${esc(c.name)}</td>
    <td>${c.level}</td><td>${moneyStr(c.money)}</td>
    <td><span class="pill ${c.online?'on':'off'}">${c.online?'在线':'离线'}</span></td>
    <td>${c.map}/${c.zone}</td>
    <td><button class="btn ghost" onclick="renameChar(${c.guid},'${esc(c.name)}')">改名</button>
        <button class="btn ghost" onclick="resetTalent('${esc(c.name)}')">重置天赋</button></td></tr>`).join('');
  $('chrList').innerHTML = `<div class="msg" id="chrMsg"></div><table><thead><tr>
    <th>GUID</th><th>账号</th><th>名称</th><th>等级</th><th>金币</th><th>状态</th><th>地图/区域</th><th>操作</th>
    </tr></thead><tbody>${rows}</tbody></table>`;
}
function renameChar(g, name) {
  const nn = prompt(`将角色「${name}」改名（下次登录生效）：`, '');
  if (nn) execCmd(`character rename ${name} ${nn}`, 'chrMsg');
}
function resetTalent(name) {
  if (confirm(`重置角色「${name}」的天赋？`)) execCmd(`reset talents ${name}`, 'chrMsg');
}

// ===== 物品 =====
let itemPage = 0;
async function renderItems(m) {
  m.innerHTML = `<div class="card"><h2>物品检索与发放</h2>
    <div class="frm">
      <label>关键词/ID<input id="itKw" placeholder="名称或ID"></label>
      <label>大类<select id="itCls"><option value="0">全部</option><option value="0">消耗品</option><option value="2">武器</option><option value="4">护甲</option><option value="7">商业品</option><option value="15">货币</option></select></label>
      <label>品质<select id="itQ"><option value="0">全部</option><option value="1">粗糙</option><option value="2">普通</option><option value="3">精良</option><option value="4">史诗</option><option value="5">传说</option></select></label>
      <label>装备栏位<select id="itInv"><option value="0">全部</option><option value="1">头部</option><option value="3">肩部</option><option value="5">胸甲</option><option value="7">腿部</option><option value="16">主手</option><option value="17">双手</option><option value="21">远程</option></select></label>
      <label>物品等级≥<input id="itMin" type="number" style="width:80px"></label>
      <label>物品等级≤<input id="itMax" type="number" style="width:80px"></label>
      <button class="btn" onclick="itemPage=0;loadItems()">搜索</button>
    </div>
    <div class="frm">
      <label>发放给角色<input id="itTarget" placeholder="角色名"></label>
      <label>数量<input id="itCount" type="number" value="1" style="width:70px"></label>
    </div>
    <div id="itList"></div>
    <div class="pager">
      <button class="btn ghost" onclick="itemPage=Math.max(0,itemPage-1);loadItems()">上一页</button>
      <button class="btn ghost" onclick="itemPage++;loadItems()">下一页</button>
    </div></div>`;
  loadItems();
}
async function loadItems() {
  const r = await api('/items', {
    kw:$('itKw')?.value||'', class:$('itCls')?.value||0, quality:$('itQ')?.value||0,
    invType:$('itInv')?.value||0, minLevel:$('itMin')?.value||0, maxLevel:$('itMax')?.value||0, page:itemPage
  });
  const rows = (r.rows||[]).map(it=>`<tr>
    <td class="mono">${it.entry}</td>
    <td>${esc(it.name)}${it.nameEn && it.nameEn!==it.name?`<div style="color:var(--tx2);font-size:11px">${esc(it.nameEn)}</div>`:''}</td>
    <td>${it.class}/${it.subclass}</td><td class="q${it.quality}">${it.quality}</td>
    <td>${it.itemLevel}</td><td>${it.requiredLevel}</td>
    <td><button class="btn" onclick="giveItem(${it.entry},'${esc(it.name).replace(/'/g,'')}')">发放</button></td></tr>`).join('');
  $('itList').innerHTML = `<div class="msg" id="itMsg"></div><table><thead><tr>
    <th>物品ID</th><th>名称</th><th>类别</th><th>品质</th><th>物品等级</th><th>需求等级</th><th></th>
    </tr></thead><tbody>${rows}</tbody></table>`;
}
function giveItem(entry, name) {
  const t = $('itTarget').value.trim(), n = $('itCount').value||1;
  if (!t) return showMsg('itMsg', '请填写发放目标角色名', false);
  execCmd(`send items ${t} "GM后台发放" "${name}" ${entry}:${n}`, 'itMsg');
}

// ===== 金币 =====
function renderGold(m) {
  m.innerHTML = `<div class="card"><h2>金币发放</h2>
    <div class="frm">
      <label>角色名<input id="gdTarget" placeholder="角色名"></label>
      <label>金币金额（单位：金）<input id="gdAmt" type="number" value="1"></label>
      <button class="btn" onclick="giveGold()">发放</button>
    </div>
    <div id="gdMsg" class="msg"></div>
    <div class="hint">通过游戏内邮件发放，单位为金（1金=100银=10000铜）</div></div>`;
}
function giveGold() {
  const t = $('gdTarget').value.trim(), a = $('gdAmt').value;
  if (!t) return showMsg('gdMsg','请填写角色名',false);
  execCmd(`send money ${t} "GM后台发放" "金币" ${a}g`, 'gdMsg');
}

// ===== 在线 =====
async function renderOnline(m) {
  m.innerHTML = `<div class="card"><h2>在线状态</h2><div id="olList"></div></div>`;
  const r = await api('/online');
  const acc = (r.accounts||[]).map(a=>`<tr><td>${a.id}</td><td>${esc(a.username)}</td><td class="mono">${esc(a.last_ip)}</td></tr>`).join('');
  const chr = (r.characters||[]).map(c=>`<tr><td>${c.guid}</td><td>${c.account}</td><td>${esc(c.name)}</td><td>${c.level}</td><td>${c.map}/${c.zone}</td></tr>`).join('');
  $('olList').innerHTML = `<p style="margin-bottom:10px">在线账号 ${r.accounts.length} · 在线角色 ${r.characters.length}</p>
    <h3 style="margin:8px 0">账号</h3><table><thead><tr><th>ID</th><th>账号</th><th>IP</th></tr></thead><tbody>${acc}</tbody></table>
    <h3 style="margin:12px 0">角色</h3><table><thead><tr><th>GUID</th><th>账号</th><th>名称</th><th>等级</th><th>地图/区域</th></tr></thead><tbody>${chr}</tbody></table>`;
}

// ===== 封禁 =====
async function renderBans(m) {
  m.innerHTML = `<div class="card"><h2>封禁管理</h2>
    <div class="frm">
      <label>账号<input id="bnAcc" placeholder="账号名"></label>
      <label>时长<input id="bnTime" placeholder="如 1d / 4d20h / -1永久"></label>
      <label>原因<input id="bnReason" placeholder="原因"></label>
      <button class="btn danger" onclick="banAccount()">封禁</button>
      <button class="btn" onclick="unbanAccount()">解封</button>
    </div>
    <div id="bnMsg" class="msg"></div>
    <div id="bnList"></div></div>`;
  loadBans();
}
async function loadBans() {
  const r = await api('/bans');
  const rows = (r.rows||[]).map(b=>`<tr>
    <td>${b.id}</td><td>${new Date(b.bandate*1000).toLocaleString()}</td>
    <td>${b.unbandate>0?new Date(b.unbandate*1000).toLocaleString():'永久'}</td>
    <td>${esc(b.bannedby)}</td><td>${esc(b.reason)}</td>
    <td><span class="pill ${b.active?'on':'off'}">${b.active?'生效':'已解除'}</span></td></tr>`).join('');
  $('bnList').innerHTML = `<table><thead><tr><th>账号ID</th><th>封禁时间</th><th>解封时间</th><th>操作人</th><th>原因</th><th>状态</th></tr></thead><tbody>${rows}</tbody></table>`;
}
function banAccount() {
  const a=$('bnAcc').value.trim(), t=$('bnTime').value.trim(), r=$('bnReason').value.trim()||'违规';
  if (!a) return showMsg('bnMsg','请填写账号',false);
  execCmd(`ban account ${a} ${t||'-1'} ${r}`, 'bnMsg');
}
function unbanAccount() {
  const a=$('bnAcc').value.trim();
  if (!a) return showMsg('bnMsg','请填写账号',false);
  execCmd(`unban account ${a}`, 'bnMsg');
}

// ===== 活动 =====
function eventTime(unix) {
  if (!unix || unix <= 1) return '未设定';
  const d = new Date(unix * 1000);
  return isNaN(d.getTime()) ? '未设定' : d.toLocaleString();
}
function eventDuration(minutes) {
  if (!minutes) return '未设定';
  const days = Math.floor(minutes / 1440), hours = Math.floor(minutes % 1440 / 60), mins = minutes % 60;
  return (days ? days+'天 ' : '') + (hours ? hours+'时 ' : '') + (mins ? mins+'分' : '');
}
async function renderEvents(m) {
  m.innerHTML = `<div class="card"><h2>服务器活动</h2>
    <div class="frm">
      <label>活动ID<input id="evId" type="number"></label>
      <button class="btn" onclick="eventStart()">手动开启</button>
      <button class="btn danger" onclick="eventStop()">手动关闭</button>
      <button class="btn ghost" onclick="loadEvents()">刷新状态</button>
    </div>
    <div id="evMsg" class="msg"></div>
    <div class="hint">状态来自 AzerothCore 当前运行时活动列表；计划时间由核心的下一次状态切换计算，不修改数据库。</div>
    <div id="evList"></div></div>`;
  loadEvents();
}
async function loadEvents() {
  const r = await api('/events');
  const rows = (r.rows||[]).map(e=>`<tr>
    <td>${e.eventEntry}</td>
    <td>${esc(e.description)||'（无描述）'}${e.descriptionEn && e.descriptionEn!==e.description?`<div style="color:var(--tx2);font-size:11px">${esc(e.descriptionEn)}</div>`:''}</td>
    <td><span class="pill ${e.active?'on':'off'}">${esc(e.status)}</span></td>
    <td>${e.nextAction==='start'?'计划开启':'计划结束'}<div style="color:var(--tx2);font-size:11px">${eventTime(e.nextChangeAt)}（${eventDuration(Math.ceil((e.nextChangeIn||0)/60))}后）</div></td>
    <td>${eventTime(e.startAt)}</td><td>${eventTime(e.endAt)}</td>
    <td>${eventDuration(e.occurence)}</td><td>${eventDuration(e.length)}</td>
    <td><button class="btn ghost" onclick="selectEvent(${e.eventEntry})">操作</button></td></tr>`).join('');
  $('evList').innerHTML = `<div class="hint">共 ${r.total||0} 个活动；服务器时间：${eventTime(r.serverTime)}</div><table><thead><tr><th>ID</th><th>描述</th><th>当前状态</th><th>下一次状态切换</th><th>最早开始</th><th>最晚结束</th><th>循环周期</th><th>持续时间</th><th></th></tr></thead><tbody>${rows}</tbody></table>`;
}
function selectEvent(id) { $('evId').value=id; }
function eventStart() { const id=$('evId').value; if(id) execCmd(`event start ${id}`, 'evMsg'); }
function eventStop() { const id=$('evId').value; if(id) execCmd(`event stop ${id}`, 'evMsg'); }

// ===== 维护 =====
function renderMaintain(m) {
  m.innerHTML = `<div class="card"><h2>维护：账号/角色导出导入</h2>
    <div class="frm" style="flex-direction:column;align-items:stretch;max-width:520px">
      <label>导出（pdump write）——角色名或GUID<input id="pdDump" placeholder="角色名或GUID"></label>
      <button class="btn" onclick="pdumpWrite()">导出</button>
      <div id="pdMsg" class="msg"></div>
      <hr style="border-color:var(--bd);margin:10px 0">
      <label>导入（pdump load）——文件名<input id="pdFile" placeholder="dump文件名"></label>
      <label>目标账号<input id="pdAccount" placeholder="账号名"></label>
      <button class="btn" onclick="pdumpLoad()">导入</button>
    </div>
    <div class="hint">pdump 导出文件保存在 worldserver 工作目录，导入时填写文件名。此为维护期操作，请谨慎使用。</div></div>`;
}
function pdumpWrite() {
  const v=$('pdDump').value.trim();
  if (!v) return showMsg('pdMsg','请填写角色名或GUID',false);
  execCmd(`pdump write ${v} ${v}`, 'pdMsg');
}
function pdumpLoad() {
  const f=$('pdFile').value.trim(), a=$('pdAccount').value.trim();
  if (!f||!a) return showMsg('pdMsg','请填写文件名和目标账号',false);
  if (!confirm('确认导入账号存档？')) return;
  execCmd(`pdump load ${f} ${a}`, 'pdMsg');
}

// 启动
if (TOKEN) {
  $('login').style.display='none'; $('app').style.display='block';
  switchView('accounts');
}
</script>
</body>
</html>)html";
    }
}
