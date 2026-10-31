---
title: PHP 入门笔记
date: 2026-10-31 
---

## 一、PHP 是什么？

### 1. 定义

PHP 是一种主要运行在**服务器**上的脚本语言，专门用来做网站和 Web 应用，可以直接写在 HTML 里。

### 2. 相当于PHP 是餐厅的后厨

你去餐厅吃饭：

- 你看到的是菜单、摆盘、端上来的菜 → **浏览器看到的 HTML/CSS/JS**
- 后厨里洗菜、切菜、炒菜的过程 → **服务器上的 PHP 代码**
- 仓库（冰箱）→ **数据库、文件**

浏览器访问一个 PHP 页面时，大致发生：

1. 浏览器向服务器要 `index.php`
2. Web 服务器（Apache/Nginx）把请求交给 PHP 解释器
3. PHP 执行代码（可能查数据库、算价格、判断登录）
4. PHP 把结果变成 HTML 返回
5. 浏览器拿到 HTML 并显示

关键点：**用户一般看不到 PHP 源代码，只能看到它加工后的 HTML**。这也是它和 JavaScript 最大的区别：JS 在浏览器里跑，源码用户能看；PHP 在服务器上跑，源码留在服务器。

（当然，如果服务器没配好，PHP 源码被当文本下载，就会泄露——部署时要注意。）

## 二、PHP 初步语法

### 1. 文件与“进出厨房的门”

PHP 文件一般以 `.php` 结尾。文件里可以全是 PHP，也可以 HTML 和 PHP 混着写。

进入 PHP 模式用 `<?php`，退出用 `?>`：

php

```
<!DOCTYPE html>
<html>
<body>
  <h1>你好</h1>
  <?php echo "这句话是 PHP 生成的"; ?>
</body>
</html>
```

`<?=` 是 `<?php echo` 的简写,就像这样：

php

```
<p>欢迎，<?= $name ?></p>
```

小建议：**如果文件里只有 PHP 代码，结尾的 `?>` 最好省略**。因为它后面的空格/换行可能被输出，导致 “headers already sent” 之类的问题（官方手册建议纯 PHP 文件省略结束标记）。

### 2. 语句、分号、注释

- 每条语句结尾加 `;`（最后一条在 `?>` 前可以省，但建议统一加）
- 注释三种：

php

```
<?php
// 单行注释
# 也是单行注释（但是不常用）
/* 多行
   注释 */
echo "Hello";
```

### 3. 大小写和空白

- **变量名区分大小写**：`$name` 和 `$Name` 是两个变量
- **关键字、函数名、类名不区分大小写**：`echo`、`ECHO`、`Echo` 都行；`strlen()` 和 `STRLEN()` 也行（但别故意这么写）
- 空格、换行、缩进随便加，不影响执行（字符串里面的除外）

### 4. 第一个完整例子

php

```
<?php
// first.php
$name = "小明";
echo "你好，" . $name . "！";
```

输出：

代码块

```
你好，小明！
```

怎么运行：

- 装 XAMPP / phpStudy，把文件放进网站根目录，浏览器访问
- 或者命令行：`php first.php`
- 或者用 PHP 自带的小服务器：`php -S localhost:8000`，然后访问 `http://localhost:8000/first.php`

### 5. 易错

- 漏分号或用了中文分号 `；`、中文引号 `“”`（但是学了C语言应该也不容易这样
- PHP 代码没放进 `<?php ... ?>` 
- 文件开头有 BOM 或多余空白，导致页面顶部多出空行
- 变量漏写 `$`

## 三、echo、print、var_dump

### 1. echo：大喇叭

- [官方手册](https://www.php.net/manual/zh/function.echo.php)明确说 “echo 不是函数，而是语言结构”
- 可以一次输出多个值，用逗号隔开
- **没有返回值**
- 不能当函数用（不能 `$f = 'echo'`，也不能命名参数）

php

```
<?php
echo "Hello";
echo "Hello", " ", "World";   // 输出 Hello World
echo "a" . "b" . "c";          // 输出 abc
echo 6 * 7;                    // 输出 42
```

注意：`echo("hello")` 能跑，但括号只是把 `"hello"` 包起来，不是函数调用。`echo("a", "b")` 反而会报解析错误。

#### 2.print：小喇叭，会回一句“收到”

- 也是**语言结构**，不是函数
- **只能输出一个值**
- **总是返回 1**

正因为返回 1，它可以塞进表达式里：

php



```
<?php
$ok = print "hello";   // 先输出 hello，然后 $ok 变成 1
var_dump($ok);         // int(1)
```

php



```
<?php
// 三元表达式里可以用 print，但不能用 echo
(1 === 1) ? print "真" : print "假";   // 输出：真
```

### 3. var_dump：X 光机 / 体检报告

- 是**函数**
- 不只显示值，还显示**类型、长度、结构**
- 数组和对象会递归展开，缩进显示
- 没有返回值（返回 void）
- 调试时最常用

官方定义：`var_dump()` 显示一个或多个表达式的结构信息，包括表达式的类型与值；数组和对象将递归展开值，通过缩进显示其结构（[手册](https://www.php.net/manual/zh/function.var-dump.php)）。

php



```
<?php
var_dump(123);          // int(123)
var_dump(1.5);          // float(1.5)
var_dump(true);         // bool(true)
var_dump("hi");         // string(2) "hi"
var_dump(null);         // NULL

var_dump([1, "a"]);
// array(2) {
//   [0]=>
//   int(1)
//   [1]=>
//   string(1) "a"
// }
```

### 4. 三者对比

|                | echo       | print              | var_dump           |
| -------------- | ---------- | ------------------ | ------------------ |
| 本质           | 语言结构   | 语言结构           | 函数               |
| 参数个数       | 多个       | 一个               | 一个或多个         |
| 返回值         | 无         | 1                  | 无（void）         |
| 能否放进表达式 | 不能       | 能                 | 能                 |
| 主要用途       | 输出字符串 | 输出字符串（少用） | 调试，看类型和结构 |
| 输出类型信息   | 否         | 否                 | 是                 |

### 5. 调试：var_dump、print_r、var_export

| 函数           | 特点                                                       | 适合              |
| -------------- | ---------------------------------------------------------- | ----------------- |
| `var_dump()`   | 类型 + 值 + 长度，最详细                                   | 调试，确认类型    |
| `print_r()`    | 人类可读，默认不显示类型；第二个参数传 `true` 可返回字符串 | 快速看数组结构    |
| `var_export()` | 输出合法的 PHP 代码形式                                    | 生成配置/缓存文件 |

php



```
<?php
$arr = ["a" => 1, "b" => [2, 3]];
print_r($arr);
// Array
// (
//     [a] => 1
//     [b] => Array
//         (
//             [0] => 2
//             [1] => 3
//         )
// )
```

## 四、PHP 变量

### 1. 变量是什么

变量就是一个**贴了名字的储物柜**。`$` 是柜子上的挂钩，名字是标签，`=` 是“把东西放进去”。

php

```
<?php
$name = "小明";   // 把字符串放进 $name
$age  = 18;       // 把整数放进 $age
echo "我叫{$name}，今年{$age}岁。";
```

输出：

代码块

```
我叫小明，今年18岁。
```

几个要点：

- 变量名以 `$` 开头，后面必须是字母或下划线，再后面可以是字母、数字、下划线
- **区分大小写**：`$name`、`$Name`、`$NAME` 是三个不同的变量
- **不需要提前声明**，第一次赋值就创建了
- **弱类型/动态类型**：同一个柜子今天装字符串，明天装数字，PHP 不拦你

php

```
<?php
$x = 1;
var_dump($x);   // int(1)
$x = "hello";
var_dump($x);   // string(5) "hello"
$x = 1.5;
var_dump($x);   // float(1.5)
```

### 2. `=` 不是“等于“

（C语言讲过哦喵~

- `=` 是**赋值**：把右边放进左边
- `==` 是**松散比较**：值相等（会做类型转换）
- `===` 是**严格比较**：类型和值都相等

php

```
<?php
$a = 1;      // 赋值
var_dump($a == "1");   // bool(true)
var_dump($a === "1");  // bool(false)
```

### 3. 变量变量（了解即可）

一个变量的名字，又存在另一个变量里：

php

```
<?php
$name = "city";
$$name = "北京";   // 相当于 $city = "北京"
echo $city;        // 北京
```

相当于钥匙上写着另一个柜子的编号。实际项目里很少用，看到能认识就行。

### 4. 引用赋值：配一把备用钥匙

普通的 `$b = $a` 是**复制一份**放进新柜子；`$b = &$a` 是**给同一个柜子配了把备用钥匙**。

php

```
<?php
$a = 1;
$b = $a;     // 复制
$b = 2;
echo $a;     // 1，$a 没变

$c = 1;
$d = &$c;    // 引用，同一个柜子
$d = 2;
echo $c;     // 2，$c 也变了
```

`unset($d)` 只是把 `$d` 这把钥匙扔掉，`$c` 和柜子都还在。

### 5. 作用域：函数是“隔音房间”

函数内部默认看不到外面的变量：

php

```
<?php
$x = 10;

function test() {
    // echo $x;  // 错误：函数里没有 $x
    global $x;   // 把外面的 $x 拿进来
    echo $x;     // 10
}

test();
```

三种办法让函数拿到外面的变量：

1. `global $x;`（在函数里声明）
2. `$GLOBALS['x']`（直接访问全局数组）
3. 通过参数传进去（**最推荐**，关系清晰）

反过来，函数里定义的变量，函数执行完就没了。想让某个值“记住”，用 `static`：

php

```
<?php
function counter() {
    static $n = 0;   // 只初始化一次
    $n++;
    return $n;
}

echo counter();  // 1
echo counter();  // 2
echo counter();  // 3
```

比喻：普通局部变量是“一次性纸杯”，函数结束就扔；`static` 是“放在柜子里的杯子”，下次进来还在。

### 6. 超全局变量

这些变量在**任何地方**都能直接用（函数里也不用 `global`）：

| 变量        | 装什么                                     |
| ----------- | ------------------------------------------ |
| `$GLOBALS`  | 所有全局变量                               |
| `$_SERVER`  | 服务器和执行环境信息                       |
| `$_GET`     | URL 查询参数                               |
| `$_POST`    | POST 表单数据                              |
| `$_FILES`   | 上传的文件                                 |
| `$_COOKIE`  | Cookie                                     |
| `$_SESSION` | 会话                                       |
| `$_REQUEST` | GET/POST/Cookie 的合集（少用，来源不明确） |
| `$_ENV`     | 环境变量                                   |

注意：表单提交上来的都是**字符串**（哪怕是数字），需要自己转换。官方手册在类型比较表里也专门提醒了这一点。

### 7. 常量

常量是**写死就不能改的值**，适合放配置：

```
<?php
define("SITE_NAME", "我的网站");
echo SITE_NAME;

const PI = 3.14;      // PHP 5.3+，文件顶层/类里可用
echo PI;
```

- 常量名前不加 `$`
- 一旦定义，不能重新赋值
- `define()` 默认区分大小写；第三个参数传 `true` 可开启不区分（PHP 7.3 起废弃，8.0 移除，别用）
- 检查是否存在：`defined("SITE_NAME")`
- 魔术常量：`__LINE__`、`__FILE__`、`__DIR__`、`__FUNCTION__`、`__CLASS__` 等，会随位置自动变化

------

## 五、PHP 5 的数据类型（八种）

PHP 5 官方手册把类型分成三大类、共八种：

| 分类             | 类型              | 中文   | 大白话             | 例子             |
| ---------------- | ----------------- | ------ | ------------------ | ---------------- |
| 标量（scalar）   | `boolean`         | 布尔型 | 开关               | `true` / `false` |
|                  | `integer`         | 整型   | 整数               | `42`、`-7`       |
|                  | `float`（double） | 浮点型 | 小数               | `3.14`、`1.0E3`  |
|                  | `string`          | 字符串 | 文字               | `"你好"`         |
| 复合（compound） | `array`           | 数组   | 带格子的柜子       | `[1, 2, 3]`      |
|                  | `object`          | 对象   | 有属性有技能的东西 | `new Person()`   |
| 特殊（special）  | `resource`        | 资源   | 外部东西的取货凭证 | `fopen(...)`     |
|                  | `NULL`            | 空值   | 空盒子             | `null`           |

> 说明：`callable`、`iterable`、`mixed` 这些是后来的“伪类型”或新类型（`iterable` 是 PHP 7.1 加的），PHP 5 的八种就是上表这些。

### 1. boolean（布尔型）：开关

只有两个值：`true` 和 `false`（大小写不敏感）。

php



```
<?php
$isLogin = true;
$isAdmin = false;
var_dump($isLogin);   // bool(true)
```

**重点：哪些值会被当成 false？**

在 PHP 里，以下值在 `if`、`while`、`&&` 等布尔上下文里都算“假”：

- `false`
- `0`（整数零）
- `0.0`（浮点零）
- `""`（空字符串）
- `"0"`（只含一个 0 的字符串）—— **这个最坑**
- `[]`（空数组）
- `null`

其他基本都是 `true`，包括 `"0.0"`、`" "`（空格）、`-1`、`"false"`（字符串）、`"00"`。

php



```
<?php
var_dump((bool)"0");     // bool(false)  ← 注意
var_dump((bool)"0.0");   // bool(true)   ← 注意
var_dump((bool)"false"); // bool(true)   ← 注意
var_dump((bool)[]);      // bool(false)
```

比喻：PHP 判断“真假”不看东西长什么样，只看是不是“空/零”。字符串 `"0"` 虽然有一个字符，但在 PHP 眼里等于零，所以是假。

### 2. integer（整型）：整数

php



```
<?php
$dec = 123;      // 十进制
$neg = -45;      // 负数
$hex = 0x1A;     // 十六进制 = 26
$oct = 0755;     // 八进制 = 493
$bin = 0b1010;   // 二进制 = 10（PHP 5.4+）
```

要点：

- 整数的大小跟平台有关：32 位系统最大约 21 亿，64 位系统最大约 9.2e18
- 用 `PHP_INT_MAX` 看当前平台的最大值，`PHP_INT_SIZE` 看字节数（4 或 8）
- **溢出会变成浮点数**：

php



```
<?php
var_dump(PHP_INT_MAX);        // int(9223372036854775807)（64 位）
var_dump(PHP_INT_MAX + 1);    // float(9.2233720368547758E+18)
```

- 判断：`is_int($x)` / `is_integer($x)`（别名）
- 转换：`(int)$x`、`intval($x)`

### 3. float（浮点型）：小数

也叫 `double`、`real`。注意：`gettype()` 对浮点数返回的是 **“double”**，不是 “float”。

php



```
<?php
$pi = 3.14;
$big = 1.0E3;    // 1000.0，科学计数法
var_dump($pi);   // float(3.14)
echo gettype($pi); // double
```

**重点：浮点数不能直接用 `==` 判断相等。**

因为计算机用二进制存小数，很多十进制小数存不精确：

php



```
<?php
var_dump(0.1 + 0.2);            // float(0.30000000000000004)
var_dump(0.1 + 0.2 == 0.3);     // bool(false)  ← 坑
```

（PHP 7.1 起 `var_dump` 显示得更精确；PHP 5 可能显示 `float(0.3)`，但实际值仍不精确。）

正确做法：判断差值是否足够小，或者用 `round()`：

php



```
<?php
$a = 0.1 + 0.2;
$b = 0.3;

var_dump(abs($a - $b) < 1e-10);        // bool(true)
var_dump(round($a, 2) == $b);          // bool(true)
```

比喻：浮点数像“用尺子量出来的近似值”，不是精确的分数。比较两个测量值，要看“差得是不是在误差范围内”，而不是“是否一模一样”。

另外还有两个特殊值：`NAN`（不是数，比如 `sqrt(-1)`）和 `INF`（无穷大）。`NAN` 和任何值比较（包括它自己）都是 false。

### 4. string（字符串）：文字

四种写法：

php



```
<?php
// 1. 单引号：只认 \' 和 \\
$s1 = '你好\n世界';   // 输出：你好\n世界（\n 不换行）

// 2. 双引号：认转义和变量
$name = "小明";
$s2 = "你好，$name\n";   // 换行，并插入变量

// 3. heredoc：双引号风格的多行字符串
$s3 = <<<EOT
第一行
第二行 $name
EOT;

// 4. nowdoc：单引号风格的多行字符串（PHP 5.3+）
$s4 = <<<'EOT'
这里 $name 不会被替换
EOT;
```

要点：

- 单引号里只有 `\'` 和 `\\` 是转义，其他 `\n` 都按字面显示
- 双引号里 `\n`（换行）、`\t`（制表）、`\$`、`\"` 等会转义，变量也会被替换
- 拼接用 `.`（点），不是 `+`
- 双引号里插入数组/对象属性，用花括号更稳：

php



```
<?php
$arr = ["name" => "小明"];
echo "你好，{$arr['name']}";   // 你好，小明
// echo "你好，$arr['name']";  // 解析错误
```

- `strlen()` 数的是**字节**，不是字符。UTF-8 下一个汉字占 3 字节：

php



```
<?php
echo strlen("你好");      // 6
echo mb_strlen("你好");   // 2（需要 mbstring 扩展）
```

- 取单个字符：`$str[0]`（PHP 5 也支持 `$str{0}`，但 7.4 废弃、8.0 移除，别用花括号）

### 5. array（数组）：带格子的柜子

PHP 的数组其实是**有序映射**（ordered map）：每个值都有一个 key（键），key 可以是整数或字符串。

php



```
<?php
// 索引数组：key 是 0、1、2...
$fruits = ["苹果", "香蕉", "橙子"];
echo $fruits[0];   // 苹果

// 关联数组：key 是自己起的名字
$person = [
    "name" => "小明",
    "age"  => 18,
    "city" => "北京"
];
echo $person["name"];   // 小明
```

要点：

- `[]` 短语法从 PHP 5.4 开始支持；老代码用 `array(...)`
- key 的规则：
  - 纯数字字符串 `"8"` 会被转成整数 `8`
  - 浮点数 key 会被截断成整数
  - `true` → `1`，`false` → `0`，`null` → `""`
- 不写 key 时，自动用“当前最大整数 key + 1”：

php



```
<?php
$arr = [];
$arr[] = "a";   // key 0
$arr[] = "b";   // key 1
```

- `count($arr)` 数元素个数
- `isset($arr["key"])` 判断“键存在且值不是 null”；如果值可能是 null，用 `array_key_exists()`
- `in_array($needle, $haystack, true)` 第三个参数传 `true` 才是严格比较
- 数组赋值是**复制**（写时复制），改副本不影响原数组

php



```
<?php
$a = [1, 2, 3];
$b = $a;
$b[0] = 99;
echo $a[0];   // 1，原数组没变
```

比喻：数组像一排带标签的快递柜，每个格子有编号（key）和内容（value）。你可以按编号取，也可以按标签取。

### 6. object（对象）：有属性、有技能的东西

对象是“类”的实例。类像图纸，对象像按图纸造出来的东西。

php



```
<?php
class Person {
    public $name;
    public $age;

    public function __construct($name, $age) {
        $this->name = $name;
        $this->age  = $age;
    }

    public function sayHello() {
        return "你好，我是" . $this->name;
    }
}

$p = new Person("小明", 18);
echo $p->name;          // 小明
echo $p->sayHello();    // 你好，我是小明

var_dump($p);
// object(Person)#1 (2) {
//   ["name"]=>
//   string(6) "小明"
//   ["age"]=>
//   int(18)
// }
```

（`#1` 是对象编号，可能不同。）

要点：

- `new` 造对象，`->` 访问属性/方法，`::` 访问静态成员/常量
- **对象变量存的是“门禁卡”（handle），不是对象本身**：

php



```
<?php
$a = new Person("小明", 18);
$b = $a;          // 复制的是门禁卡，两个人进同一间屋
$b->name = "小红";
echo $a->name;    // 小红
```

想真正复制对象，用 `clone`（浅复制）：

php



```
<?php
$c = clone $a;
$c->name = "小刚";
echo $a->name;    // 小红，原对象没变
```

比喻：`$a = $b` 对数组是“复印一份文件”，对对象是“多配一张门禁卡”。复印的文件改了不影响原件；门禁卡进的是同一个房间，改房间里的东西大家都看得见。

### 7. resource（资源）：外部东西的“取货凭证”

资源不是普通数据，而是一个**指向外部资源的句柄**：打开的文件、数据库连接、图片画布等。

php



```
<?php
$fp = fopen("php://memory", "r");
var_dump($fp);              // resource(5) of type (stream)（数字可能不同）
var_dump(is_resource($fp)); // bool(true)

fclose($fp);
var_dump(is_resource($fp)); // bool(false)
```

要点：

- 资源由专门的函数创建（`fopen`、`mysqli_connect` 等）
- 用完要释放（`fclose` 等），否则可能泄漏
- `get_resource_type($fp)` 看类型
- 资源不能直接存进数据库，也不能被 `var_dump` 展开成普通值

比喻：资源像“取货凭证/门禁卡”，它本身不是货，但凭它可以去操作仓库里的东西。凭证作废（关闭）后，就不能再用了。

### 8. NULL（空值）：空盒子

`NULL` 表示“没有值”。大小写不敏感（`null`、`NULL`、`Null` 都一样）。

三种情况会得到 null：

php



```
<?php
$a = null;          // 1. 明确赋值为 null

// 2. 从未赋值的变量，访问时得到 null，并提示未定义
var_dump($b);       // NULL + Warning/Notice: Undefined variable

$c = 1;
unset($c);          // 3. unset 之后变量被销毁
var_dump($c);       // NULL + Warning/Notice: Undefined variable
```

判断：

php



```
<?php
$x = null;
var_dump(is_null($x));   // bool(true)
var_dump($x === null);   // bool(true)
var_dump($x == null);    // bool(true)
var_dump($x == 0);       // bool(true)  ← 坑！null 和 0 松散比较是 true
```

所以判断 null 一定用 `=== null` 或 `is_null()`。

比喻：

- `null` = 空盒子，连空气都没有
- `""` = 盒子里装了一张白纸
- `0` = 盒子里装了数字 0
- `"0"` = 盒子里装了一个写着 0 的纸条

它们“看起来都空空的”，但完全不是一回事。

### 9. 类型判断与转换

判断类型：

| 函数                         | 作用                                  |
| ---------------------------- | ------------------------------------- |
| `gettype($x)`                | 返回类型名字符串（浮点返回 “double”） |
| `is_int()` / `is_integer()`  | 是否整数                              |
| `is_float()` / `is_double()` | 是否浮点                              |
| `is_string()`                | 是否字符串                            |
| `is_bool()`                  | 是否布尔                              |
| `is_array()`                 | 是否数组                              |
| `is_object()`                | 是否对象                              |
| `is_resource()`              | 是否资源                              |
| `is_null()`                  | 是否 null                             |
| `is_numeric()`               | 是否数字或数字字符串                  |
| `is_callable()`              | 是否可调用                            |

强制转换：

php



```
<?php
$s = "123";
var_dump((int)$s);      // int(123)
var_dump((float)$s);    // float(123)
var_dump((string)123);  // string(3) "123"
var_dump((bool)"0");    // bool(false)
var_dump((array)"abc"); // array(1) { [0]=> string(3) "abc" }
```

`settype()` 会直接改变变量本身的类型：

php



```
<?php
$x = "123";
settype($x, "integer");
var_dump($x);   // int(123)
```

类型转换函数：`intval()`、`floatval()`、`strval()`、`boolval()`（PHP 5.5+）。

**自动类型转换（类型戏法）**：

php



```
<?php
var_dump("10" + 5);        // int(15)
var_dump("10.5" + 1);      // float(11.5)
var_dump("10 apples" + 1); // int(11)，并有一个 notice（PHP 5/7）
var_dump("abc" + 1);       // PHP 5/7：int(1) + 警告；PHP 8：TypeError
```

【PHP 8 注意】PHP 8 对“非数字字符串”做算术会抛 `TypeError`，不再像 PHP 5 那样悄悄当 0。

## 七、函数

### 1. 函数是什么

函数是一台**榨汁机**：你把原料（参数）放进去，按按钮（调用），它给你一杯果汁（返回值）。你不用关心里面的刀片怎么转。

php



```
<?php
function add($a, $b) {
    return $a + $b;
}

echo add(2, 3);   // 5
```

- `function` 是声明关键字
- `add` 是函数名
- `$a`、`$b` 是参数
- `return` 把结果交出来
- 函数名**不区分大小写**，但不能和内置函数重名
- 函数不能重复定义（会报 fatal error）

### 2. 参数：默认值、引用、可变参数

**默认值**（有默认值的参数放右边）：

php



```
<?php
function greet($name, $greeting = "你好") {
    return $greeting . "，" . $name;
}

echo greet("小明");          // 你好，小明
echo greet("Tom", "Hello");  // Hello，Tom
```

默认值必须是常量表达式，不能写 `$x` 这种变量。

**引用参数**（函数里改，外面也变）：

php



```
<?php
function addOne(&$n) {
    $n++;
}

$x = 1;
addOne($x);
echo $x;   // 2
```

比喻：普通参数是“把文件复印一份给函数”，函数在复印件上改，原件不变；引用参数是“把原件递进去”。

**可变参数**（PHP 5.6+）：

php



```
<?php
function sum(...$nums) {
    return array_sum($nums);
}

echo sum(1, 2, 3, 4);   // 10
```

老办法（PHP 5 全版本可用）：

php



```
<?php
function sum2() {
    $args = func_get_args();
    return array_sum($args);
}

echo sum2(1, 2, 3);   // 6
```

### 3. 返回值

- `return` 可以返回任意类型：数字、字符串、数组、对象、null
- 没有 `return`（或 `return;`）的函数，返回 `null`
- `return` 会立刻结束函数，后面的代码不执行

php



```
<?php
function divide($a, $b) {
    if ($b == 0) {
        return null;    // 提前返回
    }
    return $a / $b;
}

var_dump(divide(10, 2));   // int(5)（整除时返回整数）
var_dump(divide(10, 0));   // NULL
```

### 4. 作用域与 static

函数内部是独立空间，看不到外面的变量；要用 `global` 或参数传进来。函数里的 `static` 变量会在多次调用之间保留值（前面变量章节讲过）。

php



```
<?php
function makeCounter() {
    static $count = 0;
    $count++;
    return $count;
}

echo makeCounter();   // 1
echo makeCounter();   // 2
```

### 5. 可变函数、匿名函数、闭包

**可变函数**：函数名存在变量里。

php



```
<?php
$fn = "strlen";
echo $fn("hello");   // 5

$fn2 = "strtoupper";
echo $fn2("abc");    // ABC
```

注意：`echo`、`print`、`isset`、`empty` 这些是语言结构，不能这样调用。

**匿名函数 / 闭包**（PHP 5.3+）：

php



```
<?php
$double = function ($x) {
    return $x * 2;
};

echo $double(5);   // 10
```

闭包要用外面的变量，得用 `use`：

php



```
<?php
$rate = 0.1;
$tax = function ($price) use ($rate) {
    return $price * (1 + $rate);
};

echo $tax(100);   // 110
```

`use (&$rate)` 是引用捕获，函数里改会影响外面；不加 `&` 是值捕获，捕获的是定义那一刻的副本。

**箭头函数**（PHP 7.4+，了解）：

php



```
<?php
$double = fn($x) => $x * 2;
echo $double(5);   // 10
```

### 6. 递归：函数自己调用自己

php



```
<?php
function factorial($n) {
    if ($n <= 1) {
        return 1;
    }
    return $n * factorial($n - 1);
}

echo factorial(5);   // 120
```

比喻：俄罗斯套娃，一层套一层，直到最小的那个（终止条件）。递归一定要有终止条件，否则会栈溢出。

### 7. 类型声明（PHP 5 与 7/8 的差别）

PHP 5 支持类名、数组、`callable` 参数声明：

php



```
<?php
function total(array $nums) {
    return array_sum($nums);
}
```

PHP 7 开始支持标量类型和返回值类型：

php



```
<?php
declare(strict_types=1);   // 严格模式，必须放在文件第一行

function add(int $a, int $b): int {
    return $a + $b;
}
```

PHP 8 支持联合类型、命名参数等：

php



```
<?php
function show(int|string $id): string {
    return "ID: " . $id;
}

show(id: 123);   // 命名参数
```

新手先掌握“参数”和“返回值”即可，类型声明可以慢慢加。

### 8. 常用内置函数（先混个脸熟）

| 类别   | 函数                                          | 作用                           |
| ------ | --------------------------------------------- | ------------------------------ |
| 字符串 | `strlen()`                                    | 字节长度                       |
|        | `mb_strlen()`                                 | 字符长度（中文用）             |
|        | `strpos()`                                    | 找子串位置（没找到返回 false） |
|        | `substr()`                                    | 截取                           |
|        | `str_replace()`                               | 替换                           |
|        | `trim()`                                      | 去首尾空白                     |
|        | `strtoupper()` / `strtolower()`               | 大小写                         |
|        | `implode()` / `explode()`                     | 数组转字符串 / 字符串转数组    |
| 数组   | `count()`                                     | 元素个数                       |
|        | `array_push()` / `array_pop()`                | 尾部加/取                      |
|        | `array_merge()`                               | 合并                           |
|        | `array_keys()` / `array_values()`             | 取键/取值                      |
|        | `in_array()`                                  | 是否包含                       |
|        | `array_map()` / `array_filter()`              | 映射/过滤                      |
|        | `sort()` / `usort()`                          | 排序                           |
| 判断   | `isset()`                                     | 是否存在且不为 null            |
|        | `empty()`                                     | 是否为空（“0” 也算空）         |
|        | `is_numeric()`                                | 是否数字字符串                 |
| 输出   | `echo` / `print` / `var_dump()` / `print_r()` | 输出/调试                      |

### 9. 函数小练习

php



```
<?php
// 1. 判断偶数
function isEven($n) {
    return $n % 2 === 0;
}

// 2. 安全除法
function safeDivide($a, $b) {
    if ($b == 0) {
        return null;
    }
    return $a / $b;
}

// 3. 格式化价格
function formatPrice($price) {
    return "¥" . number_format($price, 2);
}

var_dump(isEven(4));            // bool(true)
var_dump(safeDivide(10, 0));    // NULL
echo formatPrice(1234.5);       // ¥1,234.50
```

------

## 八、把知识串起来：一个小例子

写一个“成绩等级”函数，把变量、类型、比较、函数、输出都用上：

php



```
<?php
function grade($score) {
    // 1. 先确认是数字（表单传来的都是字符串）
    if (!is_numeric($score)) {
        return "分数必须是数字";
    }

    // 2. 转成浮点数
    $score = (float)$score;

    // 3. 范围检查
    if ($score < 0 || $score > 100) {
        return "分数必须在 0 到 100 之间";
    }

    // 4. 用比较判断等级
    if ($score >= 90) {
        return "优秀";
    }
    if ($score >= 60) {
        return "及格";
    }
    return "不及格";
}

echo grade("95");    // 优秀
echo grade(59);      // 不及格
echo grade("abc");   // 分数必须是数字
echo grade(120);     // 分数必须在 0 到 100 之间
```

这个例子体现了：变量、函数、`is_numeric()` 判断、强制转换 `(float)`、比较运算符、`return` 提前结束、字符串输出。

------

## 九、速查表

### 八种类型

| 类型     | 判断函数        | 例子         | `var_dump` 样子                |
| -------- | --------------- | ------------ | ------------------------------ |
| boolean  | `is_bool()`     | `true`       | `bool(true)`                   |
| integer  | `is_int()`      | `42`         | `int(42)`                      |
| float    | `is_float()`    | `3.14`       | `float(3.14)`                  |
| string   | `is_string()`   | `"hi"`       | `string(2) "hi"`               |
| array    | `is_array()`    | `[1, 2]`     | `array(2) { ... }`             |
| object   | `is_object()`   | `new Foo()`  | `object(Foo)#1 (0) { }`        |
| resource | `is_resource()` | `fopen(...)` | `resource(5) of type (stream)` |
| NULL     | `is_null()`     | `null`       | `NULL`                         |

- `==` 会转类型，`===` 不会
- 数字和字符串比，PHP 5/7 转数字，PHP 8 转字符串（非数字字符串时）
- 判断“没找到”用 `=== false`
- 判断 null 用 `=== null`
- 浮点数别用 `==`
- 不确定就用 `===`

### 常见“假值”

`false`、`0`、`0.0`、`""`、`"0"`、`[]`、`null`

------

## 十、参考资料

以下都是 PHP 官方手册（中文版）和官网页面，本文的结论均以此为依据：

1. [PHP 是什么（引言）](https://www.php.net/manual/zh/intro-whatis.php)
2. [PHP 基本语法](https://www.php.net/manual/zh/language.basic-syntax.php)
3. [echo](https://www.php.net/manual/zh/function.echo.php)
4. [print](https://www.php.net/manual/zh/function.print.php)
5. [var_dump](https://www.php.net/manual/zh/function.var-dump.php)
6. [变量](https://www.php.net/manual/zh/language.variables.php)
7. [类型总览](https://www.php.net/manual/zh/language.types.php)
8. [PHP 类型比较表](https://www.php.net/manual/zh/types.comparisons.php)
9. [比较运算符](https://www.php.net/manual/zh/language.operators.comparison.php)
10. [类型戏法（自动转换）](https://www.php.net/manual/zh/language.types.type-juggling.php)
11. [函数](https://www.php.net/manual/zh/language.functions.php)
12. [PHP 支持周期（EOL）](https://www.php.net/eol.php)

其中几条关键依据：

- **echo** 是语言结构、没有返回值、可传多个参数 —— [echo 手册](https://www.php.net/manual/zh/function.echo.php)
- **print** 是语言结构、只接受一个参数、总是返回 1 —— [print 手册](https://www.php.net/manual/zh/function.print.php)
- **var_dump** 显示类型与值、递归展开数组/对象、无返回值 —— [var_dump 手册](https://www.php.net/manual/zh/function.var-dump.php)
- `0 == ""`、`0 == "abc"` 等在 PHP 8.0 之前为 true，之后为 false —— [类型比较表](https://www.php.net/manual/zh/types.comparisons.php)中的 `*` 注释
- PHP 5.6 于 2018-12-31 停止支持 —— [官方 EOL 页面](https://www.php.net/eol.php)

