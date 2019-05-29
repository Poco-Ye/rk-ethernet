

--------------80211------------------

phy   mac

xtal1  mac_clk&clkout（一起连，外部不接自激电路就直接mac_clk给，dts上设置output直接给xtal1，百兆网是25M，千兆网是125M）

tx0 - tx0      

tx1 - tx1

tx2 - tx2

tx3 - tx3

txen- txen

txclk-txclk


rx0 - rx0

rx1 - rx1

rx2 - rx2

rx3 - rx3

rxen-rxen

rxclk-rxclk


rxdv-rxdv

mdio-mdio

mdc-mdc

 mac col - phy rst
 
 注意每根线都得连上，少连一根都会找不到phy设备，还有rst也要看看有没有使能，如果吞吐有问题再调tx rx delay
---------------------------------------------------------------------------------
