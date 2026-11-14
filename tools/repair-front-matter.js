/**
 * 自动修复 front matter（在构建前跑，CI 里也会跑）
 *
 * 起因：从模板复制 / 在 Typora 里另存为时，开头的 `---` 很容易丢掉，
 * 一旦丢掉 Hexo 就认不出 front matter，文章会变成「没标题、正文开头多出 date: 字样」。
 * 这个脚本扫描 source/_posts 和 source/_diary，发现「有 key: value 但没有 --- 包裹」时自动补上。
 *
 * 用法：node tools/repair-front-matter.js
 */
const fs = require("fs");
const path = require("path");

const ROOT = path.resolve(__dirname, "..");
const DIRS = [
  path.join(ROOT, "source", "_posts"),
  path.join(ROOT, "source", "_diary")
];

const KEY_RE = /^[A-Za-z_][\w-]*\s*:/;
const log = [];

function tryRepair(text) {
  const t = text.replace(/\r\n/g, "\n");
  // 已经有合法的 front matter 就别动
  if (/^\s*---\n[\s\S]*?\n---(\n|$)/.test(t)) return null;

  const lines = t.split("\n");
  // 跳过开头的空行
  let start = 0;
  while (start < lines.length && lines[start].trim() === "") start++;

  const fm = [];
  let i = start;
  while (i < lines.length && KEY_RE.test(lines[i])) {
    fm.push(lines[i].trimEnd());
    i++;
  }
  if (fm.length === 0) return null; // 没东西可修

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
    log.push(`修复: ${path.relative(ROOT, file)}`);
  }
}

// 顺手提醒：日记文件名最好就是日期
const diaryDir = path.join(ROOT, "source", "_diary");
if (fs.existsSync(diaryDir)) {
  for (const name of fs.readdirSync(diaryDir)) {
    if (!name.toLowerCase().endsWith(".md")) continue;
    if (!/^\d{4}-\d{2}-\d{2}\.md$/.test(name)) {
      log.push(`提醒: 日记文件名不是日期格式 -> source/_diary/${name}（建议改成 2026-11-15.md）`);
    }
  }
}

console.log(`[repair-front-matter] 扫描 ${scanned} 个文件，修复 ${fixed} 个`);
for (const line of log) console.log("  " + line);
