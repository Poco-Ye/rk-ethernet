# Rockchip Quick Check Ethernet

文件标识：RK-KF-YF-XXX

发布版本：V1.1.0

日期：2021-09-14

文件密级：公开资料

**免责声明**

本文档按“现状”提供，瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

**商标声明**

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

**版权所有 © 2020 瑞芯微电子股份有限公司**

超越合理使用范畴，非经本公司书面许可，任何单位和个人不得擅自摘抄、复制本文档内容的部分或全部，并不得以任何形式传播。

瑞芯微电子股份有限公司

Rockchip Electronics Co., Ltd.

地址：     福建省福州市铜盘路软件园A区18号

网址：     [www.rock-chips.com](http://www.rock-chips.com)

客户服务电话： +86-4007-700-590

客户服务传真： +86-591-83951833

客户服务邮箱： [fae@rock-chips.com](mailto:fae@rock-chips.com)

---

**前言**

**概述**

本文提供 Rockchip 平台以太网软件配置快速排查方法。

**产品版本**

| **芯片名称** | **内核版本** |
| -------- | -------- |
| 所有芯片     | 所有版本     |

**读者对象**

本文档（本指南）主要适用于以下工程师：

技术支持工程师
软件开发工程师

**修订记录**

| **版本号** | **作者** | **修改日期** | **修改说明** |
| ---------- | -------- | :----------- | ------------ |
| V1.0.0     | 叶彬     | 2021-09-14   | 初始版本     |

---

**目录**

[TOC]

---

## 思路

以太网打不开或者ping不通，先快速排查以下配置。

## Clock配置

先找到DTS上对应gmac的节点，检查clk的部分。

`cat /sys/kernel/debug/clk/clk_summary`

各平台的配置参考的《Rockchip_Developer_Guide_Linux_GMAC_Mode_Configuration_CN.pdf》。

若无此配置文件，找FAE提供。

![image](./1.png)

## pinctrl配置

找到DTS上对应gmac的节点，检查引脚配置部分。

各平台的配置参考的《Rockchip_Developer_Guide_Linux_GMAC_Mode_Configuration_CN.pdf》。

若无此配置文件，找FAE提供。

![image](./2.png)

检查配置是否已经生效。

`cat /sys/kernel/debug/pinctrl/pinctrl-rockchip-pinctrl/pinmux-pins`

![image](./3.png)

<div style="page-break-after: always;"></div>

## io-domain配置

#### 实际电压测量

![image](./4.png)

- 检查PMU提供给主控gmac部分的vccio电压，电表或示波器测量。

- 检查phy芯片的vddio电压，电表或示波器测量。

- 两个电压必须一致。

#### io-domain GRF配置

![image](./5.png)
<div style="page-break-after: always;"></div>

有部分主控可以自适应，GRF内部会随着PMU给到vccio电压而改变配置。大部分主控需要配置与实际给的电压一致，配置不正确可能会烧掉IO引脚。

参考《SDK/RKDocs/common/IO-Domain/Rockchip_Developer_Guide_Linux_IO_DOMAIN_CN.pdf》。