// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
//
// class AuthService {
//   final storage = FlutterSecureStorage();
//
//   Future<void> login(String username, String password) async {
//     final response = await http.post(
//       Uri.parse('https://damaspay.com/api/authenticate'),
//       headers: <String, String>{
//         'Content-Type': 'application/json; charset=UTF-8',
//       },
//       body: jsonEncode(<String, String>{
//         'username': username,
//         'password': password,
//       }),
//     );
//
//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       final token = data['token'];
//       await storage.write(key: 'authToken', value: token);
//     } else {
//       throw Exception('Failed to authenticate');
//     }
//   }
//
//   Future<String?> getToken() async {
//     return await storage.read(key: 'authToken');
//   }
//
//   Future<void> logout() async {
//     await storage.delete(key: 'authToken');
//   }
// }
