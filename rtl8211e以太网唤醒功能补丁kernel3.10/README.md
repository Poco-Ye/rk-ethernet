打上此补丁后，当PHY接收到magic package时，PME脚会产生中断，唤醒主控。

1. magic_pkt.rar
　用于发给magic package给测试机器的工具
2. 打上补丁20141009_wol_io_irq.patch
3. make menuconfig配置：
　CONFIG_REALTEK_PHY=y
4. dts中需要正确以下中断
 	phyirq-gpio = <&gpio0 GPIO_D1 GPIO_ACTIVE_LOW>; // 用于phy中断，例如断开网线，接上网线识别
	wolirq-gpio = <&gpio0 GPIO_D0 GPIO_ACTIVE_LOW>; // 用于wol中断，当phy收到magic package时，产生中断唤醒主控


如果按上面修改后，发现无法唤醒主控，需要先量一上phy PME脚是否有中断产生?
