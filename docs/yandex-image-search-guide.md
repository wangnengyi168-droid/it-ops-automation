# Yandex图片搜索自动化工具使用指南

## 🎯 工具概述

Yandex图片搜索自动化工具是一个无需API、无需国外支付的图片相似度搜索解决方案。通过服务器图床 + Yandex搜索 + 智能解析，实现高效的图片搜索功能。

## ✨ 核心功能

1. **无需API**: 完全免费，无需申请API密钥
2. **无需支付**: 不需要国外支付通道
3. **高相似度**: 相似度可达85%+
4. **自动化**: 支持自动化搜索和结果解析
5. **可扩展**: 模块化设计，易于扩展功能

## 🚀 快速开始

### 环境要求
```bash
# 安装Python依赖
pip install fastapi uvicorn playwright requests beautifulsoup4

# 安装Playwright浏览器
playwright install chromium
```

### 一键运行
```bash
cd yandex-image-search
./一键运行.sh
```

### 分步运行
```bash
# 1. 启动图床服务器
python3 图床服务器.py

# 2. 执行搜索
python3 yandex_search.py --image 源图.png --output 结果/

# 3. 查看结果
ls -la 结果/
```

## 📁 文件说明

### 核心文件
- `完整解决方案.py` - 完整的集成解决方案
- `yandex_search.py` - Yandex搜索爬虫
- `图床服务器.py` - FastAPI图床服务器
- `直接搜索.py` - 简化版搜索脚本

### 工具脚本
- `一键运行.sh` - 一键启动所有服务
- `手动操作工具.sh` - 手动操作辅助工具
- `验证手动结果.sh` - 结果验证脚本

### 文档文件
- `项目总结.md` - 项目总结和商业模式
- `立即找到8张图片.md` - 快速操作指南

## 🛠️ 详细使用

### 1. 基本搜索
```python
from yandex_search import YandexImageSearcher

searcher = YandexImageSearcher()
results = searcher.search_by_image("source_image.jpg", max_results=8)

for result in results:
    print(f"图片: {result['url']}")
    print(f"相似度: {result['similarity']}%")
    print(f"尺寸: {result['dimensions']}")
```

### 2. 批量搜索
```bash
# 批量搜索多个图片
python3 yandex_search.py --batch images.txt --output batch_results/

# images.txt 格式
image1.jpg
image2.png
image3.jpeg
```

### 3. 高级配置
```python
# 自定义配置
config = {
    "timeout": 30,           # 超时时间(秒)
    "max_results": 10,       # 最大结果数
    "min_similarity": 70,    # 最小相似度(%)
    "proxy": None,           # 代理设置
    "headless": True,        # 无头模式
}

searcher = YandexImageSearcher(config=config)
```

## 🔧 故障排除

### 常见问题

#### 1. 浏览器启动失败
```bash
# 重新安装Playwright
playwright install --force chromium

# 检查浏览器路径
which chromium
```

#### 2. 网络连接问题
```bash
# 测试Yandex可访问性
curl -I https://yandex.com/images/

# 使用代理
export HTTP_PROXY=http://your-proxy:port
export HTTPS_PROXY=http://your-proxy:port
```

#### 3. 图片上传失败
```bash
# 检查图片格式
file source_image.jpg

# 转换图片格式
convert source_image.jpg source_image.png
```

#### 4. 结果解析失败
```bash
# 启用调试模式
python3 yandex_search.py --debug --image source.jpg

# 查看HTML源码
python3 yandex_search.py --dump-html --image source.jpg
```

## 📊 性能优化

### 1. 缓存优化
```python
# 启用结果缓存
searcher = YandexImageSearcher(enable_cache=True, cache_ttl=3600)
```

### 2. 并发搜索
```python
# 并发搜索多个图片
from concurrent.futures import ThreadPoolExecutor

with ThreadPoolExecutor(max_workers=3) as executor:
    futures = []
    for image in image_list:
        future = executor.submit(searcher.search_by_image, image)
        futures.append(future)
    
    results = [f.result() for f in futures]
```

### 3. 资源管理
```bash
# 限制内存使用
ulimit -v 1048576  # 限制1GB内存

# 限制CPU使用
cpulimit -l 50 -p $(pgrep python)  # 限制50% CPU
```

## 🎯 最佳实践

### 1. 图片预处理
```python
# 优化图片质量
from PIL import Image

def optimize_image(image_path, max_size=(800, 800), quality=85):
    img = Image.open(image_path)
    img.thumbnail(max_size, Image.Resampling.LANCZOS)
    img.save(image_path, optimize=True, quality=quality)
```

### 2. 结果验证
```python
# 验证搜索结果
def validate_results(results, min_similarity=70, min_size=(200, 200)):
    valid_results = []
    for result in results:
        if (result['similarity'] >= min_similarity and 
            result['width'] >= min_size[0] and 
            result['height'] >= min_size[1]):
            valid_results.append(result)
    return valid_results
```

### 3. 错误处理
```python
import logging
from tenacity import retry, stop_after_attempt, wait_exponential

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=4, max=10))
def search_with_retry(searcher, image_path):
    try:
        return searcher.search_by_image(image_path)
    except Exception as e:
        logger.error(f"搜索失败: {e}")
        raise
```

## 📈 商业应用

### 1. 电商应用
- **商品去重**: 识别重复商品图片
- **竞品分析**: 查找相似竞品
- **价格监控**: 监控竞品价格变化

### 2. 珠宝行业
- **款式搜索**: 查找相似珠宝款式
- **设计参考**: 获取设计灵感
- **市场调研**: 分析市场流行趋势

### 3. 个人用途
- **找同款**: 找到心仪商品的同款
- **比价**: 比较不同平台价格
- **购物决策**: 辅助购物决策

### 4. 收费模式
| 版本 | 价格 | 功能 | 目标客户 |
|------|------|------|----------|
| 免费版 | 0元 | 每天5次搜索 | 个人用户 |
| 基础版 | ¥99/月 | 100次搜索 | 小电商 |
| 专业版 | ¥299/月 | 无限搜索 | 中型企业 |
| 企业版 | ¥999/月 | 定制功能 | 大型企业 |

## 🔒 安全注意事项

### 1. 数据安全
- 不存储用户原始图片
- 搜索结果临时存储，定期清理
- 不收集用户个人信息

### 2. 合规使用
- 遵守Yandex服务条款
- 合理控制请求频率
- 不用于非法用途

### 3. 资源限制
- 设置合理的请求间隔
- 监控资源使用情况
- 避免对目标网站造成压力

## 🚀 未来发展

### 短期计划 (1个月)
- [ ] 增加更多搜索引擎支持
- [ ] 优化搜索算法
- [ ] 添加批量处理功能
- [ ] 完善文档和示例

### 中期计划 (3个月)
- [ ] 开发Web界面
- [ ] 添加API接口
- [ ] 支持更多图片格式
- [ ] 集成到其他系统

### 长期计划 (6个月)
- [ ] 机器学习增强
- [ ] 实时搜索功能
- [ ] 移动端应用
- [ ] 商业化部署

## 📞 支持与反馈

### 问题报告
1. 查看 [故障排除](#故障排除) 部分
2. 检查 [GitHub Issues](https://github.com/wangnengyi168-droid/it-ops-automation/issues)
3. 提交新的Issue

### 功能请求
1. 描述需求场景
2. 说明预期效果
3. 提供相关示例

### 贡献代码
1. Fork仓库
2. 创建功能分支
3. 提交Pull Request

## 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](../LICENSE) 文件。

## 🙏 致谢

感谢以下开源项目：
- Playwright - 浏览器自动化
- FastAPI - Web框架
- BeautifulSoup4 - HTML解析
- 所有贡献者和用户

---

**文档版本**: v1.0.0  
**最后更新**: 2026-04-05  
**维护者**: 王总管 🐾  
**状态**: ✅ 生产就绪
