#!/usr/bin/env python3
"""门店页生成脚本：读 data/stores.json，渲染 templates/，输出 stores/。

用法：python3 build.py
"""

import json
import sys
from datetime import date
from pathlib import Path

ROOT = Path(__file__).parent
DATA = ROOT / "data" / "stores.json"
OUT = ROOT / "stores"

REQUIRED_FIELDS = ["id", "name", "city", "category", "zone", "x", "y", "address"]

def main():
    stores = json.loads(DATA.read_text(encoding="utf-8"))

    # 必填检查
    seen = set()
    errors = []
    for s in stores:
        sid = s.get("id", "<无id>")
        for f in REQUIRED_FIELDS:
            if f not in s:
                errors.append(f"{sid}: 缺必填字段 {f}")
        if sid in seen:
            errors.append(f"{sid}: id 重复")
        seen.add(sid)
    if errors:
        print("数据检查未通过：", file=sys.stderr)
        for e in errors:
            print(f"  - {e}", file=sys.stderr)
        sys.exit(1)

    card_tpl = (ROOT / "templates" / "store.html").read_text(encoding="utf-8")
    faq_tpl = (ROOT / "templates" / "store-faq.html").read_text(encoding="utf-8")
    updated = date.today().strftime("%Y-%m")

    OUT.mkdir(exist_ok=True)

    # 清理旧产物
    for f in OUT.glob("*.html"):
        f.unlink()

    for s in stores:
        store_json = json.dumps(s, ensure_ascii=False, indent=2)
        card = card_tpl.replace("{{STORE_JSON}}", store_json)
        card = card.replace("{{name}}", s["name"])
        card = card.replace("{{faq_href}}", f"{s['id']}-faq.html")
        card = card.replace("{{UPDATED}}", updated)
        (OUT / f"{s['id']}.html").write_text(card, encoding="utf-8")
        print(f"生成 stores/{s['id']}.html")

        if s.get("faq"):
            faq_page = faq_tpl.replace("{{name}}", s["name"])
            faq_page = faq_page.replace(
                "{{FAQ_JSON}}", json.dumps(s["faq"], ensure_ascii=False, indent=2)
            )
            if s.get("phone"):
                hint = (
                    '<div class="hint">找不到答案？直接打电话问老板 👉 '
                    f'<a href="tel:{s["phone"]}" style="color:#2c7a4d;font-weight:500;">{s["phone"]}</a></div>'
                )
            else:
                hint = '<div class="hint">找不到答案？到店直接问老板最快 👋</div>'
            faq_page = faq_page.replace("{{HINT}}", hint)
            (OUT / f"{s['id']}-faq.html").write_text(faq_page, encoding="utf-8")
            print(f"生成 stores/{s['id']}-faq.html")

if __name__ == "__main__":
    main()
