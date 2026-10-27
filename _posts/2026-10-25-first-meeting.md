---
title: 第一次例会：前端基础与 HTTP 入门
date: 2026-10-22 20:00:00 +0800
categories: 团队
tags: [例会, CTF, Web, HTTP]
excerpt: 从装工具开始，到 URL、HTML、HTTP 报文，再到用 Docker 起一台靶机——这是第一次例会的完整内容，也是后面所有 Web 题的地基。
---

这次例会分成两半：前半段解决「工欲善其事」，把工具装好、配好；后半段讲真正的地基——URL、前端三件套、HTTP 报文。最后留了作业：抓人生第一个包，做完 CTFHub 的 HTTP 题。

## 例会前：把工具装好

### BurpSuite

压缩包里有破解教程，装不上可以看这个：[ddosi 的 BurpSuite 教程](https://www.ddosi.org/burpsuite-pro-bcheck/)

**强烈建议准备一个专门的 Web 渗透浏览器**，和平时用的分开。推荐火狐

- **Firefox**：装 FoxyProxy，用来和 BurpSuite 联动。参考 [CSDN 这篇](https://blog.csdn.net/curious233/article/details/113179504)
- **Chrome**：装 SwitchyOmega。参考 [这篇](https://www.cnblogs.com/ychun/p/17388369.html)

判断是否配好只有一个标准：**能抓到包**。

不过说实话，BurpSuite 自带的**内嵌浏览器**就够了，前期 80% 的 Web 题它都能应付。

### HackBar

装在浏览器里的，用来快速改请求参数、编解码。火狐按 readme 装就行；谷歌用 [这个](https://wiki.bafangwy.com/doc/620/)。

### Phpstudy

本地一键搭 PHP 环境，方便在自己电脑上跑一个 localhost 网站。

参考：[CSDN 教程](https://blog.csdn.net/Stupid__Angel/article/details/126806410)

⚠️  php 文件、html 文件都必须放在它的 `www` 目录下才能访问。

### VMware / WSL

装个 Ubuntu 就行。Windows 上最省事的还是 WSL，[官方文档](https://learn.microsoft.com/zh-cn/windows/wsl/install)，装的过程中遇到问题直接问 AI。

### Yakit

国产的渗透工具，图形化、功能全，适合不想配一堆插件的人。

- [GitHub 仓库](https://github.com/yaklang/yakit)
- [官网介绍](https://yaklang.io/products/intro/)

## 正式开始：URL、前端与 HTTP

想快速把概念过一遍，MDN 是最好的起点：[Web 开发入门](https://developer.mozilla.org/zh-CN/docs/Learn_web_development/Getting_started)，侧边栏可以按需挑着看。

## 前端基础

### URL

URL（Uniform Resource Locator）用来指示「怎么访问互联网上的某个资源」。你只要上过网，就已经在用它了。

一个 URL 由这些部分组成：

| 部分 | 含义 |
| --- | --- |
| Scheme | 协议，如 HTTP、HTTPS、FTP |
| User | 需要认证时可以在 URL 里写用户名密码 |
| Host / Domain | 目标服务器的域名或 IP |
| Port | 端口，HTTP 默认 80，HTTPS 默认 443，也可以用 1–65535 里任意一个 |
| Path | 资源在服务器上的路径 |
| Query String | 附加参数，比如 `/blog?id=1` |
| Fragment | 页面内的锚点，直接跳到某一段 |

端口不好理解的话可以这么想：**服务器是一栋房子，端口是通向不同房间（服务）的门。**

### HTML

参考：[MDN HTML 基础](https://developer.mozilla.org/zh-CN/docs/Learn/Getting_started_with_the_web/HTML_basics)

HTML 是超文本标记语言，用一系列**元素**包裹内容、定义结构。一个最基本的骨架：

```html
<!doctype html>
<html lang="zh-CN">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width">
    <title>页面标题</title>
  </head>
  <body>
    <h1>这里才是用户看到的内容</h1>
  </body>
</html>
```

- `<!doctype html>`：声明文档类型，现在主要作用是保证浏览器正常渲染
- `<html>`：根元素，`lang` 里写页面语种
- `<head>`：放「不想让用户直接看到」的东西——标题、字符集、CSS、SEO 关键词
- `<meta charset="utf-8">`：声明 UTF-8 编码，能覆盖世界上绝大多数文字
- `<meta name="viewport">`：让移动端按视口宽度渲染，不然内容会被缩小
- `<title>`：浏览器标签页上的文字
- `<body>`：用户能看到的全部内容

### CSS

参考：[MDN CSS 基础](https://developer.mozilla.org/zh-CN/docs/Learn/Getting_started_with_the_web/CSS_basics)

负责「长什么样」。**对理解 Web 请求来说用处不大**，知道它是控制样式的就够了。

### JavaScript

参考：[MDN JavaScript 基础](https://developer.mozilla.org/zh-CN/docs/Learn/Getting_started_with_the_web/JavaScript_basics)

和 PHP、Python 类似的编程语言，最初只跑在浏览器里做页面交互，现在有 Node.js 也能写后端。

## HTTP 报文

参考：[MDN HTTP 文档](https://developer.mozilla.org/zh-CN/docs/Web/HTTP)。东西很多，这里只挑重点。

### HTTP 是做什么的

HTTP 是一种用来获取资源的**协议**，是 Web 上一切数据交换的基础。

### 一次 HTTP 请求的流程

在浏览器控制台的 Network 面板里能完整看到这个过程：

1. **建立 TCP 连接**——用来发送一条或多条请求、接收响应。可以新建，也可以复用已有的
2. **发送请求报文**——HTTP/2 之前是人类可读的纯文本；HTTP/2 封进了帧里，但原理一样
3. **读取响应报文**
4. **关闭连接，或留着复用**

请求长这样：

```http
GET / HTTP/1.1
Host: developer.mozilla.org
Accept-Language: zh
```

响应长这样：

```http
HTTP/1.1 304 Not Modified
Date: Tue, 28 Oct 2025 14:23:56 GMT
Server: Apache/2.4.39 (Win64) OpenSSL/1.1.1b
Connection: Keep-Alive
Keep-Alive: timeout=5, max=100
ETag: "9bd-64238b2a3e677"
```

### 请求与响应

- **请求**：方法 + 路径 + 版本，然后是一堆 Header，空行之后是 Body
- **响应**：版本 + 状态码 + 说明，同样是一堆 Header，空行之后是 Body

### 状态码

参考：[MDN 状态码列表](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Status)

按首字母分组记：

| 段 | 含义 | 常见 |
| --- | --- | --- |
| 2xx | 成功 | 200 OK |
| 3xx | 重定向 / 缓存 | 301 永久跳转、302 临时跳转、304 未修改 |
| 4xx | 客户端的问题 | 400 参数错、403 禁止访问、404 找不到、405 方法不允许 |
| 5xx | 服务端的问题 | 500 内部错误、502 网关错误、503 服务不可用 |

### HTTP 方法

参考：[MDN 方法列表](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Reference/Methods)

- **GET**：从服务器拿信息
- **POST**：提交数据，可能新建记录
- **PUT**：提交数据，更新已有信息
- **DELETE**：删除记录

实际做题时 90% 是 GET 和 POST。

### 常见请求头与响应头

#### Origin

表示请求的**来源**（协议 + 主机 + 端口）。

```http
Origin: null
Origin: <scheme>://<hostname>
Origin: http://baidu.com:8080
```

⚠️ **这个头一般只出现在 CORS 跨域请求里，普通请求没有。**

#### Allow

响应头，列出资源支持哪些方法。服务器返回 **405 Method Not Allowed** 时应该同时带上它；如果 Allow 是空的，说明这个资源现在不接受任何方法的访问。

```http
Allow: GET, POST, HEAD
```

#### Host

指明请求要发到哪台主机、哪个端口。HTTP/1.1 里**必须**有，缺了或者写了多个，服务器可能直接回 400。

```http
Host: developer.mozilla.org
```

值得注意：TCP 连接是**先于** Host 头建立的，所以 Host 并不真的决定连到哪台机器。开发者如果做了不安全的校验，就会引出 Host 头相关的漏洞。

#### Referer

告诉服务器「我是从哪个页面点过来的」，用于统计、日志、防盗链。

```http
Referer: https://developer.mozilla.org/zh-CN/docs/Web/JavaScript
```

#### Set-Cookie

响应头，服务器用它把 cookie 塞给浏览器。要设多个 cookie 就发多条 Set-Cookie。

```
Set-Cookie: session=abc123; Domain=example.com; Path=/; HttpOnly; SameSite=Lax
```

几个关键属性：

**Domain（可选）** —— 这个 cookie 能送到哪些主机。只能设成当前域名或更高级别的域名，设了之后**对它和它的所有子域名都生效**；不设则默认只有当前主机（不含子域名）。

**HttpOnly（可选）** —— 禁止 JavaScript 通过 `document.cookie` 读到它，用来防 XSS。注意：带 HttpOnly 的 cookie **仍然会**跟着 `fetch`、`XMLHttpRequest` 发出去，只是脚本读不到值。

**SameSite（可选，CSRF 的重点）** —— 控制跨站请求要不要带上这个 cookie：

- `Strict`：只有同站请求才带，从别的域名点过来也不带
- `Lax`：跨站的图片、iframe 不带，但用户点链接导航过来会带；**不写时的默认值**
- `None`：跨站也带，但**必须同时加 `Secure`**，否则浏览器直接拒绝

#### Cookie

请求头，把之前服务器 Set-Cookie 存下来的东西带回去。多个用 `; ` 分隔。

```http
Cookie: PHPSESSID=298zf09hf012fh2; csrftoken=u32t4o3tb3gg43
```

#### X-Forwarded-For

用来标识**经过代理之后**客户端的真实 IP。客户端直连时服务器看到的就是它的 IP；一旦中间有代理，服务器只能看到最后一跳代理的 IP，所以有了这个头。

```http
X-Forwarded-For: <client>, <proxy1>, <proxy2>
```

最左边是原始客户端，最右边是最近的代理。**这个头可以被伪造**，很多权限绕过题就出在这里。

## Docker 在 CTF 里的用法

[下载地址](https://www.docker.com/products/docker-desktop/)

Docker 在 CTF 里主要用来**在本地搭靶机**，复现题目环境。题目一般会给你一个 `Dockerfile`：

```dockerfile
FROM python:3.11
WORKDIR /app
COPY . .
RUN pip install flask
EXPOSE 5000
CMD ["python", "app.py"]
```

几个指令：

- `FROM`：基础镜像
- `WORKDIR`：容器里的工作目录
- `COPY`：把本地文件复制进镜像
- `RUN`：构建镜像时执行的命令（装依赖）
- `EXPOSE`：声明容器用的端口
- `CMD`：容器启动时默认执行什么

### 本地启动靶机

进到 Dockerfile 所在目录，先构建镜像：

```bash
docker build -t ctf-web .
```

- `build`：根据 Dockerfile 构建
- `-t ctf-web`：镜像起名叫 `ctf-web`
- `.`：用当前目录当构建上下文

然后启动容器：

```bash
docker run -d -p 8080:5000 --name ctf ctf-web
```

- `-d`：后台运行
- `-p 8080:5000`：宿主机 8080 映射到容器 5000
- `--name ctf`：容器叫 `ctf`

起来之后访问 `http://127.0.0.1:8080` 就能看到靶机了。

### 常用命令

```bash
dos ctf         # 看容器日志
docker exec -it ctf sh  # 进容器终端
docker stop ctf         # 停止
docker rm ctf           # 删除
```

如果题目给了 `docker-compose.yml`，更省事：

```bash
docker compose up -d --build   # 构建并启动
docker compose down            # 停止并删除
```

一句话总结：**看 Dockerfile 了解环境 → build 构建 → run 启动 → 本地访问调试。**

学有余力可以看：[CSRF 深入](https://book.jorianwoltjer.com/web/client-side/cross-site-request-forgery-csrf)


 

|



