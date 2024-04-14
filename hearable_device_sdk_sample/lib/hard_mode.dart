import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hearable_device_sdk_sample/result.dart';
import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

import 'package:flutter/services.dart';
import 'dart:math' as math;
import 'package:bordered_text/bordered_text.dart';
import 'package:audioplayers/audioplayers.dart';

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

class Hard_mode extends StatelessWidget {
  const Hard_mode({super.key});

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
      child: _Hard_mode(),
    );
  }
}

class _Hard_mode extends StatefulWidget {
  @override
  State<_Hard_mode> createState() => _Hard_modeState();
}

class _Hard_modeState extends State<_Hard_mode> with TickerProviderStateMixin {
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

  late AnimationController _controllerOne;
  late AnimationController _controllerFive;
  Timer? timer;
  final bgm = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // 初期化
    NineAxisSensor().peopleX = 0;
    NineAxisSensor().speed = 0;
    NineAxisSensor().peopleAcceleration = 0;
    NineAxisSensor().trainAcceleration = 0;

    // 画面を横向きに
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    // センサオン
    // NineAxisSensor().isEnabled = true;
    _switch9AxisSensor(true);

    // 0~1を1秒でループ
    _controllerOne = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat();
    // 0~1を5秒でループ
    _controllerFive = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    // 処理関数の定義
    timer = Timer.periodic(const Duration(seconds: 1), gameHandler);

    // BGMの設定
    bgm.play(AssetSource('hard_bgm.mp3'));
    bgm.setVolume(0.1);
    bgm.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void dispose() {
    // センサオフ
    // NineAxisSensor().isEnabled = false;
    _switch9AxisSensor(false);

    // AnimationControllerを閉じる
    _controllerOne.dispose();
    _controllerFive.dispose();

    // 処理関数の終了
    timer?.cancel();

    // BGMの終了
    bgm.stop();
    bgm.dispose();

    super.dispose();
  }

  int gameHandlerCounter = 0; // ゲームハンドラのカウンタ
  bool countdowned = false; // カウントダウンしたか
  int nextShakeTime = 3; // 次の揺れまでの時間
  int nextShakeDirection = 1; // 次の揺れの方向
  int level = 1; // 現在のレベル
  int score = 0; // 現在のスコア
  bool pushed = false; // ゲーム終了画面に移行する動作を1回にするため

  void gameHandler(Timer timer) {
    if (!countdowned) {
      countdownPlay();
    } else {
      trainShakeHandler();
      updateScore();
      updateLevel();
      gameHandlerCounter++;
    }
  }

  int countdownCounter = 4; // カウントダウンのカウンタ
  bool countdown_sounded = false; // 音を出したか
  void countdownPlay() {
    // カウントダウンしているときに呼び出される関数
    if (countdownCounter > 0) {
      countdown_sounded = false;
      countdownCounter--;
    } else {
      // NineAxisSensor().isEnabled = true;
      countdowned = true;
    }
  }

  // 左右に表示する注意マーク(表示するときのみ注意マークの画像のパスをいれ、そうでないときは透過画像のパスをいれる)
  String leftAttention = 'assets/null.png';
  String rightAttenion = 'assets/null.png';

  void trainShakeHandler() {
    // 電車の揺れの処理
    if (nextShakeTime <= 0) {
      // 揺れる時間になったとき
      NineAxisSensor().trainAcceleration =
          nextShakeDirection * (10 + level.toDouble() * 0.5);
      nextShakeTime = math.Random().nextInt(4 - level ~/ 5) +
          2; // Level:second 0~4:2~5s 5~9:2~4s 10~14:2~3s 15:2s
      nextShakeDirection = math.Random().nextInt(2) * 2 - 1;
    }

    if (nextShakeTime == 1) {
      // 揺れる1秒前の処理
      if (nextShakeDirection == 1) {
        rightAttenion = 'assets/attention.png';
        AudioPlayer().play(AssetSource('right_alert.mp3'));
      } else {
        leftAttention = 'assets/attention.png';
        AudioPlayer().play(AssetSource('left_alert.mp3'));
      }
    } else {
      leftAttention = 'assets/null.png';
      rightAttenion = 'assets/null.png';
    }

    nextShakeTime--;
  }

  void updateScore() {
    // スコア加算の処理
    score += NineAxisSensor().peopleX.toInt().abs() * 2;
  }

  void updateLevel() {
    // レベル加算の処理
    if (level < 15) {
      // ハードモードはレベル15まで
      level = score ~/ 1000 + 1;
    }
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
        // 背景
        body: Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/bg_train_hard.jpg'), // ハードモードの背景
              fit: BoxFit.fitHeight,
            )),
            child: Stack(// ウィジェットを重ねる(スコアとプレイヤーを重ねるため)
                children: [
              // スコア、レベル
              Consumer<NineAxisSensor>(
                builder: (context, nineAxisSensor, _) {
                  nineAxisSensor.foo(); // センサ取得と同じタイミング(連続的に)で更新したいため(要改善)
                  return Align(
                    alignment: Alignment.topRight,
                    child: Column(children: [
                      // const SizedBox(height: 20,),
                      // スコア表示
                      BorderedText(
                        // 縁取り文字
                        strokeWidth: 5.0,
                        strokeColor: Colors.deepOrange,
                        child: Text(
                          "Score: $score",
                          style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white70,
                              fontFamily: 'banana'),
                        ),
                      ),
                      //レベル表示
                      BorderedText(
                        // 縁取り文字
                        strokeWidth: 5.0,
                        strokeColor: Colors.black,
                        child: Text(
                          "Level: $level",
                          style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white70,
                              fontFamily: 'banana'),
                        ),
                      ),
                    ]),
                  );
                },
              ),
              // 注意の表示(ハードモードはなし)
              // Consumer<NineAxisSensor>(
              //   builder: (context, nineAxisSensor, _){
              //     nineAxisSensor.foo();   // センサ取得と同じタイミング(連続的に)で更新したいため(要改善)

              //     return Center(
              //       child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,

              //       children: [
              //        Image.asset(leftAttention, height: 100, width: 100,), // leftAttentionには注意マークか透過画像のパスが入っているため、そのまま出力
              //        const SizedBox(width: 400,),
              //        Image.asset(rightAttenion, height: 100, width: 100,), // rightAttentionには注意マークか透過画像のパスが入っているため、そのまま出力
              //         ],
              //       ),
              //     );
              //   },
              // ),

              // プレイヤー
              Container(
                width: double.infinity,
                child: SingleChildScrollView(
                  // 下はみ出し対策
                  physics: NeverScrollableScrollPhysics(), // スクロール不可
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10), // 下に空白
                    child: Column(
                      // 列表示
                      mainAxisAlignment: MainAxisAlignment.start, // 並べ方(上詰め)
                      children: <Widget>[
                        // 前後の揺れのアニメーション
                        AnimatedBuilder(
                            animation: _controllerFive,
                            builder: (context, child) {
                              return Column(
                                verticalDirection: VerticalDirection.up,
                                children: <Widget>[
                                  Consumer<NineAxisSensor>(
                                      builder: ((context, nineAxisSensor, _) {
                                    // パラメータ
                                    double people_x =
                                        nineAxisSensor.testHandler();
                                    String people_img =
                                        'assets/default_standing_hard.png';
                                    String shadow_img =
                                        'assets/default_standing_shadow_hard.png';

                                    // 端に行くと画像が変化
                                    if (people_x < -250) {
                                      people_img =
                                          'assets/left_standing_hard.png';
                                      shadow_img =
                                          'assets/left_standing_shadow_hard.png';
                                    }
                                    if (people_x > 250) {
                                      people_img =
                                          'assets/right_standing_hard.png';
                                      shadow_img =
                                          'assets/right_standing_shadow_hard.png';
                                    }

                                    // 画面外に出るとリザルト画面に
                                    if (people_x.abs() > 450) {
                                      if (!pushed) {
                                        pushed = true;
                                        Future(() {
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      Result(score)));
                                        });
                                      }
                                    }

                                    return AnimatedBuilder(
                                        animation: _controllerFive,
                                        builder: (context, child) {
                                          // 横移動(全体)
                                          return Transform(
                                              transform: Matrix4.identity()
                                                ..translate(people_x),
                                              child: Column(
                                                  verticalDirection:
                                                      VerticalDirection
                                                          .up, // 影を後ろにプレイヤーを前に配置したいため、(影 → プレイヤー)の順に表示する
                                                  children: <Widget>[
                                                    // 影
                                                    Transform(
                                                        transform: Matrix4
                                                            .identity()
                                                          ..rotateX(math.sin(2 *
                                                                      math.pi *
                                                                      _controllerFive
                                                                          .value) /
                                                                  6 *
                                                                  math.pi /
                                                                  2 +
                                                              (math.pi / 2)),
                                                        alignment:
                                                            Alignment.topCenter,
                                                        child: Image.asset(
                                                          shadow_img,
                                                          height: 200,
                                                          width: 200,
                                                        )),
                                                    // 本体
                                                    Transform(
                                                      transform: Matrix4
                                                          .identity()
                                                        ..rotateX(math.sin(2 *
                                                                math.pi *
                                                                _controllerFive
                                                                    .value) /
                                                            3 *
                                                            math.pi /
                                                            2),
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child: Image.asset(
                                                        people_img,
                                                        height: 200,
                                                        width: 200,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 140,
                                                    )
                                                    // // センサ値
                                                    // Text(people_x.toString()),
                                                    // // スコア
                                                    // Text("Score: $score"),
                                                    // // レベル
                                                    // Text("Level :$level"),
                                                  ]));
                                        });
                                  })),
                                ],
                              );
                            }),

                        // // 回転テスト
                        // AnimatedBuilder(
                        //   animation: _controller,
                        //   builder: (context, child){
                        //     return Column(
                        //       verticalDirection: VerticalDirection.up,
                        //       children: <Widget>[
                        //         Transform(
                        //           transform: Matrix4.identity()
                        //             ..rotateX(math.sin(2*math.pi*_controller.value) / 6 * math.pi / 2 + (math.pi/2)),
                        //           alignment: Alignment.topCenter,
                        //           child: Image.asset('assets/default_standing_shadow.png', height: 150, width: 150,)
                        //         ),
                        //         Transform(
                        //         transform: Matrix4.identity()
                        //           // ..translate((_controller.value-0.5) * 200)
                        //           ..rotateX(math.sin(2*math.pi*_controller.value) / 1.5  * math.pi / 2),
                        //         alignment: Alignment.bottomCenter,
                        //         child: Image.asset('assets/default_standing.png', height: 150, width: 150,),
                        //         ),
                        //       ],
                        //     );
                        //   }),

                        // // 動きのテスト
                        // Consumer<NineAxisSensor>(
                        //   builder: ((context, nineAxisSensor, _){
                        //     double people_x = nineAxisSensor.testHandler();

                        //     return AnimatedBuilder(
                        //       animation: _controller,
                        //       builder: (context, child){
                        //         return Transform(
                        //           transform: Matrix4.identity()
                        //             // ..translate((_controller.value-0.5) * 2 * people_x),
                        //             ..translate(people_x),
                        //             // ..rotateX((_controller.value-0.5) * 3.141592653589793 / 2),
                        //           alignment: Alignment.bottomCenter,
                        //           child: Column(
                        //             children: <Widget>[
                        //               Image.asset('assets/default_standing.png', height: 150, width: 150,),
                        //               Text(people_x.toString())
                        //             ]
                        //           )
                        //         );
                        //       });
                        //   })),
                      ],
                    ),
                  ),
                ),
              ),
              //　カウントダウン時、半透明の膜を全体に表示(ハードモードは赤)
              Consumer<NineAxisSensor>(
                builder: (context, nineAxisSensor, _) {
                  return Container(
                    width: double.infinity,
                    color: (countdownCounter > 0)
                        ? const Color.fromARGB(255, 121, 30, 30)
                            ?.withOpacity(0.6)
                        : Colors.white.withOpacity(0),
                  );
                },
              ),
              // カウントダウン
              AnimatedBuilder(
                animation: _controllerOne,
                builder: (context, child) {
                  String number = (countdownCounter - 1).toString();

                  if (countdownCounter > 1) {
                    // カウントダウン時の処理
                    if (!countdown_sounded) {
                      AudioPlayer().play(AssetSource('countdown_sound.mp3'));
                      countdown_sounded = true;
                    }
                  } else if (countdownCounter == 1) {
                    // 始まるときの処理
                    if (!countdown_sounded) {
                      AudioPlayer().play(AssetSource('countdown_start.mp3'));
                      countdown_sounded = true;
                    }
                    number = 'Start!';
                  } else {
                    number = "";
                  }
                  return Center(
                      child: Transform(
                    transform: Matrix4.identity()
                      ..scale((countdownCounter != 1)
                          ? (1 - _controllerOne.value)
                          : 1.0),
                    alignment: Alignment.center,
                    child: BorderedText(
                      // 縁取り文字
                      strokeWidth: 30.0,
                      strokeColor: Colors.black,
                      child: Text(
                        number,
                        style: const TextStyle(
                            fontSize: 150,
                            color: Colors.white70,
                            fontFamily: 'banana'),
                      ),
                    ),
                  ));
                },
              ),
            ])));
  }
}
