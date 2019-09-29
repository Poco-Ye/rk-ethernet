led是连在phy上面的，有几个led, led_speed100 led_link led_speed10 led_duplex ledtx ledrx

除非cpu有内部phy可以配置cpu，如果是mac 连接外部 phy 那就是只能通过写寄存器的方式去配置
目前的驱动也是在probe上面进行寄存器配置的
