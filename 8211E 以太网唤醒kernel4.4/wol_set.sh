#***********************************************************************
#                       8211E配制
#        可以在不休眠情况下验证功能，如下几点需要手动修改：   
#        1、寄存器路径可能不同： busybox find /sys/ -name phy_reg
#        2、网关可能不同:  ifconfig 自己确认修改
#		 3、有可能MAC地址随机，统一固定成00:12:34:56:78:9a， magic tool也设置一样 
#
#***************************************************************************


# 1、set Mac adress=00:12:34:56:78:9a
echo 31 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x0007 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue 
sleep 0.5

echo 30 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x006e > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue  
sleep 0.5

echo 21 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x96de > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue

echo 22 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0xad17 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue

echo 23 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x5af7 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue


#2、set max packet length
echo 30 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x006d > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
echo 22 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x1fff > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue

#3、enable wol eake-up frame event
echo 31 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x0007 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5

echo 30 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x006d > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5

echo 21 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x0001 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue

echo 21 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x0002 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue

echo 21 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x0004 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue

echo 21 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x0008 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue

echo 21 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x0010 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue

echo 21 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x0020 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue

echo 21 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x0040 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue

echo 21 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x0080 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue

#5、enable all event
echo 31 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x0007 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue 
sleep 0.5

echo 30 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x006d > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue  
sleep 0.5

echo 21 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0xffff > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue

#6、set wake-up frame mask,wake-up frame mask=0x0000_03C0_0020_3000
echo 30 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x0064 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue

echo 21 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x3000 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue

echo 22 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x0020 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue

echo 23 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x03C0 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue

echo 24 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x0000 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue

echo 25 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x0000 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue

echo 26 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x0000 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue

echo 27 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x0000 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue

echo 28 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x0000 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue

#4、disable rgmii pad
echo 30 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x006d > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
echo 25 > /sys/devices/ff290000.eth/stmmac-0:01/phy_reg
sleep 0.5
echo 0x0001 > /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue
sleep 0.5
cat  /sys/devices/ff290000.eth/stmmac-0:01/phy_regValue



