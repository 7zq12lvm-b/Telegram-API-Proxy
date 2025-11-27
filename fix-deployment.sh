#!/bin/bash

# 快速修复部署脚本
# 用于诊断和修复 "Hello world" 问题

echo "=========================================="
echo "Telegram API Proxy 部署诊断工具"
echo "=========================================="
echo ""

# 检查文件结构
echo "1. 检查文件结构..."
if [ -f "functions/api/[[path]].js" ]; then
    echo "✅ Pages Functions 文件存在: functions/api/[[path]].js"
else
    echo "❌ Pages Functions 文件不存在！"
    echo "   请确保 functions/api/[[path]].js 存在"
    exit 1
fi

if [ -f "index.html" ]; then
    echo "✅ index.html 存在"
else
    echo "❌ index.html 不存在！"
    exit 1
fi

echo ""
echo "2. 检查 Git 状态..."
if [ -d ".git" ]; then
    echo "✅ Git 仓库已初始化"
    
    # 检查是否有未提交的更改
    if [ -n "$(git status --porcelain)" ]; then
        echo "⚠️  有未提交的更改："
        git status --short
        echo ""
        read -p "是否提交这些更改？(y/n) " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git add .
            git commit -m "Fix deployment - ensure Functions are included"
            echo "✅ 更改已提交"
        fi
    else
        echo "✅ 所有更改已提交"
    fi
    
    # 检查远程仓库
    if git remote -v | grep -q "origin"; then
        echo "✅ 远程仓库已配置"
        echo "   远程仓库: $(git remote get-url origin)"
    else
        echo "⚠️  未配置远程仓库"
        echo "   请添加远程仓库："
        echo "   git remote add origin <你的仓库URL>"
    fi
else
    echo "⚠️  未初始化 Git 仓库"
    echo "   建议初始化 Git："
    echo "   git init"
    echo "   git add ."
    echo "   git commit -m 'Initial commit'"
fi

echo ""
echo "3. 检查部署配置..."
if [ -f "package.json" ]; then
    echo "✅ package.json 存在"
else
    echo "❌ package.json 不存在"
fi

echo ""
echo "=========================================="
echo "诊断完成！"
echo "=========================================="
echo ""
echo "下一步操作："
echo ""
echo "如果使用 Cloudflare Pages："
echo "1. 确保代码已推送到 Git 仓库"
echo "2. 在 Cloudflare Dashboard 中："
echo "   - 进入 Workers & Pages → Pages"
echo "   - 找到你的项目"
echo "   - 检查 Functions 标签，确认 functions/api/[[path]].js 存在"
echo "   - 如果没有，点击 'Retry deployment' 或重新连接 Git"
echo ""
echo "如果使用 Cloudflare Workers："
echo "1. 确保 wrangler.toml 存在并配置正确"
echo "2. 运行: wrangler deploy"
echo ""
echo "验证部署："
echo "./test-api.sh 你的域名 你的BotToken"
echo ""

