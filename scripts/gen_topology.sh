#!/bin/bash
# ============================================================
# 拓扑图自动生成脚本 — 根据 nmap 扫描结果生成 Mermaid 拓扑图
# 用法: bash gen_topology.sh <扫描结果目录>
# 输出: <扫描结果目录>/topology.md + topology.png(需mmdc)
# ============================================================

SCANDIR="${1:-.}"
OUTFILE="$SCANDIR/topology.md"

echo "正在生成拓扑图..."

cat > "$OUTFILE" << 'HEADER'
# 网络拓扑图

## 物理拓扑

```mermaid
graph TD
HEADER

# 解析 nmap 结果
declare -A SUBNETS
declare -A HOSTS
declare -A SERVICES

# 从 nmap 存活扫描提取主机
for f in "$SCANDIR"/03_nmap_alive_*.txt; do
    [ -f "$f" ] || continue
    CURRENT_NET=""
    while IFS= read -r line; do
        if [[ "$line" =~ ^Nmap\ scan\ report\ for\ ([0-9.]+) ]]; then
            IP="${BASH_REMATCH[1]}"
            NET=$(echo "$IP" | cut -d. -f1-3).0/24
            SUBNETS["$NET"]=1
            if [ -z "${HOSTS[$NET]}" ]; then
                HOSTS["$NET"]="$IP"
            else
                HOSTS["$NET"]="${HOSTS[$NET]} $IP"
            fi
        fi
    done < "$f"
done

# 生成 Mermaid 图
{
    echo "graph TD"
    
    # 互联网
    echo "    INTERNET((☁️ Internet))"
    
    # 网关（通常是 .1）
    for NET in "${!SUBNETS[@]}"; do
        GW=$(echo "$NET" | sed 's/\.0\/24/.1/')
        echo "    GW${NET//./_}[\"🔀 网关 $GW\"]"
        echo "    INTERNET --> GW${NET//./_}"
    done
    
    # 子网和主机
    for NET in "${!HOSTS[@]}"; do
        echo "    subgraph \"$NET\""
        for IP in ${HOSTS[$NET]}; do
            NODE=$(echo "$IP" | tr '.' '_')
            # 判断设备类型
            if [[ "$IP" == *.1 ]]; then
                echo "        $NODE[\"🔀 路由器 $IP\"]"
            elif [[ "$IP" == *.2 || "$IP" == *.254 ]]; then
                echo "        $NODE[\"📡 交换机/AP $IP\"]"
            else
                echo "        $NODE[\"💻 $IP\"]"
            fi
            # 连接到网关
            GW=$(echo "$NET" | sed 's/\.0\/24/.1/')
            GWNODE=$(echo "$GW" | tr '.' '_')
            echo "        GW${GWNODE} --> $NODE"
        done
        echo "    end"
    done
    
    echo ""
    echo "    classDef router fill:#ff9,stroke:#333,stroke-width:2px"
    echo "    classDef switch fill:#9cf,stroke:#333"
    echo "    classDef host fill:#fff,stroke:#333"
} > "$OUTFILE"

# 追加主机列表
{
    echo ""
    echo '```'
    echo ""
    echo "## 设备清单"
    echo "| IP地址 | 设备类型 | 子网 |"
    echo "|--------|---------|------|"
    for NET in "${!HOSTS[@]}"; do
        for IP in ${HOSTS[$NET]}; do
            TYPE="未知"
            if [[ "$IP" == *.1 ]]; then TYPE="路由器/网关"; 
            elif [[ "$IP" == *.2 || "$IP" == *.254 ]]; then TYPE="交换机"; 
            fi
            echo "| $IP | $TYPE | $NET |"
        done
    done
    echo ""
    echo "---"
    echo "生成时间: $(date)"
    echo "扫描目录: $SCANDIR"
} >> "$OUTFILE"

echo "✓ 拓扑图已生成: $OUTFILE"
echo "  用浏览器打开或 mermaid-cli 渲染为 PNG:"
echo "  mmdc -i $OUTFILE -o topology.png"
