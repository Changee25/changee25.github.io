/**
 * 一次性工具：把主题依赖的外链资源下载到本地 source/vendor/
 *
 * 用法（在 hexo-blog 目录下）：
 *   先 hexo generate 生成 public/
 *   node tools/localize-cdn.js
 *   再 hexo generate
 *
 * 它会扫描 public/ 里所有 html/css/js，找出 lib.baomitu.com / at.alicdn.com
 * 上的 js、css、字体、图片，按原路径下载到 source/vendor/<host>/<path>，
 * 并把 css 里指向这两家的绝对地址改成本地 /vendor/ 路径（相对地址保持不变）。
 */
const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const PUB = path.join(ROOT, "public");
const VENDOR = path.join(ROOT, "source", "vendor");

const LOCAL_HOSTS = ["lib.baomitu.com", "at.alicdn.com"];
const hostPrefixRe = /^(?:https?:)?\/\/(lib\.baomitu\.com|at\.alicdn\.com)\//i;

const urls = new Set();
// 既认 https://cdn/... 也认已被钩子改成本的 /vendor/cdn/...（后者反推回源地址）
const scanRe = /(?:(?:https?:)?\/\/|\/vendor\/)(?:lib\.baomitu\.com|at\.alicdn\.com)\/[^\s"'()<>\\]+/gi;

function walk(dir) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) walk(p);
    else if (/\.(html|css|js)$/i.test(e.name)) {
      const t = fs.readFileSync(p, "utf8");
      let m;
      while ((m = scanRe.exec(t))) {
        let u = m[0];
        if (u.startsWith("/vendor/")) u = "https://" + u.slice("/vendor/".length);
        else if (u.startsWith("//")) u = "https:" + u;
        urls.add(u);
      }
    }
  }
}

function localPathFor(url) {
  const u = new URL(url);
  const clean = u.pathname;
  return path.join(VENDOR, u.hostname, clean);
}

async function download(url) {
  const dest = localPathFor(url);
  if (fs.existsSync(dest) && fs.statSync(dest).size > 0) return { url, dest, cached: true };
  const r = await fetch(url, { redirect: "follow" });
  if (!r.ok) throw new Error(`${r.status} ${url}`);
  const buf = Buffer.from(await r.arrayBuffer());
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  fs.writeFileSync(dest, buf);
  return { url, dest, bytes: buf.length };
}

// 把绝对地址改成本地路径（只改指向这两家 CDN 的）
function rewriteCss(text) {
  return text.replace(/(?:https?:)?\/\/(lib\.baomitu\.com|at\.alicdn\.com)\//gi, "/vendor/$1/");
}

(async () => {
  if (!fs.existsSync(PUB)) throw new Error("找不到 public/，先 hexo generate");
  walk(PUB);

  const log = [];
  const queue = [...urls];
  const seen = new Set();
  const cssToPatch = [];

  while (queue.length) {
    const url = queue.shift();
    if (seen.has(url)) continue;
    seen.add(url);
    try {
      const res = await download(url);
      log.push(`${res.cached ? "cached" : "get   "} ${url}`);
      if (/\.css$/i.test(new URL(url).pathname)) cssToPatch.push(res.dest);
    } catch (e) {
      log.push(`FAIL   ${url} :: ${e.message}`);
    }
  }

  // css 里引用的字体/图片：先改绝对地址，再把本地相对/绝对引用也抓下来
  for (const cssFile of cssToPatch) {
    let text = fs.readFileSync(cssFile, "utf8");
    const before = text;
    text = rewriteCss(text);
    if (text !== before) fs.writeFileSync(cssFile, text, "utf8");

    const urlRe = /url\(\s*['"]?([^'")]+)['"]?\s*\)/gi;
    let m;
    const deps = new Set();
    while ((m = urlRe.exec(text))) {
      let ref = m[1].trim();
      if (!ref || ref.startsWith("data:")) continue;
      let abs;
      if (/^\/\//.test(ref)) abs = "https:" + ref;
      else if (/^https?:/.test(ref)) abs = ref;
      else if (/^\/vendor\//.test(ref)) {
        const rel = ref.replace(/^\/vendor\//, "");
        const host = rel.split("/")[0];
        abs = "https://" + rel;
      } else {
        // 相对地址，按 css 自身位置解析
        const cssUrl = "https://" + path.relative(VENDOR, cssFile).split(path.sep).join("/");
        abs = new URL(ref, cssUrl).toString();
      }
      if (hostPrefixRe.test(abs)) deps.add(abs);
    }
    for (const dep of deps) {
      if (seen.has(dep)) continue;
      seen.add(dep);
      try {
        const res = await download(dep);
        log.push(`${res.cached ? "cached" : "get   "} ${dep}`);
      } catch (e) {
        log.push(`FAIL   ${dep} :: ${e.message}`);
      }
    }
  }

  fs.writeFileSync(path.join(ROOT, ".tmp_localize.log"), log.join("\n"), "utf8");
  console.log(log.join("\n"));
  console.log(`\n共处理 ${seen.size} 个地址`);
})();
