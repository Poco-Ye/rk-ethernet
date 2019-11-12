led是连在phy上面的，有几个led, led_speed100 led_link led_speed10 led_duplex ledtx ledrx

除非cpu有内部phy可以配置cpu，如果是mac 连接外部 phy 那就是只能通过写寄存器的方式去配置
目前的驱动也是在probe上面进行寄存器配置的


8211E_phy_led.patch	 

kernel_4.4_rk322x_phy_led_control.patch 内部phy控制	

phy_led_ctrl.diff	 stmmac_main.c(可一起给客户) 这个是主要gmac 接phy的控制  rtl8211e, rtl8201f, dp84838三个phy兼容的补丁



可以参考Phy手册



以8211E为例子

```
+	/*set led1(yellow) act*/
+	val = phy_read(phydev, 26);
+	val &= (~(1<4));// bit4=0
+	val |= ( (1<5));// bit5=1
+	val &= (~(1<6));// bit6=0
+	phy_write(phydev, 26, val);
+
+	/*set led0(green) link*/
+	val = phy_read(phydev, 28);
+	val |= ( (7<0));// bit0,1,2=1
+	val &= (~(7<4));// bit4,5,6=0
+	val &= (~(7<8));// bit8,9,10=0
+	phy_write(phydev, 28, val);
```


黄灯led1设置为 0  0  0  1 [active]（link is up）就会亮，同时设置10M/100M/1000M

绿灯led0设置为 1  1  1  0 [link 10/100/1000](不管是那个频率的网) 有数据就会闪烁






