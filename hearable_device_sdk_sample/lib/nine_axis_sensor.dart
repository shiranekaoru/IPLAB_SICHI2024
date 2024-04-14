import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:hearable_device_sdk_sample_plugin/hearable_device_sdk_sample_plugin.dart';
import 'dart:math' as math;

class NineAxisSensor extends ChangeNotifier {
  final HearableDeviceSdkSamplePlugin _samplePlugin =
      HearableDeviceSdkSamplePlugin();
  bool isEnabled = false;

  int? _resultCode;
  Uint8List? _data;

  static final NineAxisSensor _instance = NineAxisSensor._internal();

  factory NineAxisSensor() {
    return _instance;
  }

  NineAxisSensor._internal();

  int? get resultCode => _resultCode;
  Uint8List? get data => _data;

  double peopleX = 0.0;
  double speed = 0;
  double peopleAcceleration = 0;
  double trainAcceleration = 0;

  void foo(){}

  // test
  int moveRandom(){
    int ans = math.Random().nextInt(3) - 1; // -1,0,1で動く
    return ans;
  }

  void updatePeopleAcceleration() {
    int gyroscopeY = getGyroscopeY();
    if (gyroscopeY.abs() < 50){
      gyroscopeY = 0;
    }
    peopleAcceleration = -getGyroscopeY().toDouble() / 200.0;
  }

  void updateSpeed() {
    speed += peopleAcceleration;
    speed += trainAcceleration;
    trainAcceleration = 0;

    speed /= 1.02;
  }

  void updatePeopleX() {
    peopleX += speed;
  }

  int getRandomNum() {
    //ランダム変数生成
    var random = math.Random();
    int randomNumber = random.nextInt(5) + 1; // 0から4の範囲で乱数を生成
    //print(randomNumber);
    return randomNumber;
  }

  double testHandler() {
    updatePeopleAcceleration();
    updateSpeed();
    updatePeopleX();
    return peopleX;
  }

  int getAccelerationX(){
    // x軸の加速度
    int offset = 5;
    String str = '';  // 結果用の変数
    if (_data != null) {
      Uint8List data = _data!;
      str +=
        '${data[offset].toRadixString(16)}${data[offset].toRadixString(16)}';
      int decimalValue = int.parse(str, radix: 16); //　16進数を10進数にしてintに変換
      if (decimalValue > 23767) {
        decimalValue -= 65536;
      }
      return decimalValue;
    } else {
      return 0;
    }
  }
  int getAccelerationY(){
    // y軸の加速度
    int offset = 7;
    String str = '';  // 結果用の変数
    if (_data != null) {
      Uint8List data = _data!;
      str +=
        '${data[offset].toRadixString(16)}${data[offset].toRadixString(16)}';
      int decimalValue = int.parse(str, radix: 16); //　16進数を10進数にしてintに変換
      if (decimalValue > 23767) {
        decimalValue -= 65536;
      }
      return decimalValue;
    } else {
      return 0;
    }
  }
  int getAccelerationZ(){
    // z軸の加速度
    int offset = 9;
    String str = '';  // 結果用の変数
    if (_data != null) {
      Uint8List data = _data!;
      str +=
        '${data[offset].toRadixString(16)}${data[offset].toRadixString(16)}';
      int decimalValue = int.parse(str, radix: 16); //　16進数を10進数にしてintに変換
      if (decimalValue > 23767) {
        decimalValue -= 65536;
      }
      return decimalValue;
    } else {
      return 0;
    }
  }
  int getGyroscopeX(){
    // x軸の角速度
    int offset = 11;
    String str = '';  // 結果用の変数
    if (_data != null) {
      Uint8List data = _data!;
      str +=
        '${data[offset].toRadixString(16)}${data[offset].toRadixString(16)}';
      int decimalValue = int.parse(str, radix: 16); //　16進数を10進数にしてintに変換
      if (decimalValue > 23767) {
        decimalValue -= 65536;
      }
      return decimalValue;
    } else {
      return 0;
    }
  }
  int getGyroscopeY(){
    // y軸の角速度
    int offset = 13;
    String str = '';  // 結果用の変数
    if (_data != null) {
      Uint8List data = _data!;
      str +=
        '${data[offset].toRadixString(16)}${data[offset].toRadixString(16)}';
      int decimalValue = int.parse(str, radix: 16); //　16進数を10進数にしてintに変換
      if (decimalValue > 23767) {
        decimalValue = (decimalValue - 65536) ~/ 14;
      }

      return decimalValue;
    } else {
      return 0;
    }
  }
  int getGyroscopeZ(){
    // z軸の角速度
    int offset = 15;
    String str = '';  // 結果用の変数
    if (_data != null) {
      Uint8List data = _data!;
      str +=
        '${data[offset].toRadixString(16)}${data[offset].toRadixString(16)}';
      int decimalValue = int.parse(str, radix: 16); //　16進数を10進数にしてintに変換
      if (decimalValue > 23767) {
        decimalValue -= 65536;
      }
      return decimalValue;
    } else {
      return 0;
    }
  }
  int getMagneticX(){
    // x軸の地磁気
    int offset = 17;
    String str = '';  // 結果用の変数
    if (_data != null) {
      Uint8List data = _data!;
      str +=
        '${data[offset].toRadixString(16)}${data[offset].toRadixString(16)}';
      int decimalValue = int.parse(str, radix: 16); //　16進数を10進数にしてintに変換
      if (decimalValue > 23767) {
        decimalValue -= 65536;
      }
      return decimalValue;
    } else {
      return 0;
    }
  }
  int getMagneticY(){
    // y軸の地磁気
    int offset = 19;
    String str = '';  // 結果用の変数
    if (_data != null) {
      Uint8List data = _data!;
      str +=
        '${data[offset].toRadixString(16)}${data[offset].toRadixString(16)}';
      int decimalValue = int.parse(str, radix: 16); //　16進数を10進数にしてintに変換
      if (decimalValue > 23767) {
        decimalValue -= 65536;
      }
      return decimalValue;
    } else {
      return 0;
    }
  }
  int getMagneticZ(){
    // z軸の地磁気
    int offset = 21;
    String str = '';  // 結果用の変数
    if (_data != null) {
      Uint8List data = _data!;
      str +=
        '${data[offset].toRadixString(16)}${data[offset].toRadixString(16)}';
      int decimalValue = int.parse(str, radix: 16); //　16進数を10進数にしてintに変換
      if (decimalValue > 23767) {
        decimalValue -= 65536;
      }
      return decimalValue;
    } else {
      return 0;
    }
  }

  String getResultString() {
    String str = '';
    //9軸センサの加速度情報をX,Y,Z軸に分離して表示する準備
    int accXoffset = 5;
    int accYoffset = 7;
    int accZoffset = 9;
    int gyrXoffset = 11;
    int gyrYoffset = 13;
    int gyrZoffset = 15;
    int magXoffset = 17;
    int magYoffset = 19;
    int magZoffset = 21;
    String accX = "";
    String accY = "";
    String accZ = "";
    String gyrX = "";
    String gyrY = "";
    String gyrZ = "";
    String magX = "";
    String magY = "";
    String magZ = "";

    /*サンプルアプリのオリジナルソースコード
    if (_resultCode != null) {
      str += 'result code: $_resultCode';
    }

    if (_data != null) {
      str += '\nbyte[]:\n';
      Uint8List data = _data!;
      for (int i = 0; i < data.length - 1; i++) {
        str += '${data[i].toRadixString(16)}, ';
      }
      str += data.last.toRadixString(16);
    }*/

    //9時センサの加速度、角速度、地磁気情報をX,Y,Z軸に分離する処理
    if (_data != null) {
      Uint8List data = _data!;
      for (int i = 0; i < 5; i++) {
        accX +=
            '${data[accXoffset + (i * 22)].toRadixString(16)}${data[accXoffset + 1 + (i * 22)].toRadixString(16)}';
        accY +=
            '${data[accYoffset + (i * 22)].toRadixString(16)}${data[accYoffset + 1 + (i * 22)].toRadixString(16)}';
        accZ +=
            '${data[accZoffset + (i * 22)].toRadixString(16)}${data[accZoffset + 1 + (i * 22)].toRadixString(16)}';
        gyrX +=
            '${data[gyrXoffset + (i * 22)].toRadixString(16)}${data[gyrXoffset + 1 + (i * 22)].toRadixString(16)}';
        gyrY +=
            '${data[gyrYoffset + (i * 22)].toRadixString(16)}${data[gyrYoffset + 1 + (i * 22)].toRadixString(16)}';
        gyrZ +=
            '${data[gyrZoffset + (i * 22)].toRadixString(16)}${data[gyrZoffset + 1 + (i * 22)].toRadixString(16)}';
        magX +=
            '${data[magXoffset + (i * 22)].toRadixString(16)}${data[magXoffset + 1 + (i * 22)].toRadixString(16)}';
        magY +=
            '${data[magYoffset + (i * 22)].toRadixString(16)}${data[magYoffset + 1 + (i * 22)].toRadixString(16)}';
        magZ +=
            '${data[gyrZoffset + (i * 22)].toRadixString(16)}${data[magZoffset + 1 + (i * 22)].toRadixString(16)}';
        if (i != 4) {
          accX += ',';
          accY += ',';
          accZ += ',';
          gyrX += ',';
          gyrY += ',';
          gyrZ += ',';
          magX += ',';
          magY += ',';
          magZ += ',';
        }
      }
      str += 'accX:' +
          accX +
          '\n' +
          'accY:' +
          accY +
          '\n' +
          'accZ:' +
          accZ +
          '\n' +
          'gyrX:' +
          gyrX +
          '\n' +
          'gyrY:' +
          gyrY +
          '\n' +
          'gyrZ:' +
          gyrZ +
          '\n' +
          'magX:' +
          magX +
          '\n' +
          'magY:' +
          magY +
          '\n' +
          'magZ:' +
          magZ;
    }
    return str;
  }

  Future<bool> addNineAxisSensorNotificationListener() async {
    final res = await _samplePlugin.addNineAxisSensorNotificationListener(
        onStartNotification: _onStartNotification,
        onStopNotification: _onStopNotification,
        onReceiveNotification: _onReceiveNotification);
    return res;
  }

  void _removeNineAxisSensorNotificationListener() {
    _samplePlugin.removeNineAxisSensorNotificationListener();
  }

  void _onStartNotification(int resultCode) {
    _resultCode = resultCode;
    notifyListeners();
  }

  void _onStopNotification(int resultCode) {
    _removeNineAxisSensorNotificationListener();
    _resultCode = resultCode;
    notifyListeners();
  }

  void _onReceiveNotification(Uint8List? data, int resultCode) {
    _data = data;
    _resultCode = resultCode;
    notifyListeners();
  }
}
