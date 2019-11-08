
0、开两个终端，一个查看Kconfig，一个在menuconfig上搜索（所有的Kconfig子块可以搜索到），可以很快确定目前的模块驱动
```
确认mac clk tx clk rx clk mdc clk，再确认复用，gmac奇怪问题比较多是电源的问题，特别是CPU LOGIC电压的问题或者IO驱动强度，配了CRU clk却拿不到，
查看clk_summary没有一个是使能的
PHY的问题主要就是25M晶振，没有贴没有clk给出，txclk是由phy clk给gmac，然后gmac再给出去tx clk，有管脚复用设置phy的时候可能RX clk也不对

总之是gmac操作phy的寄存器，一种是我操作ok了你硬件不行产生偏差，一种是我操作ok你没反应就像石头一样没有启动，一种是我操作有问题比如复用，
一种是我操作ok你也ok但是有干扰（delay或者电压比如概率性获取不到ip或者丢包或者断线）
```

1、对于有些差的网络，尤其公司网络，同一个DHCP服务器下面主机过多，有时候会出现，DHCP获取不到IP地址的现象。

```
对于这种问题，处理办法是，把DHCP的超时时间增大。目前的dhcp超时时间是30s，补丁把超时时间增大到90s。 插拔网卡出现概率性性获取不了ip
89785  参考 把超时时间增大到90s.patch
```
2、也测量一下cpu logci 电压 看一下dts上面的PMU的配置 正常是1.05v左右
```
regulators {
compatible = "simple-bus";
#address-cells = <1>;
#size-cells = <0>;
vdd_logic: regulator@0 {
compatible = "regulator-fixed";
regulator-name = "vdd_logic";
regulator-min-microvolt = <1050000>;
regulator-max-microvolt = <1050000>;
regulator-always-on;
};
};

cat /sys/kernel/debug/regulator/vdd_logic/vdd_logic/*

echo 1050000 > /sys/kernel/debug/regulator/vdd_log/voltage
```

3、上行或者下行带宽比较低，和CPU和ddr关系比较大，可以调整一下参数和测试看看，最好是将上行带宽高的dts配置和以太网驱动移植过去
```
RX能到900,TX不行，比较怀疑是TX_CLK占空比不对，所以我们检查以太网以clk为主，mac clk(可以断掉33欧姆电阻)  tx clk rx clk
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
```
4、设置静态
```
ifconfig eth0 up
ifconfig eth0 192.168.1.100 broadcast 192.168.1.255 netmask 255.255.255.0 up
单网卡添加多个IP地址
ifconfig eth0:0 192.168.1.100 netmask 255.255.255.0 up
ifconfig eth0:1 192.168.2.100 netmask 255.255.255.0 up
```
5、cat /sys/devices/platform/fe300000.ethernet/net/eth0/carrier
```
拔插网线的前后输入这个命令，看下底层状态是否正确；
平台不同节点路径可能不一样，在sys下面输入find -name "carrier" 没插网线的时候是0 ，插网线的时候是1
```
6、rtl8152有自带驱动的kernel/drivers/net/usb，无法拿到IP 地址，可能是没有MAC 地址的问题，
```
可使用ftp 上的补丁《rtl8152解决MAC 地址为空补丁》
```
7、以太网抓包
```
tcpdump -i eth0 -s 0 -w /data/snf.pcap
```
8、
```
EthernetNetworkFactory  /frameworks/opt/net/ethernet/java/com/android/server/ethernet/
ConnectivityService

https://blog.csdn.net/u013686019/article/details/51447129
或者网络优先级更改
```

9、PHY ID 00000000 就要确认一下mdc clk的2.5M以下（可以打上mdc2.5M patch）
```
对照原理图，先确定IOMUX关系是否正确
busybox find /d/pinctrl -name pinmux-pins
cat ./sys/kernel/debug/pinctrl/pinctrl/pinmux-pins

[ 0.668216] eth%d: PHY ID 00000000 at 1 IRQ POLL (stmmac-0:01)

PHY ID不正确，示波器量测MDC是2.5M 及2.5M以下,使用patch使MDC clk降低
```
10、某些交换机上面之后出现不能正常获取到IP地址
```
目前出现一些板卡，接在某些交换机上面之后出现不能正常获取到IP地址，频繁重复获取，有些交换机或者是路由器又是正常，可能跟EEEE功能有关，
打上关闭EEE功能的patch
```

11、cat /d/clk/clk_summary
```
对照原理图，先确定IOMUX关系是否正确，
busybox find /d/pinctrl -name pinmux-pins
cat xxx/xxx/pinmux-pins
```

12、RMII_CLK_CTL配置是低，PHY就会有50M输出，如果是拉高就是我们给PHY时钟

13、3399经常MAC MDC引脚会被复用，测的频率还是TX CLK 125M， RX CLK 25M(异常，导致phy设置异常)，MAC CLK 125M
```
GPIO3B[0]
gslx680: gslx680@40 {
touch-gpio = <&gpio3 RK_PB0 IRQ_TYPE_EDGE_RISING>; 
```

----------------------------------------------------------------



```
ethtool -s eth0 speed 100 duplex full autoneg off

--------------rtl8211------------------

phy   mac xtal1  mac_clk&clkout（一起连，外部不接自激电路就直接mac_clk给，dts上设置output直接给xtal1，百兆网是25M，千兆网是125M）
tx0 - tx0   tx1 - tx1  tx2 - tx2 tx3 - tx3 txen- txen txclk-txclk rx0 - rx0 rx1 - rx1 rx2 - rx2 rx3 - rx3 rxen-rxen rxclk-rxclk rxdv-rxdv mdio-mdio mdc-mdc GPIO - phy rst
 
 注意每根线都得连上，少连一根都会找不到phy设备，还有rst也要看看有没有使能，如果吞吐有问题再调tx rx delay
 
 ---------------lan8720A---------------------
 
 LED1_AD1 接下拉的时候 INTB才会输出CLK(接25M晶振，内部倍频 INTB输出50M) 

DNP（do not populate）不焊接的意思，LED0_AD0接下拉是设置芯片地址为0

phy   mac xtal1  mac_clk tx0 - tx0  tx1 - tx1 //tx2 - tx2 //tx3 - tx3 txen- txen //txclk-txclk rx0 - rx0 rx1 - rx1 //rx2 - rx2 //rx3 - rx3 //rxen-rxen //rxclk-rxclk rxdv-rxdv rxer-rxer mdio-mdio mdc-mdc gpio - phy rst

```
 
 
 
 
 
