# 个人数据分析作品集 · 中英双语「翻页式」网站

**整页翻页式**（不是长滚动页）：每一屏固定为视口大小（100vw × 100vh），内容不会溢出，靠翻页切换；项目在列表页点击后进入独立详情页。

纯静态，零外部依赖（不挂 CDN、不需要构建工具）。双击 `index.html` 即可预览，也可直接部署到 GitHub Pages / Vercel / Netlify。

## 语言版本

| 文件 | 语言 |
|---|---|
| `index.html` | 中文（lang="zh-CN"） |
| `en.html` | 英文（lang="en"） |

导航栏右上角切换（中文页显示 `EN`，英文页显示 `中文`），两页通过 `<link rel="alternate" hreflang>` 互相声明。

## 页面结构（共 11 屏）

```
① cover        封面：姓名 / 定位 / 标签 / 联系方式
② skills       技能与数据概览：4 个 KPI + 4 组技能
③ projects     项目列表：2 张可点击卡片  ← 点卡片进入项目
④ p1           项目一 概览：背景 + 我的工作 + 主图 + 下载
⑤ p1-findings  项目一 关键发现（4 条）+ 主图
⑥ p1-charts    项目一 图表画廊（10 张，点击放大）
⑦ p2           项目二 概览：背景 + 我的工作 + 主图 + 下载
⑧ p2-findings  项目二 关键发现（5 条）+ 主图
⑨ p2-charts    项目二 图表画廊（6 张，点击放大）
⑩ more         其他经历（临床数据治理 / 疾病风险预测 / 队列分析 / 血管研发）
⑪ contact      联系方式 + 简历下载 + 数据来源
```

## 交互方式

| 操作 | 效果 |
|---|---|
| 底部 `‹` `›` 按钮 | 上一屏 / 下一屏 |
| 键盘 `←` `→`、`PageUp/PageDown`、空格 | 翻页 |
| 键盘 `Home` / `End` | 跳到首 / 末屏 |
| 底部圆点 | 直接跳到某一屏 |
| 顶部导航链接 | 跳到 封面 / 技能 / 项目 / 经历 / 联系 |
| **点击项目卡片** | 进入该项目概览页 |
| 项目页「返回项目列表」 | 回到 projects |
| 点击任意图表 | 灯箱放大（`Esc` 或点击关闭） |
| 地址栏 hash | 每屏有独立 `#id`，可直接分享某一屏链接 |

## 文件结构

```
site/
├── index.html                  # 中文版（翻页式）
├── en.html                     # 英文版（翻页式）
├── README.md
└── assets/
    ├── style.css               # 整屏布局 + 翻页动效 + 响应式
    ├── 周玉_数据分析_简历.pdf
    ├── charts/                 # 中文图表（16 张 SVG）
    │   ├── p1-fig01.svg … p1-fig10.svg
    │   ├── p2-fig01.svg … p2-fig06.svg
    │   └── en/                 # 英文图表（16 张 SVG，公司名已英文化）
    └── data/                   # 可下载数据与脚本
        ├── 项目一_清洗后数据.csv / 项目一_SQL分析.sql
        ├── 项目二_清洗后数据.csv / 项目二_SQL分析.sql
        └── 项目二_Tableau构建指南.md
```

## 本地预览与部署

```bash
cd site
python -m http.server 8000   # 浏览器打开 http://localhost:8000
```

部署到 GitHub Pages：把 `site` 下全部文件推到仓库根目录 → Settings → Pages → Source 选 `Deploy from a branch`（`main` / `root`）→ 访问 `https://<用户名>.github.io/<仓库>/`（英文版加 `en.html`）。仓库需为 Public，简历与数据文件都会公开。

## 如何修改

| 要改什么 | 改哪里 | 执行 |
|---|---|---|
| 页面文案（中/英） | `scripts/build_site.py`（`C` 字典；`CH` 为图表标题） | `python scripts/build_site.py` |
| 图表（中文） | `scripts/gen_charts.py` / `gen_retail_charts.py` | 对应脚本 |
| 图表（英文） | `scripts/gen_charts_en.py`（含公司名中英对照） | 该脚本 |
| 图表同步到站点 | `scripts/prep_site_assets.py` | 该脚本 |
| 版式与配色 | `site/assets/style.css` | 直接改 |

**新增一屏**：在 `build_site.py` 的 HTML 模板中加一个 `<section class="slide" id="新id">`，导航或卡片用 `data-go="新id"` 即可跳转——翻页脚本会自动把它纳入序列并生成圆点。

## 已验证项（无头 Chrome / Playwright 实测）

- 中英两版各 **11 屏**，在 1440×900、1920×1080、1366×768 三种视口下**均无内容溢出、无文档滚动**
- 每屏高度严格等于「视口高 − 顶栏」，符合整页固定尺寸要求
- 翻页交互全部正常：下一屏 / 项目卡片跳转 / 返回 / 方向键 / 导航跳转 / 圆点跳转
- 图表灯箱可正常打开与关闭；画廊中文 10 张、英文 10 张、项目二 6 张**全部加载成功**
- 手机 390×844 下控制条居中不溢出（此前圆点被 `.ctrl button` 样式撑宽导致溢出，已修复）
- 0 控制台报错、0 失败请求

## 窄屏回退

窄屏（≤900px）或矮屏（≤620px）时，单屏内容按单列排布；若仍放不下，该屏内允许纵向滚动，避免内容被裁切。
