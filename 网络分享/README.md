```
ifconfig eth2 down
ndc netd 5000 softap fwreload eth2 AP
ifconfig eth2 up
ndc netd 5002 softap startap
ifconfig eth2 192.168.20.1
ndc netd 5003 tether start 192.168.20.1 192.168.20.254
echo 1 > /proc/sys/net/ipv4/ip_forward
ndc netd 5004 nat enable eth2 wlan0 1 192.168.20.1/24
ip rule add from all lookup main pref 9999
iptables -t nat -I PREROUTING -i eth2 -p udp --dport 53 -j DNAT --to-destination 8.8.8.8
```
```
DNAT --to-destination 8.8.8.8这个小心不要粘在一起，当连手机热点获取到的dns不行，就必需自行给dns

logcat

ifconfig -a

ps -ef

ip route

iptables -vnL

--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2974,6 +2974,7 @@ int stmmac_dvr_probe(struct device *device,
                }
        }

+    strcpy(ndev->name,"eth2");
        ret = register_netdev(ndev);
        if (ret) {
                netdev_err(priv->dev, "%s: ERROR %i registering the device\n",
		
		
		
hcq@ubuntu:~/33997.1/frameworks/opt/net/ethernet/java/com/android/server/ethernet$ git diff EthernetNetworkFactory.java
diff --git a/java/com/android/server/ethernet/EthernetNetworkFactory.java b/java/com/android/server/ethernet/EthernetNetworkFactory.java
index 4acf1d1..6100b93 100755
--- a/java/com/android/server/ethernet/EthernetNetworkFactory.java
+++ b/java/com/android/server/ethernet/EthernetNetworkFactory.java
@@ -244,7 +244,11 @@ class EthernetNetworkFactory {
             Log.d(TAG, "Already connected or connecting, skip connect");
             return;
         }
-
+       if(mIface.equals("eth2")){
+               Log.e(TAG, "fix eth2 softap mode, skip eth2 connect");
+               return;
+       }


+       SystemProperties.set("ctl.start", service_start_softap_wlan0_to_eth2);  
        //在init.connectivity.rc 中加服务，效果类似于setprop ctl.start service,会触发运行，selinux权限可能要设置
	
init.connectivity.rc	
service service_start_softap_wlan0_to_eth2 /system/bin/start_softap_wlan0_to_eth2.sh
    class main
    disabled
    oneshot




```

```
桥接的方式
使用桥接的工具(br0 eth0在同一个桥上)
brctl addbr br0
brctl addif br0 eth0
brctl addif br0 wlan0
先打开热点，
ifconfig br0 192.168.1.1
桥的IP与摄像头保持一致

```

```
客户实际使用已成功 4G网分享到eth0
ip rule add from all lookup main pref 9999
ifconfig eth0 down
ifconfig eth0 up
busybox ifconfig eth0 192.168.44.1
ndc netd 5003 tether start 192.168.44.2 192.168.44.254
ndc netd 7 nat enable eth0 ppp0 1 192.168.44.1/24
echo 1 >/proc/sys/net/ipv4/ip_forward
iptables -t nat -I PREROUTING -i eth0 -p udp --dport 53 -j DNAT --to-destination 120.196.165.7

9.0使用
下面為最後試出來的命令組合
ip rule add from all lookup main pref 9999
ifconfig eth0 down
ifconfig eth0 up
busybox ifconfig eth0 192.168.44.1
ndc netd 5003 tether start 192.168.44.2 192.168.44.254
ndc netd 7 nat enable eth0 wwan0 1 192.168.44.1/24
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -I PREROUTING -i eth0 -p udp --dport 53 -j DNAT --to-destination 8.8.8.8
```
```
android11 网络分享
busybox ifconfig eth0 192.168.43.1 netmask 255.255.255.0;
ndc tether interface add eth0;
ndc tether start 192.168.43.1 192.168.43.254
ndc nat enable eth0 wlan0 1 192.168.43.1/24
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -I PREROUTING -i eth0 -p udp --dport 53 -j DNAT --to-destination 8.8.8.8
ip rule add from all iif eth0 oif wlan0 lookup wlan0 pref 22000
ip rule add from all lookup wlan0 pref 22000
ip rule add from all lookup main pref 9999
```








