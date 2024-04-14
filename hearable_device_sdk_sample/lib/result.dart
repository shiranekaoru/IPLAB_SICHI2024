import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:bordered_text/bordered_text.dart';
import 'package:flutter/services.dart';
import 'package:hearable_device_sdk_sample/hearable_service_view.dart';
import 'package:hearable_device_sdk_sample/start.dart';


class Result extends StatefulWidget {
  Result(this.score);
  int score;
  
  @override
  _ResultState createState() => _ResultState(score);

}

class _ResultState extends State<Result> {
  _ResultState(this.score);
  int score;

  @override
  void initState() {
    super.initState();
    //画面を横にする
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    AudioPlayer().play(AssetSource('slip.mp3'));
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
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg_train_result.jpg'),
            fit: BoxFit.fitHeight,
          )
        ),
        child:
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // GameOver
              BorderedText(
                strokeWidth: 8.0,
                strokeColor: Colors.brown,
                child: const Text(
                  "Game Over",
                  style: TextStyle(
                    fontSize: 48,
                    color: Colors.white70,
                    fontFamily: 'banana'
                  ),
                ),
              ),
              // Score
              BorderedText(
                strokeWidth: 4.0,
                strokeColor: Colors.black,
                child: Text(
                  "Score: $score",
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontFamily: 'banana'
                  ),
                ),
              ),

              const SizedBox(height: 30,),

              // ボタン
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  // Navigator.pushReplacement(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => Start())
                  //  );
                  Navigator.pop(context);
                },
                child: const Text(
                  'スタート画面に戻る',
                  style: TextStyle(
                    fontSize: 24,
                    fontFamily: 'banana',
                  ),
                ),
              ),
            ],
          )
      )
    );
  }

}