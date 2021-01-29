```
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2702,6 +2702,7 @@ static int stmmac_open(struct net_device *dev)

        stmmac_enable_all_queues(priv);
        stmmac_start_all_queues(priv);
+    netif_carrier_off(dev);

        return 0;

```
