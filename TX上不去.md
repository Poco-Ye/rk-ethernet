```
1、IO驱动强度改一下（可以用IO指令 GRF_GPIO3A_E01 Address: Operational Base + offset (0x0e110) GPIO3A drive strength control）
2、DDR频率不够
TX上不去是DDR不够，定频到800M，TX就上去了
驱动强度的还是改一下
cat clk_summary |grep ddr
sclk_ddrc就是DDR的频率
cat /sys/kernel/debug/opp/opp_summary
cd /sys/class/devfreq/dmc/
echo userspace > governor
echo 800000000 > userspace/set_freq     


ddr频率对以太网有影响，考虑到休眠变频的影响或者本身上行低
&dmc {
        status = "okay";
        center-supply = <&vdd_center>;
        upthreshold = <40>;
        downdifferential = <20>;
        system-status-freq = <
                /*system status         freq(KHz)*/
                SYS_STATUS_NORMAL       800000
                SYS_STATUS_REBOOT       800000
                SYS_STATUS_SUSPEND      800000
                SYS_STATUS_VIDEO_1080P  800000
                SYS_STATUS_VIDEO_4K     800000
                SYS_STATUS_VIDEO_4K_10B 800000
                SYS_STATUS_PERFORMANCE  800000
                SYS_STATUS_BOOST        800000
                SYS_STATUS_DUALVIEW     800000
                SYS_STATUS_ISP          800000
        >;

3、CPU中断资源不够
interrupts,CPU资源不够导致iperf测试吞吐低

cat /proc/interrupts
          CPU0       CPU1       CPU2       CPU3       CPU4         CPU5
24:      84760          0          0          0        0              0     GICv3  44 Level     eth0
echo 4 > /proc/irq/24/smp_affinity_list(换挂到CPU4)
24:      84760          0          0          0       393058          0     GICv3  44 Level     eth0

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index abde6c5..791c32c 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -2833,8 +2833,10 @@ int stmmac_dvr_probe(struct device *device,
 		     struct stmmac_resources *res)
 {
 	int ret = 0;
+	int cpu_id =5;
 	struct net_device *ndev = NULL;
 	struct stmmac_priv *priv;
+	struct cpumask cpumask;
 
 	ndev = alloc_etherdev(sizeof(struct stmmac_priv));
 	if (!ndev)
@@ -2855,7 +2857,11 @@ int stmmac_dvr_probe(struct device *device,
 	priv->dev->irq = res->irq;
 	priv->wol_irq = res->wol_irq;
 	priv->lpi_irq = res->lpi_irq;
-
+	
+	cpumask_clear(&cpumask);
+	cpumask_set_cpu(cpu_id,&cpumask);
+	irq_set_affinity(priv->dev->irq,&cpumask);
+	
 	if (res->mac)
 		memcpy(priv->dev->dev_addr, res->mac, ETH_ALEN);
 
 
nice -n -20 iperf -c 192.168.30.100 -i 1 -t 5 -w 1M -d -P8

可以直接测好丢过去，硬要他们自己解自己系统资源问题，就怪他们

```
