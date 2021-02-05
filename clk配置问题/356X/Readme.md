https://10.10.10.29/c/rk/kernel/+/116115

```


&gmac0 {

    phy-mode = "rgmii";

    clock_in_out = "input";



    snps,reset-gpio = <&gpio2 RK_PD3 GPIO_ACTIVE_LOW>;

    snps,reset-active-low;

    /* Reset time is 20ms, 100ms for rtl8211f */

    snps,reset-delays-us = <0 20000 100000>;



    assigned-clocks = <&cru SCLK_GMAC0_RX_TX>, <&cru SCLK_GMAC0>;

    assigned-clock-parents = <&cru SCLK_GMAC0_RGMII_SPEED>, <&gmac0_clkin>;



    pinctrl-names = "default";

    pinctrl-0 = <&gmac0_miim

             &gmac0_tx_bus2

             &gmac0_rx_bus2

             &gmac0_rgmii_clk

             &gmac0_rgmii_bus

             &gmac0_clkinout>;



    tx_delay = <0x3c>;

    rx_delay = <0x2f>;



    phy-handle = <&rgmii_phy0>;

    status = "okay";

};



&gmac1 {

    phy-mode = "rgmii";

    clock_in_out = "input";



    snps,reset-gpio = <&gpio2 RK_PD1 GPIO_ACTIVE_LOW>;

    snps,reset-active-low;

    /* Reset time is 20ms, 100ms for rtl8211f */

    snps,reset-delays-us = <0 20000 100000>;



    assigned-clocks = <&cru SCLK_GMAC1_RX_TX>, <&cru SCLK_GMAC1>;

    assigned-clock-parents = <&cru SCLK_GMAC1_RGMII_SPEED>, <&gmac1_clkin>;



    pinctrl-names = "default";

    pinctrl-0 = <&gmac1m1_miim

             &gmac1m1_tx_bus2

             &gmac1m1_rx_bus2

             &gmac1m1_rgmii_clk

             &gmac1m1_rgmii_bus

             &gmac1m1_clkinout>;



    tx_delay = <0x4f>;

    rx_delay = <0x26>;



    phy-handle = <&rgmii_phy1>;

    status = "okay";

};
```
