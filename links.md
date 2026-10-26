---
layout: page
title: 友链
permalink: /links/
---

<div id="lock" class="lock">
  <h2>要密码才能看</h2>
  <form id="lock-form">
    <input id="pw" type="password" placeholder="密码" autocomplete="current-password">
    <button type="submit">进入</button>
  </form>
  <p class="err" id="err"></p>
</div>

<div id="friends" class="friends" hidden>
{% for f in site.data.friends %}
  <a class="friend-card" href="{{ f.url }}" target="_blank" rel="noopener">
    <span class="friend-name">{{ f.name }}</span>
    <span class="friend-desc">{{ f.desc }}</span>
    <span class="friend-url">{{ f.url | remove: "https://" | remove: "http://" }}</span>
  </a>
{% endfor %}
</div>

<script>
(function () {
  var HASH = '0026dfa9677472300020fb4ca90df0cf593f3f93de9acb6e918a856f5d39bd43';
  var lock = document.getElementById('lock');
  var box = document.getElementById('friends');
  var err = document.getElementById('err');
  var form = document.getElementById('lock-form');
  var input = document.getElementById('pw');

  function toHex(buf) {
    return Array.prototype.map.call(new Uint8Array(buf), function (b) {
      return ('0' + b.toString(16)).slice(-2);
    }).join('');
  }

  function unlock() {
    lock.style.display = 'none';
    box.hidden = false;
  }

  try {
    if (sessionStorage.getItem('friends-ok') === HASH) { unlock(); }
  } catch (e) {}

  form.addEventListener('submit', function (e) {
    e.preventDefault();
    if (!(window.crypto && crypto.subtle)) {
      err.textContent = '请用 https 地址打开这个页面';
      return;
    }
    crypto.subtle.digest('SHA-256', new TextEncoder().encode(input.value)).then(function (buf) {
      if (toHex(buf) === HASH) {
        try { sessionStorage.setItem('friends-ok', HASH); } catch (e2) {}
        unlock();
      } else {
        err.textContent = '密码不对，再试一次';
        lock.classList.add('shake');
        setTimeout(function () { lock.classList.remove('shake'); }, 400);
        input.select();
      }
    });
  });
})();
</script>
