```
&pcie0 {
        ep-gpios = <&gpio2 4 GPIO_ACTIVE_HIGH>;  //这个rst要修改成自己定义
        num-lines = <4>;
        max-link-speed = <1>;
        pinctrl-names = "default";
        pinctrl-0 = <&pcie_gpios>;
        status = "okay";
};
&pcie_phy {
        status = "okay";
};

这个是我之前调过，驱动是用的drivers/net/ethernet/realtek/r8169.c
日志可参考附件
```
