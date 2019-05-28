#!/system/bin/sh

#echo "para num = $#"

if [ "$#" -ne 3 ]; then
echo "Usage      : gmac_tx_rx_delay_adj.sh [chip] [tx or rx] [value]"
echo "For example: gmac_tx_rx_delay_adj.sh rk3399 tx 0x40 (adjust rk3399 tx_delay to 0x40)"
exit
fi

if [ "$1" = "rk3399" ]; then
    reg=0xff77c218
    if [ "$2" = "tx" ]; then
        val=0x007f0000
        val=$(($val+$3))
    fi
    if [ "$2" = "rx" ]; then
        val=0x7f000000
        val=$(($val+($3*256)))
    fi
fi

if [ "$1" = "rk3288" ]; then
    reg=0xff770250
    if [ "$2" = "tx" ]; then
        val=0x007f0000
        val=$(($val+$3))
    fi
    if [ "$2" = "rx" ]; then
        val=0x3f800000
        val=$(($val+($3*128)))
    fi
fi

if [ "$1" = "rk3368" ]; then
    reg=0xff770440
    if [ "$2" = "tx" ]; then
        val=0x007f0000
        val=$(($val+$3))
    fi
    if [ "$2" = "rx" ]; then
        val=0x7f000000
        val=$(($val+($3*256)))
    fi
fi

if [ "$1" = "rk3126" ]; then
    reg=0x20008168
    if [ "$2" = "tx" ]; then
        val=0x007f0000
        val=$(($val+$3))
    fi
    if [ "$2" = "rx" ]; then
        val=0x3f800000
        val=$(($val+($3*128)))
    fi
fi

if [ "$1" = "rk3128" ]; then
    reg=0x20008168
    if [ "$2" = "tx" ]; then
        val=0x007f0000
        val=$(($val+$3))
    fi
    if [ "$2" = "rx" ]; then
        val=0x3f800000
        val=$(($val+($3*128)))
    fi
fi

if [ "$1" = "rk3228" ]; then
    reg=0x11000900
    if [ "$2" = "tx" ]; then
        val=0x007f0000
        val=$(($val+$3))
    fi
    if [ "$2" = "rx" ]; then
        val=0x3f800000
        val=$(($val+($3*128)))
    fi
fi

printf "io -w -4 $reg 0x%08x\n" $val
io -w -4 $reg $val
echo "io -4 $reg"
io -4 $reg





