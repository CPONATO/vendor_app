import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void manageHttpResponse({
  required http.Response response,
  required BuildContext context,
  required VoidCallback onSuccess,
}) {
  // Log để debug
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  switch (response.statusCode) {
    case 200:
    case 201:
      if (response.body != null && response.body.isNotEmpty) {
        final decodedResponse = jsonDecode(response.body);
        onSuccess.call();
      } else {
        showSnackBar(context, 'Error: Empty response from server');
      }
      break;
    case 400:
      showSnackBar(context, 'Error: Bad request');
      break;
    case 500:
      showSnackBar(context, 'Error: Server error');
      break;
    default:
      showSnackBar(context, 'Error: Something went wrong');
  }
}

void showSnackBar(BuildContext context, String title) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      margin: const EdgeInsets.all(15),
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.grey,
      content: Text(title),
    ),
  );
}
