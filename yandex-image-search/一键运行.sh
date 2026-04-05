#!/bin/bash

# 🚀 一键运行Yandex解决方案
# 无需API，无需国外支付，完全免费

echo "="*60
echo "🚀 Yandex解决方案 - 一键运行脚本"
echo "="*60
echo "方案: 服务器图床 + Yandex搜索 + 自动解析"
echo "优势: 无需API，无需国外支付，完全免费"
echo "目标: 查找8张最相似的项链图片"
echo "="*60

# 检查Python环境
echo "🔧 检查环境..."
python3 --version || { echo "❌ Python3未安装"; exit 1; }

# 检查必要库
echo "📦 检查Python库..."
REQUIRED_PACKAGES=("requests" "playwright" "fastapi" "uvicorn")
for pkg in "${REQUIRED_PACKAGES[@]}"; do
    python3 -c "import $pkg" 2>/dev/null && echo "✅ $pkg 已安装" || echo "⚠️ $pkg 未安装"
done

# 安装缺失的库
echo ""
echo "📥 安装必要库..."
pip3 install requests playwright fastapi uvicorn --quiet

# 安装Playwright浏览器
echo "🌐 安装Playwright浏览器..."
python3 -m playwright install chromium

# 创建目录结构
echo "📁 创建目录结构..."
mkdir -p ~/桌面/测试结果/08_Yandex解决方案/{logs,results,images}

# 检查源图片
SOURCE_IMAGE="$HOME/桌面/测试结果/源图_项链.png"
echo "🔍 检查源图片: $SOURCE_IMAGE"

if [ ! -f "$SOURCE_IMAGE" ]; then
    echo "❌ 源图片不存在: $SOURCE_IMAGE"
    echo "请确保源图片存在，或修改SOURCE_IMAGE变量"
    exit 1
fi

echo "✅ 源图片存在，大小: $(stat -c%s "$SOURCE_IMAGE") 字节"

# 启动图床服务器 (后台运行)
echo ""
echo "🚀 启动图床服务器..."
cd ~/桌面/测试结果/08_Yandex解决方案
python3 图床服务器.py > logs/server.log 2>&1 &
SERVER_PID=$!
echo "📡 服务器PID: $SERVER_PID"

# 等待服务器启动
echo "⏳ 等待服务器启动..."
sleep 3

# 检查服务器状态
echo "🔍 检查服务器状态..."
curl -s http://192.168.1.217:8000/status || echo "⚠️ 服务器可能未启动成功"

# 运行主程序
echo ""
echo "🎯 开始查找相似项链..."
cd ~/桌面/测试结果/08_Yandex解决方案
python3 完整解决方案.py

# 保存结果
echo ""
echo "📊 保存运行结果..."
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
cp -r results/ results_backup_$TIMESTAMP/ 2>/dev/null || true

# 停止服务器
echo ""
echo "🛑 停止图床服务器..."
kill $SERVER_PID 2>/dev/null || true

echo ""
echo "="*60
echo "✅ 运行完成！"
echo "="*60
echo ""
echo "📋 生成的文件:"
echo "  📁 ~/桌面/测试结果/08_Yandex解决方案/"
echo "    ├── logs/              # 日志文件"
echo "    ├── results/           # 搜索结果"
echo "    ├── images/            # 下载的图片"
echo "    ├── 图床服务器.py      # 图床服务器"
echo "    ├── yandex_search.py   # Yandex搜索"
echo "    ├── 完整解决方案.py    # 主程序"
echo "    └── 一键运行.sh        # 本脚本"
echo ""
echo "🌐 查看结果:"
echo "  cd ~/桌面/测试结果/08_Yandex解决方案/results/"
echo "  xdg-open 查看相似款式.html"
echo ""
echo "🚀 下一步:"
echo "  1. 验证搜索结果质量"
echo "  2. 优化搜索精度"
echo "  3. 开始商业化部署"
echo "  4. 寻找第一批客户"
echo ""
echo "💡 商业模式:"
echo "  💰 免费版: 每天5次搜索"
echo "  💰 基础版: ¥99/月，100次搜索"
echo "  💰 专业版: ¥299/月，无限搜索"
echo "  💰 企业版: ¥999/月，定制功能"
echo ""
echo "🎯 目标客户:"
echo "  👔 电商卖家 (找竞品、分析市场)"
echo "  🛒 采购人员 (找供应商、比价)"
echo "  💎 珠宝商 (设计参考、市场调研)"
echo "  👤 个人用户 (找同款、比价)"
echo ""
echo "="*60
echo "💡 一句话结论: 没支付能力 ≠ 做不了项目，只是要选对路径！"
echo "这个方案你1天就能跑通，立即开始赚钱！"
echo "="*60