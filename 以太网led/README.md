led是连在phy上面的，有几个led, led_speed100 led_link led_speed10 led_duplex ledtx ledrx

除非cpu有内部phy可以配置cpu，如果是mac 连接外部 phy 那就是只能通过写寄存器的方式去配置
目前的驱动也是在probe上面进行寄存器配置的


8211E_phy_led.patch	 

kernel_4.4_rk322x_phy_led_control.patch 内部phy控制	

phy_led_ctrl.diff	 stmmac_main.c 这个是主要gmac 接phy的控制  rtl8211e, rtl8201f, dp84838三个phy兼容的补丁

