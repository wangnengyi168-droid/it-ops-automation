#!/bin/bash
# ============================================================
# 网络一键扫描脚本 — 现场运维工具
# 用法: sudo bash net_scan.sh [目标网段，如 192.168.1.0/24]
# 依赖: nmap, arp-scan, iproute2 (apt install nmap arp-scan)
# ============================================================

set -e
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTDIR="/home/wang/网络扫描/scan_${TIMESTAMP}"
mkdir -p "$OUTDIR"

echo "=========================================="
echo " 网络一键扫描工具 v1.0"
echo " 输出目录: $OUTDIR"
echo "=========================================="

# --- 1. 基础网络信息 ---
echo "[1/7] 收集基础网络信息..."
{
    echo "=== 主机名 ==="
    hostname
    echo ""
    echo "=== 本机IP ==="
    ip -4 addr show | grep -v 127.0.0.1
    echo ""
    echo "=== 默认路由 ==="
    ip route show default
    echo ""
    echo "=== 完整路由表 ==="
    ip route show
    echo ""
    echo "=== ARP表 ==="
    ip neigh show
    echo ""
    echo "=== DNS ==="
    cat /etc/resolv.conf 2>/dev/null || echo "N/A"
    echo ""
    echo "=== 系统信息 ==="
    uname -a
} > "$OUTDIR/01_basic_info.txt"

# --- 2. ARP 扫描（局域网存活主机） ---
echo "[2/7] ARP 扫描..."
if command -v arp-scan &>/dev/null; then
    # 自动检测本地网段
    for IFACE in $(ip -4 addr show | grep -oP 'inet \K[\d./]+'); do
        NET=$(echo "$IFACE" | cut -d/ -f1 | cut -d. -f1-3)
        arp-scan --interface=$(ip route | grep "$NET" | grep -oP 'dev \K\S+') --localnet 2>/dev/null > "$OUTDIR/02_arpscan.txt" || true
    done
    echo "  ✓ arp-scan 完成"
else
    echo "  ⚠ arp-scan 未安装，使用 ping 扫描替代"
    # 备用：快速 ping 扫描
    for IFACE in $(ip -4 addr show | grep -v 127 | grep -oP 'inet \K[\d./]+'); do
        NET=$(echo "$IFACE" | cut -d/ -f1 | cut -d. -f1-3).0/24
        echo "--- $NET ---" >> "$OUTDIR/02_arpscan.txt"
        fping -a -g "$NET" -c 1 2>/dev/null >> "$OUTDIR/02_arpscan.txt" || \
        for i in $(seq 1 254); do ping -c 1 -W 1 "$NET" | head -1 >> "$OUTDIR/02_arpscan.txt" & done
        wait
    done
fi

# --- 3. nmap 存活扫描 ---
echo "[3/7] nmap 存活主机扫描..."
if command -v nmap &>/dev/null; then
    TARGET="${1:-192.168.1.0/24}"
    # 如果有多个网段参数，依次扫描
    for NET in "$@"; do
        SAFE=$(echo "$NET" | tr '/' '_')
        nmap -sn -T4 "$NET" -oN "$OUTDIR/03_nmap_alive_${SAFE}.txt" 2>/dev/null || true
    done
    echo "  ✓ nmap 存活扫描完成: $*"
else
    echo "  ⚠ nmap 未安装，跳过端口扫描"
fi

# --- 4. nmap 服务识别（针对存活主机） ---
echo "[4/7] nmap 服务识别（Top 100 端口）..."
if command -v nmap &>/dev/null; then
    for NET in "$@"; do
        SAFE=$(echo "$NET" | tr '/' '_')
        nmap -sV --top-ports 100 -T4 --open "$NET" -oN "$OUTDIR/04_nmap_services_${SAFE}.txt" 2>/dev/null || true
    done
    echo "  ✓ 服务识别完成"
fi

# --- 5. DHCP 探测 ---
echo "[5/7] DHCP 信息..."
{
    echo "=== DHCP 租约 ==="
    cat /var/lib/dhcp/dhclient.leases 2>/dev/null || echo "N/A"
    echo ""
    echo "=== 网络管理器 DHCP ==="
    cat /var/lib/NetworkManager/*.lease 2>/dev/null || echo "N/A"
    echo ""
    echo "=== 爱快网关常见端口检测 ==="
    for IP in $(ip route | grep -oP 'default via \K\S+'); do
        echo "网关 $IP:"
        nc -z -w 2 "$IP" 80 && echo "  80 HTTP: open" || echo "  80 HTTP: closed"
        nc -z -w 2 "$IP" 443 && echo "  443 HTTPS: open" || echo "  443 HTTPS: closed"
        nc -z -w 2 "$IP" 22 && echo "  22 SSH: open" || echo "  22 SSH: closed"
        nc -z -w 2 "$IP" 1044 && echo "  1044 爱快云: open" || echo "  1044 爱快云: closed"
    done
} > "$OUTDIR/05_dhcp_gateway.txt"

# --- 6. 常见服务端口快速探测 ---
echo "[6/7] 常见服务端口探测..."
{
    for PORT in 22 80 443 3306 5432 8080 8443 1044 2049 445 139 3389 5900 8000 9090; do
        echo "--- Port $PORT ---"
        if command -v nmap &>/dev/null; then
            nmap -p "$PORT" --open -T4 "$@" 2>/dev/null | grep -E "open|Host" || true
        fi
    done
} > "$OUTDIR/06_common_ports.txt"

# --- 7. 生成摘要 ---
echo "[7/7] 生成扫描摘要..."
{
    echo "========================================"
    echo " 网络扫描摘要报告"
    echo " 时间: $(date)"
    echo "========================================"
    echo ""
    echo "=== 存活主机汇总 ==="
    if command -v nmap &>/dev/null; then
        grep -h "Nmap scan report" "$OUTDIR"/03_nmap_alive_*.txt 2>/dev/null | sort -V || echo "N/A"
    else
        cat "$OUTDIR"/02_arpscan.txt 2>/dev/null || echo "N/A"
    fi
    echo ""
    echo "=== 发现的开放服务 ==="
    if [ -f "$OUTDIR/04_nmap_services_0_24.txt" ]; then
        grep -E "open|filtered" "$OUTDIR"/04_nmap_services_*.txt 2>/dev/null | head -100
    fi
    echo ""
    echo "=== 网关信息 ==="
    cat "$OUTDIR/05_dhcp_gateway.txt"
    echo ""
    echo "=== 文件清单 ==="
    ls -la "$OUTDIR"/
} > "$OUTDIR/SUMMARY.txt"

echo ""
echo "=========================================="
echo " 扫描完成！结果保存在: $OUTDIR"
echo " 文件列表:"
ls -la "$OUTDIR"/
echo "=========================================="
