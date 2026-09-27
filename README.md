# 个人数据分析作品集 · 中英双语网站

**暗色 + 荧光绿**的单页滚动式作品集：DIN 风格压缩标题、编号卡片、横向图表画廊、滚动渐显与光标跟随。

纯静态，零外部依赖（字体已内嵌），双击 `index.html` 即可预览，也可直接部署到 GitHub Pages / Vercel / Netlify。

## 语言版本

| 文件 | 语言 |
|---|---|
| `index.html` | 中文（lang="zh-CN"） |
| `en.html` | 英文（lang="en"） |

导航右上角切换（中文页 `EN` / 英文页 `中文`），两页通过 `<link rel="alternate" hreflang>` 互相声明。

## 设计系统

| 元素 | 规格 |
|---|---|
| 背景 / 文字 | `#000000` / `#f6f8f6` |
| 点缀色 | `#c9ff1a`（荧光绿，用于眉标、编号、箭头、链接悬停） |
| 显示字体 | **Barlow Condensed**（内嵌 woff2，OFL 协议，DIN 风格压缩体） |
| 中文正文字体 | PingFang SC / Microsoft YaHei / Noto Sans CJK SC |
| 大标题 | `clamp(64px, 17.5vw, 250px)`，字重 700，大写 |
| 区块标题 | `clamp(34px, 6.4vw, 72px)`，后接荧光绿 `↘` |
| 眉标 | 10px / 700 / 字间距 2.4px / 大写 / 荧光绿 |
| 卡片 | 直角（radius 0），1px 半透明描边，悬停出现荧光绿底线 |
| 网格间距 | `clamp()` 视口自适应 |

## 页面结构

```
#home        首屏：眉标 + 超大字姓名 + 定位 + 联系方式 + 横向图表缩略条 + 滚动提示
.stats       数据条：项目数 / 数据记录 / SQL 查询类数 / 图表数（滚动到视野时数字动画）
#experience  个人经历：ABOUT ME 自我介绍 + 关键数据 + CAREER PATH 时间轴
#works       个人作品：两张大编号卡片（01 / 02），点击跳到项目详情
#p1 / #p2    项目详情：我做了什么 / 关键发现（双栏）+ 横向图表画廊（可拖拽，点击放大）+ 下载
#strengths   个人优势：4 组能力，编号 01–04
#contact     联系方式：超大 LET'S TALK + 联系卡片
footer       数据来源 + 回到顶部
```

## 交互

- **光标跟随光晕**：荧光绿径向渐变随鼠标移动
- **滚动渐显**：IntersectionObserver，元素进入视野时上移淡入（交错延迟）
- **导航**：固定顶部、平滑滚动、滚动侦测高亮当前区块
- **数字动画**：数据条数字滚动到视野时从 0 递增
- **横向画廊**：鼠标拖拽滚动 + 滚轮纵向转横向
- **灯箱**：点击图表放大，`Esc` 关闭
- **移动端**：菜单折叠为 MENU 按钮；窄屏单列排版
- **无障碍**：支持 `prefers-reduced-motion`，关闭动效与光晕

## 文件结构

```
site/
├── index.html                  # 中文版
├── en.html                     # 英文版
├── README.md
└── assets/
    ├── style.css               # 设计系统与全部样式
    ├── favicon.svg             # 站点图标（柱状图造型）
    ├── resume_yu_zhou.pdf      # 简历下载
    ├── fonts/                  # Barlow Condensed（400/600/700）+ OFL 许可
    ├── charts/                 # 中文图表（16 张 SVG）
    │   ├── p1-fig01.svg … p1-fig10.svg
    │   ├── p2-fig01.svg … p2-fig06.svg
    │   └── en/                 # 英文图表（16 张，公司名已英文化）
    └── data/                   # 可下载数据与脚本
```

## 本地预览与部署

```bash
cd site
python -m http.server 8000   # 打开 http://localhost:8000
```

GitHub Pages：把 `site` 下全部文件推到仓库根目录 → Settings → Pages → Source `Deploy from a branch`（`main` / root）。
线上地址：https://2001yuzhou.github.io/data-portfolio/ （英文版 `/en.html`）

## 如何修改

| 要改什么 | 改哪里 | 执行 |
|---|---|---|
| 页面文案与结构（中英） | `scripts/build_site.py` | `python scripts/build_site.py` |
| 配色 / 字体 / 间距 | `site/assets/style.css` | 直接改 |
| 图表（中文） | `scripts/gen_charts.py`、`gen_retail_charts.py` | 对应脚本 |
| 图表（英文） | `scripts/gen_charts_en.py` | 该脚本 |

## 已验证项（无头 Chrome / Playwright 实测）

- 中英两页各 7 大区块，16 张图表**全部加载**（英文页 16/16 引用英文图表）
- 无 HTTP 404、无控制台报错、无横向溢出
- 滚动渐显 47/47 全部激活；导航点击与滚动高亮正常
- 画廊拖拽可横向滚动；灯箱打开/关闭正常
- 移动端 390px：菜单折叠与展开正常、无横向溢出
- Barlow Condensed 字体正确加载；背景 `#000`、点缀色 `#c9ff1a` 生效
