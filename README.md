# AMOUR 的博客 · 使用说明

**已上线**：https://changee25.github.io

| 东西 | 位置 | 谁维护 |
|---|---|---|
| 线上站点 | `main` 分支（构建产物） | **GitHub Actions 自动写，你别手动改** |
| 站点源码 | `src` 分支 ← 本目录 `D:\DSH\hexo-blog` | 你（Typora 写文章、改配置） |
| 旧版备份 | `D:\DSH\changee25.github.io-jekyll备份-20261112-0126.zip` + git 历史 `d77989d` | — |

一图流：

```
Typora 写 md  →  source/_posts  →  GitHub Desktop 提交+推送 src
                                        ↓（GitHub Actions 自动跑 hexo generate）
                                   main 分支  →  GitHub Pages  →  changee25.github.io
```

---

## 一、写作和发布（你最关心的）

### 一条文章从写到上线

1. **建文章**（挑一种）
   - 用脚本（推荐，会自动补 front matter）：
     ```powershell
     cd D:\DSH\hexo-blog
     powershell -ExecutionPolicy Bypass -File tools\new-post.ps1 -Title "文章标题" -Category 随笔 -Tags 日记,随笔 -Open
     ```
     会自动生成 `source\_posts\2026-11-12-文章标题.md` 并用 Typora 打开。
   - 或者自己在 `D:\DSH\hexo-blog\source\_posts\` 新建 `.md`，开头手写：
     ```yaml
     ---
     title: 文章标题
     date: 2026-11-12 20:00:00
     categories: 随笔
     tags: [日记, 随笔]
     description: 一句话摘要（首页卡片显示这句）
     ---
     ```
2. **用 Typora 写正文**，图片放 `D:\DSH\hexo-blog\source\img\`，正文里写 `![说明](/img/图片名.png)`
3. **提交推送**：打开 GitHub Desktop → 选 `hexo-blog` 这个仓库 → 左下角填一句提交信息 → **Commit to src** → 右上角 **Push origin**
4. **等 1~2 分钟**，GitHub Actions 自动构建发布（仓库页 **Actions** 标签能看到进度），刷新 https://changee25.github.io 就是新文章

### 关于「装了 Git 就够了吗」

**只装 Git 不够**：Typora 写的是 Markdown，GitHub Pages 只能发 HTML，中间必须有 `hexo generate` 这一步。

但现在**配了 GitHub Actions，构建在云端跑**，所以你这边确实只需要 Git（GitHub Desktop 里自带）——
本机可以永远不装 Node.js，改 md → 推送 → 机器人构建发布。

> 唯一装 Node 的理由是：想在**本地预览**再推送（`npx hexo server` 看 http://localhost:4000）。
> 装了 Node.js LTS 之后 `npx hexo server` 就能用；不装也能写文章，只是发布前看不到本地效果。

### 注意：以后别手动推 main

main 分支现在归机器人管。你只要动 `src`，别在 main 上提交，否则会被下一次自动发布覆盖。

---

## 二、换头像 / 换标签图标

```powershell
cd D:\DSH\hexo-blog
powershell -ExecutionPolicy Bypass -File tools\update-avatar.ps1 -ImagePath "C:\你的图片\头像.png"
```

自动：居中裁正方形 → `source\img\avatar.jpg`（512×512 JPEG，导航栏+关于页）→ `source\img\avatar-favicon.png`（64×64，标签图标）。原图不动。

手动也能覆盖这两个文件，**后缀不能改**（配置里写死了路径）。

---

## 三、你的各项要求对应在哪

| 要求 | 实现位置 | 状态 |
|---|---|---|
| 主页背景换成压缩包那张图 | `source/img/banner.jpg`（原图 10000×5625 → 1920×1080 / 262 KB），`_config.fluid.yml` → `index.banner_img` | ✅ 已上线 |
| 左上角换成头像 + 昵称 AMOUR | 文字 `navbar.blog_title`；头像走 `source/css/custom.css` 的 `::before`，文件 `source/img/avatar.jpg` | ✅ 已上线 |
| 图 3 文字换成那句英文 | `index.slogan.text` + `fun_features.typing` 打字机 | ✅ 已上线 |
| 去掉 文档(安装主题/图标用法)、搜索、分类、社群 | `navbar.menu` 只剩 首页·文章·日记·友链·关于 + 日夜切换 | ✅ 已上线 |
| 不删文章 | 两篇正文原样迁移，仅 `excerpt:` → `description:` | ✅ |
| 不依赖外部 CDN | 21 个文件下到 `source/vendor/`，`scripts/localize-cdn.js` 构建时改写 | ✅ |
| 用新站替换旧站 | main 分支已换成新站，`.nojekyll` 已提交 | ✅ 已上线 |

---

## 四、日常改动速查

| 想改什么 | 改哪里 |
|---|---|
| 首屏大图 | 覆盖 `source/img/banner.jpg`（建议 1920×1080、300 KB 内） |
| 昵称 | `_config.fluid.yml` → `navbar.blog_title`、`about.name` |
| 那句英文 | `index.slogan.text`；顺带 `_config.yml` 的 `subtitle`、`about.intro` |
| 导航项 | `navbar.menu`（图标：`icon-home-fill` `icon-articles` `icon-archive-fill` `icon-date-fill` `icon-tags-fill` `icon-link-fill` `icon-user-fill`） |
| 友链 | `_config.fluid.yml` → `links.items` |
| 首屏高度/压暗 | `index.banner_img_height`（100=整屏）、`index.banner_mask_alpha` |
| 关于页正文 | `source/about/index.md` |
| 日记 | `source/diary/index.md` |

---

## 五、本地预览（可选，需要 Node.js）

```bash
npx hexo server      # http://localhost:4000
npx hexo clean       # 改了配置不生效时先清缓存
```

---

## 六、出问题怎么办

| 现象 | 原因 / 处理 |
|---|---|
| 推了 src 但线上没变 | 看仓库 **Actions** 标签：绿勾=构建完，红叉=失败。失败点进去看日志 |
| Actions 报 `403 / permission denied` | 仓库 **Settings → Actions → General → Workflow permissions** 选 **Read and write**，再点 Actions 页面的 **Re-run** |
| 浏览器还是旧页面 | `Ctrl+F5` 强刷；或等 1~2 分钟 |
| 想退回旧版 Jekyll | 仓库里 `git revert a9e989d` 后推 main；或从备份 zip 恢复 |
| 分类/标签页还在 | `/categories/` `/tags/` 会照常生成，只是没有导航入口，不影响 |
| 想开评论区 | `_config.fluid.yml` → `post.comments.enable: true`，再选 giscus / waline / twikoo，我可以帮你配 |

---

## 七、目录结构

```
D:\DSH\hexo-blog\                 ← 源码仓库（src 分支）
├─ .github/workflows/deploy.yml   推 src 自动构建并发布 main
├─ _config.yml                    站点：域名、网址格式
├─ _config.fluid.yml              主题：导航、首屏、头像、友链、页脚
├─ scripts/localize-cdn.js        构建钩子：外链改本地 + 生成 .nojekyll
├─ tools/
│  ├─ new-post.ps1                新建文章（带 front matter）
│  ├─ update-avatar.ps1           一键换头像 + favicon
│  ├─ sync-to-repo.ps1            （备用）本地构建后手动同步到发布仓库
│  └─ localize-cdn.js             一次性工具：把新的外链资源下到 source/vendor/
├─ source/
│  ├─ _posts/                     文章（Typora 写这里）
│  ├─ about|diary|links/          页面
│  ├─ css/custom.css              导航栏头像、窄屏字号
│  ├─ img/                        banner.jpg / avatar.jpg / avatar-favicon.png
│  └─ vendor/                     本地化的 jQuery/Bootstrap/typed.js/图标字体
└─ public/                        本地构建产物（不提交）

D:\DSH\changee25.github.io\       ← 发布仓库（= main 分支的副本，只读参考）
```

---

## 八、这台机器的两个坑

1. **PATH 是坏的**：`robocopy`、`xcopy`、`netstat`、`find` 直接敲都提示“不是内部或外部命令”。脚本里我都写了完整路径（`C:\Windows\System32\...`），你手动敲命令时注意。
2. **系统代理（Clash 127.0.0.1:7897）目前返回 502**：所有外链资源我都本地化了，所以网站不受影响；但你自己 npm / git 联网可能不稳，需要时把代理修好或关掉。
