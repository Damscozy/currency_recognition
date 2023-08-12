// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

enum Artifacts {
  five('Five naira'),
  ten('Ten naira'),
  twenty('Twenty naira'),
  fifty('Fifty naira'),
  onehundred('One hundred naira'),
  twohundred('Two hundred naira'),
  fivehundred('Five hundred naira'),
  onethousand('One thousand naira');

  const Artifacts(this.title);
  final String title;
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, e});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late bool _isLoading;
  File? _image;
  List? _outputs;

  final player = AudioPlayer();
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    FlutterNativeSplash.remove();
    _isLoading = true;
    loadModel().then((value) {
      setState(() {
        _isLoading = false;
      });
    });
    _image;
    _outputs;
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  loadModel() async {
    String? res = await Tflite.loadModel(
        labels: "assets/labels.txt",
        model: "assets/model_unquant.tflite",
        numThreads: 1, // defaults to 1
        isAsset:
            true, // defaults to true, set to false to load resources outside assets
        useGpuDelegate:
            false // defaults to false, set to true to use GPU delegate
        );
    print('Recognition Response $res');
  }

  Future pickImage() async {
    var image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return null;
    setState(() {
      _isLoading = true;
      _image = File(image.path);
    });
    await classifyImage(_image).then((value) => playSound());
  }

  Future takePicture() async {
    var image = await _imagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    setState(() {
      _isLoading = true;
      _image = File(image.path);
    });
    await classifyImage(_image).then((value) => playSound());
  }

  // Classifying Selected Image
  classifyImage(File? image) async {
    var output = await Tflite.runModelOnImage(
      path: image!.path,
      numResults: 5,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _isLoading = false;
      // Declear List _outputs in the class will be used to show the classifed class name and confidence
      _outputs = output;
    });
  }

  playSound() async {
    if (_outputs != null &&
        _outputs!.isNotEmpty &&
        _outputs![0]["label"].contains(Artifacts.five.title)) {
      await player.play(AssetSource('audios/five_naira.wav'));
    } else if (_outputs != null &&
        _outputs!.isNotEmpty &&
        _outputs![0]["label"].contains(Artifacts.ten.title)) {
      await player.play(AssetSource('audios/ten_naira.wav'));
    } else if (_outputs != null &&
        _outputs!.isNotEmpty &&
        _outputs![0]["label"].contains(Artifacts.twenty.title))
      await player.play(AssetSource('audios/twenty_naira.wav'));
    else if (_outputs != null &&
        _outputs!.isNotEmpty &&
        _outputs![0]["label"].contains(Artifacts.fifty.title)) {
      await player.play(AssetSource('audios/fifty_naira.wav'));
    } else if (_outputs != null &&
        _outputs!.isNotEmpty &&
        _outputs![0]["label"].contains(Artifacts.onehundred.title)) {
      await player.play(AssetSource('audios/hundred_naira.wav'));
    } else if (_outputs != null &&
        _outputs!.isNotEmpty &&
        _outputs![0]["label"].contains(Artifacts.twohundred.title)) {
      await player.play(AssetSource('audios/two_hundred_naira.wav'));
    } else if (_outputs != null &&
        _outputs!.isNotEmpty &&
        _outputs![0]["label"].contains(Artifacts.fivehundred.title)) {
      await player.play(AssetSource('audios/five_hundred_naira.wav'));
    } else if (_outputs != null &&
        _outputs!.isNotEmpty &&
        _outputs![0]["label"].contains(Artifacts.onethousand.title)) {
      await player.play(AssetSource('audios/one_thousand_naira.wav'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF347F47),
        title: Text(
          'Currency Detector',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 2,
      ),
      body: _isLoading
          ? Container(
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                color: Color(0xFF347F47),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _image == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              NoImageFound(
                                assets:
                                    // 'assets/lotties/lf30_editor_iklprodp.json',
                                    'assets/lotties/animation_ll85kjq2.json',
                                title:
                                    'No image available kindly select an Image',
                                subtitle:
                                    'Image/picture may not clear or its not present in your model',
                              ),
                            ],
                          )
                        : Align(
                            alignment: AlignmentDirectional(-1, 0),
                            child: Image.file(
                              _image!,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height * 0.3,
                              fit: BoxFit.contain,
                            ),
                          ),
                    const SizedBox(height: 20),
                    if (_outputs != null && _outputs!.isNotEmpty
                        // &&
                        //     _outputs![0]["label"]
                        )
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Text(
                                  'Currency Name (Note):',
                                  textAlign: TextAlign.left,
                                  style: GoogleFonts.inter(
                                    color: Color(0xFF347F47),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              if (_outputs != null &&
                                  _outputs!.isNotEmpty &&
                                  _outputs![0]["label"]
                                      .contains(Artifacts.five.title))
                                CurrencyValue(
                                  title: '₦5.00',
                                  subtitle: 'Five Naira Note',
                                )
                              else if (_outputs != null &&
                                  _outputs!.isNotEmpty &&
                                  _outputs![0]["label"]
                                      .contains(Artifacts.ten.title))
                                CurrencyValue(
                                  title: '₦10.00',
                                  subtitle: 'Ten Naira Note',
                                )
                              else if (_outputs != null &&
                                  _outputs!.isNotEmpty &&
                                  _outputs![0]["label"]
                                      .contains(Artifacts.twenty.title))
                                CurrencyValue(
                                  title: '₦20.00',
                                  subtitle: 'Twenty Naira Note',
                                )
                              else if (_outputs != null &&
                                  _outputs!.isNotEmpty &&
                                  _outputs![0]["label"]
                                      .contains(Artifacts.fifty.title))
                                CurrencyValue(
                                  title: '₦50.00',
                                  subtitle: 'Fifty Naira Note',
                                )
                              else if (_outputs != null &&
                                  _outputs!.isNotEmpty &&
                                  _outputs![0]["label"]
                                      .contains(Artifacts.onehundred.title))
                                CurrencyValue(
                                  title: '₦100.00',
                                  subtitle: 'One Hundred Naira Note',
                                )
                              else if (_outputs != null &&
                                  _outputs!.isNotEmpty &&
                                  _outputs![0]["label"]
                                      .contains(Artifacts.twohundred.title))
                                CurrencyValue(
                                  title: '₦200.00',
                                  subtitle: 'Two Hundred Naira Note',
                                )
                              else if (_outputs != null &&
                                  _outputs!.isNotEmpty &&
                                  _outputs![0]["label"]
                                      .contains(Artifacts.fivehundred.title))
                                CurrencyValue(
                                  title: '₦500.00',
                                  subtitle: 'Five Hundred Naira Note',
                                )
                              else if (_outputs != null &&
                                  _outputs!.isNotEmpty &&
                                  _outputs![0]["label"]
                                      .contains(Artifacts.onehundred.title))
                                CurrencyValue(
                                  title: '₦1,000.00',
                                  subtitle: 'One Thousand Naira Note',
                                ),
                            ],
                          ),
                          const Gap(20),
                          if (_outputs != null &&
                              _outputs!.isNotEmpty &&
                              _outputs![0]["label"]
                                  .contains(Artifacts.five.title))
                            ImageDesc(
                              engTitle: 'Description:',
                              engDesc:
                                  'The Nigerian 5 Naira note features portraits of Alhaji Aliyu Mai-Bornu and Dr. Clement Isong, former Governors of the Central Bank. Predominantly brown or greenish, it showcases cultural designs, security features, and inscriptions denoting "Central Bank of Nigeria" and "Five Naira." Its design signifies historical and monetary significance.',
                            )
                          else if (_outputs != null &&
                              _outputs!.isNotEmpty &&
                              _outputs![0]["label"]
                                  .contains(Artifacts.ten.title))
                            ImageDesc(
                              engTitle: 'Description:',
                              engDesc:
                                  'The Nigerian 10 Naira note showcases a portrait of Alvan Ikoku, a prominent educator and politician. With vibrant colors, cultural motifs, and security elements, it bears inscriptions "Central Bank of Nigeria" and "Ten Naira," embodying educational and historical value within the nation\'s currency system.',
                            )
                          else if (_outputs != null &&
                              _outputs!.isNotEmpty &&
                              _outputs![0]["label"]
                                  .contains(Artifacts.twenty.title))
                            ImageDesc(
                              engTitle: 'Description:',
                              engDesc:
                                  'The Nigerian 20 Naira note features an illustration of Alhaji Aliyu Mai-Bornu, a former Central Bank Governor. Its design incorporates traditional patterns, security features, and inscriptions "Central Bank of Nigeria" and "Twenty Naira," symbolizing monetary heritage and leadership significance in Nigeria\'s currency landscape.',
                            )
                          else if (_outputs != null &&
                              _outputs!.isNotEmpty &&
                              _outputs![0]["label"]
                                  .contains(Artifacts.fifty.title))
                            ImageDesc(
                              engTitle: 'Description:',
                              engDesc:
                                  'The Nigerian 50 Naira note showcases an image of Ahmadu Bello, an influential statesman. With cultural motifs, security details, and the inscriptions "Central Bank of Nigeria" and "Fifty Naira," it embodies historical and leadership essence, reflecting the nation\'s heritage and political importance on its currency.',
                            )
                          else if (_outputs != null &&
                              _outputs!.isNotEmpty &&
                              _outputs![0]["label"]
                                  .contains(Artifacts.onehundred.title))
                            ImageDesc(
                              engTitle: 'Description:',
                              engDesc:
                                  'The Nigerian 100 Naira note features the portrait of Chief Obafemi Awolowo, a renowned nationalist. Adorned with cultural designs, security elements, and inscriptions "Central Bank of Nigeria" and "One Hundred Naira," it signifies historical and political prominence, capturing the essence of leadership and heritage on its denomination.',
                            )
                          else if (_outputs != null &&
                              _outputs!.isNotEmpty &&
                              _outputs![0]["label"]
                                  .contains(Artifacts.twohundred.title))
                            ImageDesc(
                              engTitle: 'Description:',
                              engDesc:
                                  'As of my last knowledge update in September 2021, Nigeria had not issued a 200 Naira note. If there have been any updates or changes since then, I wouldn\'t be aware of them. Please verify the information from a current and reliable source.',
                            )
                          else if (_outputs != null &&
                              _outputs!.isNotEmpty &&
                              _outputs![0]["label"]
                                  .contains(Artifacts.fivehundred.title))
                            ImageDesc(
                              engTitle: 'Description:',
                              engDesc:
                                  'The Nigerian 500 Naira note features a portrait of Dr. Nnamdi Azikiwe, a pivotal figure in the nation\'s history. Adorned with cultural motifs, security elements, and inscriptions "Central Bank of Nigeria" and "Five Hundred Naira," it embodies historical significance, reflecting leadership and identity on its currency denomination.',
                            )
                          else if (_outputs != null &&
                              _outputs!.isNotEmpty &&
                              _outputs![0]["label"]
                                  .contains(Artifacts.onethousand.title))
                            ImageDesc(
                              engTitle: 'Description:',
                              engDesc:
                                  'The Nigerian 1000 Naira note depicts the likeness of Alhaji Aliyu Mai-Bornu and Dr. Clement Isong, former Central Bank Governors. With cultural designs, security features, and inscriptions "Central Bank of Nigeria" and "One Thousand Naira," it signifies monetary and historical importance, honoring their roles in the nation\'s economy.',
                            ),
                          const Gap(20),
                        ],
                      )
                    else
                      (_image == null)
                          ? Container()
                          : _outputs == null
                              ? Text(
                                  'Image Not Available Yet Kindly use the below button to select an image',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Container(
                                  child: Text(''),
                                ),
                    const Gap(20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            print('Take Picture Button pressed ...');
                            takePicture();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                width: 1,
                                color: Color(0xFF347F47),
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera,
                                  size: 20,
                                  color: Color(0xFF347F47),
                                ),
                                const Gap(5),
                                Text(
                                  _image == null
                                      ? 'Take Picture'
                                      : 'Retake Picture',
                                  style: GoogleFonts.poppins(
                                    color: Color(0xFF347F47),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // const Gap(20),
                        InkWell(
                          onTap: () {
                            print('Pick Image Button pressed ...');
                            pickImage();
                            // _image == null;
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            decoration: BoxDecoration(
                              color: Color(0xFF347F47),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.photo,
                                  size: 20,
                                  color: Colors.white,
                                ),
                                const Gap(5),
                                Text(
                                  _image == null
                                      ? 'Upload Image'
                                      : 'Re-upload Image',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Gap(20),
                    InkWell(
                      onTap: () async {
                        print('Sound Button pressed ...');
                        playSound();
                      },
                      child: Container(
                        // width: MediaQuery.of(context).size.width * .4,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 20),
                        decoration: BoxDecoration(
                          color: Color(0xFF347F47),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.audiotrack,
                              size: 20,
                              color: Colors.white,
                            ),
                            const Gap(5),
                            Text(
                              'Play Sound',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Gap(40),
                  ],
                ),
              ),
            ),
    );
  }
}

class CurrencyValue extends StatelessWidget {
  final String? title;
  final String? subtitle;
  CurrencyValue({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title!,
          style: GoogleFonts.inter(
            color: Color(0xFF347F47),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        // const Gap(5),
        Text(
          subtitle!,
          style: GoogleFonts.inter(
            color: Color(0xFF347F47),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class ImageDesc extends StatelessWidget {
  String engTitle;
  String engDesc;
  ImageDesc({
    Key? key,
    required this.engTitle,
    required this.engDesc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              engTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(10),
            Text(
              engDesc,
              style: GoogleFonts.inter(
                color: Colors.black,
                fontSize: 20,
              ),
            ),
            const Gap(40),
          ],
        )
      ],
    );
  }
}

class NoImageFound extends StatelessWidget {
  String? title, subtitle, assets;
  NoImageFound({
    required this.title,
    required this.subtitle,
    this.assets,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 2,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Lottie.asset(
            assets!,
            filterQuality: FilterQuality.high,
            height: 250,
          ),
          const Gap(10),
          Text(
            title!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
          const Gap(10),
          Text(
            subtitle!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
