import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_html/flutter_html.dart';

class PrivacyPolicyPage extends StatefulWidget {
  @override
  _PrivacyPolicyPageState createState() => _PrivacyPolicyPageState();
}

class _PrivacyPolicyPageState extends State<PrivacyPolicyPage> {
  String? _privacyPolicyContent;

  @override
  void initState() {
    super.initState();
    _fetchPrivacyPolicy();
  }

  Future<void> _fetchPrivacyPolicy() async {
    String apiUrl = "https://wingx.shop/api/get_policy/1"; // 請替換為您的API URL
    Dio dio = Dio();

    try {
      Response response = await dio.get(apiUrl);
      setState(() {
        _privacyPolicyContent = response.data['content']; // 根據您的API響應結構進行調整
      });
    } catch (e) {
      print("Error fetching privacy policy: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('隱私權政策', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _privacyPolicyContent != null
              ? Html(data: _privacyPolicyContent)
              : CircularProgressIndicator(),
        ),
      ),
    );
  }
}
