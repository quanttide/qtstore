# =============================================================================
# CDN + DNS（store.quanttide.com）
#
# 链路：OSS 静态网站桶（site.tf，私有）→ CDN 加速 + 私有回源鉴权
#   → CNAME 接入（云解析）→ 用户浏览器
#
# 说明：
#   - 桶 ACL 私有（RAM 用户无权限设公共读），回源鉴权分两步：
#     ① 账号级授权（AliyunCDNAccessingPrivateOSSRole，已存在——由首个
#        qtcloud-media studio 部署创建，不在本仓重复管理；若缺失，执行：
#        aliyun ram AttachPolicyToRole --RoleName AliyunCDNAccessingPrivateOSSRole
#        --PolicyName AliyunCDNAccessingPrivateOSSRolePolicy --PolicyType Custom）
#     ② 域名级开关：私有回源开关（l2_oss_key，private_oss_auth=on）
#   - 证书：*.quanttide.com 泛域名证书（acme.sh 签发，90 天自动续期；
#     续期后重跑 scripts/configure-store-cdn.sh 更新 CDN 证书）。
#     terraform 不管理证书内容（避免私钥入库）。
#   - 前置：quanttide.com 已完成 ICP 备案
# =============================================================================

resource "alicloud_cdn_domain_new" "site" {
  domain_name = "store.quanttide.com"
  cdn_type    = "web"
  scope       = "global"

  # 源站：OSS 静态网站桶（私有回源鉴权见上方说明）
  sources {
    content  = format("%s.%s", alicloud_oss_bucket.site.bucket, alicloud_oss_bucket.site.extranet_endpoint)
    type     = "oss"
    port     = 80
    priority = 20
  }
}

# ── 私有 Bucket 回源开关（l2_oss_key：private_oss_auth=on，STS 同账号回源） ──
resource "alicloud_cdn_domain_config" "site_private_back" {
  domain_name   = alicloud_cdn_domain_new.site.domain_name
  function_name = "l2_oss_key"
  function_args {
    arg_name  = "private_oss_auth"
    arg_value = "on"
  }
}

# 根路径改写为 /index.html：私有回源（签名请求）与 OSS 静态网站托管
# 默认首页重写存在已知冲突（/ 回源 403），改为 CDN 侧直接回源 index.html
resource "alicloud_cdn_domain_config" "site_root_rewrite" {
  domain_name   = alicloud_cdn_domain_new.site.domain_name
  function_name = "back_to_origin_url_rewrite"
  function_args {
    arg_name  = "source_url"
    arg_value = "^/$"
  }
  function_args {
    arg_name  = "target_url"
    arg_value = "/index.html"
  }
  function_args {
    arg_name  = "flag"
    arg_value = "break"
  }
}

# 强制 HTTPS：HTTP 请求 301 跳转 HTTPS
resource "alicloud_cdn_domain_config" "site_https_force" {
  domain_name   = alicloud_cdn_domain_new.site.domain_name
  function_name = "https_force"
  function_args {
    arg_name  = "enable"
    arg_value = "on"
  }
}

# ── DNS：CNAME 接入 ─────────────────────────────────────────────────

resource "alicloud_alidns_record" "site" {
  domain_name = "quanttide.com"
  rr          = "store"
  type        = "CNAME"
  value       = alicloud_cdn_domain_new.site.cname
  ttl         = 600
}
