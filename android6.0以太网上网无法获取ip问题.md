```
https://blog.csdn.net/dkbdkbdkb/article/details/79792255


板子这边通过以太网上网，一开始能获取ip并且上网，但是一段时间后，网络会断掉，究其原因是ip地址没有了



getprop | grep dhcp

系统的dhcpcd守护进程挂了
[dhcp.eth0.result]: [failed]
[init.svc.dhcpcd_eth0]: [stopped]

service dhcpcd_eth0 /system/bin/dhcpcd -aABDKL
     class late_start

     disabled

     oneshot
     

oneshot就是只运行一次的意思，挂了不会再运行



要让这个服务继续运行就要（这项服务的启动结果将会放入“ init.svc.<服务名>“属性中，所有服务）
on property:init.svc.dhcpcd_eth0=stopped
    start dhcpcd_eth0




127|rk322x_box:/ # getprop |grep init.svc
[init.svc.adbd]: [running]
[init.svc.audioserver]: [running]
[init.svc.bootanim]: [stopped]
[init.svc.cameraserver]: [running]
[init.svc.console]: [running]
[init.svc.debuggerd]: [running]
[init.svc.displayd]: [running]
[init.svc.drm]: [running]
[init.svc.drmservice]: [stopped]
[init.svc.gatekeeperd]: [running]
[init.svc.healthd]: [running]
[init.svc.installd]: [running]
[init.svc.keystore]: [running]
[init.svc.lmkd]: [running]
[init.svc.logd]: [running]
[init.svc.logd-reinit]: [stopped]
[init.svc.media]: [running]
[init.svc.mediacodec]: [running]
[init.svc.mediadrm]: [running]
[init.svc.mediaextractor]: [running]
[init.svc.netd]: [running]
[init.svc.perfprofd]: [running]
[init.svc.ril-daemon]: [stopped]
[init.svc.servicemanager]: [running]
[init.svc.surfaceflinger]: [running]
[init.svc.ueventd]: [running]
[init.svc.vold]: [running]
[init.svc.zygote]: [running]


服务关闭后重启打开发现
dhcpcd:Android requires an interface
dhcpcd:stop_control:No such file or directory



原服务改成这样就可以
service dhcpcd_eth0 /system/bin/dhcpcd -aABDKL -d eth0


```

