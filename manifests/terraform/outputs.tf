output "site_bucket" {
  description = "站点发布分发桶（部署产物见 .github/workflows/deploy-site.yml）"
  value       = alicloud_oss_bucket.site.bucket
}
