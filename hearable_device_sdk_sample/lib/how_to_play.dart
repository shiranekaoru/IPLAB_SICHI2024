import 'package:flutter/material.dart';

class HowToPlay extends StatefulWidget {
  @override
  _HowToPlayState createState() => _HowToPlayState();
}

class _HowToPlayState extends State<HowToPlay> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar( // 上のヘッダー
        //   title: const Text('センサデータ確認', style: TextStyle(fontSize: 16)),
        //   centerTitle: true,
        //   backgroundColor: Colors.black,
        // ),

        // スタート画面に戻るボタン
        floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
        floatingActionButton: SizedBox(
          width: 110,
          height: 110,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: FloatingActionButton(
              child: Icon(Icons.arrow_back_ios_new_rounded),
              backgroundColor: Colors.amber,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
        // 説明画像の表示
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
              image: DecorationImage(
            image: AssetImage('assets/how_to_play.jpg'),
            fit: BoxFit.fitHeight,
          )),
        ));
  }
}
