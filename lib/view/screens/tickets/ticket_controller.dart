
import 'package:dacotech/view/screens/tickets/screen_support_tickets.dart';
import 'package:dacotech/widgets/custom_api_url/constant_url.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../widgets/custom_token/constant_token.dart';

class TicketController extends GetxController {
  var isLoading = false.obs; // Initialize isLoading as false initially
  TextEditingController titleController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  var selectedPriority = ''.obs;
  var tickets = [].obs;
  var selectedCategoryId = Rxn<int>(); // Holds the selected category ID
  var selectedCategory = " ".obs; // Selected category
  var priorities = <String>['low', 'medium', 'high'].obs;
  RxList<Category> categories = <Category>[].obs;
  var ticketDetails = {}.obs;
  var error = ''.obs;


  @override
  void onInit() {
    fetchTickets();
    fetchCategories();
    super.onInit();
  }

  // Method for Open New Ticket
  Future<void> openNewTicket(BuildContext context) async {
    if (titleController.text.isEmpty ) {
      Get.snackbar('Error', 'title is required.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (selectedCategory.value == '' ) {
      Get.snackbar('Error', 'select a valid category',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (selectedPriority.value == '' ) {
      Get.snackbar('Error', 'select a valid priority',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (messageController.text.isEmpty ) {
      Get.snackbar('Error', 'Message is required.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      isLoading(true);
      String? token = await getToken();

      if (token == null) {
        Get.snackbar("Error", "Unable to authenticate. Please login again.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        isLoading(false);
        update();
        return;
      }

      var body = {
        'title': titleController.text,
        'message': messageController.text,
        'category':selectedCategoryId.value,
        'priority': selectedPriority.value,
      };

      var headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      print('Request Body: $body');
      print('Headers: $headers');

      var jsonBody = jsonEncode(body); // Encode the body as JSON

      var response = await http.post(
        Uri.parse('$baseUrl/api/new_ticket'),
        headers: headers,
        body: jsonBody, // Pass the JSON body in the request
      );


      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          Get.snackbar("Success", "Ticket created successfully",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,);
          Get.off(ScreenSupportTicket());
          clearFields();
          await fetchTickets();
        } else {
          print('Error creating ticket: ${responseData['message']}');
          Get.snackbar("Error", "Error creating ticket: ${responseData['message']}",
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
        }
      } else {
          print('Error creating ticket: ${response.statusCode}');
          print('Response Body: ${response.body}');
          Get.snackbar("Error", "Error creating ticket: ${response.statusCode}",
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print('Exception occurred: $e');
      Get.snackbar("Error", "An error occurred: $e",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
      update();
    }
  }


  void clearFields() {
    selectedCategory.value = '';
    titleController.clear();
    selectedPriority.value= '';
    messageController.clear();
  }

  //Method for Fetch Ticket Categories
  Future<void> fetchCategories() async {
    isLoading.value = true;
    String apiUrl = '$baseUrl/api/ticketCategories';

    try {
    String? token = await getToken();
    if (token == null) {
      throw Exception('Token is null or empty');
    }

      var response = await http.get(Uri.parse(apiUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          }
      );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      List<dynamic> data = jsonResponse['data']['ticketCategories'];
      List<Category> fetchedCategories =
      data.map((item) => Category.fromJson(item)).toList();
      categories.assignAll(fetchedCategories);
      //print('Fetched Categories: $categories');
      } else {
        throw Exception('Failed to load categories. Status code: ${response.statusCode}');
}
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  //Method for Fetch Tickets History
  Future<void> fetchTickets() async {
    try {
      isLoading(true);
      String? token = await getToken(); // Implement your getToken() method for authentication
      if (token != null) {
        var response = await http.get(
          Uri.parse('$baseUrl/api/tickets'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        //print('Response Status Code: ${response.statusCode}');
        //print('Response Body: ${response.body}');
        if (response.statusCode == 200) {
          var responseData = json.decode(response.body);
          if (responseData.containsKey('data') && responseData['data'].containsKey('tickets')) {
            var fetchedTickets = responseData['data']['tickets'].map<Ticket>((ticket) => Ticket.fromJson(ticket)).toList();
            // Reverse the list to have the latest tickets at the top
            fetchedTickets = fetchedTickets.reversed.toList();
            // Assign the reversed list to the tickets observable list
            tickets.assignAll(fetchedTickets);
          } else {
            print('Unexpected response structure: $responseData');
          }
        } else {
          print('Error fetching tickets: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Exception occurred: $e');
    } finally {
      isLoading(false);
    }
  }

  //Method for Fetching Ticket Details

  var ticketReplies = [].obs;
  Future<void> fetchTicketDetail(String ticketId) async {
    isLoading(true);
    try {
      String? token = await getToken();
      if (token == null) {
        throw Exception('Token is null or empty');
      }
      var response = await http.get(
        Uri.parse('$baseUrl/api/get_ticket_detail/$ticketId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        var ticketData = responseData['data']['tickets'];
        var categoryData = responseData['data']['tickets']['category'];
        var repliesData = responseData['data']['ticket_replies'];
        if (ticketData != null) {
          ticketDetails.value = {
            ...ticketData,
            'category': categoryData,
          };
          ticketReplies.value = repliesData;
        } else {
          throw Exception('No ticket found with the provided ID');
        }
      } else {
        error('Failed to load ticket details');
      }
      await Future.delayed(Duration(seconds: 1));
    } catch (e) {
      error('An error occurred: $e');
    } finally {
      isLoading(false);
    }
  }
  // Method to Post Reply
  Future<void> postReply(BuildContext context, String ticketId, String message) async {

    String? token = await getToken();
    if (token == null) {
      Get.snackbar('Error', 'Token is null');
      isLoading.value = false;
      return;
    }
    isLoading.value =true;
    final response = await http.post(
      Uri.parse('$baseUrl/api/post_reply'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'ticket_id': ticketId,
        'message': message,
      }),
    );
    if (response.statusCode == 200) {
      final reply = json.decode(response.body);
      print("Post Reply Success");
      ticketReplies.add(reply); // Add the new reply to the list
    } else {
      print("Post Reply Failed");
      // Handle error
    }
    await Future.delayed(Duration(seconds: 1)); // Simulating network request
    // After posting, fetch the updated ticket details and replies
    await fetchTicketDetail(ticketId);
    isLoading.value = false;
    Navigator.pop(context);
  }

  @override
  void onClose() {
    clearFields(); // Reset fields when controller is disposed
    super.onClose();
  }

}
class Ticket {
  final String category;
  final String title;
  final String ticket_id;
  final String status;
  final String lastUpdated;

  Ticket({
    required this.category,
    required this.title,
    required this.ticket_id,
    required this.status,
    required this.lastUpdated,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      category: json['ticketcategory_id']?.toString() ??'',
      title: json['title'] ?? '',
      ticket_id: json['ticket_id'] ?? '',
      status: json['status'] ?? '',
      lastUpdated: json['updated_at']?.toString()??'',
    );
  }
}


class Category {
  final int id;
  final String name;
  final String createdAt;
  final String updatedAt;

  Category({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}


