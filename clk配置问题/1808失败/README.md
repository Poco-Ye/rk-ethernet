```
MAC control
io -4 -l 0x300 0xffdd0000

CRU
io -4 -r 0x0XFF35016c

GRF
io -4 -l 0x10 0xfe000900

以太网gmac配置看这些寄存器


这个patch还不行就加上，插上网线可能会有50M变成25M的
+	clocks = <&cru SCLK_GMAC>, <&cru SCLK_GMAC_RX_TX>,
+		 <&cru SCLK_GMAC_RX_TX>, <&cru SCLK_GMAC_REF>,
+		 <&cru SCLK_GMAC_REFOUT>, <&cru ACLK_GMAC>,
+		 <&cru PCLK_GMAC>, <&cru SCLK_GMAC_RMII_SPEED>;
+	clock-names = "stmmaceth", "mac_clk_rx",
+		 "mac_clk_tx", "clk_mac_ref",
+		 "clk_mac_refout", "aclk_mac",
+		 "pclk_mac", "clk_mac_speed";





这个是我测试成功的1808 input 100M 的配置
&gmac {
        status = "okay";
        phy-supply = <&vcc_phy>;
        phy-mode = "rmii";
        clock_in_out = "input";
        snps,reset-gpio = <&gpio2 RK_PA0 GPIO_ACTIVE_LOW>;              //GPIO2_C0      RMII_RST_1V8IO
        snps,reset-active-low;
        /* Reset time is 20ms, 100ms for rtl8211f */
        snps,reset-delays-us = <0 20000 100000>;
        assigned-clocks = <&cru SCLK_GMAC_RX_TX>, <&cru SCLK_GMAC>;
        assigned-clock-parents = <&cru SCLK_GMAC_RMII_SPEED>, <&gmac_clkin>;

        tx_delay = <0x3f>;
        rx_delay = <0x43>;
};


        gmac_clkin: external-gmac-clock {
                compatible = "fixed-clock";
                clock-frequency = <50000000>;
                clock-output-names = "gmac_clkin";
                #clock-cells = <0>;
        };
```
