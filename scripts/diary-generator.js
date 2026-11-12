/**
 * 日记生成器：一天一篇 → 自动倒序 + 分页
 *
 * 数据来源：source/_diary/*.md（下划线开头，Hexo 不会把它当文章或静态文件处理）
 * 文件格式：
 *   ---
 *   date: 2026-11-12
 *   title: 2026-11-12 & 13   # 可选，想自定义显示标题时才写
 *   ---
 *   正文（Markdown）
 *
 * 输出：/diary/ 、/diary/page/2/ …（模板用主题的 page 布局，
 * 所以导航栏、头图、页脚和别的页面完全一致）
 */
const fs = require("fs");
const path = require("path");

const PER_PAGE = 3; // 每页显示几天，想改就改这里
const DIR = "_diary";
const TITLE = "日记";

function splitFrontMatter(raw) {
  const text = raw.replace(/^\uFEFF/, "").replace(/\r\n/g, "\n");
  const m = text.match(/^---\n([\s\S]*?)\n---\n?([\s\S]*)$/);
  if (!m) return { data: {}, body: text.trim() };
  const data = {};
  for (const line of m[1].split("\n")) {
    const kv = line.match(/^([A-Za-z_][\w-]*)\s*:\s*(.*)$/);
    if (!kv) continue;
    let v = kv[2].trim();
    if ((v.startsWith('"') && v.endsWith('"')) || (v.startsWith("'") && v.endsWith("'"))) {
      v = v.slice(1, -1);
    }
    data[kv[1]] = v;
  }
  return { data, body: m[2].trim() };
}

function esc(s) {
  return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

function buildPager(current, total, root) {
  if (total <= 1) return "";
  const href = (n) => `${root}diary/` + (n === 1 ? "" : `page/${n}/`);
  const parts = [];
  if (current > 1) {
    parts.push(`<a class="extend prev" rel="prev" href="${href(current - 1)}"><i class="iconfont icon-arrowleft"></i></a>`);
  }
  for (let n = 1; n <= total; n++) {
    parts.push(
      n === current
        ? `<span class="page-number current">${n}</span>`
        : `<a class="page-number" href="${href(n)}">${n}</a>`
    );
  }
  if (current < total) {
    parts.push(`<a class="extend next" rel="next" href="${href(current + 1)}"><i class="iconfont icon-arrowright"></i></a>`);
  }
  return `<nav aria-label="navigation"><span class="pagination" id="pagination">${parts.join("\n")}</span></nav>`;
}

hexo.extend.generator.register("diary", function () {
  const dir = path.join(hexo.source_dir, DIR);
  if (!fs.existsSync(dir)) return [];

  const entries = fs
    .readdirSync(dir)
    .filter((f) => f.toLowerCase().endsWith(".md"))
    .map((f) => {
      const base = path.basename(f, path.extname(f));
      const { data, body } = splitFrontMatter(fs.readFileSync(path.join(dir, f), "utf8"));
      const dateText = (data.date || base).trim();
      const ts = Date.parse(dateText);
      return {
        dateText,
        label: (data.title || dateText).trim(),
        anchor: "d" + dateText.replace(/[^\d]/g, ""),
        ts: isNaN(ts) ? 0 : ts,
        html: hexo.render.renderSync({ text: body, engine: "markdown" })
      };
    })
    .sort((a, b) => (b.ts - a.ts) || b.dateText.localeCompare(a.dateText));

  if (entries.length === 0) return [];

  const root = (hexo.config.root || "/").replace(/\/?$/, "/");
  const total = Math.max(1, Math.ceil(entries.length / PER_PAGE));
  const pages = [];

  for (let i = 0; i < total; i++) {
    const chunk = entries.slice(i * PER_PAGE, (i + 1) * PER_PAGE);
    const body = chunk
      .map(
        (e) => `<section class="diary-entry" id="${e.anchor}">
  <h3 class="diary-date">${esc(e.label)}</h3>
  <div class="diary-body">${e.html}</div>
</section>`
      )
      .join("\n");

    pages.push({
      path: i === 0 ? "diary/index.html" : `diary/page/${i + 1}/index.html`,
      layout: "page",
      data: {
        title: TITLE,
        subtitle: i === 0 ? TITLE : `${TITLE} · 第 ${i + 1} 页`,
        content: body + buildPager(i + 1, total, root)
      }
    });
  }

  return pages;
});
