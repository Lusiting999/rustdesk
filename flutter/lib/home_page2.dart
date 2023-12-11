import 'dart:convert';

import 'package:flutter/material.dart';

import 'models/native_model.dart';
import 'models/platform_model.dart';
import 'models/server_model.dart';

class HomePage2 extends StatefulWidget {
  HomePage2();

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage2> {
  final List<Client> _clients = [];

  String statusStr = 'Init...';

  // am start com.carriez.flutter_hbb/.MainActivity --es serverUrl remote.skywayplatform.com:21116 --es serverKey 67Wh8GdegxRvaai2KcCgOj8DpziuOGeB8IbRanhkVFE=
  // am start com.carriez.flutter_hbb/.MainActivity --es serverUrl asdfasfd --es serverKey asdfasdfsa
  @override
  void initState() {
    super.initState();
    PlatformFFI.setListener((evt) {
      try {
        var name = evt['name'];
        print('Sting goAutoCheck name:$name');
        if (name == 'add_connection') {
          final client = Client.fromJson(jsonDecode(evt["client"]));
          statusStr = 'Client Connected...';
          if (mounted) setState(() {});
          print('Sting goAutoCheck cmLoginRes client.id:${client.id}');
          bind.cmLoginRes(connId: client.id, res: true);
          if (!client.isFileTransfer) {
            print('Sting goAutoCheck start_capture');
            PlatformFFI.toAndroidChannel.invokeMethod("start_capture");
          }
          PlatformFFI.toAndroidChannel.invokeMethod("cancel_notification", client.id);
        } else if (name == 'chat_server_mode') {
          print('Sting event go');
          var text = evt['text'];
          int keyCode = -1;
          if (text is String) {
            keyCode = json.decode(text)['keyCode'] ?? -1;
          } else {
            keyCode = text['keyCode'] ?? -1;
          }
          if (keyCode != -1) {
            print('Sting event send key $keyCode');
            PlatformFFI.toAndroidChannel.invokeMethod("send_key", keyCode);
          } else {
            print('Sting event send key error!!!');
          }
        }
      } catch (e) {}
    });
    loadData();
  }

  void loadData() async {
    try {
      await Future.delayed(Duration(milliseconds: 500));
      String initConfig = await PlatformFFI.toAndroidChannel.invokeMethod('get_config');
      print('Sting initConfig:$initConfig');
      var configs = json.decode(initConfig);
      String serverUrl = configs['serverUrl'] ?? '';
      String serverKey = configs['serverKey'] ?? '';
      if (serverUrl.isEmpty || serverKey.isEmpty) {
        statusStr = 'Init Config Error...';
        setState(() {});
        return;
      } else {
        bind.mainSetOption(key: "custom-rendezvous-server", value: serverUrl);
        bind.mainSetOption(key: "key", value: serverKey);
      }
      // 初始化配置
      // Map<String, dynamic> oldOptions = jsonDecode(await bind.mainGetOptions());
      // print('Sting oldOptions:$oldOptions');
      // //String id0 = oldOptions['custom-rendezvous-server'] ?? "";
      // //String relay0 = oldOptions['relay-server'] ?? "";
      // String idServer = oldOptions['custom-rendezvous-server'] ?? "";
      // if (idServer.isEmpty) {
      //   bind.mainSetOption(key: "custom-rendezvous-server", value: 'remote.skywayplatform.com:21116');
      // }
      // String keyValue = oldOptions['key'] ?? "";
      // if (keyValue.isEmpty) {
      //   bind.mainSetOption(key: "key", value: '67Wh8GdegxRvaai2KcCgOj8DpziuOGeB8IbRanhkVFE=');
      // }
      statusStr = 'Init Config...';
      setState(() {});
      // 启动服务
      await startService();

      // 都准备好了自动退到后台
      await Future.delayed(Duration(milliseconds: 2000));
      // await PlatformFFI.toAndroidChannel.invokeMethod("moveTaskToBack");
    } catch (e) {
      statusStr = 'Init Config Error!!!';
      setState(() {});
    }
  }

  /// Start the screen sharing service.
  Future<Null> startService() async {
    try {
      statusStr = 'Init Service...';
      setState(() {});
      await PlatformFFI.toAndroidChannel.invokeMethod("init_service");
      await bind.mainStartService();
      await Future.delayed(Duration(milliseconds: 2000));
      // await bind.mainChangeId(newId: 'A123456789');
      // await Future.delayed(Duration(milliseconds: 500));
      statusStr = 'Init ID and Password...';
      setState(() {});
      final id = await bind.mainGetMyId();
      // final temporaryPassword = await bind.mainGetTemporaryPassword();
      //final pw = await bind.mainGetPermanentPassword();
      await bind.mainSetPermanentPassword(password: 'abc123');
      await Future.delayed(Duration(milliseconds: 2000));
      final pw = await bind.mainGetPermanentPassword();
      print('Sting go new id:$id pw:$pw');
      await PlatformFFI.toAndroidChannel.invokeMethod("send_broadcast", "$id,$pw");
      statusStr = 'Init success...';
      setState(() {});
      // await updateClientState();
    } catch (e) {
      statusStr = 'Init Service Error!!!';
      setState(() {});
    }
    // Wakelock.enable();
  }

  // force
  // updateClientState([String? json]) async {
  //   try {
  //     var res = await bind.cmGetClientsState();
  //     statusStr = 'Get Clients...';
  //     setState(() {});
  //     await Future.delayed(Duration(milliseconds: 1000));
  //     print('Sting cmGetClientsState res:$res');
  //     final List clientsJson = jsonDecode(res);
  //     _clients.clear();
  //     for (var clientJson in clientsJson) {
  //       final client = Client.fromJson(clientJson);
  //       _clients.add(client);
  //     }
  //     print('Sting cmGetClientsState _clients:$_clients');
  //     if (_clients.isNotEmpty) {
  //       Client client = _clients[0];
  //       statusStr = 'Login Client...';
  //       setState(() {});
  //       bind.cmLoginRes(connId: client.id, res: true);
  //     }
  //     print('Sting cmGetClientsState success');
  //     setState(() {});
  //   } catch (e) {
  //     await Future.delayed(Duration(milliseconds: 1000));
  //     statusStr = 'Get Clients Error!!!';
  //     setState(() {});
  //     // debugPrint("Failed to updateClientState:$e");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: null,
        body: Container(
          width: double.maxFinite,
          height: double.infinity,
          color: Colors.white,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Status: $statusStr',
                style: TextStyle(fontSize: 20, color: Colors.black),
              )
            ],
          ),
        ),
      ),
    );
  }
}
