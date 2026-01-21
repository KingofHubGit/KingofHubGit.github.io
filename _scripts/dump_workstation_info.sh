#!/bin/bash

# 确保以 root 或 sudo 权限运行以获取完整的硬件 SN
if [ "$EUID" -ne 0 ]; then
  echo "请使用 sudo 运行此脚本以获取完整序列号信息。"
  exit 1
fi

case $1 in
  "cpu_bench")
    echo "Running CPU benchmark..."
    CPU_BENCH=true
    DISK_BENCH=false
    ;;
  "disk_bench")
    echo "Running disk benchmark..."
    DISK_BENCH=true
    CPU_BENCH=false
    ;;
  "dump_only")
    echo "Dumping hardware information..."
    DUMP_ONLY=true
    ;;
  *)
    CPU_BENCH=true
    DISK_BENCH=true
    DUMP_ONLY=true
    ;;
esac

if [ "$CPU_BENCH" == true ]; then
    echo "=========================================================="
    echo "                第一步：主机及 CPU 核心信息"
    echo "=========================================================="

    # 获取主机信息
    HOST_MODEL=$(cat /sys/class/dmi/id/product_name 2>/dev/null || echo "未知")
    HOST_SN=$(cat /sys/class/dmi/id/product_serial 2>/dev/null || echo "未知")

    # 获取 CPU 信息
    CPU_MODEL=$(grep -m 1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)
    CPU_CORES=$(nproc)
    CPU_ARCH=$(uname -m)
    IP=$(hostname -I | awk '{print $1}')
    MEMORY_SIZE=$(free -h | grep Mem | awk '{print $2}')

    echo "主机型号: $HOST_MODEL"
    echo "主机 SN:   $HOST_SN"
    echo "CPU 型号:  $CPU_MODEL"
    echo "核心总数:  $CPU_CORES Threads ($CPU_ARCH)"
    echo "IP:       $IP"
    echo "内存大小:  $MEMORY_SIZE MB"

    if [ "$DUMP_ONLY" != true ]; then
          echo "=========================================================="
          echo "                CPU性能测试"
          echo "=========================================================="

          sudo apt install sysbench

          # --threads 指定线程数（建议设置为 CPU 总核心数）
          # --cpu-max-prime 计算素数上限，越大压力越大
          # 关注指标：events per second (每秒完成的任务数，越高越好)
          sysbench cpu --threads=$(nproc) --cpu-max-prime=20000 run

          echo "=========================================================="
          echo "                Memory性能测试"
          echo "=========================================================="

          # --memory-oper 指定 read(读) 或 write(写)
          # --memory-block-size 块大小
          # 关注指标：MiB/sec (吞吐量，数值越高内存带宽越强)。
          sysbench memory --threads=$(nproc) --memory-block-size=1M --memory-total-size=100G run
    fi
fi

if [ "$DISK_BENCH" == true ]; then
    echo -e "\n=========================================================="
    echo "                第二步：SSD 磁盘详细信息"
    echo "=========================================================="

    # 1. 查找所有的物理磁盘 (TYPE=disk)
    # 2. 过滤常见的 SSD/NVMe 关键词 (或者通过 TRAN 传输协议判断)
    # 3. 使用 lsblk 轮询打印

    # 获取所有物理盘名称 (例如 sda, nvme0n1)
    disks=$(lsblk -d -n -o NAME)

    for disk in $disks; do
        # 检查是否为物理盘或固态存储 (排除回环设备 loop)
        if [[ $disk == loop* ]]; then continue; fi

        # 获取该盘的传输协议 (nvme, sata, sas)
        tran=$(lsblk -dn -o TRAN "/dev/$disk" | xargs)
        
        echo ">>> 物理盘设备: /dev/$disk [协议: ${tran:-未知}]"
        
        # 打印该物理盘及其分区的详细信息
        # NAME: 名称, SIZE: 大小, SERIAL: 物理序列号, UUID: 文件系统标识, MOUNTPOINT: 挂载点, MODEL: 型号
        lsblk -o NAME,SIZE,SERIAL,UUID,MOUNTPOINT,MODEL "/dev/$disk"

        if [ "$DUMP_ONLY" != true ]; then
          sudo hdparm -Tt "/dev/$disk"
        fi
        
        echo "----------------------------------------------------------"
    done
fi
