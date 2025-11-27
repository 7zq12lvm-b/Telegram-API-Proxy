# Telegram API Proxy

![Version](https://img.shields.io/badge/version-6.0-blue.svg?cacheSeconds=2592000)
![License: GPL-3.0](https://img.shields.io/badge/License-GPL--3.0-yellow.svg)

A Cloudflare-based solution for accessing the Telegram API without VPN in regions where it's restricted.

## Overview

This project provides a secure and reliable proxy for the Telegram Bot API that works in regions where access to the official Telegram API might be restricted. The proxy is hosted on Cloudflare Pages, ensuring high availability and performance.

## Features

- Unlimited users and API requests
- High stability against network disruptions and filtering
- Secure data transmission
- Easy integration with existing code

## How to Use

Replace the standard Telegram API URL (`https://api.telegram.org/bot`) with:

```
https://telegram-api-proxy-anonymous.pages.dev/api/bot
```

### Example in JavaScript

```javascript
const Http = new XMLHttpRequest();
let botToken = "YOUR_BOT_TOKEN";
let ChatID = "YOUR_CHAT_ID";
let message = "Hello World";

var url = 'https://telegram-api-proxy-anonymous.pages.dev/api/bot' + botToken + 
          '/sendMessage?text=' + message + 
          '&chat_id=' + ChatID;

Http.open("GET", url);
Http.send();
```

### Example in Python

```python
import requests

def send_telegram_message(message):
    token = "YOUR_BOT_TOKEN"
    chat_id = "YOUR_CHAT_ID"
    url = f"https://telegram-api-proxy-anonymous.pages.dev/api/bot{token}/sendMessage"
    
    payload = {
        "text": message,
        "chat_id": chat_id
    }
    
    response = requests.get(url, params=payload)
    return response.json()
```

## Online Demo

You can access the web interface at:

[https://telegram-api-proxy-anonymous.pages.dev/](https://telegram-api-proxy-anonymous.pages.dev/)

## Deployment

想要自己部署到 Cloudflare？查看详细的部署指南：

- **[中文部署指南](DEPLOY.md)** - 包含 Cloudflare Pages 和 Workers 两种部署方式的详细说明

### Quick Start

1. **使用 Cloudflare Pages（推荐）**：
   - 将代码推送到 GitHub/GitLab
   - 在 Cloudflare Dashboard 中连接仓库并部署
   - 详细步骤见 [DEPLOY.md](DEPLOY.md)

2. **使用 Cloudflare Workers**：
   ```bash
   npm install -g wrangler
   wrangler login
   wrangler deploy
   ```

## License

This project is licensed under the [GPL-3.0](LICENSE) License.

## Author

**Anonymous**

* Telegram: [@BXAMbot](https://t.me/BXAMbot)
