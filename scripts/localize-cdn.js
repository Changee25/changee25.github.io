/**
 * Hexo 构建钩子
 *
 * 1) 静态资源本地化：Fluid 默认从 lib.baomitu.com 取 jQuery / Bootstrap / typed.js 等，
 *    图标字体从 at.alicdn.com 取。这些文件已经用 tools/localize-cdn.js 下到
 *    source/vendor/ 里，这里把渲染结果里的地址换成本地路径，
 *    避免代理 / DNS 抖动导致「导航没图标、首屏副标题空白」。
 *
 * 2) 生成 .nojekyll：GitHub Pages 默认会用 Jekyll 处理分支内容，
 *    放一个空的 .nojekyll 让它直接按静态文件发布。
 */
const fs = require("fs");
const path = require("path");

const HOST_RE = /(?:https?:)?\/\/(lib\.baomitu\.com|at\.alicdn\.com)\//gi;

hexo.extend.filter.register("after_render:html", function (str) {
  const root = (this.config.root || "/").replace(/\/?$/, "/");
  return str.replace(HOST_RE, root + "vendor/$1/");
});

hexo.extend.filter.register("after_generate", function () {
  try {
    fs.writeFileSync(path.join(hexo.public_dir, ".nojekyll"), "");
  } catch (e) {
    // 写不了就算了，不影响站点本身
  }
});
