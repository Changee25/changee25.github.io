# AMOUR 的博客 · Hexo + Fluid 使用说明

原来的 Jekyll 站点（`D:\DSH\changee25.github.io`）已经**换成新站的内容**，现在：

| 东西 | 位置 | 说明 |
|---|---|---|
| 站点源码 | `D:\DSH\hexo-blog` | Hexo + Fluid，改内容在这里 |
| 发布仓库 | `D:\DSH\changee25.github.io` | 工作区已是新站构建产物，**已提交、待推送** |
| 旧版备份 | `D:\DSH\changee25.github.io-jekyll备份-20261112-0126.zip` | 另外完整旧版在 git 历史 `d77989d` 里 |
| 本地预览 | `http://localhost:4020/` | 我在跑 `hexo server`，看完关掉即可 |

**当前状态：`main` 比线上多 1 个提交（`a9e989d`），推到 GitHub 就上线。**

---

## 一、你的要求都做在哪了

| 要求 | 实现位置 | 状态 |
|---|---|---|
| 主页背景换成压缩包那张图 | `source/img/banner.jpg`（10000×5625 → 1920×1080 / 262 KB），`_config.fluid.yml` → `index.banner_img` | ✅ |
| 左上角换成头像 + 昵称 AMOUR | 文字 `navbar.blog_title`；头像走 `source/css/custom.css` 的 `::before`，文件 `source/img/avatar.jpg` | ✅ |
| 图 3 的文字换成那句英文 | `index.slogan.text` + `fun_features.typing` | ✅ |
| 去掉 文档/搜索/分类/社群 | `navbar.menu` 只有 首页·文章·日记·友链·关于 + 日夜切换 | ✅ |
| 不删文章 | 两篇正文原样迁移，仅 `excerpt:` → `description:` | ✅ |
| 不依赖外链 CDN | 21 个文件下到 `source/vendor/`，`scripts/localize-cdn.js` 构建时改写 | ✅ |
| 用新站替换旧站 | 旧仓库工作区已替换 + 提交 `a9e989d` | ✅ 待你 push |

---

## 二、换头像 / 换标签图标

### 一条命令（自动裁正方形 + 自动生成 favicon）

```powershell
cd D:\DSH\hexo-blog
powershell -ExecutionPolicy Bypass -File tools\update-avatar.ps1 -ImagePath "C:\你的图片\头像.png"
```

做三件事：居中裁正方形 → `source\img\avatar.jpg`（512×512 JPEG，导航栏+关于页用）→ `source\img\avatar-favicon.png`（64×64，浏览器标签图标）。原图不动。

只想看效果不覆盖：加 `-OutDir D:\tmp\test`。

### 手动覆盖

| 换什么 | 覆盖哪个文件 |
|---|---|
| 头像 | `source\img\avatar.jpg` |
| 标签图标 | `source\img\avatar-favicon.png` |

**后缀不能改**（配置里写死了 `/img/avatar.jpg`、`/img/avatar-favicon.png`）。改完跑一次构建 + 同步（见第五节）。

---

## 三、日常命令

本机没有全局 node，所以用 `npx`（装了 Node.js 之后才有）。

```bash
npx hexo server      # 预览 http://localhost:4000
npx hexo generate    # 构建到 public/
npx hexo clean       # 清缓存
npx hexo new "标题"  # 新建文章
```

| 想改什么 | 改哪里 |
|---|---|
| 首屏大图 | 覆盖 `source/img/banner.jpg` |
| 昵称 | `_config.fluid.yml` → `navbar.blog_title`、`about.name` |
| 那句英文 | `index.slogan.text`，顺带 `_config.yml` 的 `subtitle`、`about.intro` |
| 导航项 | `navbar.menu`（图标：`icon-home-fill` `icon-articles` `icon-archive-fill` `icon-date-fill` `icon-tags-fill` `icon-link-fill` `icon-user-fill`） |
| 友链 | `links.items` |
| 首屏高度/压暗 | `index.banner_img_height`、`index.banner_mask_alpha` |

---

## 四、上线 & 回滚

### 现在只差推送

**方式 A：GitHub Desktop**（推荐）
打开 GitHub Desktop → 它已经认得 `D:\DSH\changee25.github.io` 这个仓库（如果没加过：File → Add local repository）→ 会显示 1 个待推送提交 → 点 **Push origin**。

**方式 B：命令行**
```powershell
cd D:\DSH\changee25.github.io
D:\tools\Git\cmd\git.exe push origin main
# Username: Changee25    Password: 粘 Personal Access Token（GitHub → Settings → Developer settings，勾 repo）
```

> 我这边推不了：机器上没有任何 git 凭据（`could not read Username`），不是仓库的问题。
> 这次是**普通推送**，不用 force——新的提交接在线上历史（`d77989d`）后面。

推完等 1~2 分钟，https://changee25.github.io 就是新版。`.nojekyll` 已提交，GitHub Pages 会直接静态发布，不再跑 Jekyll。

### 想退回旧版（Jekyll）

```powershell
cd D:\DSH\changee25.github.io
D:\tools\Git\cmd\git.exe revert a9e989d --no-edit    # 生成一个“撤销替换”的提交
D:\tools\Git\cmd\git.exe push origin main
```

或者只想要旧代码不推送：`git reset --hard d77989d`。

---

## 五、以后改完内容怎么发布

```powershell
# 1) 重新构建
cd D:\DSH\hexo-blog
npx hexo clean
npx hexo generate

# 2) 同步进仓库并提交（robocopy 会镜像，保护 .git）
powershell -ExecutionPolicy Bypass -File tools\sync-to-repo.ps1

# 3) 去 GitHub Desktop 点 Push origin
```

也可以一步到位：`powershell -ExecutionPolicy Bypass -File tools\sync-to-repo.ps1 -Build`（会把构建也一起跑了，前提是装了 Node）。

> 为什么源码和发布仓库分开：GitHub Pages 只能发布静态文件。`hexo-blog` 存源码，`changee25.github.io` 存构建结果——这也是 Hexo 社区的标准做法。

---

## 六、目录结构

```
D:\DSH\hexo-blog\                 ← 源码（改这里）
├─ _config.yml                    站点：域名、网址格式、deploy 配置
├─ _config.fluid.yml              主题：导航、首屏、头像、友链、页脚
├─ scripts/localize-cdn.js        构建钩子：外链改本地 + 生成 .nojekyll
├─ tools/
│  ├─ update-avatar.ps1           一键换头像 + favicon
│  ├─ sync-to-repo.ps1            构建产物同步进发布仓库并提交
│  └─ localize-cdn.js             一次性工具：把新的外链资源下到 source/vendor/
├─ source/
│  ├─ _posts/                     文章
│  ├─ about|diary|links/          页面
│  ├─ css/custom.css              导航栏头像、窄屏字号
│  ├─ img/                        banner.jpg / avatar.jpg / avatar-favicon.png
│  └─ vendor/                     本地化的 jQuery/Bootstrap/typed.js/图标字体
└─ public/                        构建产物

D:\DSH\changee25.github.io\       ← 发布仓库（已放好新站内容，待 push）
```

---

## 七、还需要知道的

1. **CDN 已本地化**：jQuery / Bootstrap / typed.js / fancybox / tocbot / nprogress / clipboard / anchor + 两个图标字体，共 21 个文件在 `source/vendor/`。以后升级主题若冒出新的外链，跑一次 `node tools/localize-cdn.js` 再构建即可。
2. **分类/标签页仍会生成**（`/categories/`、`/tags/`），只是没有导航入口。
3. **评论区是关的**。想开：`_config.fluid.yml` → `post.comments.enable: true`，再选 giscus / waline / twikoo。
4. **旧链接不变**：`/2026/10/31/php-basics/` 这类地址和原来一致。
5. **这台机器的 PATH 是坏的**（`robocopy`、`xcopy`、`netstat` 直接敲都找不到），所以脚本里都用了完整路径 `C:\Windows\System32\...`，你手动敲命令时注意一下。
6. `.npmrc` / `pnpm-workspace.yaml` 是装依赖时的配置（国内 npmmirror 源），日常用不到。

---

## 八、这次做了什么

- 建 Hexo 站点，装 hexo 8.1.2 + Fluid 1.9.9 及配套渲染器/生成器
- 迁移 2 篇文章 + 关于/日记/友链 3 页；友链数据从 `_data/friends.yml` 挪进主题配置
- 壁纸压成 banner.jpg；你的头像裁成 avatar.jpg + avatar-favicon.png
- `custom.css`：导航栏头像 + 昵称、窄屏副标题字号
- CDN 本地化（21 个文件）+ 构建钩子 + `.nojekyll`
- 逐页截图验证：首页、文章页、友链页、关于页、归档页、手机端、坏代理环境
- 旧仓库同步到线上最新（`d77989d`）后替换内容并提交（`a9e989d`），保留 Jekyll 备份 zip
