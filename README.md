
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
20、概率性获取不到ip（变现位dhcp timeout）
```
第一种是开关机，解决：确认reset引脚先拉低延时再拉高延时
第二种是不断插拔，解决：确认一下logic电压，tx rx delay修改吞吐测试，io电流加大，dhcp延时加一下，或者是变压器硬件的原因
第三种是休眠唤醒之后或者长时间概率性，解决：disable eee patch可能是phy的原因节能标准不一致，确认logic电压，还不行ifconfig eth0 down/up 补丁 

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
 
 
 
 
 
