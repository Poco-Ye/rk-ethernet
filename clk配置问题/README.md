```
 &cru {
     assigned-clocks = <&cru PLL_NPLL>;
     assigned-clock-rates = <1000000000>;
 };


3399的CRU寄存器在0xff760000

 cru: clock-controller@ff760000 {
                compatible = "rockchip,rk3399-cru";
                reg = <0x0 0xff760000 0x0 0x1000>;
                #clock-cells = <1>;
                #reset-cells = <1>;
                assigned-clocks =
                        <&cru ACLK_VOP0>, <&cru HCLK_VOP0>,
                        <&cru ACLK_VOP1>, <&cru HCLK_VOP1>,
                        <&cru ARMCLKL>, <&cru ARMCLKB>,
                        <&cru PLL_GPLL>, <&cru PLL_CPLL>,
                        <&cru ACLK_GPU>, <&cru PLL_NPLL>,
                        <&cru ACLK_PERIHP>, <&cru HCLK_PERIHP>,
                        <&cru PCLK_PERIHP>,
                        <&cru ACLK_PERILP0>, <&cru HCLK_PERILP0>,
                        <&cru PCLK_PERILP0>, <&cru ACLK_CCI>,
                        <&cru HCLK_PERILP1>, <&cru PCLK_PERILP1>,
                        <&cru ACLK_VIO>, <&cru ACLK_HDCP>,
                        <&cru ACLK_GIC_PRE>,
                        <&cru PCLK_DDR>;
                assigned-clock-rates =
                         <400000000>,  <200000000>,
                         <400000000>,  <200000000>,
                         <816000000>, <816000000>,
                         <594000000>,  <800000000>,
                         <200000000>, <1000000000>,
                         <150000000>,   <75000000>,


assigned-clocks这种节点类似pinctrl子系统，是给clock 子系统使用的，在datasheet上有对于模块的所有的CLOCK

比如一个gmac会列出十几个clock寄存器位置

gmac  3  0  aclk_gmac_cpl l_src        4 - - - - - - - - G6[9] - -

IO_CLK 4 8  clkin_gmac<IO> - - - - - - - - - - - -       这个是输入的IO clk 所以设置输入的时候，有对应得方法，填大小，设置clock
IO_CLK 4 9  gmac_phy_rx_clk<IO> - - - - - - - - - - - -


cat /d/clk/clk_summary  可以看到目前得clk得设置情况，总之方法就是设置寄存器


比如在gmac节点上面

1、clocks节点（这个和clock names配合时候，用意就是给寄存器设置名字，好看一点），cru所有寄存器在include/dt-bindings/clock/rk3399-cru.h

clocks = <&cru SCLK_MAC>, <&cru SCLK_MAC_RX>,
         <&cru SCLK_MAC_TX>, <&cru SCLK_MACREF>,
         <&cru SCLK_MACREF_OUT>, <&cru ACLK_GMAC>,
         <&cru PCLK_GMAC>;
clock-names = "stmmaceth", "mac_clk_rx",
              "mac_clk_tx", "clk_mac_ref",
              "clk_mac_refout", "aclk_mac",
              "pclk_mac";

2、assigned-clocks
在drivers/clk/clk-conf.c里面处理

这个开头已经看到了，就是设置对应得寄存器得意思，“指定的意思”

a、可以设置寄存器得值
assigned-clock-rates

b、可以设置父节点
assigned-clock-parents




看pin子系统在/d/pinctrl/pinmux-pins
看clock子系统在/d/clk/clk_summary

可以看到他们的设置，设置复用了没有，或者设置clock了没有

```





3368 android 8.1配置
clk in
```

首先配置一个外部的provider
gmac_clkin: external-gmac-clock {
          compatible = "fixed-clock";
          clock-frequency = <50000000>;
          clock-output-names = "gmac_clkin";
          #clock-cells = <0>;
 };


&gmac {
phy-supply = <&vcc_phy>;
clock_in_out = "input";
snps,reset-gpio = <&gpio2 13 GPIO_ACTIVE_LOW>;
snps,reset-active-low;
assigned-clocks = <&cru SCLK_GMAC>;
assigned-clock-parents = <&gmac_clkin>;      //这里是真正设置的地方
snps,reset-delays-us = <0 50000 50000>;
status = "okay";
};
```

clk out 
```
寄存器的数值不用更改，因为百兆一般默认都50M接两根线（50*2）

&gmac {
        phy-supply = <&vcc_phy>;
        phy-mode = "rmii";
        clock_in_out = "output";
        snps,reset-gpio = <&gpio2 13 GPIO_ACTIVE_LOW>;
        snps,reset-active-low;
        snps,reset-delays-us = <0 50000 50000>;
        status = "okay";
};


还有或者有可能要改一下parents，主要修改的SCLK_GMAC，这个好像有问题

&gmac {
phy-supply = <&vcc_phy>;
clock_in_out = "output";
snps,reset-gpio = <&gpio2 13 GPIO_ACTIVE_LOW>;
snps,reset-active-low;
assigned-clocks = <&cru SCLK_GMAC>;
assigned-clock-parents = <&cru SCLK_GMAC>;
snps,reset-delays-us = <0 50000 50000>;
status = "okay";
};

这个是3368的挂在CPLL下面的，这个用了好像没有问题
--- a/arch/arm64/boot/dts/rockchip/rk3368-808.dtsi
+++ b/arch/arm64/boot/dts/rockchip/rk3368-808.dtsi
@@ -52,12 +52,12 @@
                io-channels = <&saradc 2>;
        };

-       ext_gmac: gmac-clk {
+       /*ext_gmac: gmac-clk {
                compatible = "fixed-clock";
                clock-frequency = <125000000>;
                clock-output-names = "ext_gmac";
                #clock-cells = <0>;
-       };
+       };*/

        vcc_phy: vcc-phy-regulator {
                compatible = "regulator-fixed";
@@ -825,13 +825,14 @@
 &gmac {
        phy-supply = <&vcc_phy>;
        phy-mode = "rgmii";
-       clock_in_out = "input";
+       clock_in_out = "output";
        snps,reset-gpio = <&gpio3 11 GPIO_ACTIVE_LOW>;
        snps,reset-active-low;
        snps,reset-delays-us = <0 10000 50000>;
-       assigned-clocks = <&cru SCLK_MAC>;
-       assigned-clock-parents = <&ext_gmac>;
+    assigned-clocks = <&cru SCLK_MAC>, <&cru SCLK_RMII_SRC>;
+    assigned-clock-rates = <125000000>;
+    assigned-clock-parents = <&cru PLL_CPLL>, <&cru SCLK_MAC>;
        pinctrl-0 = <&rgmii_pins>;
        tx_delay = <0x28>;
        rx_delay = <0x11>;

diff --git a/arch/arm64/boot/dts/rockchip/rk3368.dtsi b/arch/arm64/boot/dts/rockchip/rk3368.dtsi
index b8d9a44..0b46eee 100644
--- a/arch/arm64/boot/dts/rockchip/rk3368.dtsi
+++ b/arch/arm64/boot/dts/rockchip/rk3368.dtsi
@@ -1162,7 +1162,7 @@
                        <&cru ACLK_CCI_PRE>;
                assigned-clock-rates =
                        <816000000>, <816000000>,
-                       <576000000>, <400000000>,
+                       <576000000>, <1000000000>,
                        <300000000>, <300000000>,
                        <150000000>, <150000000>,
                        <75000000>, <75000000>,



```

```
百兆也可以配置在npll下面
&gmac {
	phy-supply = <&vcc_phy>;
	phy-mode = "rmii";
	clock_in_out = "output";
	snps,reset-gpio = <&gpio3 15 GPIO_ACTIVE_LOW>;
	snps,reset-active-low;
	snps,reset-delays-us = <0 10000 50000>;
	//assigned-clocks = <&cru SCLK_MAC>;
	//assigned-clock-parents = <&cru SCLK_MAC>;
	assigned-clocks = <&cru SCLK_MAC>,<&cru SCLK_RMII_SRC>;
	assigned-clock-rates = <50000000>;
	assigned-clock-parents = <&cru PLL_NPLL>,<&cru SCLK_MAC>;

	pinctrl-names = "default";
	pinctrl-0 = <&rmii_pins>;
	tx_delay = <0x48>;
	rx_delay = <0x21>;
	status = "okay";
};

还不行rmii的驱动强度调大

kernel/drivers/clk/rockchip/clk-px30.c
修改clk方法：

	COMPOSITE(SCLK_GMAC_SRC, "clk_gmac_src", mux_gpll_cpll_npll_p, 0,
			PX30_CLKSEL_CON(22), 14, 2, MFLAGS, 8, 5, DFLAGS,
			PX30_CLKGATE_CON(7), 11, GFLAGS),
	MUX(SCLK_GMAC, "clk_gmac", mux_gmac_p,  CLK_SET_RATE_PARENT,
			PX30_CLKSEL_CON(23), 6, 1, MFLAGS),


&gmac {
phy-supply = <&vcc_phy>;
clock_in_out = "output";
snps,reset-gpio = <&gpio2 13 GPIO_ACTIVE_LOW>;
snps,reset-active-low;
assigned-clocks = <&cru SCLK_GMAC_SRC>, <&cru SCLK_GMAC>;
assigned-clock-rates = <50000000>;
assigned-clock-parents = <&cru PLL_NPLL>, <&cru SCLK_GMAC_SRC>;
snps,reset-delays-us = <0 50000 50000>;
status = "okay";
};

#include "px30.dtsi"

 &cru {
     assigned-clocks = <&cru PLL_NPLL>;
     assigned-clock-rates = <1000000000>;
 };
 
经过排查发现，是由于rtl8201的RXD3/CLK_CT引脚没接对导致的，原本接地配置成RMII REF_CLK Output mode了。
硬件上改成拉高，配置成Input mode就可以了。


可以直接看clk设置的寄存器，对着datasheet来设置
CRU
FF76_0000
CRU_CLKSEL_CON20
Address: Operational Base + offset (0x0150)
Internal clock select and divide register20

15:14   RW 0x2
clk_gmac_pll_sel  clk_gmac  clock source select control register
2'b00:CPLL
2'b01:GPLL
2'b1x:NPLL


```


```
3368的clk配置
clk: failed to reparent mac_clk to clkin_gmac: -22

     ext_gmac: gmac-clk {
         compatible = "fixed-clock";
         clock-frequency = <125000000>;
         clock-output-names = "ext_gmac";
         #clock-cells = <0>;
     };
     
 &gmac {
     status = "okay";
     phy-supply = <&vcc_lan>;
     phy-mode = "rgmii";
     clock_in_out = "input";
     assigned-clocks = <&cru SCLK_MAC>;
     assigned-clock-parents = <&ext_gmac>;
     pinctrl-names = "default";
     pinctrl-0 = <&rgmii_pins>;
     tx_delay = <0x30>;
     rx_delay = <0x10>;
 };


```

```
1126_1109 
1126_1109都是用同一份SDK

百兆输入
&gmac {
                phy-mode = "rmii";
                clock_in_out = "input";

                snps,reset-gpio = <&gpio3 RK_PC5 GPIO_ACTIVE_LOW>;
                snps,reset-active-low;
                snps,reset-delays-us = <0 100000 100000>;

                assigned-clocks = <&cru CLK_GMAC_RGMII_M0>,<&cru CLK_GMAC_SRC_M0>, <&cru CLK_GMAC_SRC>, <&cru CLK_GMAC_TX_RX>;
                assigned-clock-rates = <0>,<0>, <50000000>;
                assigned-clock-parents = <&gmac_clkin_m0>,<&cru CLK_GMAC_RGMII_M0>, <&cru CLK_GMAC_SRC_M0>, <&cru RMII_MODE_CLK>;

                pinctrl-names = "default";
                pinctrl-0 = <&rmiim0_pins &gmac_clk_m0_pins>;

                status = "okay";
};

百兆输出

&gmac {
        phy-mode = "rmii";
        clock_in_out = "output";

        snps,reset-gpio = <&gpio3 RK_PC5 GPIO_ACTIVE_LOW>;
        snps,reset-active-low;
        snps,reset-delays-us = <0 100000 100000>;

        assigned-clocks = <&cru CLK_GMAC_SRC>, <&cru CLK_GMAC_TX_RX>;
        assigned-clock-parents = <&cru CLK_GMAC_SRC_M0>, <&cru RMII_MODE_CLK>;
        assigned-clock-rates = <50000000>;

        pinctrl-names = "default";
        pinctrl-0 = <&rmiim0_pins &gmac_clk_m0_drv_level0_pins>;

        phy-handle = <&phy>;
        status = "okay";
};

百兆输出M1（已经量产的配置）
&gmac {
		phy‐mode = "rmii";
		clock_in_out = "output";
		snps,reset‐gpio = <&gpio3 RK_PC5 GPIO_ACTIVE_LOW>;
		snps,reset‐active‐low;
		/* Reset time is 20ms, 100ms for rtl8211f */
		snps,reset‐delays‐us = <0 50000 100000>;

+         assigned-clocks = <&cru CLK_GMAC_SRC_M1>, <&cru CLK_GMAC_SRC>, <&cru CLK_GMAC_TX_RX>;
+         assigned-clock-rates = <0>, <50000000>;
+         assigned-clock-parents = <&cru CLK_GMAC_RGMII_M1>, <&cru CLK_GMAC_SRC_M1>, <&cru RMII_MODE_CLK>;

		pinctrl‐names = "default";
		pinctrl-0 = <&rmiim1_pins &gmac_clk_m1_pins>;
		
	 phy-handle = <&phy>;
	 status = "okay";
};



3288 设置为输出

&gmac {
	phy-supply = <&vcc_phy>;
	phy-mode = "rgmii";
	clock_in_out = "output";
	snps,reset-gpio = <&gpio4 8 GPIO_ACTIVE_HIGH>;
	snps,reset-active-low;
	snps,reset-delays-us = <0 10000 50000>;
	assigned-clocks = <&cru SCLK_MAC>;
	assigned-clock-rates = <125000000>;
	pinctrl-names = "default";
	pinctrl-0 = <&rgmii_pins>, <&bcm_rst>;
	tx_delay = <0x30>;
	rx_delay = <0x10>;
	max-speed = <100>;
	status = "okay";
};


公板3568成功配置

--- a/arch/arm64/boot/dts/rockchip/rk3568-evb1-ddr4-v10.dtsi
+++ b/arch/arm64/boot/dts/rockchip/rk3568-evb1-ddr4-v10.dtsi
@@ -206,7 +206,7 @@

 &gmac0 {
        phy-mode = "rgmii";
-       clock_in_out = "output";
+       clock_in_out = "input";

        snps,reset-gpio = <&gpio2 RK_PD3 GPIO_ACTIVE_LOW>;
        snps,reset-active-low;
@@ -214,7 +214,7 @@
        snps,reset-delays-us = <0 20000 100000>;

        assigned-clocks = <&cru SCLK_GMAC0_RX_TX>, <&cru SCLK_GMAC0>;
-       assigned-clock-parents = <&cru SCLK_GMAC0_RGMII_SPEED>;
+       assigned-clock-parents = <&cru SCLK_GMAC0_RGMII_SPEED>, <&gmac0_clkin>;
        assigned-clock-rates = <0>, <125000000>;

        pinctrl-names = "default";
@@ -222,6 +222,7 @@
                     &gmac0_tx_bus2
                     &gmac0_rx_bus2
                     &gmac0_rgmii_clk
+                    &gmac0_clkinout
                     &gmac0_rgmii_bus>;

        tx_delay = <0x3c>;
@@ -233,7 +234,7 @@

 &gmac1 {
        phy-mode = "rgmii";
-       clock_in_out = "output";
+       clock_in_out = "input";

        snps,reset-gpio = <&gpio2 RK_PD1 GPIO_ACTIVE_LOW>;
        snps,reset-active-low;
@@ -241,7 +242,7 @@
        snps,reset-delays-us = <0 20000 100000>;

        assigned-clocks = <&cru SCLK_GMAC1_RX_TX>, <&cru SCLK_GMAC1>;
-       assigned-clock-parents = <&cru SCLK_GMAC1_RGMII_SPEED>;
+       assigned-clock-parents = <&cru SCLK_GMAC1_RGMII_SPEED>, <&gmac1_clkin>;
        assigned-clock-rates = <0>, <125000000>;

        pinctrl-names = "default";
@@ -249,6 +250,7 @@
                     &gmac1m1_tx_bus2
                     &gmac1m1_rx_bus2
                     &gmac1m1_rgmii_clk
+                    &gmac1m1_clkinout
                     &gmac1m1_rgmii_bus>;

        tx_delay = <0x4f>;


```


