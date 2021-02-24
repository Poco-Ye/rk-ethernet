```
ppoe需要使能

--------- beginning of crash
02-20 14:21:25.381 607 2281 E AndroidRuntime: *** FATAL EXCEPTION IN SYSTEM PROCESS: Thread-18
02-20 14:21:25.381 607 2281 E AndroidRuntime: java.lang.NullPointerException: Attempt to invoke interface method 'boolean android.net.IPppoeManager.setupPppoe(java.lang.String, java.lang.String, java.lang.String, java.lang.String, java.lang.String)' on a null object reference
02-20 14:21:25.381 607 2281 E AndroidRuntime: at android.net.PppoeManager.setupPppoe(PppoeManager.java:198)
02-20 14:21:25.381 607 2281 E AndroidRuntime: at android.net.PppoeManager.connect(PppoeManager.java:295)
02-20 14:21:25.381 607 2281 E AndroidRuntime: at com.android.server.ethernet.EthernetNetworkFactory$1.run(EthernetNetworkFactory.java:485)
02-20 14:21:25.381 607 2281 E AndroidRuntime: at java.lang.Thread.run(Thread.java:761)
02-20 14:21:25.637 847 847 E AndroidRuntime: FATAL EXCEPTION: main
02-20 14:21:25.637 847 847 E AndroidRuntime: Process: com.android.settings, PID: 847
02-20 14:21:25.637 847 847 E AndroidRuntime: DeadSystemException: The system died; earlier logs will point to the root

```
