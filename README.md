# 用 DSH + GitHub Pages 搭个人博客

这个目录已经是一个可以直接发布的 Jekyll 博客。整件事分三步：**本地生成 → 推到 GitHub → 写好第一篇**。

---

## 0. 目录结构

```
blog/
├── _config.yml               # 站点配置（标题、作者、网址、主题）
├── Gemfile                   # 仅本地预览需要
├── .gitignore
├── index.md                  # 首页，自动列出所有文章
├── about.md                  # 「关于」页
└── _posts/
    └── 2026-10-25-first-meeting.md   # 第一次例会（空模板，待你填）
```

Jekyll 的规则很简单：**`_posts/` 里放 Markdown，首页自动出列表**。文件名必须是 `年-月-日-标题.md`，开头的 front matter 决定标题和日期。

---

## 1. 填掉剩下的占位符

站点地址已经按你的账号 `Changee25` 填好（`_config.yml` 里的 `url`），仓库名请用 **`changee25.github.io`**。

还需要改的只有个人内容：

1. `_config.yml` 里的 `title`、`description`、`author`、`email`
2. `about.md` 里的自我介绍和邮箱
3. `_posts/2026-10-25-first-meeting.md` 里的 `【 】` 内容

仓库名决定网址：

| 仓库名 | 网址 | `baseurl` |
| --- | --- | --- |
| `changee25.github.io` | `https://changee25.github.io` | `""`（已设好） |
| `blog` 等其他名字 | `https://changee25.github.io/blog/` | `"/blog"` |

**用 `changee25.github.io`**，网址最短，`baseurl` 留空不用管。

---

## 2. 推到 GitHub

这个目录**已经是一个初始化好的 git 仓库**，并且完成了第一次提交（分支 `main`）。剩下只差一个远端：

**方式 A：用 GitHub Desktop（最省事，已装在你机器上）**

1. 打开 GitHub Desktop → `File → Add local repository…` → 选 `D:\DSH\blog`
2. 右上角 `Publish repository`
3. 仓库名填 `changee25.github.io`，**取消勾选** `Keep this code private`（Pages 免费版必须公开）
4. `Publish`，登录过一次之后鉴权它全包了

**方式 B：命令行**

先在 GitHub 网页上新建仓库 `changee25.github.io`（**公开**，不要勾 README / .gitignore，避免冲突），然后：

```bash
cd D:\DSH\blog
git remote add origin https://github.com/changee25/changee25.github.io.git
git push -u origin main
```

（推送到 GitHub 不能用账号密码，要么用 Personal Access Token，要么走 SSH。这是方式 A 更省事的原因。）

推送完成后：

1. 打开仓库 → **Settings → Pages**
2. **Source** 选 `Deploy from a branch`，分支选 `main`，目录选 `/ (root)`
3. 等 1–2 分钟，访问 <https://changee25.github.io>

> GitHub Pages 原生支持 Jekyll，**不需要写任何 Actions 工作流**，推上去自动构建。

---

## 3. 写新文章

复制一份模板改名即可：

```
_posts/2026-11-01-some-topic.md
```

最小可用内容：

```markdown
---
layout: post
title: "文章标题"
date: 2026-11-01 20:00:00 +0800
categories: 随笔
tags: [标签一, 标签二]
---

正文从这里开始，正常写 Markdown 就行。
```

推送后 1–2 分钟自动上线。想改外观，只改 `_config.yml` 里的 `theme`，GitHub Pages 支持的主题见 <https://pages.github.com/themes/>。

---

## 4. 本地预览（可选）

线上构建一次要等一两分钟，改样式时本地预览更快。需要装 Ruby 3.x，然后：

```bash
bundle install
bundle exec jekyll serve --livereload
```

浏览器打开 <http://127.0.0.1:4000>。改文件会自动刷新。
不想装 Ruby 也可以跳过这步——直接推，看线上效果。

---

## 5. 常见坑

| 现象 | 原因 |
| --- | --- |
| 页面 404 | 仓库不是公开的，或 Pages 的 Source 没设成 `main` / `root` |
| 样式全丢、链接 404 | 项目仓库忘了把 `baseurl` 改成 `"/仓库名"` |
| 文章不出现 | 文件名不是 `年-月-日-标题.md`，或 front matter 里 `date` 与文件名日期冲突 |
| 构建失败 | 仓库 **Actions** 标签页里看红色报错，通常是 YAML 缩进或 front matter 里的冒号没加引号 |
| 中文标题乱码 | 文件保存为 UTF-8，`title` 建议用英文引号包起来：`title: "第一次例会"` |
| 推送要密码 | GitHub 已不支持密码，用 Personal Access Token 或 SSH key |

---

## 6. 让 DSH 接管后续维护

搭好之后，日常只需要对 DSH 说：

- **写新文章**：「在 `D:\DSH\blog\_posts` 下新建一篇关于 XXX 的文章，日期 2026-11-05，tags 用 学习/笔记，正文按我给的要点展开」
- **改样式**：「把主题换成 minima 的 dark skin，顶部导航加上标签页」
- **发布**：「提交并推送到 origin main，commit message 写『新增 XXX 文章』」
- **排查**：「Pages 构建失败了，看日志告诉我哪里错了」

DSH 能直接读写这个目录、执行 git，所以除了填内容，其余都可以交给它。
