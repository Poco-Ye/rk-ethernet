/*
 * Copyright (C) 2014 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.android.server.ethernet;

import android.content.Context;
import android.net.ConnectivityManager;
import android.net.DhcpResults;
import android.net.EthernetManager;
import android.net.IEthernetServiceListener;
import android.net.InterfaceConfiguration;
import android.net.IpConfiguration;
import android.net.IpConfiguration.IpAssignment;
import android.net.IpConfiguration.ProxySettings;
import android.net.LinkProperties;
import android.net.LinkAddress;
import android.net.NetworkAgent;
import android.net.NetworkCapabilities;
import android.net.NetworkFactory;
import android.net.NetworkInfo;
import android.net.NetworkInfo.DetailedState;
import android.net.NetworkUtils;
import android.net.StaticIpConfiguration;
import android.net.RouteInfo;
import android.os.Handler;
import android.os.IBinder;
import android.os.INetworkManagementService;
import android.os.Looper;
import android.os.RemoteCallbackList;
import android.os.RemoteException;
import android.os.ServiceManager;
import android.text.TextUtils;
import android.util.Log;
import android.content.Intent;
import android.os.UserHandle;
import android.provider.Settings;
import android.os.Message;
import android.os.HandlerThread;
import android.os.SystemProperties;
import android.net.ip.IIpClient;
import android.net.shared.ProvisioningConfiguration;
import android.net.ip.IpClientCallbacks;
import android.net.ip.IpClientUtil;
import android.os.ConditionVariable;

import com.android.internal.util.IndentingPrintWriter;
import com.android.server.net.BaseNetworkObserver;

import java.io.FileDescriptor;
import java.io.PrintWriter;

import java.io.File;
import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.lang.Exception;
import java.util.List;
import java.net.InetAddress;
import java.net.Inet4Address;

class EthernetNetworkFactoryExt {
    private static final String TAG = "EthernetNetworkFactoryExt";
    private static String mIface = "usb0";
    private static boolean mLinkUp = false;
    private static String mMode = "0"; // 0: DHCP; 1: Static
    private static final int EVENT_INTERFACE_LINK_STATE_CHANGED = 0;
    private static final int EVENT_INTERFACE_LINK_STATE_CHANGED_DELAY_MS = 1000;
    private static final boolean DBG = true;
    
    private INetworkManagementService mNMService;
    private Context mContext;
    private Handler mHandler;
    private int mConnectState;  //0: disconnect ; 1: connect; 2: connecting
    private LinkProperties mLinkProperties;
    private IIpClient mIpClient;
    private EthernetManager mEthernetManager;
    private StaticIpConfiguration mStaticIpConfiguration;
    private IpConfiguration mIpConfiguration;
    private IpClientCallbacksImpl mIpClientCallback;

    public EthernetNetworkFactoryExt() {
        HandlerThread handlerThread = new HandlerThread("EthernetNetworkFactoryExtThread");
        handlerThread.start();
        mHandler = new EthernetNetworkFactoryExtHandler(handlerThread.getLooper(), this);
        mConnectState = 0;
        mIpClient = null;
    }

    private class EthernetNetworkFactoryExtHandler extends Handler {
        private EthernetNetworkFactoryExt mEthernetNetworkFactoryExt;

        public EthernetNetworkFactoryExtHandler(Looper looper, EthernetNetworkFactoryExt factory) {
            super(looper);
            mEthernetNetworkFactoryExt = factory;
        }

        @Override
        public void handleMessage(Message msg) {
            switch (msg.what) {
                case EVENT_INTERFACE_LINK_STATE_CHANGED:
                    if(msg.arg1 == 1) {
                        mEthernetNetworkFactoryExt.connect();
                    } else {
                        mEthernetNetworkFactoryExt.disconnect();
                    }
                break;
            }
        }
    }

    private void setInterfaceUp(String iface) {
        try {
            mNMService.setInterfaceUp(iface);
        } catch (Exception e) {
            Log.e(TAG, "Error upping interface " + iface + ": " + e);
        }
    }

    private void addToLocalNetwork(String iface, List<RouteInfo> routes) {
        Log.d(TAG, "addToLocalNetwork: iface = " + iface);
        try {
            mNMService.addInterfaceToLocalNetwork(iface, routes);
        } catch (RemoteException e) {
            Log.e(TAG, "Failed to add iface to local network " + e);
        }
    }

    private void removeToLocalNetwork(String iface) {
        Log.d(TAG, "removeToLocalNetwork: iface = " + iface);
        try {
            mNMService.removeInterfaceFromLocalNetwork(iface);
        } catch (RemoteException e) {
            Log.e(TAG, "Failed to remove iface to local network " + e);
        }
    }

    public void start(Context context, INetworkManagementService s) {
        mContext = context;
        mNMService = s;
        mEthernetManager = (EthernetManager) context.getSystemService(Context.ETHERNET_SERVICE);
        mIpConfiguration = new IpConfiguration();
        try {
            final String[] ifaces = mNMService.listInterfaces();
            Log.e(TAG, "get list of interfaces " + ifaces[0]);
            for (String iface : ifaces) {
                synchronized(this) {
                    if (mIface.equals(iface)) {
                        setInterfaceUp(iface);
                        break;
                    }
                }
            }
        } catch (RemoteException e) {
            Log.e(TAG, "Could not get list of interfaces " + e);
        }
    }

    public void interfaceLinkStateChanged(String iface, boolean up) {
        Log.d(TAG, "interfaceLinkStateChanged: iface = " + iface + ", up = " + up);
        if (!mIface.equals(iface))
            return;
        if (mLinkUp == up)
            return;

        mLinkUp = up;
        if (up) {
            mHandler.removeMessages(EVENT_INTERFACE_LINK_STATE_CHANGED);
            mHandler.sendMessageDelayed(mHandler.obtainMessage(EVENT_INTERFACE_LINK_STATE_CHANGED, 1, 0),
                            EVENT_INTERFACE_LINK_STATE_CHANGED_DELAY_MS);
        } else {
            mHandler.removeMessages(EVENT_INTERFACE_LINK_STATE_CHANGED);
            mHandler.sendMessageDelayed(mHandler.obtainMessage(EVENT_INTERFACE_LINK_STATE_CHANGED, 0, 0),
                            0);            
        }
    }

    /* For Android 5.x and Android 6.0 */
    /*private boolean startDhcp(String iface) {
        NetworkUtils.stopDhcp(iface);
        Log.d(TAG, "runDhcp");
        DhcpResults dhcpResults = new DhcpResults();
        if (!NetworkUtils.runDhcp(iface, dhcpResults)) {
            Log.e(TAG, "runDhcp failed for " + iface);
            return false;
        }
        mLinkProperties = dhcpResults.toLinkProperties(iface);
        return true;
    }

    private void stopDhcp(String iface) {
        NetworkUtils.stopDhcp(mIface);
    }*/

    private class IpClientCallbacksImpl extends IpClientCallbacks {
        private final ConditionVariable mIpClientStartCv = new ConditionVariable(false);
        private final ConditionVariable mIpClientShutdownCv = new ConditionVariable(false);

        @Override
        public void onIpClientCreated(IIpClient ipClient) {
            mIpClient = ipClient;
            mIpClientStartCv.open();
        }

        private void awaitIpClientStart() {
            mIpClientStartCv.block();
        }

        private void awaitIpClientShutdown() {
            mIpClientShutdownCv.block();
        }

        @Override
        public void onProvisioningSuccess(LinkProperties newLp) {
            mLinkProperties = newLp;
            List<RouteInfo> routes = mLinkProperties.getRoutes();
            addToLocalNetwork(mIface, routes);
        }

        @Override
        public void onProvisioningFailure(LinkProperties newLp) {
            mLinkProperties = newLp;
        }

        @Override
        public void onLinkPropertiesChange(LinkProperties newLp) {
            mLinkProperties = newLp;
        }

        @Override
        public void onQuit() {
            mIpClient = null;
            mIpClientShutdownCv.open();
        }
    }
    /* For Android 7.x */
    private boolean startDhcp(String iface, IpConfiguration ipconfig) {
        Log.d(TAG, "IpClient.startProvisioning");

        stopDhcp(iface);
        mIpClientCallback = new IpClientCallbacksImpl();
        IpClientUtil.makeIpClient(mContext, mIface, mIpClientCallback);
        mIpClientCallback.awaitIpClientStart();

        final ProvisioningConfiguration config;
        if (ipconfig.getIpAssignment() == IpAssignment.STATIC) {
            config = new ProvisioningConfiguration.Builder()
                .withStaticConfiguration(ipconfig.getStaticIpConfiguration())
                .build();
        } else {
                config = new ProvisioningConfiguration.Builder()
                .withProvisioningTimeoutMs(0)
                .build();
	}
        try {
            mIpClient.startProvisioning(config.toStableParcelable());
        } catch (RemoteException e) {
            e.rethrowFromSystemServer();
        }
        return true;
    }

    private void stopDhcp(String iface) {
        if (mIpClient != null) {
            try {
                mIpClient.shutdown();
            } catch (RemoteException e) {
                e.rethrowFromSystemServer();
            }
            mIpClientCallback.awaitIpClientShutdown();
            mIpClient = null;
        }
        mIpClientCallback = null;
    }

    private void setStaticIpConfiguration(){
        mStaticIpConfiguration =new StaticIpConfiguration();
        String mIpAddress = "172.16.110.10";
        int mNetmask = 16;
        String mGateway = "172.16.110.1";
        String mDns1 = "192.168.1.1";
        String mDns2 = "8.8.8.8";

        String mProStaticInfo = SystemProperties.get("persist.net.eth1.staticinfo", null);
        if(!TextUtils.isEmpty(mProStaticInfo)){
            String mStaticInfo[] = mProStaticInfo.split(",");
            mIpAddress = mStaticInfo[0];
            mNetmask =  Integer.parseInt(mStaticInfo[1]);
/*          if(!TextUtils.isEmpty(mStaticInfo[2]) && !TextUtils.isEmpty(mStaticInfo[3])) {
                mGateway = mStaticInfo[2];
                mDns1 = mStaticInfo[3];
            }
            if(!TextUtils.isEmpty(mStaticInfo[4]))
                mDns2 = mStaticInfo[4];
*/      }

        Inet4Address inetAddr = getIPv4Address(mIpAddress);
        int prefixLength = mNetmask;
//      InetAddress gatewayAddr =getIPv4Address(mGateway); 
//      InetAddress dnsAddr = getIPv4Address(mDns1);

        mStaticIpConfiguration.ipAddress = new LinkAddress(inetAddr, prefixLength);
        // eth1 used in LAN, not need gateway dns
/*
        mStaticIpConfiguration.gateway=gatewayAddr;
        mStaticIpConfiguration.dnsServers.add(dnsAddr);
        mStaticIpConfiguration.dnsServers.add(getIPv4Address(mDns2));
*/
    }

    private boolean setStaticIpAddress(StaticIpConfiguration staticConfig) {
        if (DBG) Log.d(TAG, "setStaticIpAddress:" + staticConfig);
        if (staticConfig.ipAddress != null ) {
            mIpConfiguration.setIpAssignment(IpConfiguration.IpAssignment.STATIC);
            mIpConfiguration.setStaticIpConfiguration(staticConfig);
            startDhcp(mIface, mIpConfiguration);
            return true;
        } else {
            Log.e(TAG, "Invalid static IP configuration.");
        }
            return false;
    }

    private void startDhcpServer() {
        if (DBG) Log.d(TAG, "startDhcpServer");
        String startIp = SystemProperties.get("persist.dhcpserver.start", "192.168.1.150");
        String endIp = SystemProperties.get("persist.dhcpserver.end", "192.168.1.250");
        String[] dhcpRange = {startIp, endIp};
        try {
            mNMService.tetherInterface(mIface);
            mNMService.startTethering(dhcpRange);
        } catch (Exception e) {
            Log.e(TAG, "Error tether interface " + mIface + ": " + e);
        }          
    }

    private void stopDhcpServer() {
        if (DBG) Log.d(TAG, "stopDhcpServer");
        try {
            mNMService.stopTethering();
        } catch (Exception e) {
            Log.e(TAG, "Error tether stop interface " + mIface + ": " + e);
        }
            
    }

    private void connect() {
    Thread connectThread = new Thread(new Runnable() {
        public void run() {
            if (mConnectState == 1) {
                Log.d(TAG, "already connected, skip");
                return;
            }
            mConnectState = 2;
            mMode = SystemProperties.get("persist.net.eth1.mode", "1");
            if (mMode.equals("0")) { // DHCP
                mIpConfiguration.setIpAssignment(IpConfiguration.IpAssignment.DHCP);
                if (!startDhcp(mIface, mIpConfiguration)) {
                    Log.e(TAG, "startDhcp failed for " + mIface);
                    mConnectState = 0;
                    return;
                }
                Log.d(TAG, "startDhcp success for " + mIface);
            } else { // Static
                setStaticIpConfiguration();
                if (!setStaticIpAddress(mStaticIpConfiguration)) {
                    // We've already logged an error.
                    if (DBG) Log.i(TAG, "setStaticIpAddress error,set again");
                    try {
                        Thread.sleep(200);    
                    } catch (InterruptedException e) {
                        e.printStackTrace();
                    }
                    if (!setStaticIpAddress(mStaticIpConfiguration)) {
                        mConnectState = 0;
                        return;
                    }
                }
                mLinkProperties = mStaticIpConfiguration.toLinkProperties(mIface);

                //add dhcpserver
                if (SystemProperties.get("persist.dhcpserver.enable", "0").equals("1")) {
                    startDhcpServer();
                }
            }
            mConnectState = 1;
        }
    });
    connectThread.start();
    }

    private void disconnect() {
        Thread disconnectThread = new Thread(new Runnable() {
            public void run() {
            if (mConnectState == 0) {
                Log.d(TAG, "already disconnected, skip");
                return;
            }
            mMode = SystemProperties.get("persist.net.eth1.mode", "0");
            if (mMode.equals("0")) { // DHCP
                stopDhcp(mIface);
            } else {
                if (SystemProperties.get("persist.dhcpserver.enable", "0").equals("1")) {
                    stopDhcpServer();
                }
            }
            try {
                mNMService.clearInterfaceAddresses(mIface);
            } catch (Exception e) {
                Log.e(TAG, "Failed to clear addresses " + e);
            }
            removeToLocalNetwork(mIface);
            mLinkProperties = null;
            mConnectState = 0;
        }
    });
    disconnectThread.start();
    }    

    public void interfaceAdded(String iface) {
        Log.d(TAG, "interfaceAdded: iface = " + iface);
        if (!mIface.equals(iface))
            return;
        setInterfaceUp(mIface);
        mLinkUp = false;
    }

    public void interfaceRemoved(String iface) {
        Log.d(TAG, "interfaceRemoved: iface = " + iface);
        if (!mIface.equals(iface))
            return;
        mLinkUp = false;
        mHandler.removeMessages(EVENT_INTERFACE_LINK_STATE_CHANGED);
        disconnect();
    }

    private Inet4Address getIPv4Address(String text) {
        try {
            return (Inet4Address) NetworkUtils.numericToInetAddress(text);
        } catch (IllegalArgumentException|ClassCastException e) {
            return null;
        }
    }

     public String getGateway() {
        for (RouteInfo route : mLinkProperties.getRoutes()) {
            if (route.hasGateway()) {
                InetAddress gateway = route.getGateway();
                if (route.isIPv4Default()) {
                    return gateway.getHostAddress();
                }
            }
        }
        return "";
    }

}

