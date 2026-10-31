# 站点源码

量潮门店中心的正式站点。首页 `index.html`、滁州地图 `map.html`；门店页由 `build.py` 从数据生成到 `stores/`。

## 目录

```
src/site/
├── index.html        # 首页
├── map.html          # 滁州老城示意地图（运行时读 data/stores.json）
├── data/
│   ├── stores.json   # 门店数据（唯一事实源）
│   └── schema.md     # 字段定义与业务约定
├── templates/        # 门店页 / FAQ 页模板
├── build.py          # 生成 stores/ 下的门店页
└── stores/           # 生成产物（不入库，部署时构建）
```

## 加一家新店

1. 按 `data/schema.md` 在 `data/stores.json` 末尾追加对象（没核实的字段不写，留"待确认"）。
2. 运行 `python3 build.py`，本地打开 `map.html` 和 `stores/{id}.html` 检查。
3. 提交推送，部署工作流自动重建。
