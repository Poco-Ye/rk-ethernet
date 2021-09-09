```
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -325,6 +325,9 @@ static int get_phy_id(struct mii_bus *bus, int addr, u32 *phy_id,
 {
        int phy_reg;

+    *phy_id = 0x11223344;
+    return 0;
+
        if (is_c45)
                return get_phy_c45_ids(bus, addr, phy_id, c45_ids);```



--- a/drivers/net/phy/phy_device.c 
 +++ b/drivers/net/phy/phy_device.c 
 @@ -161,14 +161,14 @@ struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id, 
   dev->dev.release = phy_device_release; 
   - dev->speed = 0; 
 - dev->duplex = -1; 
 + dev->speed = SPEED_1000; 
 + dev->duplex = DUPLEX_FULL; 
 dev->pause = 0; 
 dev->asym_pause = 0; 
 dev->link = 1; 
 dev->interface = PHY_INTERFACE_MODE_GMII; 
   - dev->autoneg = AUTONEG_ENABLE; 
 + dev->autoneg = AUTONEG_DISABLE; 
   dev->is_c45 = is_c45; 
 dev->addr = addr; 
 @@ -1108,6 +1108,9 @@ int genphy_read_status(struct phy_device *phydev) 
 else 
 phydev->speed = SPEED_10; 
   +  
 + phydev->duplex = DUPLEX_FULL; 
 + phydev->speed = SPEED_1000; 
 phydev->pause = 0; 
 phydev->asym_pause = 0; 
 }
 
 
```






