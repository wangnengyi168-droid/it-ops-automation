# IT Ops Automation

老王的 IT 运维自动化工具集。

## 目录结构

```
├── scripts/              # 运维脚本
│   ├── backup_nas.sh     # NAS 备份脚本
│   ├── *.sh              # 网络扫描脚本
│   └── *.py              # Python 工具
├── yandex-image-search/  # Yandex 图片搜索工具
└── docs/                 # 文档
```

## 工具列表

| 工具 | 用途 |
|------|------|
| `backup_nas.sh` | NAS 自动备份 |
| 网络扫描脚本 | 内网设备发现、端口扫描 |
| Yandex 图片搜索 | 无需 API 的图片搜索方案 |

## 使用方法

```bash
# NAS 备份
./scripts/backup_nas.sh /path/to/source wang2025.lan

# 网络扫描
./scripts/scan_network.sh 192.168.101.0/24
```

## 适用场景

- IT 运维自动化
- 网络设备管理
- 数据备份与恢复
- 远程桌面管理

---
*Last updated: 2026-06-13*
