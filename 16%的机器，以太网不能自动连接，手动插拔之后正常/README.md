除了延长时间，还进行重新获取ip

```
+++ b/drivers/net/ethernet/rockchip/gmac/stmmac_platform.c
@@ -358,10 +358,10 @@ static int phy_power_on(bool enable)
//reset
if (gpio_is_valid(bsp_priv->reset_io)) {
gpio_direction_output(bsp_priv->reset_io,
bsp_priv->reset_io_level);
- mdelay(5);
+ mdelay(100);
gpio_direction_output(bsp_priv->reset_io, !bsp_priv->reset_io_level);
}
- mdelay(30);
+ mdelay(100);
} else {
//pull down reset
```
