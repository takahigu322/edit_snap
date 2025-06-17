import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:camera/camera.dart';


class ImageSelectScreen extends StatefulWidget {
  const ImageSelectScreen({super.key});
  @override
  State<ImageSelectScreen> createState() => _ImageSelectScreenState();
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
                onPressed: () {}, child: Text(l10n.imageEdit),
              ),
          ],
        ),
      ),
    );
  }
}