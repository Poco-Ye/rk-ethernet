#!/system/bin/sh

############################
# The main function
############################
main()
{

#PMEB PIN function selection

echo 31 > /sys/devices/0:00/phy_reg
sleep 1
echo 0x0007 > /sys/devices/0:00/phy_regValue
sleep 1
echo 19 > /sys/devices/0:00/phy_reg
sleep 1
echo 0xC434 > /sys/devices/0:00/phy_regValue
sleep 1

#SET MAC address

echo 31 > /sys/devices/0:00/phy_reg
sleep 1
echo 0x0012 > /sys/devices/0:00/phy_regValue
sleep 1
echo 16 > /sys/devices/0:00/phy_reg
sleep 1
echo 0x1022 > /sys/devices/0:00/phy_regValue
sleep 1
echo 17 > /sys/devices/0:00/phy_reg
sleep 1
echo 0x2221 > /sys/devices/0:00/phy_regValue
sleep 1
echo 18 > /sys/devices/0:00/phy_reg
sleep 1
echo 0x2423 > /sys/devices/0:00/phy_regValue
sleep 1

#SET MAX packet length

echo 31 > /sys/devices/0:00/phy_reg
sleep 1
echo 0x0011 > /sys/devices/0:00/phy_regValue
sleep 1
echo 17 > /sys/devices/0:00/phy_reg
sleep 1
echo 0x1fff > /sys/devices/0:00/phy_regValue
sleep 1
#WOL event select and enable
echo 16 > /sys/devices/0:00/phy_reg
sleep 1
echo 0x1000 > /sys/devices/0:00/phy_regValue
sleep 1

#wake up frame selection and enable

echo 31 > /sys/devices/0:00/phy_reg
sleep 1
echo 0x0008 > /sys/devices/0:00/phy_regValue
sleep 1
echo 16 > /sys/devices/0:00/phy_reg
sleep 1
echo 0x3000 > /sys/devices/0:00/phy_regValue
sleep 1
echo 17 > /sys/devices/0:00/phy_reg
sleep 1
echo 0x0020 > /sys/devices/0:00/phy_regValue
sleep 1
echo 18 > /sys/devices/0:00/phy_reg
sleep 1
echo 0x03c0 > /sys/devices/0:00/phy_regValue
sleep 1

#Wake¡ªup frame CRC

echo 31 > /sys/devices/0:00/phy_reg
sleep 1
echo 0x0010 > /sys/devices/0:00/phy_regValue
sleep 1
echo 16 > /sys/devices/0:00/phy_reg
sleep 1
echo 0xdf6b > /sys/devices/0:00/phy_regValue
sleep 1

#RMII TX isolate enable
echo 31 > /sys/devices/0:00/phy_reg
sleep 1
echo 0x0007 > /sys/devices/0:00/phy_regValue
sleep 1
echo 20 > /sys/devices/0:00/phy_reg
sleep 1
echo 0xb0d5 > /sys/devices/0:00/phy_regValue
sleep 1

#RMII RX isolate enable
echo 31 > /sys/devices/0:00/phy_reg
sleep 1
echo 0x0011 > /sys/devices/0:00/phy_regValue
sleep 1
echo 19 > /sys/devices/0:00/phy_reg
sleep 1
echo 0x8002 > /sys/devices/0:00/phy_regValue
sleep 1

}

main