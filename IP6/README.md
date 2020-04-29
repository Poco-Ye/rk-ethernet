
```
ip -6 route show dev eth0 路由表查不到网关地址

重新设置了网关地址，就能正常了

ip -6 route add fe80:0000:0000:0000:1262:ebff:fea2:0724 dev eth0

ip -6 route add default via fe80:0000:0000:0000:1262:ebff:fea2:0724 dev eth0 metric 256

问题1：路由网关地址过期的原因
问题2：为什么查不到路由表地址
问题3：路由网关地址是在内核设置的还是在应用层设置的
```
