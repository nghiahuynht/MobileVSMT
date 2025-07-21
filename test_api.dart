import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  await testCustomerApi();
}

Future<void> testCustomerApi() async {
  final url = 'https://vsmt-api.gamanjsc.com/api/Customer/GetCustomerPaging';
  
  final headers = {
    'Accept': 'application/json, text/plain, */*',
    'Accept-Language': 'en-US,en;q=0.9,vi;q=0.8',
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVc2VySWQiOiIxIiwiTG9naW5OYW1lIjoiYWRtaW4iLCJSb2xlIjoiQWRtaW4iLCJuYmYiOjE3NTI5OTcwODksImV4cCI6MTc1MzIxMzA4OSwiaWF0IjoxNzUyOTk3MDg5fQ.Yd6Fo5O96pdA4MkCY8n0oOnDEI4A90wdQ87FE9I0vl8',
    'Connection': 'keep-alive',
    'Content-Type': 'application/json; charset=UTF-8',
    'Origin': 'https://vsmt.gamanjsc.com',
    'Referer': 'https://vsmt.gamanjsc.com/',
    'Sec-Fetch-Dest': 'empty',
    'Sec-Fetch-Mode': 'cors',
    'Sec-Fetch-Site': 'same-site',
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/138.0.0.0 Safari/537.36',
    'sec-ch-ua': '"Not)A;Brand";v="8", "Chromium";v="138", "Google Chrome";v="138"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"macOS"'
  };

  final body = {
    'pageIndex': 1,
    'pageSize': 10,
    'searchString': ''
  };

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    print('Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      print('Success! Parsed JSON:');
      print(jsonEncode(jsonResponse));
      
      // Check structure
      if (jsonResponse['data'] != null) {
        final data = jsonResponse['data'];
        print('Total Items: ${data['totalItem']}');
        print('Data List Length: ${data['dataList']?.length ?? 0}');
        
        if (data['dataList'] is List && data['dataList'].isNotEmpty) {
          print('First Customer:');
          print(jsonEncode(data['dataList'][0]));
        }
      }
    } else {
      print('Error: ${response.statusCode}');
      print('Error Body: ${response.body}');
    }
  } catch (e) {
    print('Exception: $e');
  }
} 