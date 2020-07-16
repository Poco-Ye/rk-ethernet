```
MAC control
io -4 -l 0x300 0xffdd0000

CRU
io -4 -r 0x0XFF35016c

GRF
io -4 -l 0x10 0xfe000900

以太网gmac配置看这些寄存器


这个patch还不行就加上
+	clocks = <&cru SCLK_GMAC>, <&cru SCLK_GMAC_RX_TX>,
+		 <&cru SCLK_GMAC_RX_TX>, <&cru SCLK_GMAC_REF>,
+		 <&cru SCLK_GMAC_REFOUT>, <&cru ACLK_GMAC>,
+		 <&cru PCLK_GMAC>, <&cru SCLK_GMAC_RMII_SPEED>;
+	clock-names = "stmmaceth", "mac_clk_rx",
+		 "mac_clk_tx", "clk_mac_ref",
+		 "clk_mac_refout", "aclk_mac",
+		 "pclk_mac", "clk_mac_speed";
```
