
1、对于有些差的网络，尤其公司网络，同一个DHCP服务器下面主机过多，有时候会出现，DHCP获取不到IP地址的现象。
对于这种问题，处理办法是，把DHCP的超时时间增大。目前的dhcp超时时间是30s，补丁把超时时间增大到90s。 插拔网卡出现概率性性获取不了ip
89785  参考 把超时时间增大到90s.patch












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
 
 
 
 
 
 
