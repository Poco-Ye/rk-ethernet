1. 补丁适用于以下应用场景：
	系统中存在两个以太网卡（或一个4g网卡模拟成以太网卡，再加一个以太网卡），一个用于Internet访问，
另一个用于局域网访问(目前只支持DHCP动态方式获取IP地址)。

2. 如何打补丁：
	如果是Android 5.x及6.0平台：在frameworks/opt/net/ethernet/目录下打上Android 5.x & 6.0/1.diff补丁
	然后再将Android 5.x & 6.0/EthernetNetworkFactoryExt.java拷贝到frameworks/opt/net/ethernet/java/com/android/server/ethernet$目录下

	如果是Android 7.x平台：在frameworks/opt/net/ethernet/目录下打上Android 7.x/1.diff补丁
	然后再将Android 7.x/EthernetNetworkFactoryExt.java拷贝到frameworks/opt/net/ethernet/java/com/android/server/ethernet$目录下

        在init.rockchip.rc中添加服务：
        service dhcpcd_eth1 /system/bin/dhcpcd -aABDKL
             class late_start
             disabled
             oneshot		

3. 如何编译生效：
	mmm frameworks/opt/net/ethernet/将生成的ethernet-service.jar更新到机器中生效

4. 目前补丁默认适配以下场景：
	存在两个网卡：一个是eth0，用于访问Internet，另一个是eth1，用于访问局域网
	注意：如果系统中存在两个以太网卡（例如一个是gmac，另一个是usb ethernet)，驱动先启动的那个网卡会注册成eth0，后启动的网卡会注册成eth1
	如果要固定gmac是eth1, usb ethernet为eth0，可按参考delay_start_of_gmac_driver.diff修改，让gmac驱动后于usb ethernet启动

	eth0默认用于访问Internet，eth1默认用于访问局域网，如果要修改成usb0（例如4g）默认用于访问Internet，eth0(以太网卡)用于访问局域网
	需要修改frameworks/opt/net/ethernet/java/com/android/server/ethernet/EthernetNetworkFactory.java中的mIfaceMatch = "eth0";为mIfaceMatch = "usb0";
		修改frameworks/opt/net/ethernet/java/com/android/server/ethernet/EthernetNetworkFactoryExt.java中的mIface = "eth1";为mIface = "eth0";

5. 以太网eth1模式有三种：
     
        1：DHCP                    动态获取IP地址
        2：STATIC                  静态IP地址
        3：STATIC+DHCPSERVER       静态IP地址，并开启DHCPSERVER，可以给其它设备分配IP地址

   默认为动态获取地址，并关闭dhcpserver，可通过属性设置为其它模式

        1：persist.net.eth1.mode      0：dhcp    1：static
        2：persist.dhcpserver.enable  0：关闭dhcpserver   1：开启dhcpserver              注意：dhcpserver只有在static模式下开启才生效

   static模式需添加静态地址信息属性，如下所示，依次为ip，netmask（只用于局域网，因此不需要网关和dns）

       persist.net.eth1.staticinfo  192.168.1.100，24
       注意：ip和netmask必须用逗号分割（没有空格），netmask为掩码长度int型

   当开启dhcpserver模式，需输入dhcpserver的地址池（即分配IP地址的范围），与静态IP地址保持一致且不冲突

      persist.dhcpserver.start 192.168.1.150
      persist.dhcpserver.end 192.168.1.250