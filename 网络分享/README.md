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
DNAT --to-destination 8.8.8.8这个小心粘在一起了，当连手机热点获取到的dns不行，就必需自行给dns




```
