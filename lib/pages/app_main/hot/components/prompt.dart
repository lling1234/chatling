import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  final Dio _dio;

  ChatService(this._dio) {
    // 初始化 aiResponseList
    aiResponseList = [];
  }

  List<String>? aiResponseList; // 声明为可空类型

  Future<String> sendMessage(String prompt, String currentTab) async {
    // 创建消息列表
    final messages = [
      Message(role: 'system', content: prompt),
      Message(role: 'user', content: currentTab),
    ];

    try {
      final response = await _dio.post(
        'http://okgo.pro:8000/v1/chat/completions',
        data: {
          "model": "glm4",
          "messages": messages.map((msg) => msg.toJson()).toList(),
          "stream": false,
        },
        options: Options(headers: {"Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTcxMzM0NTM5MiwianRpIjoiNGJkNjFkMWYtNWFmNy00YmRiLWE0YjItYThhOTc3ZDM1NGRhIiwidHlwZSI6InJlZnJlc2giLCJzdWIiOiI1YTE2MDFhZTc5NWE0NDYzOWY3MTVlNDc0MDdlZWRkMiIsIm5iZiI6MTcxMzM0NTM5MiwiZXhwIjoxNzI4ODk3MzkyLCJ1aWQiOiI2NWNiOGZkNzFlMjllYTNiNGZlZmY0NDMiLCJ1cGxhdGZvcm0iOiJwYyIsInJvbGVzIjpbInVuYXV0aGVkX3VzZXIiXX0.H26sLOvAIdcRMjr_Yds_WQhcBBHuVrsRzLIshT2-_Kg"}
        ),
      );
      String aiResponse = response.data['choices'][0]['message']['content'].toString();

      // 检查 aiResponseList 是否为 null
      if (aiResponseList != null) {
        aiResponseList!.add(aiResponse); // 安全地添加元素
      } else {
        aiResponseList = [aiResponse]; // 如果是 null，则初始化它
      }

      // 保存评论内容
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList('AIComment', aiResponseList!); // 现在 aiResponseList 肯定不是 null

      return aiResponse;
    } catch (e) {
      print('Error sending message: $e');
      return '';
    }
  }
}

class Message {
  final String role;
  final String content;

  Message({required this.role, required this.content});

  Map toJson() {
    return {'role': role, 'content': content};
  }
}