# CHANGELOG

所有显著变更都将记录在此文件中。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)。

版本遵循语义化版本规范：0.0.x（探索期）→ 0.x.y（验证期）→ x.y.z（正式期）

---

## [Unreleased]

### 变更

- 部署链路由 GitHub Pages 改为阿里云 OSS + CDN（对齐 qtcloud-media 模式）：`manifests/terraform/`（qtstore-site 桶 + store.quanttide.com CDN 私有回源）、`scripts/configure-store-cdn.sh`（泛域名证书绑定）、部署流水线改 site/* tag 触发

## [0.1.0] - 2026-10-31

首个站点版本，部署至 store.quanttide.com。

### 新增

- `src/site/` 正式站点：首页、滁州老城示意地图、门店页生成脚本
- 门店数据单一事实源 `src/site/data/stores.json` 与字段规范 `schema.md`（三态布尔，宁可空着不编）
- 门店页 / FAQ 页模板，`build.py` 按数据生成 `stores/`，必填字段与 id 唯一性检查
- 部署工作流：main 推送触发构建并发 GitHub Pages（CNAME: store.quanttide.com）
- 首店 SOFA COFFEE 悦达889店：信息卡 + 常见问题；未核实字段（营业时间、电话、停车、容量）按约定留空显示「待确认」

### 移除

- `examples/site/` 四页原型，已收敛进 `src/site/`

## [Unreleased]

### 新增

- 仓库初始化：README、`src/site/` 站点源码占位
- `examples/site/` 四页原型迁入：首页、滁州老城门店地图、门店信息卡、SOFA COFFEE 常见问题；自 `quanttide-context-of-founder` 的 `default/laboratory/` 迁入
