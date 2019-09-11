将PC与MID连接到同一个路由器，PC最好通过有线连接路由器，MID通过无线连接



1. 在PC端运行iperf-2.0.4-win32\iperf.exe
2. 在MID端运行iperf
   1) adb push iperf system/bin
   2) adb shell chmod 777 system/bin/iperf



测试MID下行速率：

1) PC运行：

    iperf -c x.x.x.x -i 1 -w 1M -t 60
    
    其中x.x.x.x为MID的IP地址

2) MID运行：

     system/bin/iperf -s

测试MID上行速率：

1) PC运行：

    iperf -s

2) MID运行：

     system/bin/iperf -c x.x.x.x -i 1 -w 1M -t 60
    
    其中x.x.x.x为PC的IP地址








--------------------------


通用参数

-f [kmKM] 分别表示以Kbits, Mbits, KBytes, MBytes显示报告，默认以Mbits为单位,eg：iperf -c 222.35.11.23 -f K

-i sec 以秒为单位显示报告间隔，eg：iperf -c 222.35.11.23 -i 2

-l 缓冲区大小，默认是8KB,eg：iperf -c 222.35.11.23 -l 16

-m 显示tcp最大mtu值

-o 将报告和错误信息输出到文件eg：iperf -c 222.35.11.23 -o ciperflog.txt

-p 指定服务器端使用的端口或客户端所连接的端口eg：iperf -s -p 9999;iperf -c 222.35.11.23 -p 9999

-u 使用udp协议

-w 指定TCP窗口大小，默认是8KB

-B 绑定一个主机地址或接口（当主机有多个地址或接口时使用该参数）

-C 兼容旧版本（当server端和client端版本不一样时使用）

-M 设定TCP数据包的最大mtu值

-N 设定TCP不延时

-V 传输ipv6数据包

 

server专用参数

-D 以服务方式运行iperf，eg：iperf -s -D

-R 停止iperf服务，针对-D，eg：iperf -s -R

 

client端专用参数

-d 同时进行双向传输测试

-n 指定传输的字节数，eg：iperf -c 222.35.11.23 -n 100000

-r 单独进行双向传输测试

-t 测试时间，默认10秒,eg：iperf -c 222.35.11.23 -t 5

-F 指定需要传输的文件

-T 指定ttl值


