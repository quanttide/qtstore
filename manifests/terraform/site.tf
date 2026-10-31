# site 站点静态托管桶（IaC）
#
# 桶 qtstore-site：命名对齐站点规范 {repo}-{type}（如 qtmedia-site / qtclass-studio）。
# 产物：纯静态站点（src/site，build.py 生成 stores/ 后整体上传）。
# 静态网站托管：index.html 默认首页（store.quanttide.com 根路径）。
# 部署流水线：.github/workflows/deploy-site.yml（site/* tag 触发 → build.py → ossutil cp → 刷新 CDN）。
#
# 注意：桶保持私有（RAM 用户无权限设公共读 ACL，阿里云禁止 RAM 用户开放公共读）；
# CDN 回源鉴权见 cdn.tf（账号级 RAM 角色 + 私有回源开关）。

resource "alicloud_oss_bucket" "site" {
  bucket        = "qtstore-site"
  storage_class = "Standard"

  # 静态网站托管（门户入口 index.html）
  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  tags = {
    App = "qtstore-site"
    Env = "production"
  }
}
