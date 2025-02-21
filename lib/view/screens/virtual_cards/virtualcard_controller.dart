import 'dart:ui';

import 'package:dacotech/widgets/custom_api_url/constant_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../widgets/custom_token/constant_token.dart';

class VirtualCardController extends GetxController {
  var virtualCards = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;
  RxBool isCardAddedSuccessfully = false.obs;

  @override
  void onInit() {
    fetchVirtualCards();
    super.onInit();
  }

  // Method for Created New Virtual Card
  Future<void> createVirtualCard(double amount, String cardHolderName) async {
    try {
      isLoading(true);
      String? token = await getToken();

      if (token != null) {
        var response = await http.post(
          Uri.parse('$baseUrl/api/createVCard'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'amount': amount,
            'card_holder_name': cardHolderName,
          }),
        );

        if (response.statusCode == 200) {
          var contentType = response.headers['content-type'];
          isCardAddedSuccessfully.value=true;

          if (contentType != null && contentType.contains('application/json')) {
            var cardData = json.decode(response.body);
            if (cardData['success']) {
              virtualCards.add(cardData);
              isCardAddedSuccessfully.value = true;
              Get.snackbar('Message', cardData['message'],
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,);
              fetchVirtualCards(); // Fetch virtual cards immediately after creation
              print('Virtual card created successfully: $cardData');
            } else {
              print('Error creating virtual card: ${cardData['message']}');
              isCardAddedSuccessfully.value = false;
              Get.snackbar("Error", cardData['message'],
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,);
            }
          } else {
            print('Unexpected response format: HTML');
            print('Response: ${response.statusCode} ${response.reasonPhrase}');
            isCardAddedSuccessfully.value = false;
          }
        } else {
          print('Error creating virtual card: ${response.statusCode}');
          print('Response body: ${response.body}');
          isCardAddedSuccessfully.value = false;
        }
      }
    } catch (e) {
      print('Exception occurred: $e');
      isCardAddedSuccessfully.value = false; // Clear success flag
    } finally {
      isLoading(false);
    }
  }

// Method for Fetch Virtual Card History
  Future<void> fetchVirtualCards() async {
    try {
      isLoading(true);
      String? token = await getToken();
      if (token != null) {
        var response = await http.get(
          Uri.parse('$baseUrl/api/vcards'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (response.statusCode == 200) {
          var cardsData = json.decode(response.body);
          print('cardsData: $cardsData');
          if (cardsData['success'] && cardsData['data'] is List) {
            List<Map<String, dynamic>> cards =
            cardsData['data'].cast<Map<String, dynamic>>().toList();
            print('cards: $cards');
            if (cards.isEmpty) {
              print('No virtual cards found');
            } else {
              virtualCards.assignAll(
                cards.map((card) => {
                  'id': card['id']?.toString() ?? '',
                  'card_number': card['card_number'] ?? '',
                  'card_type': card['card_type'] ?? '',
                  'exp_month': card['exp_month'] ?? '',
                  'exp_year': card['exp_year'] ?? '',
                }).toList(),
              );
              print('virtualCards: $virtualCards'); // Debug statement
            }
          } else {
            print('No virtual cards found');
          }
        } else if (response.statusCode == 404) {
          print('API endpoint not found (404)');
        } else {
          print('Error fetching virtual cards: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Exception occurred: $e');
    } finally {
      isLoading(false);
    }
  }

}
