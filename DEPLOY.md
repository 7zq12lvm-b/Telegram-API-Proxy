# Cloudflare 部署指南

本指南将帮助您将这个 Telegram API Proxy 项目部署到 Cloudflare。项目支持两种部署方式：

1. **Cloudflare Pages**（推荐）- 包含前端页面和 API 代理功能
2. **Cloudflare Workers** - 纯 API 代理服务

---

## 方式一：使用 Cloudflare Pages 部署（推荐）

Cloudflare Pages 可以同时托管静态网站（前端页面）和 Functions（API 代理），这是推荐的部署方式。

### 前置要求

- Cloudflare 账户（免费账户即可）
- GitHub/GitLab 账户（用于连接代码仓库）

### 部署步骤

#### 1. 准备代码仓库

将代码推送到 GitHub 或 GitLab：

```bash
# 如果还没有初始化 git
git init
git add .
git commit -m "Initial commit"

# 推送到 GitHub（替换为你的仓库地址）
git remote add origin https://github.com/你的用户名/Telegram-API-Proxy.git
git push -u origin main
```

#### 2. 在 Cloudflare 中创建 Pages 项目

1. 登录 [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. 点击左侧菜单的 **"Workers & Pages"**
3. 点击 **"Create application"** → **"Pages"** → **"Connect to Git"**
4. 选择你的 Git 提供商（GitHub/GitLab）并授权
5. 选择你的仓库 `Telegram-API-Proxy`
6. 配置项目设置：
   - **Project name**: `telegram-api-proxy`（或你喜欢的名称）
   - **Production branch**: `main`（或你的主分支）
   - **Build command**: 留空（不需要构建）
   - **Build output directory**: `/`（根目录）
7. 点击 **"Save and Deploy"**

#### 3. 配置自定义域名（可选）

部署完成后，你可以：

1. 在 Pages 项目页面点击 **"Custom domains"**
2. 添加你的自定义域名
3. Cloudflare 会自动配置 DNS 记录

#### 4. 访问你的代理

部署完成后，你会得到一个类似这样的 URL：
```
https://telegram-api-proxy-你的用户名.pages.dev
```

API 代理地址为：
```
https://telegram-api-proxy-你的用户名.pages.dev/api/bot
```

### 验证部署

访问你的 Pages URL，应该能看到前端页面。然后测试 API：

```bash
# 替换 YOUR_BOT_TOKEN 为你的 Telegram Bot Token
curl "https://你的域名.pages.dev/api/botYOUR_BOT_TOKEN/getMe"
```

---

## 方式二：使用 Cloudflare Workers 部署

如果你只需要 API 代理功能，不需要前端页面，可以使用 Cloudflare Workers。

### 前置要求

- Cloudflare 账户
- 安装 [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/install-and-update/)

### 部署步骤

#### 1. 安装 Wrangler CLI

```bash
# 使用 npm
npm install -g wrangler

# 或使用 yarn
yarn global add wrangler
```

#### 2. 登录 Cloudflare

```bash
wrangler login
```

这会打开浏览器让你登录 Cloudflare 账户。

#### 3. 创建 Worker 项目配置

在项目根目录创建 `wrangler.toml` 文件：

```toml
name = "telegram-api-proxy"
main = "manual-worker/worker.js"
compatibility_date = "2024-01-01"

[env.production]
routes = [
  { pattern = "你的域名.com/*", zone_name = "你的域名.com" }
]
```

#### 4. 部署 Worker

```bash
# 部署到开发环境（测试）
wrangler dev

# 部署到生产环境
wrangler deploy
```

#### 5. 配置自定义域名（可选）

在 `wrangler.toml` 中配置路由，或通过 Cloudflare Dashboard：

1. 进入 **Workers & Pages** → 你的 Worker
2. 点击 **"Triggers"** → **"Routes"**
3. 添加路由规则：`你的域名.com/*`

### 验证部署

```bash
# 测试 API（替换 YOUR_BOT_TOKEN）
curl "https://你的域名.com/botYOUR_BOT_TOKEN/getMe"
```

---

## 使用 Wrangler CLI 快速部署（Pages）

如果你更喜欢使用命令行，也可以使用 Wrangler 部署 Pages：

### 1. 安装 Wrangler

```bash
npm install -g wrangler
```

### 2. 登录并创建 Pages 项目

```bash
wrangler login
wrangler pages project create telegram-api-proxy
```

### 3. 部署

```bash
wrangler pages deploy . --project-name=telegram-api-proxy
```

---

## 配置说明

### 修改 API URL

部署后，你需要更新前端页面中的 API URL。编辑 `index.html`：

```javascript
// 找到这一行（大约第 39 行）
<div class="api-url" id="apiUrl">https://telegram-api-proxy-anonymous.pages.dev/api/bot</div>

// 替换为你的域名
<div class="api-url" id="apiUrl">https://你的域名.pages.dev/api/bot</div>
```

### 修改地理限制（重要！）

**默认配置只允许来自伊朗（IR）的请求**。如果你在其他国家使用，需要修改配置：

编辑 `functions/api/[[path]].js` 和 `manual-worker/worker.js`：

```javascript
// 第 38-39 行

// 选项 1: 允许所有国家（推荐，移除限制）
const ALLOWED_COUNTRIES = [];      // 空数组 = 不限制
const BLOCKED_COUNTRIES = [];     // 空数组 = 不禁止

// 选项 2: 只允许特定国家
const ALLOWED_COUNTRIES = ['CN', 'US', 'IR'];  // 允许中国、美国、伊朗
const BLOCKED_COUNTRIES = [];

// 选项 3: 禁止特定国家
const ALLOWED_COUNTRIES = [];      // 空数组 = 允许所有
const BLOCKED_COUNTRIES = ['XX'];  // 禁止某个国家
```

**⚠️ 重要提示**：
- 如果 `ALLOWED_COUNTRIES` 不为空，只有列表中的国家可以访问
- 如果 `ALLOWED_COUNTRIES` 为空，则允许所有国家（除非在 `BLOCKED_COUNTRIES` 中）
- 修改后需要重新部署才能生效

### 修改速率限制（可选）

编辑速率限制配置：

```javascript
// 第 3-8 行
const RATE_LIMITS = {
    IP: { max: 100, window: 60000 },      // 每个 IP 每分钟最多 100 次请求
    TOKEN: { max: 200, window: 60000 },    // 每个 Token 每分钟最多 200 次请求
    GLOBAL: { max: 5000, window: 60000 },  // 全局每分钟最多 5000 次请求
    BURST: { max: 10, window: 1000 }       // 突发请求限制
};
```

---

## 使用代理

部署完成后，在你的代码中使用代理：

### JavaScript 示例

```javascript
const botToken = "YOUR_BOT_TOKEN";
const chatId = "YOUR_CHAT_ID";
const message = "Hello World";

const url = `https://你的域名.pages.dev/api/bot${botToken}/sendMessage?text=${encodeURIComponent(message)}&chat_id=${chatId}`;

fetch(url)
  .then(response => response.json())
  .then(data => console.log(data));
```

### Python 示例

```python
import requests

def send_telegram_message(message):
    token = "YOUR_BOT_TOKEN"
    chat_id = "YOUR_CHAT_ID"
    url = f"https://你的域名.pages.dev/api/bot{token}/sendMessage"
    
    payload = {
        "text": message,
        "chat_id": chat_id
    }
    
    response = requests.get(url, params=payload)
    return response.json()

# 使用
result = send_telegram_message("Hello from Python!")
print(result)
```

### cURL 示例

```bash
curl "https://你的域名.pages.dev/api/botYOUR_BOT_TOKEN/sendMessage?text=Hello&chat_id=YOUR_CHAT_ID"
```

---

## 常见问题

### Q: 部署后出现 404 错误？

A: 确保：
- 使用正确的路径格式：`/api/bot<TOKEN>/<METHOD>`
- Functions 文件位于 `functions/api/[[path]].js`
- 如果使用 Workers，确保路由配置正确

### Q: 出现 403 "Geographic restriction" 错误？

A: 这是**代理服务器的地理限制**，不是 Telegram 官方的错误。

错误信息示例：
```json
{"ok":false,"error":"Geographic restriction","error_code":403}
```

**原因**：默认配置只允许来自伊朗（IR）的请求。

**解决方法**：
1. 如果你使用的是别人部署的代理，需要自己部署一个
2. 修改 `functions/api/[[path]].js` 和 `manual-worker/worker.js` 中的配置：
   ```javascript
   const ALLOWED_COUNTRIES = [];  // 改为空数组，允许所有国家
   ```
3. 重新部署代码

### Q: 如何查看日志？

A: 
- **Pages**: 在 Cloudflare Dashboard → Pages → 你的项目 → Functions → Logs
- **Workers**: 在 Dashboard → Workers & Pages → 你的 Worker → Logs

### Q: 如何更新代码？

A: 
- **Pages**: 推送代码到 Git 仓库，Cloudflare 会自动重新部署
- **Workers**: 运行 `wrangler deploy` 重新部署

### Q: 免费账户有限制吗？

A: Cloudflare 免费账户的限制：
- **Pages**: 
  - 500 次构建/月
  - 无限请求
  - 100,000 次 Functions 调用/天
- **Workers**: 
  - 100,000 次请求/天
  - 10ms CPU 时间/请求（免费计划）

对于大多数使用场景，免费计划已经足够。

---

## 安全建议

1. **不要公开你的 Bot Token**：确保 Token 不会泄露
2. **使用环境变量**：敏感信息不要硬编码
3. **启用速率限制**：防止滥用
4. **监控日志**：定期检查异常请求

---

## 技术支持

如果遇到问题，可以：
1. 查看 [Cloudflare 文档](https://developers.cloudflare.com/)
2. 检查项目 Issues
3. 查看 Cloudflare Dashboard 中的日志

---

## 许可证

本项目采用 GPL-3.0 许可证。详见 [LICENSE](LICENSE) 文件。

