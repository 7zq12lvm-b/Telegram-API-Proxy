#!/bin/bash

# Telegram API Proxy 测试脚本
# 使用方法: ./test-api.sh YOUR_DOMAIN YOUR_BOT_TOKEN

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "使用方法: ./test-api.sh <你的域名> <你的Bot Token>"
    echo "示例: ./test-api.sh telegram-api-proxy.pages.dev 123456789:ABCdefGHIjklMNOpqrsTUVwxyz"
    exit 1
fi

DOMAIN=$1
TOKEN=$2

echo "测试 Telegram API Proxy..."
echo "域名: $DOMAIN"
echo "Token: ${TOKEN:0:20}..."
echo ""

# 测试 1: 检查根路径（应该返回 HTML）
echo "测试 1: 检查根路径..."
ROOT_RESPONSE=$(curl -s "https://$DOMAIN/")
if echo "$ROOT_RESPONSE" | grep -q "<!DOCTYPE html>"; then
    echo "✅ 根路径正常（返回 HTML）"
else
    echo "❌ 根路径异常"
fi
echo ""

# 测试 2: 检查 API 路径格式（应该返回 JSON）
echo "测试 2: 检查 API 路径格式..."
API_RESPONSE=$(curl -s "https://$DOMAIN/api/bot$TOKEN/getMe")
if echo "$API_RESPONSE" | grep -q '"ok"'; then
    echo "✅ API 路径格式正确（返回 JSON）"
    echo "响应: $API_RESPONSE"
elif echo "$API_RESPONSE" | grep -q "<!DOCTYPE html>"; then
    echo "❌ API 路径返回了 HTML 而不是 JSON"
    echo "可能的原因:"
    echo "  1. Functions 未正确部署"
    echo "  2. URL 格式错误（但这里看起来是正确的）"
    echo "  3. 检查 Cloudflare Dashboard 中的 Functions 日志"
else
    echo "⚠️  未知响应格式:"
    echo "$API_RESPONSE" | head -c 200
    echo ""
fi
echo ""

# 测试 3: 检查错误的路径格式（应该返回错误 JSON）
echo "测试 3: 检查错误路径格式（缺少 /api）..."
WRONG_RESPONSE=$(curl -s "https://$DOMAIN/bot$TOKEN/getMe")
if echo "$WRONG_RESPONSE" | grep -q '"error"'; then
    echo "✅ 错误路径正确返回错误信息"
elif echo "$WRONG_RESPONSE" | grep -q "<!DOCTYPE html>"; then
    echo "⚠️  错误路径返回了 HTML（这是正常的，因为请求没有匹配到 Functions）"
else
    echo "响应: $WRONG_RESPONSE" | head -c 200
fi
echo ""

echo "测试完成！"
echo ""
echo "如果测试失败，请检查："
echo "1. Functions 文件是否存在: functions/api/[[path]].js"
echo "2. Cloudflare Dashboard → Pages → 你的项目 → Functions → Logs"
echo "3. 确保 URL 格式正确: https://你的域名.pages.dev/api/bot<TOKEN>/<METHOD>"

