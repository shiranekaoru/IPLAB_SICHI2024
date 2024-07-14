// import 'dart:ffi';
// import 'dart:typed_data';

// import 'package:flutter/foundation.dart';
// import 'package:flutter/rendering.dart';
// import 'package:hearable_device_sdk_sample_plugin/hearable_device_sdk_sample_plugin.dart';
// import 'dart:math' as math;
// import 'package:vector_math/vector_math_64.dart' as vector_math;



import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:hearable_device_sdk_sample_plugin/hearable_device_sdk_sample_plugin.dart';
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' as vector_math;
import 'package:hearable_device_sdk_sample/KF.dart';

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

  double filteringValue = 0.05;
  vector_math.Vector3 _previousAcceleration = vector_math.Vector3.zero();
  vector_math.Vector3 _lowPassFilteredAcceleration = vector_math.Vector3.zero();
  //カルマンフィルタ
  vector_math.Vector3 _x = vector_math.Vector3.zero(); //求めたい値（オイラー角）
  vector_math.Matrix3 _v = vector_math.Matrix3.identity();
  
  vector_math.Vector3? _x_h; //状態予測モデル
  vector_math.Vector3? _x_t; //状態観測モデル
  double dt = 0.02; //時間間隔
  vector_math.Matrix3 _q = vector_math.Matrix3(1.0/100.0, 0, 0, 0, 1.0/100.0, 0, 0, 0, 1.0/100.0);
  vector_math.Matrix3 _r = vector_math.Matrix3(1.0/10.0, 0, 0, 0, 1.0/10.0, 0, 0, 0, 1.0/10.0);
  vector_math.Matrix3? _a;
  vector_math.Matrix3? _c;
  double _roll = 0.0;
  double _pitch = 0.0;

  final EKF ekf = EKF();


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

  int getAccelerationsX(int i){
    // x軸の加速度
    int offset = 5;
    String str = '';  // 結果用の変数
    
    Uint8List data = _data!;
    str +=
      '${data[offset + (i * 22)].toRadixString(16)}${data[offset + 1 + (i * 22)].toRadixString(16)}';
    int decimalValue = int.parse(str, radix: 16); //　16進数を10進数にしてintに変換
    if (decimalValue > 23767) {
      decimalValue -= 65536;
    }
    return decimalValue;
    
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

  int getAccelerationsY(int i){
    // y軸の加速度
    int offset = 7;
    String str = '';  // 結果用の変数
   
    Uint8List data = _data!;
    str +=
      '${data[offset + (i * 22)].toRadixString(16)}${data[offset + 1 + (i * 22)].toRadixString(16)}';
    int decimalValue = int.parse(str, radix: 16); //　16進数を10進数にしてintに変換
    if (decimalValue > 23767) {
      decimalValue -= 65536;
    }
    return decimalValue;
    
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

  int getAccelerationsZ(int i){
    // y軸の加速度
    int offset = 9;
    String str = '';  // 結果用の変数
    
    Uint8List data = _data!;
    str +=
      '${data[offset + (i * 22)].toRadixString(16)}${data[offset + 1 + (i * 22)].toRadixString(16)}';
    int decimalValue = int.parse(str, radix: 16); //　16進数を10進数にしてintに変換
    if (decimalValue > 23767) {
      decimalValue -= 65536;
    }
    return decimalValue;
    
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
  int getGyroScopesX(int i){
    // y軸の加速度
    int offset = 11;
    String str = '';  // 結果用の変数

    Uint8List data = _data!;
    str +=
      '${data[offset + (i * 22)].toRadixString(16)}${data[offset + 1 + (i * 22)].toRadixString(16)}';
    int decimalValue = int.parse(str, radix: 16); //　16進数を10進数にしてintに変換
    if (decimalValue > 23767) {
      decimalValue -= 65536;
    }
    return decimalValue;
    
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
  int getGyroScopesY(int i){
    // y軸の加速度
    int offset = 13;
    String str = '';  // 結果用の変数
      
    Uint8List data = _data!;
    str +=
      '${data[offset + (i * 22)].toRadixString(16)}${data[offset + 1 + (i * 22)].toRadixString(16)}';
    int decimalValue = int.parse(str, radix: 16); //　16進数を10進数にしてintに変換
    if (decimalValue > 23767) {
      decimalValue -= 65536;
    }
    return decimalValue;
    
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

  int getGyroScopesZ(int i){
    // y軸の加速度
    int offset = 15;
    String str = '';  // 結果用の変数
      
    Uint8List data = _data!;
    str +=
      '${data[offset + (i * 22)].toRadixString(16)}${data[offset + 1 + (i * 22)].toRadixString(16)}';
    int decimalValue = int.parse(str, radix: 16); //　16進数を10進数にしてintに変換
    if (decimalValue > 23767) {
      decimalValue -= 65536;
    }
    return decimalValue;
    
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

  int getMagneticsX(int i){
    // y軸の加速度
    int offset = 17;
    String str = '';  // 結果用の変数
      
    Uint8List data = _data!;
    str +=
      '${data[offset + (i * 22)].toRadixString(16)}${data[offset + 1 + (i * 22)].toRadixString(16)}';
    int decimalValue = int.parse(str, radix: 16); //　16進数を10進数にしてintに変換
    if (decimalValue > 23767) {
      decimalValue -= 65536;
    }
    return decimalValue;
    
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

  int getMagneticsY(int i){
    // y軸の加速度
    int offset = 19;
    String str = '';  // 結果用の変数
      
    Uint8List data = _data!;
    str +=
      '${data[offset + (i * 22)].toRadixString(16)}${data[offset + 1 + (i * 22)].toRadixString(16)}';
    int decimalValue = int.parse(str, radix: 16); //　16進数を10進数にしてintに変換
    if (decimalValue > 23767) {
      decimalValue -= 65536;
    }
    return decimalValue;
    
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

  int getMagneticsZ(int i){
    // y軸の加速度
    int offset = 21;
    String str = '';  // 結果用の変数
      
    Uint8List data = _data!;
    str +=
      '${data[offset + (i * 22)].toRadixString(16)}${data[offset + 1 + (i * 22)].toRadixString(16)}';
    int decimalValue = int.parse(str, radix: 16); //　16進数を10進数にしてintに変換
    if (decimalValue > 23767) {
      decimalValue -= 65536;
    }
    return decimalValue;
    
  }

  void CalcRollPitch(){
    if (_data != null) {
      Uint8List data = _data!;
      


      for (int i = 0; i < 5; i++) {
        vector_math.Vector3 currentAcceleration = vector_math.Vector3(
          getAccelerationsX(i).toDouble() / 4096.0,
          getAccelerationsY(i).toDouble() / 4096.0,
          getAccelerationsZ(i).toDouble() / 4096.0,          
        );
        


        // vector_math.Vector3 highPassFilteredAcceleration = updateAcceleration(currentAcceleration);
        _roll = math.atan(currentAcceleration.y/currentAcceleration.z);
        _pitch = math.atan(-currentAcceleration.x / math.sqrt(math.pow(currentAcceleration.y,2)+math.pow(currentAcceleration.z,2)));
    
      }
    }
  }

  double getRoll(){
    CalcRollPitch();
    return _roll * 180.0 / math.pi;
  }

  double getPitch(){
    CalcRollPitch();
    return _pitch * 180.0 / math.pi;
  }
  // 加速度データの更新関数
  vector_math.Vector3 updateAcceleration(vector_math.Vector3 currentAcceleration) {
    // ローパスフィルタで重力成分を抽出
    _lowPassFilteredAcceleration = vector_math.Vector3(
      filteringValue * currentAcceleration.x + (1 - filteringValue) * _lowPassFilteredAcceleration.x,
      filteringValue * currentAcceleration.y + (1 - filteringValue) * _lowPassFilteredAcceleration.y,
      filteringValue * currentAcceleration.z + (1 - filteringValue) * _lowPassFilteredAcceleration.z,
    );

    // ハイパスフィルタで重力成分を除去
    vector_math.Vector3 highPassFilteredAcceleration = vector_math.Vector3(
      currentAcceleration.x - _lowPassFilteredAcceleration.x,
      currentAcceleration.y - _lowPassFilteredAcceleration.y,
      currentAcceleration.z - _lowPassFilteredAcceleration.z,
    );

    _previousAcceleration = currentAcceleration;
    // フィルタ後の加速度データを返す
    return highPassFilteredAcceleration;
  }

  vector_math.Vector3 calcStatePredictionModel(vector_math.Vector3 gyro){
    vector_math.Vector3 res = vector_math.Vector3(
        _x.x + (gyro.x + gyro.y * math.tan(_x.y)*math.sin(_x.x) + gyro.z * math.tan(_x.y) * math.cos(_x.x)) * dt,
        _x.y + (gyro.y * math.cos(_x.x) - gyro.z * math.sin(_x.x)) * dt,
        _x.z + (gyro.y * (math.sin(_x.x)/math.cos(_x.y)) + gyro.z * (math.cos(_x.x)/math.cos(_x.y))) * dt,
    );
    return res;
  }

  
  vector_math.Vector3 calcStateObservationModel(vector_math.Vector3 acce, vector_math.Vector3 mag){
    double theta_x = math.atan(-acce.y/-acce.z);
    double theta_y = math.atan(acce.x/math.sqrt(math.pow(acce.x,2) + math.pow(acce.z,2)));
    vector_math.Vector3 res = vector_math.Vector3(
        theta_x,
        theta_y,
        math.atan((mag.x * math.cos(theta_y) + mag.y * math.sin(theta_y) * math.sin(theta_x) + mag.z * math.sin(theta_y) * math.cos(theta_x)) / (mag.y * math.cos(theta_x) - mag.z * math.cos(theta_x))),
    );
    return res;
  }

  vector_math.Matrix3 calcPredictionJacobian(vector_math.Vector3 gyro){
    vector_math.Matrix3 res = vector_math.Matrix3(
        //一行目
        1 + (gyro.x + gyro.y * math.tan(_x.y)*math.sin(_x.x) + gyro.z * math.tan(_x.y) * math.cos(_x.x)) * dt,
        (gyro.y * (math.sin(_x.x)/math.pow(math.cos(_x.y),2)) + gyro.z * (math.cos(_x.x)/math.pow(math.cos(_x.y),2))) * dt,
        0,
        //二行目
        (-gyro.y * math.sin(_x.x) - gyro.z * math.cos(_x.x)) * dt,
        1,
        0,
        //三行目
        (gyro.y * (math.cos(_x.x)/math.cos(_x.y)) - gyro.z * (math.sin(_x.x)/math.cos(_x.y))) * dt,
        (gyro.y * (math.sin(_x.x)* math.sin(_x.y)/math.pow(math.cos(_x.y),2)) + gyro.z * (math.cos(_x.x) * math.sin(_x.y)/math.pow(math.cos(_x.y),2))) * dt,
        1,
    );
    return res;
  }

  vector_math.Matrix3 calcObservationJacobian(){
    vector_math.Matrix3 res = vector_math.Matrix3.identity();
    return res;
  }

  

  String getResultString() {
    String str = '';
    //9軸センサの加速度情報をX,Y,Z軸に分離して表示する準備
    
    // int gyrXoffset = 11;
    // int gyrYoffset = 13;
    // int gyrZoffset = 15;
    // int magXoffset = 17;
    // int magYoffset = 19;
    // int magZoffset = 21;
    // String accX = "";
    // String accY = "";
    // String accZ = "";
    // String gyrX = "";
    // String gyrY = "";
    // String gyrZ = "";
    // String magX = "";
    // String magY = "";
    // String magZ = "";
    String theta_x = "";
    String theta_y = "";
    String theta_z = "";
    

    //9時センサの加速度、角速度、地磁気情報をX,Y,Z軸に分離する処理
    if (_data != null) {
      Uint8List data = _data!;
      


      for (int i = 0; i < 5; i++) {
        vector_math.Vector3 currentAcceleration = vector_math.Vector3(
          getAccelerationsX(i).toDouble() / 4096.0,
          getAccelerationsY(i).toDouble() / 4096.0,
          getAccelerationsZ(i).toDouble() / 4096.0,          
        );
        vector_math.Vector3 currentGyroScope = vector_math.Vector3(
          getGyroScopesX(i).toDouble() / 16383.0,
          getGyroScopesY(i).toDouble() / 16383.0,
          getGyroScopesZ(i).toDouble() / 16383.0,          
        );
        vector_math.Vector3 currentMagnetic = vector_math.Vector3(
          getMagneticsX(i).toDouble() / 0.149975574,
          getMagneticsY(i).toDouble() / 0.149975574,
          getMagneticsZ(i).toDouble() / 0.149975574,          
        );

        vector_math.Matrix3 zMeasured = vector_math.Matrix3.columns(
          currentAcceleration,
          currentGyroScope,
          currentMagnetic,
        );

        ekf.applyEKF(zMeasured);
        
        // vector_math.Vector3 highPassFilteredAcceleration = updateAcceleration(currentAcceleration);
        // _x_h = calcStatePredictionModel(currentGyroScope);
        // _x_t = calcStateObservationModel(currentAcceleration, currentMagnetic);
        // // _a = calcPredictionJacobian(currentGyroScope);
        // // _c = calcObservationJacobian();
        // vector_math.Matrix3 v_q = calcPredictionJacobian(currentGyroScope) * _v * calcPredictionJacobian(currentGyroScope).transposed() + _q;
        // vector_math.Matrix3 v_r = calcObservationJacobian() * v_q * calcObservationJacobian().transposed() + _r;
        // vector_math.Matrix3 v_r_i = v_r.clone();
        // v_r_i.invert();
        // vector_math.Matrix3 k = v_q * calcObservationJacobian().transposed() * v_r_i;
        // _x = _x_h! + k * (_x_t! - calcObservationJacobian() * _x_h);
        // _v = (vector_math.Matrix3.identity() - k * calcObservationJacobian()) * v_q;
       
        

        theta_x =
            // '${data[accXoffset + (i * 22)].toRadixString(16)}${data[accXoffset + 1 + (i * 22)].toRadixString(16)}';
            '${ekf.xEstimate[0] * 180.0 / math.pi}';

        theta_y =
            // '${data[accXoffset + (i * 22)].toRadixString(16)}${data[accXoffset + 1 + (i * 22)].toRadixString(16)}';
            '${ekf.xEstimate[1] * 180.0 / math.pi}';

        theta_z =
            // '${data[accXoffset + (i * 22)].toRadixString(16)}${data[accXoffset + 1 + (i * 22)].toRadixString(16)}';
            '${ekf.xEstimate[2] * 180.0 / math.pi}';
        
        
        // accX +=
        //     // '${data[accXoffset + (i * 22)].toRadixString(16)}${data[accXoffset + 1 + (i * 22)].toRadixString(16)}';
        //     '${highPassFilteredAcceleration.x}';
        // accY +=
        //     '${highPassFilteredAcceleration.y}';
        //     // '${data[accYoffset + (i * 22)].toRadixString(16)}${data[accYoffset + 1 + (i * 22)].toRadixString(16)}';
        // accZ =
        //     '${highPassFilteredAcceleration.z}';
        //     // '${data[accZoffset + (i * 22)].toRadixString(16)}${data[accZoffset + 1 + (i * 22)].toRadixString(16)}';
        // gyrX +=
        //     '${data[gyrXoffset + (i * 22)].toRadixString(16)}${data[gyrXoffset + 1 + (i * 22)].toRadixString(16)}';
        // gyrY +=
        //     '${data[gyrYoffset + (i * 22)].toRadixString(16)}${data[gyrYoffset + 1 + (i * 22)].toRadixString(16)}';
        // gyrZ +=
        //     '${data[gyrZoffset + (i * 22)].toRadixString(16)}${data[gyrZoffset + 1 + (i * 22)].toRadixString(16)}';
        // magX +=
        //     '${data[magXoffset + (i * 22)].toRadixString(16)}${data[magXoffset + 1 + (i * 22)].toRadixString(16)}';
        // magY +=
        //     '${data[magYoffset + (i * 22)].toRadixString(16)}${data[magYoffset + 1 + (i * 22)].toRadixString(16)}';
        // magZ +=
        //     '${data[gyrZoffset + (i * 22)].toRadixString(16)}${data[magZoffset + 1 + (i * 22)].toRadixString(16)}';
        if (i != 4) {
          
          // accX += ',';
          // accY += ',';
          // accZ += ',';
          // gyrX += ',';
          // gyrY += ',';
          // gyrZ += ',';
          // magX += ',';
          // magY += ',';
          // magZ += ',';
        }
      }
      str += 'Θx: ${theta_x}\nΘy: ${theta_y}\nΘz: ${theta_z}\n';
      // str += 'accX: ${accX}\naccY:${accY}\naccZ:${accZ}\ngyrX: ${gyrX} \n gyrY: ${gyrY}\ngyrZ:${gyrZ}\nmagX:${magX}\nmagY:${magY}\nmagZ:${magZ}';
    }
    return str;
  }


  String getAcceResultString(){
    String str = '';
    //9軸センサの加速度情報をX,Y,Z軸に分離して表示する準備
    
    String accX = "";
    String accY = "";
    String accZ = "";
    String roll_s = "";
    String pitch_s = "";
    //9時センサの加速度、角速度、地磁気情報をX,Y,Z軸に分離する処理
    if (_data != null) {
      Uint8List data = _data!;
      


      for (int i = 0; i < 5; i++) {
        vector_math.Vector3 currentAcceleration = vector_math.Vector3(
          getAccelerationsX(i).toDouble() / 4096.0,
          getAccelerationsY(i).toDouble() / 4096.0,
          getAccelerationsZ(i).toDouble() / 4096.0,          
        );
        


        // vector_math.Vector3 highPassFilteredAcceleration = updateAcceleration(currentAcceleration);
        double roll = math.atan(currentAcceleration.y/currentAcceleration.z);
        double pitch = math.atan(-currentAcceleration.x / math.sqrt(math.pow(currentAcceleration.y,2)+math.pow(currentAcceleration.z,2)));

        // // prez = '${_preAcceleration.z}';
        
        accX = '${currentAcceleration.x}';
        accY = '${currentAcceleration.y}';
        accZ = '${currentAcceleration.z}';
        roll_s = '${roll * 180.0 / math.pi}';
        pitch_s = '${pitch * 180.0 / math.pi}';
        //     // '${data[accXoffset + (i * 22)].toRadixString(16)}${data[accXoffset + 1 + (i * 22)].toRadixString(16)}';
        //     '${highPassFilteredAcceleration.x}';
        // accY +=
        //     '${highPassFilteredAcceleration.y}';
        //     // '${data[accYoffset + (i * 22)].toRadixString(16)}${data[accYoffset + 1 + (i * 22)].toRadixString(16)}';
        // accZ =
        //     '${highPassFilteredAcceleration.z}';
        //     // '${data[accZoffset + (i * 22)].toRadixString(16)}${data[accZoffset + 1 + (i * 22)].toRadixString(16)}';
        if (i != 4) {
          
          accX += ',';
          accY += ',';
          accZ += ',';
          
        }
      }
      str += 'pitch: ${pitch_s}\nroll: ${roll_s}';
      // str += 'X: ${accX}\nY:${accY}\nZ:${accZ}';
    }
    return str;
  }


  String getGyroResultString(){
    String str = '';
    //9軸センサの加速度情報をX,Y,Z軸に分離して表示する準備
    
    String gyrX = "";
    String gyrY = "";
    String gyrZ = "";

    //9時センサの加速度、角速度、地磁気情報をX,Y,Z軸に分離する処理
    if (_data != null) {
      Uint8List data = _data!;
      


      for (int i = 0; i < 5; i++) {
        vector_math.Vector3 currentGyroScope = vector_math.Vector3(
          getGyroScopesX(i).toDouble() / 16383.0,
          getGyroScopesY(i).toDouble() / 16383.0,
          getGyroScopesZ(i).toDouble() / 16383.0,          
        );

        

       
        // prez = '${_preAcceleration.z}';
        
        gyrX =
            // '${data[accXoffset + (i * 22)].toRadixString(16)}${data[accXoffset + 1 + (i * 22)].toRadixString(16)}';
            '${currentGyroScope.x}';
        gyrY =
            '${currentGyroScope.y}';
            // '${data[accYoffset + (i * 22)].toRadixString(16)}${data[accYoffset + 1 + (i * 22)].toRadixString(16)}';
        gyrZ =
            '${currentGyroScope.z}';
            // '${data[accZoffset + (i * 22)].toRadixString(16)}${data[accZoffset + 1 + (i * 22)].toRadixString(16)}';
        if (i != 4) {
          
          gyrX += ',';
          gyrY += ',';
          gyrZ += ',';
          
        }
      }
      str += 'X: ${gyrX}\nY:${gyrY}\nZ:${gyrZ}';
    }
    return str;
  }

  String getMagResultString(){
    String str = '';
    //9軸センサの加速度情報をX,Y,Z軸に分離して表示する準備
    
    String magX = "";
    String magY = "";
    String magZ = "";

    //9時センサの加速度、角速度、地磁気情報をX,Y,Z軸に分離する処理
    if (_data != null) {
      Uint8List data = _data!;
      


      for (int i = 0; i < 5; i++) {
        vector_math.Vector3 currentMagnetic = vector_math.Vector3(
          getMagneticsX(i).toDouble() / 0.149975574,
          getMagneticsY(i).toDouble() / 0.149975574,
          getMagneticsZ(i).toDouble() / 0.149975574,          
        );

        

       
        // prez = '${_preAcceleration.z}';
        
        magX =
            // '${data[accXoffset + (i * 22)].toRadixString(16)}${data[accXoffset + 1 + (i * 22)].toRadixString(16)}';
            '${currentMagnetic.x}';
        magY =
            '${currentMagnetic.y}';
            // '${data[accYoffset + (i * 22)].toRadixString(16)}${data[accYoffset + 1 + (i * 22)].toRadixString(16)}';
        magZ =
            '${currentMagnetic.z}';
            // '${data[accZoffset + (i * 22)].toRadixString(16)}${data[accZoffset + 1 + (i * 22)].toRadixString(16)}';
        if (i != 4) {
          
          magX += ',';
          magY += ',';
          magZ += ',';
          
        }
      }
      str += 'X: ${magX}\nY:${magY}\nZ:${magZ}';
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

