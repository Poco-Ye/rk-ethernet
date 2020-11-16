```
10.0有简略补丁但是图标改

9.0可能断线
diff --git a/frameworks/opt/net/ethernet/java/com/android/server/ethernet/EthernetNetworkFactory.java b/frameworks/opt/net/ethernet/java/com/android/server/ethernet/EthernetNetworkFactory.java
index 23086cba0b..19335b9e6a 100644
--- a/frameworks/opt/net/ethernet/java/com/android/server/ethernet/EthernetNetworkFactory.java
+++ b/frameworks/opt/net/ethernet/java/com/android/server/ethernet/EthernetNetworkFactory.java
@@ -103,14 +103,16 @@ public class EthernetNetworkFactory extends NetworkFactory {

     @Override
     protected void releaseNetworkFor(NetworkRequest networkRequest) {
+        Log.d(TAG, "=== jetway releaseNetworkFor");
         NetworkInterfaceState network = networkForRequest(networkRequest);
         if (network == null) {
             Log.e(TAG, "needNetworkFor, failed to get a network for " + networkRequest);
             return;
         }

+        Log.d(TAG, "=== jetway refCount:" + network.refCount);
         if (--network.refCount == 0) {
-            network.stop();
+            //network.stop();
         }
     }
```
