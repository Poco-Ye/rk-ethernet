clk 的配置主要是gmac提供给phy的时候经常有问题，或者gmac和phy同时有clk出来，也会有问题

clk的感觉是每一个设备有多个clk，然后配置多个

设备一
```

clocks = <clk节点1 clk节点索引1>   <clk节点2 clk节点索引3> 
clocks-names =  "hehe"                     "haha"

hehe haha这样的名字可以自己取的

这个设备需要两个clk，就需要两个clk provider

设备的设置和provider的设置是不一样的

provider 有多个输出的时候，就有多个索引，

provider ＃clock-cells = <1> 的时候就有多个输出，有多个索引，就有多个选择来加载使用

＃clock-cells = <0> 的时候就只有一个， 可以根据provider的索引添加，查看实际大小可以看clk_sum* clock-output-names

oscillator {
compatible = “myclocktype”;
#clock-cells = <1>;
clock-indices = <1>, <3>;
clock-output-names = “clka”, “clkb”;
}

device {
    clocks = <&osc 1>, <&ref 0>;
    clock-names = "baud", "register";
};
```

除了配置provider，也可以设置provider的父节点，分频或者倍频获得
```
assigned-clocks：A， B，C；
assigned-clock-parent：A_parent，B_parent，C_parent；

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

然后配置节点的clk由provider提供
&gmac {
phy-supply = <&vcc_phy>;
clock_in_out = "input";
snps,reset-gpio = <&gpio2 13 GPIO_ACTIVE_LOW>;
snps,reset-active-low;
assigned-clocks = <&cru SCLK_GMAC>;
assigned-clock-parents = <&gmac_clkin>;
snps,reset-delays-us = <0 50000 50000>;
status = "okay";
};
```

clk out 
```
provider没有重新配置，使用默认的

&gmac {
        phy-supply = <&vcc_phy>;
        clock_in_out = "output";
        snps,reset-gpio = <&gpio2 13 GPIO_ACTIVE_LOW>;
        snps,reset-active-low;
        snps,reset-delays-us = <0 50000 50000>;
        status = "okay";
};

```




