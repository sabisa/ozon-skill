# Ozon 选品研究工具

Ozon 电商平台选品研究工具集，包含技能手册和研究报告。

## 📁 目录结构

```
ozon-skill/
├── README.md              # 本文件
├── reports/               # 研究报告
│   ├── Ozon蓝海选品完整报告-含尺寸.md
│   ├── Ozon蓝海选品完整报告-汇总版.md
│   └── Ozon蓝海选品详细报告-商品数据.md
├── data/                  # 原始数据
│   └── products_full_data.json
├── skill/                 # 技能模块
│   ├── SKILL.md
│   ├── prompts/
│   ├── references/
│   └── templates/
└── ozon-logistics-calculator/
```

## 📊 数据概览

- 品类数量: 20个
- 商品数量: 64个
- 蓝海商品: 18个（评论数≤100）
- 数据来源: 布丁猫插件
- 更新日期: 2026-07-10

## 🛠️ 快速开始

```bash
# 启动浏览器
mkdir -p /tmp/chrome-ozon-research
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --user-data-dir=/tmp/chrome-ozon-research \
  --remote-debugging-port=9223 \
  --no-first-run \
  --no-default-browser-check > /dev/null 2>&1 &

# 使用 browser-use
browser-use
```

详细使用请参考 `skill/SKILL.md`
