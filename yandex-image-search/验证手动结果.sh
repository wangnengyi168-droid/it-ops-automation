#!/bin/bash

echo "🔍 验证手动搜索结果"
echo "===================="

RESULT_DIR="手动结果"

# 检查目录
if [ ! -d "$RESULT_DIR" ]; then
    echo "❌ 结果目录不存在: $RESULT_DIR"
    echo "请先运行手动操作，保存8张图片"
    exit 1
fi

# 检查图片数量
echo "📊 检查图片数量..."
IMAGE_COUNT=$(find "$RESULT_DIR" -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" | wc -l)
echo "找到图片: $IMAGE_COUNT 张"

if [ "$IMAGE_COUNT" -eq 0 ]; then
    echo "❌ 未找到任何图片"
    exit 1
fi

# 检查命名规范
echo ""
echo "📝 检查命名规范..."
CORRECT_NAMES=0
for i in {1..8}; do
    if [ -f "$RESULT_DIR/yandex_necklace_$i.jpg" ]; then
        echo "✅ yandex_necklace_$i.jpg 存在"
        CORRECT_NAMES=$((CORRECT_NAMES + 1))
    else
        echo "⚠️ yandex_necklace_$i.jpg 不存在"
    fi
done

# 显示所有图片
echo ""
echo "🖼️ 所有图片列表:"
ls -la "$RESULT_DIR/"*.jpg "$RESULT_DIR/"*.jpeg "$RESULT_DIR/"*.png 2>/dev/null || echo "未找到图片文件"

# 检查图片大小
echo ""
echo "📏 图片大小统计:"
for img in "$RESULT_DIR/"*.jpg "$RESULT_DIR/"*.jpeg "$RESULT_DIR/"*.png 2>/dev/null; do
    if [ -f "$img" ]; then
        size=$(stat -c%s "$img")
        echo "  $(basename "$img"): $size 字节"
    fi
done

# 创建HTML查看器
echo ""
echo "🌐 创建HTML查看器..."
cat > "$RESULT_DIR/查看结果.html" << 'EOF'
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>手动搜索 - 项链相似款式</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { text-align: center; margin-bottom: 30px; }
        .image-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; }
        .image-card { border: 1px solid #ddd; padding: 10px; border-radius: 5px; }
        .image-card img { width: 100%; height: 200px; object-fit: cover; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🔍 手动搜索 - 项链相似款式</h1>
        <p>基于Yandex反向图片搜索的相似款式收集</p>
        <p><strong>方法</strong>: 手动上传 + 手动保存</p>
        <p><strong>优势</strong>: 100%可靠，绕过所有自动化限制</p>
    </div>
    
    <div class="image-grid">
EOF

# 添加图片到HTML
counter=1
for img in "$RESULT_DIR/"*.jpg "$RESULT_DIR/"*.jpeg "$RESULT_DIR/"*.png 2>/dev/null; do
    if [ -f "$img" ]; then
        filename=$(basename "$img")
        size=$(stat -c%s "$img")
        
        cat >> "$RESULT_DIR/查看结果.html" << EOF
        <div class="image-card">
            <img src="$filename" alt="项链相似款 $counter">
            <div style="text-align:center;margin-top:10px;">
                项链相似款 $counter<br>
                $filename<br>
                $size 字节
            </div>
        </div>
EOF
        counter=$((counter + 1))
    fi
done

cat >> "$RESULT_DIR/查看结果.html" << 'EOF'
    </div>
    
    <div style="margin-top: 40px; padding: 20px; background: #f5f5f5; border-radius: 5px;">
        <h3>📋 搜索信息</h3>
        <p><strong>源图片</strong>: 源图_项链.png</p>
        <p><strong>搜索方法</strong>: Yandex图片搜索 (手动)</p>
        <p><strong>找到图片</strong>: <span id="imageCount">0</span>张</p>
        <p><strong>操作时间</strong>: 2026-04-05</p>
        <p><strong>技术方案</strong>: 绕过自动化限制，采用100%可靠的手动方案</p>
        
        <h4>🎯 选择标准</h4>
        <ul>
            <li>✅ 材质匹配: 白金/银色系优先</li>
            <li>✅ 款式匹配: 设计复杂度相似</li>
            <li>✅ 亮度匹配: 高亮度表面优先</li>
            <li>✅ 质量要求: 清晰、无水印、分辨率高</li>
        </ul>
        
        <h4>🚀 下一步计划</h4>
        <ol>
            <li>验证图片相似度质量</li>
            <li>优化手动操作流程</li>
            <li>开发半自动化辅助工具</li>
            <li>开始商业化部署</li>
        </ol>
        
        <div style="text-align: center; margin-top: 20px; padding: 15px; background: #e8f5e8; border-radius: 5px;">
            <p><strong>💡 核心优势</strong>: 没支付能力 ≠ 做不了项目，只是要选对路径！</p>
            <p>手动方案虽然效率低，但100%可靠，能立即交付结果！</p>
        </div>
    </div>
    
    <script>
        // 更新图片数量
        document.getElementById('imageCount').textContent = document.querySelectorAll('.image-card').length;
    </script>
</body>
</html>
EOF

echo "✅ HTML查看器已创建: $RESULT_DIR/查看结果.html"

# 总结
echo ""
echo "="*60
echo "📊 验证结果总结"
echo "="*60
echo "图片总数: $IMAGE_COUNT 张"
echo "规范命名: $CORRECT_NAMES/8 张"
echo "输出目录: $RESULT_DIR/"
echo "HTML查看器: $RESULT_DIR/查看结果.html"
echo ""
echo "🎯 质量评估:"
if [ "$IMAGE_COUNT" -ge 8 ]; then
    echo "✅ 优秀: 找到8张以上图片"
elif [ "$IMAGE_COUNT" -ge 5 ]; then
    echo "⚠️ 良好: 找到5-7张图片"
else
    echo "❌ 不足: 少于5张图片"
fi

if [ "$CORRECT_NAMES" -eq 8 ]; then
    echo "✅ 优秀: 所有图片命名规范"
elif [ "$CORRECT_NAMES" -ge 5 ]; then
    echo "⚠️ 良好: 大部分图片命名规范"
else
    echo "❌ 不足: 命名不规范"
fi

echo ""
echo "🚀 下一步:"
echo "1. 查看结果: xdg-open '$RESULT_DIR/查看结果.html'"
echo "2. 评估相似度质量"
echo "3. 开始后续开发"
echo "="*60