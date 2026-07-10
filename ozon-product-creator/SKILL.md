---
name: ozon-product-creator
description: 在 Ozon 卖家后台创建商品，自动填写商品信息、表单、上传图片
---

# Ozon Product Creator

在 Ozon 卖家后台 (seller.ozon.ru) 自动创建商品，填写表单、上传图片、提交商品。

## 前提条件

1. Chrome 已开启远程调试：`chrome://inspect/#remote-debugging` → 勾选 "Allow remote debugging"
2. 确保 seller.ozon.ru 已登录

---

## 第一步：获取源商品信息

### 打开源商品页面

```bash
browser-use <<'PY'
new_tab("https://www.ozon.ru/product/商品ID")
wait_for_load()
PY
```

### 获取商品基本信息（JSON-LD）

```bash
browser-use <<'PY'
# 获取 JSON-LD 产品数据（包含名称、描述、图片、价格等）
product_data = js("""
(() => {
  const scripts = document.querySelectorAll('script[type="application/ld+json"]');
  for (const script of scripts) {
    try {
      const data = JSON.parse(script.textContent);
      if (data['@type'] === 'Product') {
        return {
          name: data.name,
          description: data.description,
          brand: data.brand,
          image: data.image,
          images: data.image ? [data.image].flat() : [],
          offers: data.offers ? {
            price: data.offers.price,
            priceCurrency: data.offers.priceCurrency
          } : null
        };
      }
      if (data['@graph']) {
        const product = data['@graph'].find(item => item['@type'] === 'Product');
        if (product) {
          return {
            name: product.name,
            description: product.description,
            brand: product.brand,
            image: product.image,
            images: product.image ? [product.image].flat() : [],
            offers: product.offers ? {
              price: product.offers.price,
              priceCurrency: product.offers.priceCurrency
            } : null
          };
        }
      }
    } catch (e) {}
  }
  return null;
})()
""")
print("=== 商品数据 ===")
for key, value in product_data.items():
    if key == 'description':
        print(f"{key}: {str(value)[:200]}...")
    elif key == 'images':
        print(f"{key}: {len(value)} 张图片")
    else:
        print(f"{key}: {value}")
PY
```

### 获取商品尺寸、重量、类目（布丁猫插件）

在商品详情页，使用**布丁猫插件**可以看到：
- 包装尺寸（深×宽×高）
- 含包装重量
- 三级类目路径（如：儿童用品 > 玩具 > 故事角色扮演玩具）

### 获取商品图片

```bash
browser-use <<'PY'
# 从 JSON-LD 获取所有图片
images = js("""
(() => {
  const scripts = document.querySelectorAll('script[type="application/ld+json"]');
  for (const script of scripts) {
    try {
      const data = JSON.parse(script.textContent);
      const product = data['@type'] === 'Product' ? data : 
                      data['@graph']?.find(item => item['@type'] === 'Product');
      if (product && product.image) {
        return [product.image].flat();
      }
    } catch (e) {}
  }
  return [];
})()
""")
print("=== 图片列表 ===")
for i, img in enumerate(images[:10], 1):  # 最多10张
    print(f"{i}: {img}")
PY
```

### 下载图片到本地

```bash
# 创建图片目录
mkdir -p /Users/kyra.w/ozon_images

# 下载图片（替换为实际图片URL）
curl -o /Users/kyra.w/ozon_images/01.jpg "https://ir-21.ozonru.cn/s3/multimedia-b/6827910059.jpg"
curl -o /Users/kyra.w/ozon_images/02.jpg "https://ir-21.ozonru.cn/s3/multimedia-1/6827910060.jpg"
# ... 继续下载其他图片
```

### 获取关键词（Seefar 插件）

在商品详情页，使用 **Seefar 插件的 SKU Reverse 模块** 可以获取关键词列表，这些关键词可以填入商品的主题标签字段。

---

## 第二步：在卖家后台创建商品

### 打开商品创建页面

```bash
browser-use <<'PY'
new_tab("https://seller.ozon.ru/app/products/create")
wait_for_load()
PY
```

### 恢复草稿（如有）

如果有未完成的草稿，点击"继续"恢复：

```bash
browser-use <<'PY'
js("""
(() => {
  const btn = [...document.querySelectorAll('button')].find(b => 
    b.textContent.includes('继续') || b.textContent.includes('Продолжить')
  );
  if (btn) btn.click();
})()
""")
wait_for_load()
PY
```

### 批量填写表单字段

```bash
browser-use <<'PY'
js("""
(function() {
  const nativeSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
  
  const fields = {
    name: '商品名称（俄语）',
    offerId: '20260708000000',  // 格式：年月日时分秒
    price: '150.00',
    depth: '170',      // 包装深度 mm
    width: '110',      // 包装宽度 mm
    height: '240',     // 包装高度 mm
    weight: '803'      // 含包装重量 g
  };
  
  for (const [name, value] of Object.entries(fields)) {
    const input = document.querySelector(`input[name="${name}"]`);
    if (input) {
      nativeSetter.call(input, value);
      input.dispatchEvent(new Event('input', { bubbles: true }));
      input.dispatchEvent(new Event('change', { bubbles: true }));
    }
  }
  return 'Fields filled';
})()
""")
PY
```

### 选择类目

在类目搜索框中输入关键词，选择正确的三级类目（建议手动选择）。

### 选择品牌

```bash
browser-use <<'PY'
# 选择"无品牌"（Без бренда / No brand）
js('''
(() => {
  const input = document.querySelector('input[placeholder*="品牌"]');
  if (input) {
    input.click();
    // 等待下拉列表出现
    return 'Brand input clicked';
  }
  return 'Brand input not found';
})()
''')
PY
```

### 填写主题标签（关键词）

将 Seefar 插件获取的关键词填入主题标签字段：

```bash
browser-use <<'PY'
# 查找主题标签输入框
js("""
(function() {
  // 查找主题标签输入区域
  const tagInput = document.querySelector('textarea[placeholder*="标签"], input[placeholder*="标签"], [class*="tag"] input');
  if (tagInput) {
    const nativeSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    const keywords = ['набор доктора', 'детский набор', 'игра в доктора', 'стоматолог'];
    nativeSetter.call(tagInput, keywords.join(', '));
    tagInput.dispatchEvent(new Event('input', { bubbles: true }));
    return 'Tags set';
  }
  return 'Tag input not found';
})()
""")
PY
```

### 上传图片

```bash
browser-use <<'PY'
# 获取 file input 元素
file_input = js('''
(() => {
  const inputs = document.querySelectorAll("input[type=file]");
  for (const inp of inputs) {
    const rect = inp.getBoundingClientRect();
    if (rect.width > 0) {
      return {found: true, x: rect.x, y: rect.y};
    }
  }
  return {found: false};
})()
''')
print("File input:", file_input)
PY

# 上传图片
browser-use <<'PY'
result = cdp("DOM.setFileInputFiles", nodeId=149, files=[
  "/Users/kyra.w/ozon_images/01.jpg",
  "/Users/kyra.w/ozon_images/02.jpg",
  "/Users/kyra.w/ozon_images/03.jpg",
  "/Users/kyra.w/ozon_images/04.jpg",
  "/Users/kyra.w/ozon_images/05.jpg",
  "/Users/kyra.w/ozon_images/06.jpg",
  "/Users/kyra.w/ozon_images/07.jpg",
  "/Users/kyra.w/ozon_images/08.jpg",
  "/Users/kyra.w/ozon_images/09.jpg",
  "/Users/kyra.w/ozon_images/10.jpg"
])
print("Upload result:", result)
PY
```

### 填写商品描述

```bash
browser-use <<'PY'
# 点击富文本编辑器获得焦点
js('''
(() => {
  const editor = document.querySelector(".ProseMirror");
  if (editor) {
    editor.focus();
    return "Focused";
  }
  return "Editor not found";
})()
''')

# 使用 CDP 键盘事件输入描述文本
text = "Сюжетно ролевой набор для игры в доктора и стоматолога."
for char in text:
    cdp("Input.dispatchKeyEvent", type="keyDown", text=char, key=char)
    cdp("Input.dispatchKeyEvent", type="keyUp", key=char)
PY
```

### 滚动页面

```bash
browser-use <<'PY'
js("window.scrollTo(0, 500)")
PY
```

### 点击按钮（查找坐标）

```bash
browser-use <<'PY'
# 截图查看按钮位置
capture_screenshot()

# 或者查找按钮并点击
js("""
(() => {
  const btn = [...document.querySelectorAll('button')].find(b => 
    b.textContent.includes('完成创建') || b.textContent.includes('Создать')
  );
  if (btn) {
    btn.click();
    return 'Clicked: ' + btn.textContent;
  }
  return 'Button not found';
})()
""")
PY
```

---

## 常用命令速查

```bash
# 查看当前页面截图
browser-use <<'PY'
capture_screenshot()
PY

# 查看页面信息
browser-use <<'PY'
print(page_info())
PY

# 获取所有链接
browser-use <<'PY'
print(get_links())
PY

# 获取所有输入字段状态
browser-use <<'PY'
fields = js("""
(function() {
  const inputs = document.querySelectorAll('input[name]');
  return [...inputs].map(i => ({name: i.name, value: i.value})).filter(i => i.value);
})()
""")
for f in fields:
    print(f"{f['name']}: {f['value']}")
PY
```

---

## 常见问题

### 输入框无法输入
React 输入框必须使用 native setter：
```javascript
const nativeSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
nativeSetter.call(input, 'value');
input.dispatchEvent(new Event('input', { bubbles: true }));
```

### 浏览器超时
重新连接即可：
```bash
browser-use <<'PY'
print(page_info())
PY
```

### 类目选择无法自动化
OZON 的类目搜索组件较复杂，建议手动选择。

### 图片上传失败
确保 nodeId 正确，或者先截图确认 file input 可见。
