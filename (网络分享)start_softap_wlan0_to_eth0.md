```
#!/system/bin/sh


WAN=wlan0
LAN=eth0

function start_softap(){
 
    busybox ifconfig $LAN down
    ndc netd 5000 softap fwreload $LAN AP
    busybox ifconfig $LAN up
	
	echo "tart wifi eth1 softap!"
	
	
    ndc netd 5002 softap startap

     busybox ifconfig $LAN 192.168.43.1                                                                          
     ndc netd 5003 tether start 192.168.43.1 192.168.43.254
     
     echo 1 > /proc/sys/net/ipv4/ip_forward
     ndc netd 5004 nat enable $LAN $WAN 1 192.168.43.1/24
     
     ip rule add from all lookup main pref 9999
	 
	 SYSTEM_DNS=$(getprop net.dns1)
	 iptables -t nat -I PREROUTING -i $LAN  -p udp --dport 53 -j DNAT --to-destination $SYSTEM_DNS
 
}



function stop_softap(){
	  ndc netd 5004 nat disable $LAN $WAN 1 192.168.43.1/24
      ndc netd 6001 tether stop
      ndc netd 6002 softap stopap
}


function restart_softap(){
	stop_softap
	start_softap
}

function usage(){
	echo "./start_softap.sh [start | stop restart]"
}


if echo $@|grep -wqE "help|-h"; then
        usage
        exit 0
fi

OPTIONS="$@"
for option in ${OPTIONS:-restart}; do
        echo "processing option: $option"
        case $option in
                start)
					start_softap
                ;;
               stop)
                    stop_softap
                ;;
                restart)
                    restart_softap  
                ;;
                *)
                 eval $option || usage
                ;;
        esac
done


```



```
logcat

ifconfig -a

ps -ef

ip route

iptables -vnL

```


```
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


+       SystemProperties.set("ctl.start", "start_softap_wlan0_to_eth2.sh");  
        //在init.connectivity.rc 中加服务，效果类似于setprop ctl.start service,会触发运行
		
		
```
