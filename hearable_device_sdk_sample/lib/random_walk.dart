import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vector_math;
import 'package:provider/provider.dart';
import 'package:hearable_device_sdk_sample/nine_axis_sensor.dart';
import 'package:hearable_device_sdk_sample/alert.dart';
import 'package:hearable_device_sdk_sample_plugin/hearable_device_sdk_sample_plugin.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NineAxisSensor(),
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: Text('3D Sphere with Sensor Data'),
          ),
          body: Center(
            child: SphereCanvas(),
          ),
        ),
      ),
    );
  }
}

class SphereCanvas extends StatefulWidget {
  @override
  _SphereCanvasState createState() => _SphereCanvasState();
}

class _SphereCanvasState extends State<SphereCanvas> with TickerProviderStateMixin {
  double _angleX = 0;
  double _angleY = 0;
  double _scale = 1.0;
  double _initialScale = 1.0;
  double filtering_value = 0.05;
  vector_math.Vector3 _spherePosition = vector_math.Vector3.zero();
  vector_math.Vector3 _previousAcceleration = vector_math.Vector3.zero();
  List<vector_math.Vector3> _trail = [];
  final HearableDeviceSdkSamplePlugin _samplePlugin = HearableDeviceSdkSamplePlugin();
  final int _maxTrailLength = 100; // 軌跡の最大長
  final double _samplingInterval = 20.0 / 1000.0; // サンプリング間隔 (秒)

  @override
  void initState() {
    super.initState();
    _startNineAxisSensor();

    // 画面の更新をするためのタイマー
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  void _startNineAxisSensor() async {
    // callback登録
    if (!(await NineAxisSensor().addNineAxisSensorNotificationListener())) {
      Alert.showAlert(context, 'IllegalArgumentException');
    }
    // 取得開始
    if (!(await _samplePlugin.startNineAxisSensorNotification())) {
      Alert.showAlert(context, 'IllegalStateException');
    }
    setState(() {});
  }

  void _onScaleStart(ScaleStartDetails details) {
    _initialScale = _scale;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = _initialScale * details.scale;
      _angleX += details.focalPointDelta.dy * 0.01;
      _angleY += details.focalPointDelta.dx * 0.01;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          child: CustomPaint(
            size: Size(300, 300),
            painter: SpherePainter(_angleX, _angleY, _scale, _spherePosition, _trail),
          ),
        ),
        Positioned(
          bottom: 20,
          left: 10,
          child: Consumer<NineAxisSensor>(
            builder: (context, nineAxisSensor, _) {
              // 現在の加速度データを取得し、4096で割る
              vector_math.Vector3 currentAcceleration = vector_math.Vector3(
                nineAxisSensor.getAccelerationX().toDouble() / 4096.0,
                nineAxisSensor.getAccelerationY().toDouble() / 4096.0,
                nineAxisSensor.getAccelerationZ().toDouble() / 4096.0,
              );
              
              // 疑似ハイパスフィルタで重力加速度成分を除去
              vector_math.Vector3 LowPassedcurrentAcceleration = vector_math.Vector3(
                filtering_value * currentAcceleration.x + (1 - filtering_value) * _previousAcceleration.x,
                filtering_value * currentAcceleration.y + (1 - filtering_value) * _previousAcceleration.y,
                filtering_value * currentAcceleration.z + (1 - filtering_value) * _previousAcceleration.z,
              );

              currentAcceleration = vector_math.Vector3(
                currentAcceleration.x - LowPassedcurrentAcceleration.x,
                currentAcceleration.y - LowPassedcurrentAcceleration.y,
                currentAcceleration.z - LowPassedcurrentAcceleration.z,
              );

              // サンプリング間隔を掛け合わせて球体の位置に加算
              _spherePosition += currentAcceleration * _samplingInterval;

              // 現在の加速度を保存
              _previousAcceleration = currentAcceleration;

              // 軌跡の更新
              _trail.add(_spherePosition.clone());

              // 軌跡の長さを制限
              if (_trail.length > _maxTrailLength) {
                _trail.removeAt(0);
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'X軸の加速度: ${currentAcceleration.x}',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  Text(
                    'Y軸の加速度: ${currentAcceleration.y}',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                  Text(
                    'Z軸の加速度: ${currentAcceleration.z}',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class SpherePainter extends CustomPainter {
  final double angleX;
  final double angleY;
  final double scale;
  final vector_math.Vector3 spherePosition;
  final List<vector_math.Vector3> trail;

  SpherePainter(this.angleX, this.angleY, this.scale, this.spherePosition, this.trail);

  @override
  void paint(Canvas canvas, Size size) {
    Paint xAxisPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.0
      ..isAntiAlias = true; // アンチエイリアスを有効にする

    Paint yAxisPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2.0
      ..isAntiAlias = true; // アンチエイリアスを有効にする

    Paint zAxisPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..isAntiAlias = true; // アンチエイリアスを有効にする

    Paint trailPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 1.0
      ..isAntiAlias = true; // アンチエイリアスを有効にする

    double centerX = size.width / 2;
    double centerY = size.height / 2;

    // 変換行列を作成
    vector_math.Matrix4 matrix = vector_math.Matrix4.identity()
      ..scale(scale)
      ..rotateX(angleX)
      ..rotateY(angleY);

    // 軸の描画
    _drawLine(canvas, matrix, centerX, centerY, 0, 0, 0, 100, 0, 0, xAxisPaint); // X軸
    _drawLine(canvas, matrix, centerX, centerY, 0, 0, 0, 0, 100, 0, yAxisPaint); // Y軸
    _drawLine(canvas, matrix, centerX, centerY, 0, 0, 0, 0, 0, 100, zAxisPaint); // Z軸

    // 軌跡の描画
    for (int i = 0; i < trail.length - 1; i++) {
      _drawLine(canvas, matrix, centerX, centerY, trail[i].x, trail[i].y, trail[i].z,
          trail[i + 1].x, trail[i + 1].y, trail[i + 1].z, trailPaint);
    }

    // 球体の描画
    Paint spherePaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill
      ..isAntiAlias = true; // アンチエイリアスを有効にする

    double radius = 15; // 球体の半径を小さく設定

    // 球体の描画
    _drawSphere(canvas, matrix, centerX, centerY, spherePosition.x, spherePosition.y, spherePosition.z, radius, spherePaint);
  }

  void _drawLine(Canvas canvas, vector_math.Matrix4 matrix, double cx, double cy,
      double x1, double y1, double z1, double x2, double y2, double z2, Paint paint) {
    final p1 = _project(matrix, cx, cy, x1, y1, z1);
    final p2 = _project(matrix, cx, cy, x2, y2, z2);
    canvas.drawLine(p1, p2, paint);
  }

  void _drawSphere(Canvas canvas, vector_math.Matrix4 matrix, double cx, double cy,
      double x, double y, double z, double radius, Paint paint) {
    final center = _project(matrix, cx, cy, x, y, z);
    canvas.drawCircle(center, radius, paint);
  }

  Offset _project(vector_math.Matrix4 matrix, double cx, double cy, double x, double y, double z) {
    final vector = matrix.transform3(vector_math.Vector3(x, y, z));
    return Offset(cx + vector.x, cy - vector.y);
  }

  @override
  bool shouldRepaint(SpherePainter oldDelegate) {
    return oldDelegate.angleX != angleX || oldDelegate.angleY != angleY || oldDelegate.scale != scale || oldDelegate.spherePosition != spherePosition || oldDelegate.trail != trail;
  }
}
