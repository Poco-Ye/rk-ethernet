```
问题解决了，上层APK反射调用设置static时，代理设置有问题，改成NONE就不会报错了，
proxySettings.set(ipConfiguration, ipConfigurationEnum.get("ProxySettings.NONE"));
```
