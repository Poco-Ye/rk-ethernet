
开两个终端，一个查看Kconfig，一个在menuconfig上搜索（所有的Kconfig子块可以搜索到），可以很快确定目前的模块驱动

```
一种是我操作ok了你硬件不行产生偏差（主要是25CLK频偏），一种是我操作ok你没反应就像石头一样没有启动（phy没有启动，rest引脚或者vcc或者有些线没有接），一种是我操作有问题比如我被复用，
一种是我操作ok你也ok但是有干扰（走线干扰，delay或者电压比如概率性获取不到ip或者丢包或者断线）


确认mac clk tx clk rx clk mdc clk，再确认复用，gmac奇怪问题比较多是电源的问题，特别是CPU LOGIC电压的问题或者IO驱动强度，配了CRU clk却拿不到，
查看clk_summary没有一个是使能的
PHY的问题主要就是25M晶振，没有贴没有clk给出，txclk是由phy clk给gmac，然后gmac再给出去tx clk，有管脚复用设置phy的时候可能RX clk也不对

总之是gmac操作phy的寄存器（rx clk是操作phy寄存器给出的，mdc clk是gmac给出的【源头CRU 内部clk cpu 25M晶振 或者phy 25M晶振】），

clk数量多了（速率快干扰错），包括sdio phy uart降频 ，减少clk数量，降低看是否排除干扰
```
0、确认一下phy上晶振25M晶振频偏，网线插路由能否获取到IP，如果不能检查一下硬件，如果能用iperf测一下吞吐

1、对于有些差的网络，尤其公司网络，同一个DHCP服务器下面主机过多，有时候会出现，DHCP获取不到IP地址的现象。

```
对于这种问题，处理办法是，把DHCP的超时时间增大。目前的dhcp超时时间是30s，补丁把超时时间增大到90s。 插拔网卡出现概率性性获取不了ip
89785  参考 把超时时间增大到90s.patch
```
2、也测量一下cpu logic 电压 看一下dts上面的PMU的配置 正常是1.05v左右
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

PMU的电压输出在sys/kernel/debug/regulator/
这里可以手动调试一下

cat /sys/kernel/debug/regulator/vdd_logic/*
cat /sys/kernel/debug/regulator/vdd_log/*

echo 1050000 > /sys/kernel/debug/regulator/vdd_log/voltage

logic电压是根据ddr的频率调整的，当前的ddr频率是多少？切换一下ddr频率看是否有变化

root@rk3399_stbvr:/sys/kernel/debug/clk # cat clk_summary |grep ddr
    clk_pvtm_ddr                          0            0    24000000          0 0  
          pclk_ddr                        1            1   200000000          0 0  
             pclk_ddr_sgrf                0            0   200000000          0 0  
             pclk_ddr_mon                 0            0   200000000          0 0  
          clk_ddrc_gpll_src               0            0   800000000          0 0  
          clk_ddrc_dpll_src               1            1   792000000          0 0  
             sclk_ddrc                    1            1   792000000          0 0  
          clk_ddrc_bpll_src               0            0   408000000          0 0  
          clk_ddrc_lpll_src               0            0   408000000          0 0 

ddr 800M,vdd_log为0.9V，arch/arm64/boot/dts/rockchip/rk3399-opp.dtsi里面dmc_opp_table，改800M对应的电压opp-microvolt
         opp-800000000 {
             opp-hz = /bits/ 64 <800000000>;
             opp-microvolt = <900000>;
     
TX上不去是DDR不够，定频到800M，TX就上去了
驱动强度的还是改一下
cat clk_summary |grep ddr
sclk_ddrc就是DDR的频率
cat /sys/kernel/debug/opp/opp_summary
cd /sys/class/devfreq/dmc/
echo userspace > governor
echo 800000000 > userspace/set_freq     


ddr频率对以太网有影响，考虑到休眠变频的影响或者本身上行低
&dmc {
        status = "okay";
        center-supply = <&vdd_center>;
        upthreshold = <40>;
        downdifferential = <20>;
        system-status-freq = <
                /*system status         freq(KHz)*/
                SYS_STATUS_NORMAL       800000
                SYS_STATUS_REBOOT       800000
                SYS_STATUS_SUSPEND      800000
                SYS_STATUS_VIDEO_1080P  800000
                SYS_STATUS_VIDEO_4K     800000
                SYS_STATUS_VIDEO_4K_10B 800000
                SYS_STATUS_PERFORMANCE  800000
                SYS_STATUS_BOOST        800000
                SYS_STATUS_DUALVIEW     800000
                SYS_STATUS_ISP          800000
        >;
```

3、上行或者下行带宽比较低，调试相关delay和硬件没有用，和TX RX CLK息息相关
```
这块板子走线有那么长tx_clk 13mA驱动强度不够，软件调整为19mA
--- a/arch/arm64/boot/dts/rockchip/rk3399.dtsi
+++ b/arch/arm64/boot/dts/rockchip/rk3399.dtsi
+               pcfg_pull_none_19ma: pcfg-pull-none-19ma {
+                       bias-disable;
+                       drive-strength = <19>;
+               };
                        rgmii_pins: rgmii-pins {
                                rockchip,pins =
                                        /* mac_txclk */
-                                       <3 17 RK_FUNC_1 &pcfg_pull_none_13ma>,
+                                       <3 17 RK_FUNC_1 &pcfg_pull_none_19ma>,
一般设置tx0~3 tx clk tx en 6个脚到19ma
```
4、设置静态
```
ifconfig eth0 up
ifconfig eth0 192.168.1.100 broadcast 192.168.1.255 netmask 255.255.255.0 up
单网卡添加多个IP地址
ifconfig eth0:0 192.168.1.100 netmask 255.255.255.0 up
ifconfig eth0:1 192.168.2.100 netmask 255.255.255.0 up
若转换不了域名  主要是域名问题
echo "nameserver 8.8.8.8" > /etc/resolv.conf
或者
ndc resolver setnetdns eth0 "" 8.8.8.8


用ip route
ip addr add 192.168.1.100/24 dev eth0
ip link set dev eth0 up
echo "nameserver 8.8.8.8" > /etc/resolv.conf或者ndc resolver setnetdns eth0 "" 8.8.8.8 8.8.4.4
ip route add default via 192.168.1.1 dev eth0

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
tcpdump -i wlan0 -s 0 -w /data/wlan.pcap
```
8、过滤
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
14、
```
ping -s 1024 xx.xx.xx.xx
ping -s 指定 ping包的大小 从 1k 往上加 ，确认ping 包方式是否 在ping的数据包增大到一定程度 也会出问题
```

15、双以太网目前补丁就是eth0用于访问外网，eth1或usb0只能访问局域网
```
给客户建议，设置里面加个切换按钮，设置用哪个网口上网，保存到属性里，然后
EthernetNetworkFactory.java和EthernetNetworkFactoryExt.java两个文件根据属性来切换接口
EthernetNetworkFactory这个文件中的可以访问外网，自行参考和开发需求
```

16、识别网卡是MDC CLK和MDIO两条线，识别不了MDC就没有MDC CLK了，no phy found和硬件关系较大

17、phy_register查看
```
kernel 3.10
find ./ -name phy_reg
cat phy_reg
kernel 4.4
find ./ -name phy_registers
cat phy_registers

```
18、不能自动获取IP的主板，手动设置静态IP能正常上网
```
8201F是百兆的PHY，不走delay节点，看PCB布线RMII线也比较短
示波器看频偏值不准确，要用频率计测试
指定IP后IPERF测吞吐量能到多少？如吞吐量带宽能达到94M左右，硬件测一下RJ45眼图，看电平是否达标，如眼图测试没问题。可能是DHCP服务有问题，另外也可以用“busybox udhcpc -i eth0”或“dhcptool eth0 ”看能否自动获取到IP
```
19、获取IP问题也需要多环境测试，也有是本身环境的问题
```
可能每个工位都强制设了静态IP的原因 所以才会有时能获取，有时候获取不了是因为IP冲突，单独试了WIFI路由器出来的每个主板都是可以
```
20、概率性获取不到ip（表现为dhcp timeout）
```
第一种是开关机，解决：确认reset引脚先拉低延时再拉高延时
第二种是不断插拔，解决：确认一下logic电压，tx rx delay修改吞吐测试，io电流加大，dhcp延时加一下，或者是变压器硬件的原因
第三种是休眠唤醒之后或者长时间概率性，解决：disable eee patch可能是phy的原因节能标准不一致，确认logic电压，驱动唤醒函数，还不行ifconfig eth0 down/up 补丁 

```
21、唤醒后获取不了ip
```
diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index a534672d0955..e60d34e294ad 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -3142,6 +3142,10 @@ int stmmac_resume(struct device *dev)
if (priv->phydev)
phy_start(priv->phydev);

+ stmmac_release(ndev);
+ msleep(100);
+ stmmac_open(ndev);
+
return 0;
}
EXPORT_SYMBOL_GPL(stmmac_resume);
```
22、用stmicro驱动时修改最大速率限制
```
--- a/arch/arm/boot/dts/rk3288-evb.dtsi
+++ b/arch/arm/boot/dts/rk3288-evb.dtsi
@@ -229,7 +229,7 @@
        pinctrl-0 = <&rgmii_pins>;
        tx_delay = <0x30>;
        rx_delay = <0x10>;
-       max-speed = <100>;
+       max-speed = <1000>;
        status = "okay";
 };
```
23、uboot以太网
```
u-boot/drivers/net
designware.o  gmac_rockchip.o

CONFIG_DM_ETH=y
CONFIG_ETH_DESIGNWARE=y
CONFIG_GMAC_ROCKCHIP=y
CONFIG_DM_REGULATOR=y
CONFIG_DM_GPIO=y
```

24、关于休眠唤醒
```
休眠一下子就被唤醒了，断开负载发现和还是会出这种问题
亲测，蓝牙电源关掉，就可以了，蓝牙电源打开，PMEB唤醒引脚接地也可以进入休眠，说明不是蓝牙唤醒的
亲测，有些硬件蓝牙电源关掉也没有用，这就是个大坑，就是休眠模块的问题，IOMUX确认过的，IO domain在休眠也打开关闭都已经测试
波形也抓了没有问题，IO电流还是系统供电问题可能有关，就是休眠模块的坑

所以其它模块（蓝牙rfkill ethernet），方法都是去申请一个脚，然后去添加唤醒函数
disable_irq(irq->irq);
ret = enable_irq_wake(irq->irq);
然后在休眠的时候enable_irq

唤不醒先断开负载，对比一下IO DOMIN和 VDDIO是否匹配，不行也休眠模块的坑
```

25、推流卡顿
```
ethtool -k eth0 查看一下
关掉TX的时候的checksum，关闭硬件校验
ethtool -K eth0 tx-checksum-ipv4 off
ethtool -K eth0 tx-checksum-ipv6 off

ethtool -k eth0

ethtool -K eth0 tx-checksum off

ethtool -K eth0 tso off
```
26、delay确认
```
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
@@ -418,6 +419,8 @@ static void rk3288_set_to_rgmii(struct rk_priv_data *bsp_priv,
                return;
        }

+       printk("%s tx_delay=%x rx_delay=%x\n",__func__,tx_delay,rx_delay);
+       
        regmap_write(bsp_priv->grf, RK3288_GRF_SOC_CON1,
                     RK3288_GMAC_PHY_INTF_SEL_RGMII |
                     RK3288_GMAC_RMII_MODE_CLR);
@@ -1570,6 +1573,15 @@ static int rk_gmac_resume(struct device *dev)
```
27、以太网MAC地址ieee申请
```
一般卖到国外才需要申请
http://blog.sina.com.cn/s/blog_7d02693c0102v77o.html
```
28、以太网probe
```
4.4
stmmac_pltfr_probe

3.10
rk_gmac_probe
```
29、endpoint
```
iperf -c 192.168.32.252 -i 1 -t 99 -d
-d 同时进行双向传输测试,双向能同时到800M以上, 总吞吐量是两条流相加，有可能跟工具有关系。Marvell1512 导致16%CPU挂满，很少见
用endpoint iocharoit 测试
```
30、interrupts,CPU资源不够导致iperf测试吞吐低
```
cat /proc/interrupts
          CPU0       CPU1       CPU2       CPU3       CPU4         CPU5
24:      84760          0          0          0        0              0     GICv3  44 Level     eth0
echo 4 > /proc/irq/24/smp_affinity_list(换挂到CPU4)
24:      84760          0          0          0       393058          0     GICv3  44 Level     eth0

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index abde6c5..791c32c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2833,8 +2833,10 @@ int stmmac_dvr_probe(struct device *device,
 		     struct stmmac_resources *res)
 {
 	int ret = 0;
+	int cpu_id =5;
 	struct net_device *ndev = NULL;
 	struct stmmac_priv *priv;
+	struct cpumask cpumask;
 
 	ndev = alloc_etherdev(sizeof(struct stmmac_priv));
 	if (!ndev)
@@ -2855,7 +2857,11 @@ int stmmac_dvr_probe(struct device *device,
 	priv->dev->irq = res->irq;
 	priv->wol_irq = res->wol_irq;
 	priv->lpi_irq = res->lpi_irq;
-
+	
+	cpumask_clear(&cpumask);
+	cpumask_set_cpu(cpu_id,&cpumask);
+	irq_set_affinity(priv->dev->irq,&cpumask);
+	
 	if (res->mac)
 		memcpy(priv->dev->dev_addr, res->mac, ETH_ALEN);
 
 
nice -n -20 iperf -c 192.168.30.100 -i 1 -t 5 -w 1M -d -P8

可以直接测好丢过去，硬要他们自己解自己系统资源问题，就怪他们

```
31、delay的时间概念
```
具体的意义是相位差，推迟步进单位是2ns，最新回环补丁文档有介绍

可以理解为写delay让txc(clk)和txd(data)相位不断的靠近，具体效果还是需要用工具测量吞吐
```
32、添加以太网选项
```
redmine 249892提到本条redmine需要mid的以太网设置补丁，请参考附件10.0_ethernet_mid_settings.zip。
其中，device\rockchip\rk3399\下的宏开启补丁，如果是其他产品，请根据对应产品在device\rockchip\XXX\目录打上
补丁完全打上后，可以在settings > network&intent 看到 ethernet选项
```
33、PX30以太网配置
```
 &gmac {
     phy-supply = <&vcc_phy>;
     assigned-clocks = <&cru SCLK_GMAC>;
     assigned-clock-parents = <&gmac_clkin>;
     clock_in_out = "input";
     pinctrl-names = "default";
     pinctrl-0 = <&rmii_pins &mac_refclk>;
     snps,reset-gpio = <&gpio2 13 GPIO_ACTIVE_LOW>;
     snps,reset-active-low;
     snps,reset-delays-us = <0 50000 50000>;
     status = "okay";
 };
```


----------------------------------------------------------------



```
ethtool -s eth0 speed 100 duplex full autoneg off

--------------rtl8211------------------

phy   mac 
xtal1  mac_clk&clkout（一起连，外部不接自激电路就直接mac_clk给，dts上设置output直接给xtal1，百兆网是25M，千兆网是125M）
tx0 - tx0
tx1 - tx1
tx2 - tx2
tx3 - tx3
txen- txen
txclk-txclk
rx0 - rx0 
rx1 - rx1
rx2 - rx2 
rx3 - rx3 
rxen-rxen 
rxclk-rxclk 
rxdv-rxdv 
mdio-mdio 
mdc-mdc 
GPIO - phy rst
 
 注意每根线都得连上，少连一根都会找不到phy设备，还有rst也要看看有没有使能，如果吞吐有问题再调tx rx delay
 
 ---------------lan8720A---------------------
 
 LED1_AD1 接下拉的时候 INTB才会输出CLK(接25M晶振，内部倍频 INTB输出50M) 

DNP（do not populate）不焊接的意思，LED0_AD0接下拉是设置芯片地址为0

phy   mac 
xtal1  mac_clk
tx0 - tx0  
tx1 - tx1 
//tx2 - tx2 
//tx3 - tx3 
txen- txen 
//txclk-txclk 
rx0 - rx0 
rx1 - rx1 
//rx2 - rx2 
//rx3 - rx3 
//rxen-rxen 
//rxclk-rxclk 
rxdv-rxdv 
rxer-rxer
mdio-mdio 
mdc-mdc 
gpio - phy rst

```
 
 
 
 
 
