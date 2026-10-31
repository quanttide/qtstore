# qtstore 部署选型（IaC）

对齐 qtcloud-media 的部署模式（私有桶 + CDN 私有回源鉴权），作为 Terraform 基础设施代码的设计依据。

## 部署选型

| 维度 | 选型 | 说明 |
|------|------|------|
| 站点形态 | 纯静态（`src/site`，`build.py` 生成门店页） | 承载 store.quanttide.com：首页 + 滁州地图 + 门店页 |
| 发布分发 | 阿里云 OSS 桶 `qtstore-site` | 静态网站托管（index.html 默认页），桶私有 |
| CDN | 阿里云 CDN `store.quanttide.com`（回源 qtstore-site，私有回源鉴权） | 泛域名证书 `*.quanttide.com`（acme.sh 签发，续期后重跑 `scripts/configure-store-cdn.sh`） |
| 服务端 | **不适用** | 首页与门店页均为纯客户端 |

## 本 IaC 范围

- **应用级**：`site.tf`（OSS 桶 `qtstore-site`）、`cdn.tf`（CDN 域名 + 私有回源开关 + 根路径改写 + 强制 HTTPS + DNS CNAME）
- **不含** 证书内容（私钥不入库，脚本绑定）；CDN 回源私有鉴权的 RAM 角色为账号级共享资源（由首个 qtcloud-media 部署创建），不在本仓管理

## site 发布

- 基础设施：`terraform apply`（状态在 `quanttide-terraform-state/qtstore/terraform.tfstate`）
- 构建上传：`.github/workflows/deploy-site.yml`（推送 tag `site/*` 触发 → build.py → ossutil cp → 刷新 CDN）
- 首次上线（2026-10-31，site/v0.1.0）为手动 ossutil 上传 + 脚本绑证书；后续版本走 tag 流水线

## 关键操作记录

1. **公共读被禁**：账户策略禁止 RAM 用户设公共读 ACL（`Put public bucket acl is not allowed`），桶保持私有，靠 CDN 私有回源（`l2_oss_key` 开关 + 账号级角色）分发；直连 OSS 会 403，属预期。
2. **根路径 403 冲突**：私有回源（签名请求）与 OSS 静态网站托管默认首页重写冲突，已在 `cdn.tf` 用 `back_to_origin_url_rewrite` 将 `/` 改写为 `/index.html`。
3. **证书续期**：`*.quanttide.com` 泛域名证书 90 天自动续期，续期后重跑 `scripts/configure-store-cdn.sh` 更新 CDN 绑定。
