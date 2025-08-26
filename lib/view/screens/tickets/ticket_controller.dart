
import 'package:escrowcorner/view/screens/tickets/screen_support_tickets.dart';
import 'package:escrowcorner/widgets/custom_api_url/constant_url.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../widgets/custom_token/constant_token.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:open_file/open_file.dart';

class TicketController extends GetxController {
  var isLoading = false.obs; // For category loading
  var isSubmitting = false.obs; // For ticket submission loading
  var isSubmittingReply = false.obs; // For reply submission loading
  TextEditingController titleController = TextEditingController();
  TextEditingController messageController = TextEditingController();
  var tickets = <Ticket>[].obs;
  var selectedCategoryId = Rxn<int>(); // Holds the selected category ID
  var selectedCategory = " ".obs; // Selected category
  var selectedFiles = <File>[].obs; // For storing selected files
  final ImagePicker _picker = ImagePicker();
  RxList<Category> categories = <Category>[].obs;
  var ticketDetails = {}.obs;
  var error = ''.obs;
  
  // Pagination variables
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var isLoadingMore = false.obs;
  var hasMoreData = true.obs;
  
  // Base URL for API calls - using dynamic configuration
  String get apiBaseUrl => baseUrl;
  
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

    if (messageController.text.isEmpty ) {
      Get.snackbar('Error', 'Message is required.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      isSubmitting(true);
      String? token = await getToken();

      if (token == null) {
        Get.snackbar("Error", "Unable to authenticate. Please login again.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        isSubmitting(false);
        update();
        return;
      }

      final url = Uri.parse('$baseUrl/api/new_ticket');

      // Create a multipart request
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        })
        ..fields['title'] = titleController.text
        ..fields['message'] = messageController.text
        ..fields['category'] = selectedCategoryId.value.toString();

      // Add files if available
      if (selectedFiles.isNotEmpty) {
        for (int i = 0; i < selectedFiles.length; i++) {
          request.files.add(await http.MultipartFile.fromPath('attachments[]', selectedFiles[i].path));
          print("File attached: ${selectedFiles[i].path}");
        }
        print("Total files attached: ${selectedFiles.length}");
      } else {
        // Add empty array field if no files are selected
        request.fields['attachments'] = '[]';
        print("No files attached - sending empty attachments array");
      }

      print('Request Fields: ${request.fields}');
      print('Request Files: ${request.files.length} files');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          Get.snackbar("Success", "Ticket created successfully",
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
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
      isSubmitting(false);
      update();
    }
  }

  void clearFields() {
    selectedCategory.value = '';
    titleController.clear();
    messageController.clear();
    selectedFiles.clear();
  }

  // Method to pick image files
  Future<void> _pickImageFile() async {
    try {
      final List<XFile> files = await _picker.pickMultiImage();
      if (files.isNotEmpty) {
        selectedFiles.addAll(files.map((file) => File(file.path)));
      }
    } catch (e) {
      print('Error picking images: $e');
      Get.snackbar(
        'Error',
        'Failed to pick images: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Method to pick document files
  Future<void> _pickDocumentFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'txt'],
      );

      if (result != null && result.files.isNotEmpty) {
        selectedFiles.addAll(
          result.files
              .where((file) => file.path != null)
              .map((file) => File(file.path!))
        );
        print("Picked files: ${selectedFiles.length} files");
      }
    } catch (e) {
      print('Error picking documents: $e');
      Get.snackbar(
        'Error',
        'Failed to pick documents: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Method to show picker options
  void showPickerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.image, color: Colors.blue),
                title: Text("Select Image"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFile();
                },
              ),
              ListTile(
                leading: Icon(Icons.file_copy, color: Colors.green),
                title: Text("Select File"),
                onTap: () {
                  Navigator.pop(context);
                  _pickDocumentFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Method to remove a specific file
  void removeFile(int index) {
    if (index >= 0 && index < selectedFiles.length) {
      selectedFiles.removeAt(index);
    }
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

  //Method for Fetch Tickets History with pagination
  Future<void> fetchTickets({int page = 1}) async {
    try {
      if (page == 1) {
        isLoading(true);
      } else {
        isLoadingMore(true);
      }
      
      String? token = await getToken();
      if (token == null) {
        Get.snackbar('Error', 'Token is null',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
        isLoading(false);
        isLoadingMore(false);
        return;
      }

      var response = await http.get(
        Uri.parse('$baseUrl/api/tickets?page=$page&per_page=3'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Tickets Response Status: ${response.statusCode}');
      print('Tickets Response Body: ${response.body}');

      if (response.statusCode == 200) {
        var responseData = json.decode(response.body);
        if (responseData.containsKey('data') && responseData['data'].containsKey('tickets')) {
          var fetchedTickets = responseData['data']['tickets'].map<Ticket>((ticket) => Ticket.fromJson(ticket)).toList();
          
          // Update pagination info if available (now nested under data)
          if (responseData['data']['pagination'] != null) {
            currentPage.value = responseData['data']['pagination']['current_page'] ?? 1;
            totalPages.value = responseData['data']['pagination']['last_page'] ?? 1;
            hasMoreData.value = responseData['data']['pagination']['has_more_pages'] ?? false;
          }
          
          if (page == 1) {
            tickets.clear();
            hasMoreData.value = true;
          }
          
          // Add new tickets to the list
          tickets.addAll(fetchedTickets);
          
          print('Tickets fetched successfully: ${tickets.length} items');
          print('Current page: ${currentPage.value}, Total pages: ${totalPages.value}, Has more: ${hasMoreData.value}');
        } else {
          print('Unexpected response structure: $responseData');
        }
      } else {
        print('Error fetching tickets: ${response.statusCode}');
        Get.snackbar('Error', 'Failed to fetch tickets',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      print('Exception occurred: $e');
      Get.snackbar('Error', 'Failed to fetch tickets: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white);
    } finally {
      isLoading(false);
      isLoadingMore(false);
    }
  }

  // Method to load more tickets
  Future<void> loadMoreTickets() async {
    if (!isLoadingMore.value && hasMoreData.value) {
      await fetchTickets(page: currentPage.value + 1);
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
      isSubmittingReply.value = false;
      return;
    }
    
    if (message.isEmpty) {
      Get.snackbar('Error', 'Message is required.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    
    isSubmittingReply.value = true;
    
    try {
      final url = Uri.parse('$baseUrl/api/post_reply');

      // Create a multipart request
      final request = http.MultipartRequest('POST', url)
        ..headers.addAll({
          'Authorization': 'Bearer $token',
          'Content-Type': 'multipart/form-data',
        })
        ..fields['ticket_id'] = ticketId
        ..fields['message'] = message;

      // Add files if available
      if (selectedFiles.isNotEmpty) {
        for (int i = 0; i < selectedFiles.length; i++) {
          request.files.add(await http.MultipartFile.fromPath('attachments[]', selectedFiles[i].path));
        }
      } else {
        // Add empty attachments array if no files are selected
        request.fields['attachments[]'] = '';
      }

      // Debug logging
      print("=== POST REPLY API REQUEST ===");
      print("URL: $url");
      print("Ticket ID: $ticketId");
      print("Message: $message");
      print("Number of attachments: ${selectedFiles.length}");
      for (int i = 0; i < selectedFiles.length; i++) {
        print("Attachment ${i + 1}: ${selectedFiles[i].path}");
      }
      print("================================");

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Debug logging for response
      print("=== POST REPLY API RESPONSE ===");
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("================================");

      if (response.statusCode == 200) {
        final reply = json.decode(response.body);
        print("Post Reply Success");
        Get.snackbar(
          'Success',
          'Reply posted successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        
        // Clear the selected files after successful submission
        selectedFiles.clear();
        
        // After posting, fetch the updated ticket details and replies
        await fetchTicketDetail(ticketId);
      } else {
        print("Post Reply Failed: ${response.statusCode}");
        print("Response: ${response.body}");
        Get.snackbar(
          'Error',
          'Failed to post reply. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Post Reply Error: $e");
      Get.snackbar(
        'Error',
        'An error occurred while posting reply.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
    
    isSubmittingReply.value = false;
  }

  // Method to download attachment from URL (mimics website behavior)
  Future<void> downloadAttachmentFromUrl(String attachmentUrl, String fileName) async {
    try {
      String? token = await getToken();
      if (token == null) {
        Get.snackbar('Error', 'Unable to authenticate. Please login again.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Show download started message
      Get.snackbar(
        'Download Started',
        'Downloading: $fileName',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 2),
      );

      // Get the appropriate directory for saving files
      Directory? saveDir;
      if (Platform.isAndroid) {
        // For Android, try to save to Pictures directory (Gallery)
        saveDir = Directory('/storage/emulated/0/Pictures');
        if (!await saveDir.exists()) {
          // Fallback to Downloads if Pictures doesn't exist
          saveDir = Directory('/storage/emulated/0/Download');
          if (!await saveDir.exists()) {
            saveDir = await getExternalStorageDirectory();
          }
        }
      } else if (Platform.isIOS) {
        // For iOS, save to app documents directory
        saveDir = await getApplicationDocumentsDirectory();
      } else {
        saveDir = await getApplicationDocumentsDirectory();
      }

      if (saveDir == null) {
        throw Exception('Could not access storage directory');
      }

      // Create file path
      String filePath = path.join(saveDir.path, fileName);
      
      // Initialize Dio for download
      Dio dio = Dio();
      
      // Add authorization header if needed
      dio.options.headers['Authorization'] = 'Bearer $token';
      
      // Download the file
      await dio.download(
        attachmentUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total) * 100;
            print('Download progress: ${progress.toStringAsFixed(1)}%');
          }
        },
      );

      // Show success message
      String saveLocation = Platform.isAndroid ? 'Gallery' : 'Documents';
      Get.snackbar(
        'Download Complete',
        '$fileName saved to $saveLocation',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
      );

      // Try to open the file
      try {
        await OpenFile.open(filePath);
      } catch (e) {
        print('Could not open file: $e');
        Get.snackbar(
          'File Downloaded',
          '$fileName saved to $saveLocation',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
      }
      
    } catch (e) {
      print('Download error: $e');
      Get.snackbar(
        'Download Error',
        'Failed to download $fileName: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 4),
      );
    }
  }

  // Method to download attachment
  Future<void> downloadAttachment(String fileName) async {
    try {
      String? token = await getToken();
      if (token == null) {
        Get.snackbar('Error', 'Unable to authenticate. Please login again.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      // Construct dynamic download URL with base path and attachment
      final downloadUrl = '$baseUrl/attachment/$fileName';
      
      // Use the same download logic as downloadAttachmentFromUrl
      await downloadAttachmentFromUrl(downloadUrl, fileName);
      
    } catch (e) {
      Get.snackbar(
        'Download Error',
        'Failed to download $fileName: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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
  final String? attachment;

  Ticket({
    required this.category,
    required this.title,
    required this.ticket_id,
    required this.status,
    required this.lastUpdated,
    this.attachment,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    // Debug logging to see what we're receiving
    print('=== TICKET JSON DEBUG ===');
    print('Full JSON: $json');
    print('Category field: ${json['category']}');
    print('Category type: ${json['category']?.runtimeType}');
    print('Category name direct: ${json['category']?['name']}');
    print('========================');
    
    // Simple and direct category name extraction
    String categoryName = 'Unknown';
    
    // Direct extraction from category object
    if (json['category'] != null && json['category'] is Map) {
      categoryName = json['category']['name'] ?? 'Unknown';
      print('Extracted category name: $categoryName');
    }
    
    print('Final category name: $categoryName');
    
    return Ticket(
      category: categoryName,
      title: json['title'] ?? '',
      ticket_id: json['ticket_id'] ?? '',
      status: json['status'] ?? '',
      lastUpdated: json['updated_at']?.toString() ?? '',
      attachment: json['attachment'] ?? json['attachments'] ?? json['files'],
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


