// テストにのみ使用
// ゲーム自体はstart.dart - how_to_play.dart
//                |
//                ├ normal_mode.dart ┐
//                └ hard_mode.dart   ┤
//                                   └ result.dart

import 'package:flutter/material.dart';
import 'package:hearable_device_sdk_sample/how_to_play.dart';
import 'package:hearable_device_sdk_sample/result.dart';
import 'package:hearable_device_sdk_sample/start.dart';
import 'package:hearable_device_sdk_sample/normal_mode.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

//import 'package:hearable_device_sdk_sample/size_config.dart';
//import 'package:hearable_device_sdk_sample/widget_config.dart';
import 'package:hearable_device_sdk_sample/widgets.dart';
import 'package:hearable_device_sdk_sample/alert.dart';
import 'package:hearable_device_sdk_sample/nine_axis_sensor.dart';
import 'package:hearable_device_sdk_sample/temperature.dart';
import 'package:hearable_device_sdk_sample/heart_rate.dart';
import 'package:hearable_device_sdk_sample/ppg.dart';
import 'package:hearable_device_sdk_sample/eaa.dart';
import 'package:hearable_device_sdk_sample/battery.dart';
import 'package:hearable_device_sdk_sample/config.dart';

import 'package:hearable_device_sdk_sample_plugin/hearable_device_sdk_sample_plugin.dart';

class HearableServiceView extends StatelessWidget {
  const HearableServiceView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: NineAxisSensor()),
        ChangeNotifierProvider.value(value: Temperature()),
        ChangeNotifierProvider.value(value: HeartRate()),
        ChangeNotifierProvider.value(value: Ppg()),
        ChangeNotifierProvider.value(value: Eaa()),
        ChangeNotifierProvider.value(value: Battery()),
      ],
      child: _HearableServiceView(),
    );
  }
}

class _HearableServiceView extends StatefulWidget {
  @override
  State<_HearableServiceView> createState() => _HearableServiceViewState();
}

class _HearableServiceViewState extends State<_HearableServiceView> {
  final HearableDeviceSdkSamplePlugin _samplePlugin =
      HearableDeviceSdkSamplePlugin();
  String userUuid = (Eaa().featureGetCount == 0)
      ? const Uuid().v4()
      : Eaa().registeringUserUuid;
  var selectedIndex = -1;
  var selectedUser = '';
  bool isSetEaaCallback = false;

  var config = Config();
  Eaa eaa = Eaa();

  TextEditingController featureRequiredNumController = TextEditingController();
  TextEditingController featureCountController = TextEditingController();
  TextEditingController eaaResultController = TextEditingController();

  TextEditingController nineAxisSensorResultController =
      TextEditingController();
  TextEditingController temperatureResultController = TextEditingController();
  TextEditingController heartRateResultController = TextEditingController();
  TextEditingController ppgResultController = TextEditingController();

  TextEditingController batteryIntervalController = TextEditingController();
  TextEditingController batteryResultController = TextEditingController();

  void _createUuid() {
    userUuid = const Uuid().v4();

    eaa.featureGetCount = 0;
    eaa.registeringUserUuid = userUuid;
    _samplePlugin.cancelEaaRegistration();

    setState(() {});
  }

  void _feature() async {
    eaa.registeringUserUuid = userUuid;
    _showDialog(context, '特徴量取得・登録中...');
    // 特徴量取得、登録
    if (!(await _samplePlugin.registerEaa(uuid: userUuid))) {
      Navigator.of(context).pop();
      // エラーダイアログ
      Alert.showAlert(context, 'Exception');
    }
  }

  void _deleteRegistration() async {
    _showDialog(context, '登録削除中...');
    // ユーザー削除
    if (!(await _samplePlugin.deleteSpecifiedRegistration(
        uuid: selectedUser))) {
      Navigator.of(context).pop();
      // エラーダイアログ
      Alert.showAlert(context, 'Exception');
    }
  }

  void _deleteAllRegistration() async {
    _showDialog(context, '登録削除中...');
    // ユーザー全削除
    if (!(await _samplePlugin.deleteAllRegistration())) {
      Navigator.of(context).pop();
      // エラーダイアログ
      Alert.showAlert(context, 'Exception');
    }
  }

  void _cancelRegistration() async {
    // 特徴量登録キャンセル
    if (!(await _samplePlugin.cancelEaaRegistration())) {
      // エラーダイアログ
      Alert.showAlert(context, 'IllegalStateException');
    }
  }

  void _verify() async {
    _showDialog(context, '照合中...');
    // 照合
    if (!(await _samplePlugin.verifyEaa())) {
      Navigator.of(context).pop();
      // エラーダイアログ
      Alert.showAlert(context, 'Exception');
    }
  }

  void _requestRegisterStatus() async {
    _showDialog(context, '登録状態取得中...');
    // 登録状態取得
    if (!(await _samplePlugin.requestRegisterStatus())) {
      Navigator.of(context).pop();
      // エラーダイアログ
      Alert.showAlert(context, 'Exception');
    }
  }

  void _switch9AxisSensor(bool enabled) async {
    NineAxisSensor().isEnabled = enabled;
    if (enabled) {
      // callback登録
      if (!(await NineAxisSensor().addNineAxisSensorNotificationListener())) {
        // エラーダイアログ
        Alert.showAlert(context, 'IllegalArgumentException');
        NineAxisSensor().isEnabled = !enabled;
      }
      // 取得開始
      if (!(await _samplePlugin.startNineAxisSensorNotification())) {
        // エラーダイアログ
        Alert.showAlert(context, 'IllegalStateException');
        NineAxisSensor().isEnabled = !enabled;
      }
    } else {
      // 取得終了
      if (!(await _samplePlugin.stopNineAxisSensorNotification())) {
        // エラーダイアログ
        Alert.showAlert(context, 'IllegalStateException');
        NineAxisSensor().isEnabled = !enabled;
      }
    }
    setState(() {});
  }

  void _switchTemperature(bool enabled) async {
    Temperature().isEnabled = enabled;
    if (enabled) {
      // callback登録
      if (!(await Temperature().addTemperatureNotificationListener())) {
        // エラーダイアログ
        Alert.showAlert(context, 'IllegalArgumentException');
        Temperature().isEnabled = !enabled;
      }
      // 取得開始
      if (!(await _samplePlugin.startTemperatureNotification())) {
        // エラーダイアログ
        Alert.showAlert(context, 'IllegalStateException');
        Temperature().isEnabled = !enabled;
      }
    } else {
      // 取得終了
      if (!(await _samplePlugin.stopTemperatureNotification())) {
        // エラーダイアログ
        Alert.showAlert(context, 'IllegalStateException');
        Temperature().isEnabled = !enabled;
      }
    }
    setState(() {});
  }

  void _switchHeartRate(bool enabled) async {
    HeartRate().isEnabled = enabled;
    if (enabled) {
      // callback登録
      if (!(await HeartRate().addHeartRateNotificationListener())) {
        // エラーダイアログ
        Alert.showAlert(context, 'IllegalArgumentException');
        HeartRate().isEnabled = !enabled;
      }
      // 取得開始
      if (!(await _samplePlugin.startHeartRateNotification())) {
        // エラーダイアログ
        Alert.showAlert(context, 'IllegalStateException');
        HeartRate().isEnabled = !enabled;
      }
    } else {
      // 取得終了
      if (!(await _samplePlugin.stopHeartRateNotification())) {
        // エラーダイアログ
        Alert.showAlert(context, 'IllegalStateException');
        HeartRate().isEnabled = !enabled;
      }
    }
    setState(() {});
  }

  void _switchPpg(bool enabled) async {
    Ppg().isEnabled = enabled;
    if (enabled) {
      // callback登録
      if (!(await Ppg().addPpgNotificationListener())) {
        // エラーダイアログ
        Alert.showAlert(context, 'IllegalArgumentException');
        Ppg().isEnabled = !enabled;
      }
      // 取得開始
      if (!(await _samplePlugin.startPpgNotification())) {
        // エラーダイアログ
        Alert.showAlert(context, 'IllegalStateException');
        Ppg().isEnabled = !enabled;
      }
    } else {
      // 取得終了
      if (!(await _samplePlugin.stopPpgNotification())) {
        // エラーダイアログ
        Alert.showAlert(context, 'IllegalStateException');
        Ppg().isEnabled = !enabled;
      }
    }
    setState(() {});
  }

  void _switchBattery(bool enabled) async {
    Battery().isEnabled = enabled;
    if (enabled) {
      // callback登録
      if (!(await Battery().addBatteryNotificationListener())) {
        // エラーダイアログ
        Alert.showAlert(context, 'IllegalArgumentException');
        Battery().isEnabled = !enabled;
      }
      // 取得開始
      if (!(await _samplePlugin.startBatteryNotification())) {
        // エラーダイアログ
        Alert.showAlert(context, 'IllegalStateException');
        Battery().isEnabled = !enabled;
      }
    } else {
      // 取得終了
      if (!(await _samplePlugin.stopBatteryNotification())) {
        // エラーダイアログ
        Alert.showAlert(context, 'IllegalStateException');
        Battery().isEnabled = !enabled;
      }
    }
    setState(() {});
  }

  // 選択可能なListView
  ListView _createUserListView(BuildContext context) {
    return ListView.builder(
        // 登録ユーザー数
        itemCount: eaa.uuids.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              selected: selectedIndex == index ? true : false,
              selectedTileColor: Colors.grey.withOpacity(0.3),
              title: Widgets.uuidText(eaa.uuids[index]),
              onTap: () {
                if (index == selectedIndex) {
                  _resetSelection();
                } else {
                  selectedIndex = index;
                  selectedUser = eaa.uuids[index];
                }
                setState(() {});
              },
            ),
          );
        });
  }

  void _showDialog(BuildContext context, String text) {
    showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.5),
        pageBuilder: (BuildContext context, Animation animation,
            Animation secondaryAnimation) {
          return AlertDialog(
            content: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 10),
                    Text(text)
                  ],
                )
              ],
            ),
          );
        });
  }

  void _resetSelection() {
    selectedIndex = -1;
    selectedUser = '';
  }

  void _saveInput(BuildContext context) {
    var num = featureRequiredNumController.text;
    var interval = batteryIntervalController.text;

    if (num.isNotEmpty) {
      var num0 = int.parse(num);
      if (num0 >= 10 && num0 != config.featureRequiredNumber) {
        config.featureRequiredNumber = num0;
        _samplePlugin.setHearableEaaConfig(featureRequiredNumber: num0);
      }
    }
    _setRequiredNumText();

    if (interval.isNotEmpty) {
      var interval0 = int.parse(interval);
      if (interval0 >= 10 && interval0 != config.batteryNotificationInterval) {
        config.batteryNotificationInterval = interval0;
        _samplePlugin.setBatteryNotificationInterval(interval: interval0);
      }
    }
    _setBatteryIntervalText();

    setState(() {});
    FocusScope.of(context).unfocus();
  }

  void _onSavedFeatureRequiredNum(String? numStr) {
    if (numStr != null) {
      config.featureRequiredNumber = int.parse(numStr);
      _setRequiredNumText();
    }
    setState(() {});
  }

  void _onSavedBatteryInterval(String? intervalStr) {
    if (intervalStr != null) {
      config.batteryNotificationInterval = int.parse(intervalStr);
      _setBatteryIntervalText();
    }
    setState(() {});
  }

  void _setRequiredNumText() {
    featureRequiredNumController.text = config.featureRequiredNumber.toString();
    featureRequiredNumController.selection = TextSelection.fromPosition(
        TextPosition(offset: featureRequiredNumController.text.length));
  }

  void _setBatteryIntervalText() {
    batteryIntervalController.text =
        config.batteryNotificationInterval.toString();
    batteryIntervalController.selection = TextSelection.fromPosition(
        TextPosition(offset: batteryIntervalController.text.length));
  }

  void _registerCallback() {
    Navigator.of(context).pop();
  }

  void _deleteRegistrationCallback() {
    Navigator.of(context).pop();
    _resetSelection();
  }

  void __cancelRegistrationCallback() {
    eaa.featureGetCount = 0;
    setState(() {});
  }

  void _verifyCallback() {
    Navigator.of(context).pop();
  }

  void _getRegistrationStatusCallback() {
    Navigator.of(context).pop();
    _resetSelection();
  }

  @override
  Widget build(BuildContext context) {
    _setRequiredNumText();
    _setBatteryIntervalText();

    if (!isSetEaaCallback) {
      eaa.addEaaListener(
          registerCallback: _registerCallback,
          cancelRegistrationCallback: null,
          deleteRegistrationCallback: _deleteRegistrationCallback,
          verifyCallback: _verifyCallback,
          getRegistrationStatusCallback: _getRegistrationStatusCallback);
      isSetEaaCallback = true;
    }

    return Scaffold(
      // 大元のキャンパス
      appBar: AppBar(
        // 上のヘッダー
        title: const Text('センサデータ確認', style: TextStyle(fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: GestureDetector(
        // スクロール可能なボディ
        behavior: HitTestBehavior.opaque,
        onTap: () => {
          _saveInput(context)
        }, // このウィジェット(ほぼ全体)をタッチしたとき行う。setStateがあるため、他dartからの値の更新を行う。
        child: SingleChildScrollView(
          // スクロール可能なウィジェット
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10), // 下に空白
            child: Column(
              // 列表示
              mainAxisAlignment: MainAxisAlignment.start, // 並べ方(上詰め)
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Normal_mode()));
                  },
                  child: Text('Normal Modeへ'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => HowToPlay()));
                  },
                  child: Text('How to Playへ'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Start()));
                  },
                  child: Text('Startへ'),
                ),

                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Result(100)));
                  },
                  child: Text('Resultへ'),
                ),

                const SizedBox(height: 10),
                const Text('確認したいデータをOnにしてください',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                // 9軸センサ
                const SizedBox(
                  height: 20,
                ),
                Consumer<NineAxisSensor>(
                    // 動的なウィジェットを作るのに必要
                    builder: ((context, nineAxisSensor, _) =>
                        Widgets.switchContainer(
                            // widgets.dart内のswitchContainer関数でスイッチの外形とスイッチの状態、関数を指定している
                            title: '9軸センサ',
                            enable: nineAxisSensor.isEnabled,
                            function:
                                _switch9AxisSensor))), // _switch9AxisSensorは引数のenable(ここではfuncitonから渡される)によってセンサの取得開始、終了を調整、またsetStateがあるためセンサ値が変化
                const SizedBox(height: 10),
                Consumer<NineAxisSensor>(
                    builder: ((context, nineAxisSensor, _) =>
                        Widgets.resultContainer(
                            // widgets.dartで定義されているコンテナのフォーマット(resultContainer{NONE,2})を用いる
                            verticalRatio: 40,
                            controller: nineAxisSensorResultController,
                            // text: nineAxisSensor.getResultString()))),
                            text:
                                nineAxisSensor.getAccelerationX().toString()))),
                const SizedBox(height: 20),
                // 温度
                Consumer<Temperature>(
                    builder: ((context, temperature, _) =>
                        Widgets.switchContainer(
                            title: '温度',
                            enable: temperature.isEnabled,
                            function: _switchTemperature))),
                const SizedBox(height: 10),
                Consumer<Temperature>(
                    builder: ((context, temperature, _) =>
                        Widgets.resultContainer2(
                            verticalRatio: 15,
                            controller: temperatureResultController,
                            text: temperature.getResultString()))),
                const SizedBox(height: 20),
                // 脈数
                Consumer<HeartRate>(
                    builder: ((context, heartRate, _) =>
                        Widgets.switchContainer(
                            title: '脈数',
                            enable: heartRate.isEnabled,
                            function: _switchHeartRate))),
                const SizedBox(height: 10),
                Consumer<HeartRate>(
                    builder: ((context, heartRate, _) =>
                        Widgets.resultContainer2(
                            verticalRatio: 18,
                            controller: heartRateResultController,
                            text: heartRate.getResultString()))),
                const SizedBox(height: 20),
                // 装着適正度
                Consumer<Ppg>(
                    builder: ((context, ppg, _) => Widgets.switchContainer(
                        title: '装着適正度',
                        enable: ppg.isEnabled,
                        function: _switchPpg))),
                const SizedBox(height: 10),
                Consumer<Ppg>(
                    builder: ((context, ppg, _) => Widgets.resultContainer3(
                        verticalRatio: 18,
                        controller: ppgResultController,
                        text: ppg.getResultString()))),
                const SizedBox(height: 20),
                // バッテリー情報取得間隔設定
                Widgets.inputNumberContainer(
                    title: 'バッテリー情報取得間隔設定',
                    unit: '秒',
                    horizontalRatio: 20,
                    controller: batteryIntervalController,
                    function: _onSavedBatteryInterval),
                const SizedBox(height: 10),
                Consumer<Battery>(
                    builder: ((context, battery, _) => Widgets.switchContainer(
                        title: 'バッテリー情報',
                        enable: battery.isEnabled,
                        function: _switchBattery))),
                const SizedBox(height: 10),
                Consumer<Battery>(
                    builder: ((context, battery, _) => Widgets.resultContainer2(
                        verticalRatio: 15,
                        controller: batteryResultController,
                        text: battery.getResultString()))),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
