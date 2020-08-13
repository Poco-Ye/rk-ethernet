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
