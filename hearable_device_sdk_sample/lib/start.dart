import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/services.dart';
import 'package:hearable_device_sdk_sample/hard_mode.dart';
import 'package:hearable_device_sdk_sample/how_to_play.dart';
import 'dart:math' as math;

import 'package:hearable_device_sdk_sample/normal_mode.dart';

class Start extends StatefulWidget {
  @override
  _StartState createState() => _StartState();
}

class _StartState extends State<Start> with TickerProviderStateMixin {
  late AnimationController _controllerTwo;
  final AudioPlayer openingBGM = AudioPlayer();

  @override
  void initState() {
    super.initState();
    // 画面を横向きに
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    // フルスクリーンに
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

    // 0~1を2秒でループ
    _controllerTwo = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // BGMの再生
    openingBGM.play(AssetSource('Faint_Dream.mp3'));
    openingBGM.setVolume(0.6);
    openingBGM.setReleaseMode(ReleaseMode.loop);
  }

  @override
  void dispose() {
    // // 画面を縦に戻す
    // WidgetsFlutterBinding.ensureInitialized();
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitDown,
    //   DeviceOrientation.portraitUp
    // ]);

    // フルスクリーンに
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

    // AnimationControllerを閉じる
    _controllerTwo.dispose();

    // BGMの終了
    openingBGM.stop();
    openingBGM.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar( // 上のヘッダー
        //   title: const Text('センサデータ確認', style: TextStyle(fontSize: 16)),
        //   centerTitle: true,
        //   backgroundColor: Colors.black,
        // ),
        body: Container(
            // 背景画像(車内)
            width: double.infinity,
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage('assets/bg_train_result.jpg'), // 半透明の車内画像
              fit: BoxFit.fitHeight,
            )),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // タイトル
                AnimatedBuilder(
                    // 動くアニメーション
                    animation: _controllerTwo,
                    builder: (context, child) {
                      return Transform(
                          transform: Matrix4.identity()
                            ..translate(
                                math.sin(2 * math.pi * _controllerTwo.value) *
                                    30,
                                math.sin(2 *
                                        math.pi *
                                        math.sin(2 *
                                            math.pi *
                                            _controllerTwo.value)) *
                                    5),
                          alignment: Alignment.center,
                          child: BorderedText(
                            // 縁取りテキスト
                            strokeWidth: 12.0,
                            strokeColor: Colors.black87,
                            child: const Text(
                              "つり革バランスゲーム",
                              style: TextStyle(
                                  fontSize: 64,
                                  color: Colors.white70,
                                  fontFamily: 'banana'),
                            ),
                          ));
                    }),

                const SizedBox(
                  height: 30,
                ),

                // ノーマルモード
                SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    // ボタンの装飾
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // ボタン押したときの処理
                      openingBGM.pause();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Normal_mode())).then((_) {
                        openingBGM.resume();
                      });
                    },
                    child: const Text(
                      // ボタンの文字
                      'ノーマルモード',
                      style: TextStyle(fontSize: 24, fontFamily: 'banana'),
                    ),
                  ),
                ),

                // ハードモード
                SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    // ボタンの装飾
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.pink,
                      foregroundColor: Colors.black,
                      shadowColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // ボタン押したときの処理
                      openingBGM.pause();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Hard_mode())).then((_) {
                        openingBGM.resume();
                      });
                    },
                    child: const Text(
                      // ボタンの文字
                      'ハードモード',
                      style: TextStyle(fontSize: 24, fontFamily: 'banana'),
                    ),
                  ),
                ),

                // 遊び方
                SizedBox(
                  width: 180,
                  child: ElevatedButton(
                    // ボタンの装飾
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      // ボタン押したときの処理
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => HowToPlay()));
                    },
                    child: const Text(
                      // ボタンの文字
                      '遊び方',
                      style: TextStyle(fontSize: 24, fontFamily: 'banana'),
                    ),
                  ),
                ),
              ],
            )));
  }
}
