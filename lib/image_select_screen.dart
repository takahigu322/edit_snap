import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
// import 'package:image/image.dart' as img;
import 'dart:async';
import 'dart:typed_data';
import 'dart:io';



// 画像選択画面の定義
class ImageSelectScreen extends StatefulWidget {
  const ImageSelectScreen({super.key});
  @override
  State<ImageSelectScreen> createState() => _ImageSelectScreenState();
}

// カメラプレビュー画面の定義
class CameraPreviewScreen extends StatefulWidget {
  final CameraDescription camera;
  const CameraPreviewScreen({required this.camera, Key? key}) : super(key: key);

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();

}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  late CameraController _controller;
  bool _isProcessing = false;
  String? _predictionLabel;
  double? _predictionScore;

  void _startInferenceLoop() {
    Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!_controller.value.isStreamingImages || _isProcessing) return;

      _isProcessing = true;

      try {
        final image = await _controller.takePicture(); // 実際は非推奨（後述）
        final bytes = await image.readAsBytes();
        await _runInference(bytes);
      } catch (e) {
        print('推論エラー: $e');
      } finally {
        _isProcessing = false;
      }
    });
  }

  @override
  void dispose() {
    _controller.stopImageStream();
    _controller.dispose();
    super.dispose();
  }

  int _frameCount = 0; // 追加：フレームカウンター
  // void _processCameraImage(CameraImage image) async {
  //   if (_isProcessing) return;
  //   _isProcessing = true;
  //   try {
  //     // 1. YUV → RGB(JPEGなど)に変換
  //     Uint8List? bytes = _convertYUV420ToImage(image);
  //     if (bytes != null) {
  //       // 2. 推論関数に渡す
  //       await _runInference(bytes);
  //     }
  //   } catch (e) {
  //     print('推論エラー: $e');
  //   } finally {
  //     _isProcessing = false;
  //   }
  // }
  void _processCameraImage(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;
    try {
      print("カメラ画像受信: ${image.width}x${image.height}");
      Uint8List? bytes = convertBGRA8888toImage(image);
      if (bytes == null) {
        print("YUV→RGB変換失敗");
        return;
      }
      print("画像変換成功, bytes.length=${bytes.length}");
      await _runInference(bytes);
    } catch (e, stack) {
      print('推論エラー: $e');
      print('Stack: $stack');
    } finally {
      _isProcessing = false;
    }
  }

  //_processCameraImageカメラストリーミング推論の初期化
  Future<void> _initCamera() async {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _controller.initialize();
    await _controller.startImageStream(_processCameraImage); // ← ここが重要
    setState(() {});
  }

  Uint8List convertBGRA8888toImage(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final Uint8List bytes = image.planes[0].bytes;

    // BGRA8888は1ピクセルあたり4バイト
    // なのでRGBA形式に変換するならループで並び替えも可能

    // ここではimageパッケージのImageにピクセルセットしていく例

    //final img.Image imgImage = img.Image(width, height);
    final img.Image rgbImage = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int index = (y * width + x) * 4;

        final int b = bytes[index];
        final int g = bytes[index + 1];
        final int r = bytes[index + 2];
        final int a = bytes[index + 3];

        // imgImage.setPixelRgba(x, y, r, g, b, a);
        rgbImage.setPixelRgba(x, y, r, g, b, 255);
      }
    }

    return Uint8List.fromList(img.encodePng(rgbImage));
  }


  // Uint8List convertYUV420toImage(CameraImage image) {
  //   final int width = image.width;
  //   final int height = image.height;
  //   print("Format group: ${image.format.group}");
  //   print("Planes length: ${image.planes.length}");
  //
  //   final int uvRowStride = image.planes[1].bytesPerRow;
  //   final int uvPixelStride = image.planes[1].bytesPerPixel!;
  //
  //   final img.Image rgbImage = img.Image(width: width, height: height);
  //
  //   for (int y = 0; y < height; y++) {
  //     for (int x = 0; x < width; x++) {
  //       final int uvIndex = uvPixelStride * (x ~/ 2) + uvRowStride * (y ~/ 2);
  //       final int index = y * width + x;
  //
  //       final int yp = image.planes[0].bytes[index];
  //       final int up = image.planes[1].bytes[uvIndex];
  //       final int vp = image.planes[2].bytes[uvIndex];
  //
  //       // YUV → RGB 変換
  //       int r = (yp + 1.370705 * (vp - 128)).round();
  //       int g = (yp - 0.337633 * (up - 128) - 0.698001 * (vp - 128)).round();
  //       int b = (yp + 1.732446 * (up - 128)).round();
  //
  //       r = r.clamp(0, 255);
  //       g = g.clamp(0, 255);
  //       b = b.clamp(0, 255);
  //
  //       rgbImage.setPixelRgba(x, y, r, g, b, 255);
  //     }
  //   }
  //
  //   // ここでimg.ImageをUint8Listに変換
  //   return Uint8List.fromList(img.encodePng(rgbImage));
  // }


  // late CameraController _controller;
  late Interpreter _interpreter;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _loadModel();
  }

  // Future<void> _initCamera() async {
  //   _controller = CameraController(
  //     widget.camera, // ✅ ここが正しい
  //     ResolutionPreset.medium,
  //     // widget.cameras[0],
  //     // ResolutionPreset.medium,
  //   );
  //   await _controller.initialize();
  //   setState(() {});
  // }

  Future<void> _loadModel() async {
    _interpreter = await Interpreter.fromAsset('assets/cnn_model.tflite');
  }

  Future<void> _takePictureAndRunInference() async {
    final XFile file = await _controller.takePicture();
    final imgBytes = await File(file.path).readAsBytes();
    final image = img.decodeImage(imgBytes);
    if (image == null) return;

    final resized = img.copyResize(image, width: 32, height: 32);

    final channels = [image_lib.Channel.red, image_lib.Channel.green, image_lib.Channel.blue];
    final input = List.generate(
      1,
          (_) => List.generate(
        32,
            (y) => List.generate(
          32,
              (x) => List.generate(
            3,
                (c) => resized.getPixel(x, y).getChannel(channels[c]) / 255.0,
          ),
        ),
      ),
    );
    // 出力のためのバッファを準備（CIFAR-10の10クラス）

    final output = List.filled(10, 0.0).reshape([1, 10]);
    _interpreter.run([input], output);

    final resultIndex = output[0].indexWhere((e) => e == output[0].reduce((a, b) => a > b ? a : b));
    final List<double> scores = output[0].cast<double>();
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final maxIndex = scores.indexOf(maxScore);
    setState(() {
      // _result = '予測結果: $resultIndex';
      _predictionLabel = classLabels[maxIndex];
      _predictionScore = scores[maxIndex];
    });
  }

  // 推論準備
  List<String> classLabels = [
    'airplane', 'automobile', 'bird', 'cat', 'deer',
    'dog', 'frog', 'horse', 'ship', 'truck',
  ];

  // String? _predictionLabel;
  // double? _predictionScore;
  Future<void> _runInference(Uint8List imageBytes) async {
    final image = image_lib.decodeImage(imageBytes);
    if (image == null) {
      print("画像のデコードに失敗しました");
      return;
    }

    final resized = image_lib.copyResize(image, width: 32, height: 32);
    final channels = [image_lib.Channel.red, image_lib.Channel.green, image_lib.Channel.blue];
    final input = List.generate(
      1,
          (_) => List.generate(
        32,
            (y) => List.generate(
          32,
              (x) => List.generate(
            3,
                (c) => resized.getPixel(x, y).getChannel(channels[c]) / 255.0,
          ),
        ),
      ),
    );

    var output = List.filled(1 * 10, 0.0).reshape([1, 10]);
    print("run前: output.length=${output.length} output=$output");
    _interpreter.run(input, output);
    print("run後: output.length=${output.length} output=$output");

    print("output: $output");

    if (output.isEmpty || output[0].isEmpty) {
      print("推論結果が空です");
      return;
    }

    final List<double> scores = output[0].cast<double>();
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final maxIndex = scores.indexOf(maxScore);

    setState(() {
      _predictionLabel = classLabels[maxIndex];
      _predictionScore = scores[maxIndex];
    });
  }
  // Future<void> _runInference(Uint8List imageBytes) async {
  //   Interpreter? _interpreter;
  //   final data = await rootBundle.loadString('assets/text.txt');
  //   print(data);
  //   final interpreter = await Interpreter.fromAsset('assets/cnn_model.tflite');
  //
  //   // 前処理: 32x32にリサイズして正規化
  //   final image = image_lib.decodeImage(imageBytes);
  //   final resized = image_lib.copyResize(image!, width: 32, height: 32);
  //   final channels = [image_lib.Channel.red, image_lib.Channel.green, image_lib.Channel.blue];
  //   final input = List.generate(
  //     1,
  //         (_) => List.generate(
  //       32,
  //           (y) => List.generate(
  //         32,
  //             (x) => List.generate(
  //           3,
  //               (c) => resized.getPixel(x, y).getChannel(channels[c]) / 255.0,
  //         ),
  //       ),
  //     ),
  //   );
  //   // 出力のためのバッファを準備（CIFAR-10の10クラス）
  //   var output = List.filled(1 * 10, 0.0).reshape([1, 10]);
  //
  //   interpreter.run(input, output);
  //
  //   final List<double> scores = output[0].cast<double>();
  //   final maxScore = scores.reduce((a, b) => a > b ? a : b);
  //   final maxIndex = scores.indexOf(maxScore);
  //
  //   // final scores = output[0];
  //   // final maxIndex = scores.indexWhere((e) => e == scores.reduce((a, b) => a > b ? a : b));
  //
  //   setState(() {
  //     _predictionLabel = classLabels[maxIndex];
  //     _predictionScore = scores[maxIndex];
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) return const Center(child: CircularProgressIndicator());
    // test
    // _predictionLabel = 'test';
    // _predictionScore = 0.9;
    //
    return Scaffold(
      appBar: AppBar(title: const Text('カメラプレビュー')),
      body: Stack(
        children: [
          CameraPreview(_controller),
          if (_predictionLabel != null)
            Positioned(
              top: 32,
              left: 16,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.all(8),
                child: Text(
                  '$_predictionLabel (${(_predictionScore! * 100).toStringAsFixed(1)}%)',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ImageSelectScreenState extends State<ImageSelectScreen> {
  /* ◆ ImagePicker
  image_pickerパッケージが提供するクラス
  画像ライブラリやカメラにアクセスする機能を持つ
  */
  final ImagePicker _picker = ImagePicker();
  /* ◆ Uint8List
  8bit 符号なし整数のリスト
  */
  Uint8List? _imageBitmap;

  // カメラ起動
  List<CameraDescription>? cameras;

  @override
  void initState() {
    super.initState();
    _initCameras();
  }

  Future<void> _initCameras() async {
    cameras = await availableCameras();
    setState(() {});
  }

  void _openCamera() async {
    if (cameras == null || cameras!.isEmpty) {
      print('カメラが利用できません');
      return;
    }

    final imagePath = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => CameraPreviewScreen(camera: cameras![0]),
      ),
    );

    if (imagePath != null) {
      // 撮影画像の読み込みなどの処理をここに書く
      final bytes = await XFile(imagePath).readAsBytes();
      setState(() {
        _imageBitmap = bytes;
        _predictionLabel = null;
        _predictionScore = null;
      });

      // 必要なら推論も再度実行
      await _runInference(bytes);
    }
  }

  Future<void> _selectImage() async {
    /* ◆ XFile
    ファイルの抽象化クラス
    */
    // 画像を選択する
    final XFile? imageFile =
    await _picker.pickImage(source: ImageSource.gallery);

    // ファイルオブジェクトから画像データを取得する
    final imageBitmap = await imageFile?.readAsBytes();
    assert(imageBitmap != null);
    if (imageBitmap == null) return;

    // 画像データをデコードする
    final image = image_lib.decodeImage(imageBitmap);
    assert(image != null);
    if (image == null) return;

    /* ◆ Image
    画像データとメタデータを内包したクラス
    */
    final image_lib.Image resizedImage;
    if (image.width > image.height) {
      // 横長の画像なら横幅を500pxにリサイズする
      resizedImage = image_lib.copyResize(image, width: 500);
    } else {
      // 縦長の画像なら縦幅を500pxにリサイズする
      resizedImage = image_lib.copyResize(image, height: 500);
    }
    // 画像をエンコードして状態を更新する
    setState(() {
      _imageBitmap = image_lib.encodeBmp(resizedImage);
    });

    // 推論実行
    await _runInference(imageBitmap);
  }
  // 推論準備
  List<String> classLabels = [
    'airplane', 'automobile', 'bird', 'cat', 'deer',
    'dog', 'frog', 'horse', 'ship', 'truck',
  ];

  String? _predictionLabel;
  double? _predictionScore;

  Future<void> _runInference(Uint8List imageBytes) async {
    Interpreter? _interpreter;
    try {
      final byteData = await rootBundle.load('assets/cnn_model.tflite');
      print("Model loaded: ${byteData.lengthInBytes} bytes");
    } catch (e) {
      print("Error loading model: $e");
    }
    try {
      _interpreter = await Interpreter.fromAsset('assets/cnn_model.tflite');
      print('モデルのロードが完了');
    } catch (e) {
      print('モデルのロードでエラーが発生: $e');
    }
    final data = await rootBundle.loadString('assets/text.txt');
    print(data);
    final interpreter = await Interpreter.fromAsset('assets/cnn_model.tflite');

    // 前処理: 32x32にリサイズして正規化
    final image = image_lib.decodeImage(imageBytes);
    final resized = image_lib.copyResize(image!, width: 32, height: 32);
    final channels = [image_lib.Channel.red, image_lib.Channel.green, image_lib.Channel.blue];
    final input = List.generate(
      1,
          (_) => List.generate(
        32,
            (y) => List.generate(
          32,
              (x) => List.generate(
            3,
                    (c) => resized.getPixel(x, y).getChannel(channels[c]) / 255.0,
          ),
        ),
      ),
    );
    // 出力のためのバッファを準備（CIFAR-10の10クラス）
    var output = List.filled(1 * 10, 0.0).reshape([1, 10]);

    interpreter.run(input, output);

    final List<double> scores = output[0].cast<double>();
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final maxIndex = scores.indexOf(maxScore);

    // final scores = output[0];
    // final maxIndex = scores.indexWhere((e) => e == scores.reduce((a, b) => a > b ? a : b));

    setState(() {
      _predictionLabel = classLabels[maxIndex];
      _predictionScore = scores[maxIndex];
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = L10n.of(context);
    final imageBitmap = _imageBitmap;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(l10n.imageSelectScreenTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageBitmap != null) Image.memory(imageBitmap),
            // Image.memoryで画像表示
            ElevatedButton(
              // 「画像を選ぶ」ボタン
                onPressed: () => _selectImage(),
                child: Text(l10n.imageSelect)
              //onPressed: () => _selectImage(), child: Text(l10n.imageSelect),
            ),
            if (_predictionLabel != null && _predictionScore != null)
              Text(
                '予測: $_predictionLabel ($_predictionScore)',
                style: const TextStyle(fontSize: 18),
              ),
            if (imageBitmap != null)
              ElevatedButton(
                // 「画像を編集する」ボタン
                // onPressed: () {}, child: Text(l10n.imageEdit),
                onPressed: _openCamera, // ここでカメラプレビューして推論する
                child: Text(l10n.imageEdit),
              ),
          ],
        ),
      ),
    );
  }
}