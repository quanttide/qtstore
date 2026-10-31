# qtstore

量潮门店中心 — 门店信息与顾客入口的站点。

## 概述

对外呈现门店中心：顾客从这里进入，查看城市门店点位与单店信息卡。线上地址 [store.quanttide.com](https://store.quanttide.com)。

## 目录结构

```
qtstore/
├── src/site/          # 站点源码（首页、地图、门店数据与生成脚本，见其 README）
└── .github/workflows/ # 部署工作流（main 推送触发，构建后发 GitHub Pages）
```

## 加一家新店

改 `src/site/data/stores.json`，推送即可，流程见 `src/site/README.md`。

## 许可

[CC BY 4.0](LICENSE)
