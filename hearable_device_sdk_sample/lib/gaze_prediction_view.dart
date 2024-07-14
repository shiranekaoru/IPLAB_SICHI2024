import 'package:flutter/material.dart';
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

import 'dart:math' as math;

class GazePredictionView extends StatelessWidget {
  const GazePredictionView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NineAxisSensor(),
      child: _GazePredictionView(),
    );
  }
}

class _GazePredictionView extends StatefulWidget {
  @override
  _GazePredictionViewState createState() => _GazePredictionViewState();
}

class _GazePredictionViewState extends State<_GazePredictionView> {
  final HearableDeviceSdkSamplePlugin _samplePlugin =
      HearableDeviceSdkSamplePlugin();
  String userUuid = const Uuid().v4();
  var selectedIndex = -1;
  var selectedUser = '';
  bool isSetEaaCallback = false;

  TextEditingController nineAxisSensorResultController =
      TextEditingController();

  void _createUuid() {
    userUuid = const Uuid().v4();

    setState(() {});
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

  @override
  Widget build(BuildContext context) {
    
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('9軸センサデータ確認', style: TextStyle(fontSize: 16)),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => {FocusScope.of(context).unfocus()},
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 10),
                const Text('確認したいデータをOnにしてください',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(
                  height: 10,
                ),
                Consumer<NineAxisSensor>(
                    builder: ((context, nineAxisSensor, _) =>
                        Widgets.switchContainer(
                            title: '加速度',
                            enable: nineAxisSensor.isEnabled,
                            function: _switch9AxisSensor))),
                const SizedBox(height: 50),
                Consumer<NineAxisSensor>(
                    builder: ((context, nineAxisSensor, _) =>
                        Widgets.resultContainer(
                            verticalRatio: 60,
                            controller: nineAxisSensorResultController,
                            text: nineAxisSensor.getAcceResultString()))),
               
                Consumer<NineAxisSensor>(
                    builder: ((context, nineAxisSensor, _) =>
                        Widgets.switchContainer(
                            title: 'ジャイロ',
                            enable: nineAxisSensor.isEnabled,
                            function: _switch9AxisSensor))),
                const SizedBox(height: 50),
                Consumer<NineAxisSensor>(
                    builder: ((context, nineAxisSensor, _) =>
                        Widgets.resultContainer(
                            verticalRatio: 60,
                            controller: nineAxisSensorResultController,
                            text: nineAxisSensor.getGyroResultString()))),
                const SizedBox(height: 20),
                Consumer<NineAxisSensor>(
                    builder: ((context, nineAxisSensor, _) =>
                        Widgets.switchContainer(
                            title: '地磁気',
                            enable: nineAxisSensor.isEnabled,
                            function: _switch9AxisSensor))),
                const SizedBox(height: 50),
                Consumer<NineAxisSensor>(
                    builder: ((context, nineAxisSensor, _) =>
                        Widgets.resultContainer(
                            verticalRatio: 60,
                            controller: nineAxisSensorResultController,
                            text: nineAxisSensor.getMagResultString()))),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
    
  }
}


class BoxPainter extends CustomPainter {
  final double roll;
  final double pitch;
  final double yaw;

  BoxPainter(this.roll, this.pitch, this.yaw);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;

    final double boxSize = 100.0;
    final double halfSize = boxSize / 2;

    List<Offset> vertices = [
      Offset(-halfSize, -halfSize),
      Offset(halfSize, -halfSize),
      Offset(halfSize, halfSize),
      Offset(-halfSize, halfSize),
    ];

    vertices = vertices.map((point) => _rotate3D(point, roll, pitch, yaw)).toList();

    final Offset center = Offset(size.width / 2, size.height / 2);

    final Path path = Path()
      ..moveTo(vertices[0].dx + center.dx, vertices[0].dy + center.dy)
      ..lineTo(vertices[1].dx + center.dx, vertices[1].dy + center.dy)
      ..lineTo(vertices[2].dx + center.dx, vertices[2].dy + center.dy)
      ..lineTo(vertices[3].dx + center.dx, vertices[3].dy + center.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  Offset _rotate3D(Offset point, double roll, double pitch, double yaw) {
    final double cosRoll = math.cos(roll);
    final double sinRoll = math.sin(roll);
    final double cosPitch = math.cos(pitch);
    final double sinPitch = math.sin(pitch);
    final double cosYaw = math.cos(yaw);
    final double sinYaw = math.sin(yaw);

    final double x = point.dx * (cosYaw * cosPitch) +
        point.dy * (cosYaw * sinPitch * sinRoll - sinYaw * cosRoll) +
        point.dy * (cosYaw * sinPitch * cosRoll + sinYaw * sinRoll);
    final double y = point.dx * (sinYaw * cosPitch) +
        point.dy * (sinYaw * sinPitch * sinRoll + cosYaw * cosRoll) +
        point.dy * (sinYaw * sinPitch * cosRoll - cosYaw * sinRoll);

    return Offset(x, y);
  }

  @override
  bool shouldRepaint(BoxPainter oldDelegate) {
    return oldDelegate.roll != roll || oldDelegate.pitch != pitch || oldDelegate.yaw != yaw;
  }
}