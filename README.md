# AMOUR 的博客 · 使用说明

**线上**：https://changee25.github.io

| 东西 | 位置 | 谁维护 |
|---|---|---|
| 线上站点 | `main` 分支（构建产物） | **GitHub Actions 自动写，别手动改** |
| 站点源码 | `src` 分支 ← 本目录 `D:\DSH\hexo-blog` | 你（Typora 写文章、改配置） |
| 旧版备份 | `D:\DSH\changee25.github.io-jekyll备份-20261112-0126.zip` + git 历史 `d77989d` | — |

```
Typora 写 md  →  source/_posts  →  GitHub Desktop 提交+推送 src
                                        ↓（Actions 自动 hexo generate）
                                   main 分支  →  GitHub Pages  →  线上
```

---

## 一、写文章并发布

1. **建文章**（最省事：双击项目根目录的 **`新建文章.bat`**，按提示输标题 / 分类 / 标签，会自动生成 md 并打开 Typora）
   命令行也行：
   ```powershell
   cd D:\DSH\hexo-blog
   powershell -ExecutionPolicy Bypass -File tools\new-post.ps1 -Title "文章标题" -Category 随笔 -Tags 日记,随笔 -Open
   ```
   或者直接在 `source\_posts\` 新建 `.md`（文件名建议 `2026-11-12-english-slug.md`），开头写：
   ```yaml
   ---
   title: 文章标题
   date: 2026-11-12 20:00:00
   categories: 随笔
   tags: [日记, 随笔]
   description: 一句话摘要（首页卡片显示这句）
   index_img: /img/cover-default.jpg   # 可选，不给就用默认封面
   ---
   ```
2. **Typora 写正文**，图片放 `source\img\`，正文写 `![说明](/img/图片名.png)`（**开头要带 `/`**）
3. **推送**：GitHub Desktop → 选 `hexo-blog` 仓库 → 填提交信息 → **Commit to src** → **Push origin**
4. **等 1~2 分钟**，Actions 自动构建发布（仓库页 **Actions** 标签看进度）

> 只装 Git 够不够？**够**——构建在云端跑，本机不用装 Node.js。
> 想发布前本地预览才需要装 [Node.js LTS](https://nodejs.org/zh-cn)，然后 `npx hexo server`。

### 只用 Typora 写（完全不碰脚本 / 命令行）

Typora 自带文件树，可以直接把 `source` 文件夹当工作目录用：

1. Typora 菜单 **File → Open Folder**（打开文件夹），选：
   ```
   D:\DSH\hexo-blog\source
   ```
2. 左侧文件树里右键新建：
   | 写什么 | 在哪个文件夹 | 文件怎么命名 |
   |---|---|---|
   | 新文章 | `_posts` | `2026-11-13-english-slug.md`（日期-英文短名） |
   | 新日记 | `_diary` | `2026-11-13.md`（**只要日期**） |
3. 文件开头要有 front matter。Typora 里**先打 `---` 再回车**，会自动变成 YAML 元数据块，照着填：

   ```yaml
   ---
   title: 文章标题                      # 日记可省
   date: 2026-11-13 20:00:00
   categories: 随笔                     # 日记可省
   tags: [日记]                         # 日记可省
   description: 一句话摘要              # 日记可省
   ---
   ```
4. 懒得记格式就直接**复制模板**（放在 `source\_templates\`，这个目录 Hexo 不会发布）：
   - `文章模板.md`
   - `日记模板.md`
5. 写完保存 → GitHub Desktop → 推 `src` → 1~2 分钟自动上线

> 注意：**文章必须有 `title` 和 `date`**；日记只靠文件名日期也能排（`date` 写了优先用 `date`）。
> 文件夹里的 `_templates`、`_diary`、`_posts` 都是以 `_` 开头，Hexo 不会把它们当普通页面发布。

### 或者双击脚本（现在也会用 Typora 打开）

`.md` 的默认打开程序是 **WorkBuddy**，不是 Typora，所以脚本已经改成**显式调用 `D:\tools\Typora\Typora.exe`**。
换编辑器就改 `tools\_open-editor.ps1` 里的候选路径列表。

---

## 二、换头像 / 标签图标

```powershell
cd D:\DSH\hexo-blog
powershell -ExecutionPolicy Bypass -File tools\update-avatar.ps1 -ImagePath "C:\你的图片\头像.png"
```

自动：居中裁正方形 → `source\img\avatar.jpg`（512×512，导航栏+关于页）→ `source\img\avatar-favicon.png`（64×64，标签图标）。原图不动。手动覆盖这两个文件也行，**后缀不能改**。

---

## 三、文章封面图

规则很简单：文章 front matter 里写一行 `index_img`，首页卡片左边就会显示这张图。

| 想怎样 | 怎么做 |
|---|---|
| 这篇文章用某张图 | front matter 加 `index_img: /img/你的图.jpg` |
| 不想每篇都配 | 什么都不用写，自动用默认封面 `post.default_index_img`（现在是 `cover-default.jpg`） |
| 换默认封面 | 覆盖 `source/img/cover-default.jpg`，或改 `_config.fluid.yml` → `post.default_index_img` |
| 文章页顶部大图（不是卡片） | `_config.fluid.yml` → `post.banner_img`（现在 `banner-post.jpg`）；单篇要不一样就在 front matter 写 `banner_img` |

**当前用的图**（都在 `source/img/`，可以直接换成自己的）：

| 文件 | 用在哪 | 大小 |
|---|---|---|
| `banner.jpg` | 首页首屏大图（你上传的初音未来） | 262 KB |
| `banner-post.jpg` | 所有文章页顶部（黄昏电线杆） | 202 KB |
| `cover-default.jpg` | 新文章默认封面（雪山森林） | 68 KB |
| `cover-first-meeting.jpg` / `cover-php-basics.jpg` | 两篇现有文章的卡片封面 | 113 / 56 KB |

> ⚠️ 封面这套图和文章页头图是从 **Fluid 官方 demo 站**扒下来的（`fluid.s3.bitiful.net/bg/`）。
> 自己练手/个人用没问题，但如果以后要给很多人看、或想商用，建议换成自己的图（原创插画、Unsplash、或者买了授权的素材）。

**尺寸建议**：卡片封面 1200×750（16:10），文章页头图 1920×1080，单张压到 300 KB 内。

---

## 四、评论区（utterances）

已经配好了，用的是 **utterances**（把评论存成仓库里的 GitHub Issue，免费、无广告、不用服务器）。

**只差一步：给仓库装一次 App**

1. 打开 https://github.com/apps/utterances → **Install**
2. 选 **Only select repositories** → 勾 `Changee25/changee25.github.io` → Install
3. 打开任意一篇文章页，底部就能看到评论框；第一次有人评论时，仓库里会自动建一个同名 Issue

配置在 `_config.fluid.yml`：

```yaml
post:
  comments:
    enable: true
    type: utterances
utterances:
  repo: "Changee25/changee25.github.io"
  issue_term: pathname   # 一篇文章对应一个 Issue
  theme: github-light
  theme_dark: github-dark
```

**想换成 giscus（界面更漂亮，支持表情回应）**：需要去 https://giscus.app 填一下仓库，拿到 `repo-id` 和 `category-id` 两个值（这两个只能登录后生成，我用不了），然后把 `type` 改成 `giscus` 并填进 `giscus:` 那几行。想要就说，我帮你改。

**想关掉**：`post.comments.enable: false`。

---

## 五、你的各项要求对应在哪

| 要求 | 实现位置 | 状态 |
|---|---|---|
| 主页背景换成压缩包那张图 | `source/img/banner.jpg`，`index.banner_img` | ✅ 已上线 |
| 左上角头像 + 昵称 AMOUR | `navbar.blog_title` + `custom.css` 的 `::before`（图：`avatar.jpg`） | ✅ 已上线 |
| 那句英文打字机 | `index.slogan.text` + `fun_features.typing` | ✅ 已上线 |
| 去掉 文档/搜索/分类/社群 | `navbar.menu` 只留 首页·文章·日记·友链·关于 + 日夜切换 | ✅ 已上线 |
| 不删文章 | 两篇正文原样迁移，`excerpt:` → `description:` | ✅ |
| 不依赖外部 CDN | 21 个文件下到 `source/vendor/`，构建钩子改写路径 | ✅ |
| 替换旧站 | `main` 已换成新站 + `.nojekyll` | ✅ 已上线 |
| 文章封面 | `index_img` / `post.default_index_img` | ✅ 待推送 |
| 评论区 | `utterances`（需装一次 App） | ✅ 待推送 |

---

## 六、日常改动速查

| 想改什么 | 改哪里 |
|---|---|
| 首屏大图 | 覆盖 `source/img/banner.jpg` |
| 昵称 | `_config.fluid.yml` → `navbar.blog_title`、`about.name` |
| 那句英文 | `index.slogan.text`；顺带 `_config.yml` 的 `subtitle`、`about.intro` |
| 导航项 | `navbar.menu`（图标：`icon-home-fill` `icon-articles` `icon-archive-fill` `icon-date-fill` `icon-tags-fill` `icon-link-fill` `icon-user-fill`） |
| 友链 | `_config.fluid.yml` → `links.items` |
| 首屏高度/压暗 | `index.banner_img_height`（100=整屏）、`index.banner_mask_alpha` |
| 关于页正文 | `source/about/index.md` |
| 写日记 | 双击 **`写日记.bat`**（在 `source/_diary/` 建当天文件并打开 Typora） |
| 页脚 | `footer.content` |

### 日记是怎么组织的

改成「**一天一个文件 + 自动倒序 + 分页**」了：

```
source/_diary/
├─ 2026-10-27.md
├─ 2026-10-31.md   ← front matter 里 title: 2026-10-31 & 11-1（自定义这天显示的名字）
├─ 2026-11-02.md
└─ 2026-11-04.md
```

- 文件内容：
  ```yaml
  ---
  date: 2026-11-12
  title: 可选，想改显示的名字才写
  ---

  正文（Markdown，随便写几段）
  ```
- **不用管顺序**：`scripts/diary-generator.js` 会按 `date` 倒序生成 `/diary/`、`/diary/page/2/`……
- **每页显示几天**：改 `scripts/diary-generator.js` 顶部的 `PER_PAGE`（现在是 3）
- 生成出来的页面用的是主题的 `page` 布局，所以头图、导航、页脚和其他页面一致；条目样式在 `source/css/custom.css` 的「日记页」一节

---

## 七、出问题怎么办

| 现象 | 处理 |
|---|---|
| 推了 src 但线上没变 | 看 **Actions** 标签。红叉就点进去看日志 |
| Actions 报 403 | **Settings → Actions → General → Workflow permissions** 选 **Read and write**，然后 Re-run |
| 评论框显示 “utterances is not installed” | 去 https://github.com/apps/utterances 给仓库装一下（见第四节） |
| 浏览器还是旧页面 | `Ctrl+F5`；或等 1~2 分钟 |
| 想退回旧版 Jekyll | `git revert a9e989d` 后推 main；或用备份 zip |
| 分类/标签页还在 | `/categories/` `/tags/` 照常生成，只是没导航入口，不影响 |

---

## 八、目录结构

```
D:\DSH\hexo-blog\                 ← 源码仓库（src 分支）
├─ .github/workflows/deploy.yml   推 src 自动构建并发布 main
├─ _config.yml                    站点：域名、网址格式
├─ _config.fluid.yml              主题：导航、首屏、文章页、封面、评论、友链、页脚
├─ scripts/localize-cdn.js        构建钩子：外链改本地 + 生成 .nojekyll
├─ tools/
│  ├─ new-post.ps1                新建文章（带 front matter）
│  ├─ update-avatar.ps1           一键换头像 + favicon
│  ├─ sync-to-repo.ps1            （备用）本地构建后手动同步发布
│  └─ localize-cdn.js             一次性工具：把新的外链资源下到 source/vendor/
├─ source/
│  ├─ _posts/                     文章
│  ├─ about|diary|links/          页面
│  ├─ css/custom.css              导航栏头像、窄屏字号
│  ├─ img/                        banner.jpg / banner-post.jpg / avatar.jpg / cover-*.jpg
│  └─ vendor/                     本地化的 jQuery/Bootstrap/typed.js/图标字体
└─ public/                        本地构建产物（不提交）

D:\DSH\changee25.github.io\       ← 发布仓库（main 的副本，只读参考）
```

---

## 九、这台机器的坑

1. **PATH 是坏的**：`robocopy` `xcopy` `netstat` `find` 直接敲都提示“不是内部或外部命令”，脚本里我都写了完整路径。
2. **系统代理（Clash 127.0.0.1:7897）返回 502**：站点资源已全部本地化不受影响，但你自己 npm / git 联网可能不稳。
