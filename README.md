# IT 运维自动化工具集

![GitHub last commit](https://img.shields.io/github/last-commit/wangnengyi168-droid/it-ops-automation)
![GitHub repo size](https://img.shields.io/github/repo-size/wangnengyi168-droid/it-ops-automation)
![GitHub](https://img.shields.io/github/license/wangnengyi168-droid/it-ops-automation)

专业的IT运维自动化工具集合，包含脚本、监控、部署等实用工具。

## 📦 项目结构

```
it-ops-automation/
├── yandex-image-search/     # Yandex图片搜索自动化工具
├── scripts/                 # 通用运维脚本
├── docs/                    # 文档和指南
├── examples/                # 使用示例
└── README.md               # 本文件
```

## 🚀 快速开始

### Yandex图片搜索工具
```bash
cd yandex-image-search
./一键运行.sh
```

## 📚 工具列表

### 1. Yandex图片搜索自动化
- **功能**: 无需API的图片相似度搜索
- **技术**: Python + FastAPI + Playwright
- **特点**: 免费、无需国外支付、100%可靠
- **文件**: `yandex-image-search/完整解决方案.py`

### 2. 远程桌面连接工具 (即将添加)
- **功能**: 一键远程桌面连接
- **技术**: Bash脚本 + RDP配置
- **特点**: 自动化配置、多平台支持

### 3. 系统监控脚本 (即将添加)
- **功能**: 系统健康监控和告警
- **技术**: Bash + Python
- **特点**: 实时监控、自动告警

## 🛠️ 安装要求

### 基础要求
- Python 3.8+
- Bash shell
- Git

### Python依赖
```bash
pip install fastapi uvicorn playwright requests
playwright install
```

## 📖 使用指南

### Yandex图片搜索
1. 准备源图片
2. 运行搜索脚本
3. 获取相似图片结果
4. 分析相似度报告

### 详细文档
- [Yandex图片搜索使用指南](docs/yandex-image-search-guide.md)
- [故障排除](docs/troubleshooting.md)
- [API文档](docs/api.md)

## 🤝 贡献指南

欢迎贡献代码和想法！

1. Fork本仓库
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🙏 致谢

感谢所有贡献者和使用者！

## 📞 联系

- GitHub: [@wangnengyi168-droid](https://github.com/wangnengyi168-droid)
- 项目维护者: 王总管 🐾

---

**最后更新**: 2026-04-05  
**版本**: v1.0.0  
**状态**: 🚀 活跃开发中
