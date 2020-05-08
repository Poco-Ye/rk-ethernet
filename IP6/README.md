
```
ip -6 route show dev eth0 路由表查不到网关地址

重新设置了网关地址，就能正常了

ip -6 route add fe80:0000:0000:0000:1262:ebff:fea2:0724 dev eth0

ip -6 route add default via fe80:0000:0000:0000:1262:ebff:fea2:0724 dev eth0 metric 256

问题1：路由网关地址过期的原因
问题2：为什么查不到路由表地址
问题3：路由网关地址是在内核设置的还是在应用层设置的


路由器要设置支持 IPV6，正常会拿到inet6 相关地址.到网上搜索一下IPV6配制即可。
wlan0 Link encap:Ethernet HWaddr 80:C5:F2:2E:E7:33
inet addr:10.64.175.36 Bcast:10.64.175.255 Mask:255.255.240.0
inet6 addr: 2409:88a9:8402:8025:0:1:0:1583/128 Scope:Global
inet6 addr: fe80::8228:a54f:671:551a/64 Scope:Link
UP BROADCAST RUNNING MULTICAST MTU:1500 Metric:1
RX packets:54 errors:0 dropped:0 overruns:0 frame:0
TX packets:67 errors:0 dropped:0 overruns:0 carrier:0
collisions:0 txqueuelen:1000
RX bytes:6619 (6.4 KiB) TX bytes:9559 (9.3 KiB)



```
