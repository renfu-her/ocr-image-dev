import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:external_path/external_path.dart';
import 'package:image_picker/image_picker.dart';
import 'privacy.dart';
import 'feedback.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OCR 圖片辨識',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: ImageUploadPage(),
    );
  }
}

class ImageUploadPage extends StatefulWidget {
  @override
  _ImageUploadPageState createState() => _ImageUploadPageState();
}

class _ImageUploadPageState extends State<ImageUploadPage> {
  File? _image;
  String? _response;
  bool _isUploading = false;

  Future<void> _saveResponseToTxtFile() async {
    if (_response == null) return;

    // 請求寫入權限
    final directory = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOCUMENTS);

    // 確保目錄存在
    final dir = directory;

    // 建立檔案 (如果不存在)
    DateTime now = DateTime.now();
    String formattedDate = now
        .toString()
        .replaceAll(':', '')
        .replaceAll('-', '')
        .replaceAll(' ', '_')
        .split('.')[0];
    final file = File('${dir}/ocr_$formattedDate.txt');
    file.writeAsStringSync(_response!);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('已保存到內部儲存空間/Documents\資料夾裏面的 ocr_$formattedDate.txt')),
    );
  }

  Future<void> _pickImageFromCamera() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    setState(() {
      _response = null;
    });
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadImage(); // 拍照後立即上傳
    }
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _response = null;
    });
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    setState(() {
      _isUploading = true; // 開始上傳前設定為 true
    });

    String apiUrl = "https://blog.dev-laravel.co/google-ocr";
    Dio dio = Dio();

    try {
      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(_image!.path),
      });

      Response response = await dio.post(apiUrl, data: formData);

      Map<String, dynamic> responseData =
          response.data is String ? jsonDecode(response.data) : response.data;
      String text = responseData['data'] ?? "沒有文字解析出來";

      setState(() {
        _response = text;
      });
    } catch (e) {
      setState(() {
        _response = "Error uploading image: $e";
      });
    } finally {
      setState(() {
        _isUploading = false; // 上傳完成或出錯後設定為 false
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OCR 圖片辨識', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Center(
                child: Text('選單',
                    style: TextStyle(color: Colors.white, fontSize: 24)),
              ),
              decoration: BoxDecoration(
                color: Colors.lightBlue,
              ),
            ),
            ListTile(
              title: Text('問題反饋', style: TextStyle(fontSize: 20)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FeedbackPage()),
                );
              },
            ),
            ListTile(
              title: Text('隱私權政策', style: TextStyle(fontSize: 20)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (_image != null)
                  Icon(
                    Icons.image,
                    color: Colors.lightBlue,
                    size: 100,
                  ),
                SizedBox(height: 10),
                ElevatedButton(
                    onPressed: _pickImage,
                    child: Text(
                      '選擇圖片上傳',
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.lightBlue,
                      onPrimary: Colors.white,
                    )),
                SizedBox(height: 10),
                ElevatedButton(
                    onPressed: _pickImageFromCamera,
                    child: Text('拍照 & 上傳圖片'),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.lightBlue,
                      onPrimary: Colors.white,
                    )),
                SizedBox(height: 10),
                if (_isUploading) CircularProgressIndicator(),
                if (_response != null)
                  ElevatedButton(
                      onPressed: _saveResponseToTxtFile,
                      child: Text('保存文字到檔案'),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blueGrey,
                        onPrimary: Colors.white,
                      )),
                SizedBox(height: 20),
                if (_response != null) Text('Response:\n$_response'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
