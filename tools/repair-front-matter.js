/**
 * 自动修复 front matter（在构建前跑，CI 里也会跑）
 *
 * 处理两类常见手误：
 *   1. 开头的 `---` 丢了 → 自动补上
 *      （复制模板 / 在 Typora 里另存为时最常见，丢了 Hexo 就认不出 front matter）
 *   2. `description:meow~` 这种冒号后没空格 → 补成 `description: meow~`
 *      （YAML 要求冒号后必须有空格，否则整块解析失败）
 *
 * 用法：node tools/repair-front-matter.js
 */
const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const DIRS = [path.join(ROOT, "source", "_posts"), path.join(ROOT, "source", "_diary")];

const KEY_RE = /^[A-Za-z_][\w-]*\s*:/;
const COLON_RE = /^([A-Za-z_][\w-]*):(?!\s)(.*)$/gm;

function fixColon(body) {
  return body.replace(COLON_RE, "$1: $2");
}

function tryRepair(text) {
  const t = text.replace(/\r\n/g, "\n");

  // 情况一：已经有 --- 包裹，只检查冒号后空格
  const m = t.match(/^---\n([\s\S]*?)\n---\n?([\s\S]*)$/);
  if (m) {
    const fixed = fixColon(m[1]);
    if (fixed === m[1]) return null;
    return "---\n" + fixed + "\n---\n\n" + m[2].replace(/^\n+/, "");
  }

  // 情况二：front matter 没有 --- 包裹，补上
  const lines = t.split("\n");
  let start = 0;
  while (start < lines.length && lines[start].trim() === "") start++;

  const fm = [];
  let i = start;
  while (i < lines.length && KEY_RE.test(lines[i])) {
    fm.push(fixColon(lines[i].trimEnd()));
    i++;
  }
  if (fm.length === 0) return null;

  const rest = lines.slice(i).join("\n").replace(/^\n+/, "");
  return "---\n" + fm.join("\n") + "\n---\n\n" + rest;
}

let fixed = 0;
let scanned = 0;

for (const dir of DIRS) {
  if (!fs.existsSync(dir)) continue;
  for (const name of fs.readdirSync(dir)) {
    if (!name.toLowerCase().endsWith(".md")) continue;
    const file = path.join(dir, name);
    scanned++;
    const raw = fs.readFileSync(file, "utf8");
    const repaired = tryRepair(raw);
    if (repaired === null) continue;
    fs.writeFileSync(file, repaired, "utf8");
    fixed++;
    console.log(`  修复: ${path.relative(ROOT, file)}`);
  }
}

console.log(`[repair-front-matter] 扫描 ${scanned} 个文件，修复 ${fixed} 个`);
