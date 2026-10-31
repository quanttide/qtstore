# 门店数据规范

门店数据一处一份：`data/stores.json` 是唯一事实源。地图页运行时读它，门店页由 `build.py` 读它生成。改数据只改这个文件，然后重新跑 `python3 build.py`。

## 字段

| 字段 | 类型 | 说明 |
|------|------|------|
| `id` | string | 唯一标识，小写字母、数字、连字符（如 `sofa-coffee`）。生成页面名 `stores/{id}.html` |
| `name` | string | 店名 |
| `branch` | string | 分店名，可省略 |
| `city` | string | 城市 |
| `category` | string | 品类（咖啡馆、火锅……） |
| `zone` | string | 片区（如 `老城 · 南湖片区`），地图页展示用 |
| `x`, `y` | number | 地图坐标。画布 800×800 ≈ 4km×4km，参考点：南湖中心 ~(420,600)、悦达889 ~(390,545)、北湖 ~(550,240)、白云商厦 ~(360,270)。加店按"东南西北"目测放置 |
| `address` | string | 地址 |
| `hours` | string | 营业时间，可省略 |
| `phone` | string | 电话，可省略 |
| `parking` | string | 停车，可省略 |
| `transit` | string | 公交，可省略 |
| `seatingIndoor` | string | 店内座位 |
| `seatingOutdoor` | string | 户外座位 |
| `capacityNote` | string | 容量说明 |
| `privateRoom` | bool | 包间 |
| `bestFor` | string[] | 适合场景 |
| `priceRange` | string | 人均 |
| `menuTags` | string[] | 品类标签 |
| `stayPolicy` | string | 停留政策 |
| `invoice` | bool | 发票 |
| `bookingRequired` | bool | 是否需预订 |
| `deposit` | bool | 押金 |
| `minSpend` | bool | 低消 |
| `petAllowed` | bool | 宠物 |
| `powerOutlet` | bool | 电源 |
| `wifi` | bool | WiFi |
| `smoking` | bool | 是否允许吸烟 |
| `notes` | string | 备注，可省略 |
| `faq` | object[] | 常见问题，可省略。省略则不生成 FAQ 页 |

## 三态布尔

布尔字段的值有三种，渲染结果不同：

- `true` → 绿色标签（"有"、"可开具"……）
- `false` → 红色标签（"无"、"暂不支持"……）
- 字段缺省 → 灰色斜体"待确认"

文本字段缺省同样渲染"待确认"。

## 业务约定

**宁可空着，也不编。** 没核实过的值不要写进文件，把字段整个删掉让它显示"待确认"。不要在值里塞"（待确认）""（估算）"这类注记——待确认就删字段，值里只放事实。

## FAQ 结构

```json
"faq": [
  {
    "group": "分组名",
    "items": [
      { "q": "问题？", "a": "确定答案" },
      { "q": "问题？", "a": null },
      { "q": "问题？", "a": { "yes": true,  "text": "有，详情" } },
      { "q": "问题？", "a": { "yes": false, "text": "不提供" } }
    ]
  }
]
```

答案四态：字符串（确定）、`null`（待确认，灰显）、`{"yes": true}`（绿色"有"标签）、`{"yes": false}`（红色"无"标签）。

## 示例：一家完整门店

```json
{
  "id": "sofa-coffee",
  "name": "SOFA COFFEE",
  "branch": "悦达889店",
  "city": "滁州",
  "category": "咖啡馆",
  "zone": "老城 · 南湖片区",
  "x": 392,
  "y": 542,
  "address": "琅琊区育新东路158号 悦达889 9栋206-207（环城路19号，近南湖/老1912）",
  "priceRange": "35–45 元",
  "menuTags": ["咖啡", "非咖啡饮品", "甜点"],
  "stayPolicy": "可久坐不赶人",
  "bestFor": ["单人久坐", "双人约会", "朋友小聚", "轻办公"],
  "privateRoom": false,
  "bookingRequired": false,
  "deposit": false,
  "minSpend": false,
  "invoice": false,
  "petAllowed": false,
  "powerOutlet": true,
  "wifi": true,
  "smoking": false
}
```

注意 `hours`、`phone`、`parking`、`capacityNote` 都不在其中——原型里的值带"待核实""估算"注记，未核实，按约定删掉显示"待确认"。
