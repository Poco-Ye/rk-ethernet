```
[~] # insmod /lib/modules/misc/bonding.ko mode=1 miimon=100 max_bonds=4 //在開機時我們預設都是active backup mode
[~] # ifconfig bond0 down
[~] # echo 6 > /sys/class/net/bond0/bonding/mode //這個是切成alb mode
[~] # ifconfig bond0 up
[~] # ethtool -i eth1


stmmac_dvr_probe 
ndev->priv_flags |= IFF_LIVE_ADDR_CHANGE
```
