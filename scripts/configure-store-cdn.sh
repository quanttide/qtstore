#!/bin/bash
# 为 store.quanttide.com 绑定 CDN HTTPS 证书（泛域名）。
#
# 背景：store.quanttide.com 是量潮门店中心发布域名，CDN 源站为 OSS 桶 qtstore-site
# （桶与 CDN 域名见 manifests/terraform/；发布流程见 .github/workflows/deploy-site.yml）。
# 证书为 acme.sh 签发的泛域名证书 *.quanttide.com（ZeroSSL），续期后需重跑本脚本更新证书。
#
# 前置：本机已登录 aliyun CLI（AK 模式）；acme.sh 证书目录存在。
set -e

DOMAIN='store.quanttide.com'
CERT_DIR='/home/iguo/.acme.sh/*.quanttide.com_ecc'
CERT_NAME="cert-${DOMAIN}-$(date +%s)"

echo "=== 绑定 HTTPS 证书（CDN）==="
aliyun cdn SetCdnDomainSSLCertificate \
  --DomainName "$DOMAIN" \
  --CertName "$CERT_NAME" \
  --CertType upload \
  --SSLProtocol on \
  --SSLPub "$(cat "$CERT_DIR/fullchain.cer")" \
  --SSLPri "$(cat "$CERT_DIR/*.quanttide.com.key")"

echo "完成。验证：curl -I https://${DOMAIN}/"
