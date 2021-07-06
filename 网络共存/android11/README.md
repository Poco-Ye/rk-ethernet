```
用这两个试试，使用静态IP，地址在这个函数里面配置

    private void setStaticIpConfiguration(){
        mStaticIpConfiguration =new StaticIpConfiguration();
        String mIpAddress = "172.16.110.10";
        int mNetmask = 16;
        String mGateway = "172.16.110.1";
        String mDns1 = "192.168.1.1";
        String mDns2 = "8.8.8.8";
```
