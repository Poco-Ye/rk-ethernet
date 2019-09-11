硬件上注意点：
RXD1(phy pin10) 要加4.7K 上拉电阻。
PHYRSTB（phy pin21）原厂建议断开与主控连接，常供电，避免主控拉低

wol_set.bash 是测试脚本，在正常模式下运行，用 magic packet tool 发包，PMEDB(pin 24)会有拉低动作（注意要禁掉所有虚拟机网卡，会干扰发不出包）

可以在板子上tcpdump -i eth0 -s 0 -w /data/snf.pcap 录包。

正常magic packet 如wol_magic_packet.pkt：
