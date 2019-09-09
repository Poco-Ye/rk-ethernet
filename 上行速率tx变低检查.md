和CPU和ddr关系比较大，可以调整一下参数和测试看看，最好是将上行带宽高的dts配置和以太网驱动移植过去

echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor

调整cpu 相关参数

echo 1048576 > /proc/sys/net/core/wmem_max

echo 1048576 > /proc/sys/net/core/rmem_max

echo "4096 1048576 1048576" > /proc/sys/net/ipv4/tcp_rmem

echo "4096 1048576 1048576" > /proc/sys/net/ipv4/tcp_wmem

echo 4193104 > /proc/sys/net/ipv4/tcp_limit_output_bytes

echo 1048576 > /proc/sys/net/ipv4/udp_rmem_min

echo 1048576 > /proc/sys/net/ipv4/udp_wmem_min


DDR测试

cat /sys/devices/platform/dmc/devfreq/dmc/available_frequencies

echo userspace > /sys/devices/platform/dmc/devfreq/dmc/governor

echo 800000000 > /sys/devices/platform/dmc/devfreq/dmc/min_freq

cat /sys/devices/platform/dmc/devfreq/dmc/cur_freq
