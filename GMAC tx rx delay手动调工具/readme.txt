一般以下情况可能需要调整tx rx delay:
一是：1000M无法连接上（无法获取到IP地址）
二是: 1000M情况下吞吐率低，或ping存在丢包

gmac_tx_rx_delay_adj.sh脚本可用于调整gmac tx, rx delay，具体使用方法如下：

以rk3399为例，dts中定义的默认tx, rx delay如下
        tx_delay = <0x28>;
        rx_delay = <0x11>;

例如要调整tx delay为0x33, rx delay为0x15
gmac_tx_rx_delay_adj.sh rk3399 tx 0x33
gmac_tx_rx_delay_adj.sh rk3399 rx 0x15

注意：调整后实时生效，不需要重启机器

tx, rx delay调试方法如下：

1. 先确认插入网线时能否识别到Link up
以kernel 3.10为例，插入网线并正常识别到时，kmsg会打印：
libphy: stmmac-1:01 - Link is Up - 100/Full　　　// Link is Up表示检查到网线插入，100/Full表示连接上的速率是100M
如果插入网线时没有类似Link up打印，可以通过调整上面的tx rx delay，然后再尝试

2. 确认ping是否存在丢包
将待测机器（这里假设是盒子）与电脑直连（注意要关掉电脑的防火墙，不然可能会ping不通）（盒子与电脑都设置静态IP）
ping命令使用：（在盒子中）
ping -c 100 -i 0.01 192.168.1.100 (192.168.1.100为电脑的IP地址）
查看ping结果是否存在丢包，如果存在丢包，则可以通过调整上面的tx rx delay，然后再尝试ping测试丢包

3. 调试方法：
tx rx delay的取值范围是[0x00, 0x7f], 可在dts定义的默认值的基础上增加或减少，每次步长可选择2，每调整一次，测试下效果。
当有多个值符合要求时，取平均值使用。
找到合理的tx rx delay后，替换掉dts中的值

