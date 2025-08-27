
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
import '../../controller/language_controller.dart';

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
    fetchTickets(); // Categories are now fetched along with tickets
    super.onInit();
  }

  // Method for Open New Ticket
  Future<void> openNewTicket(BuildContext context) async {
    if (titleController.text.isEmpty ) {
      Get.snackbar(
        Get.find<LanguageController>().getTranslation('error'), 
        Get.find<LanguageController>().getTranslation('title_is_required'),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (selectedCategory.value == '' ) {
      Get.snackbar(
        Get.find<LanguageController>().getTranslation('error'), 
        Get.find<LanguageController>().getTranslation('select_a_category'),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    if (messageController.text.isEmpty ) {
      Get.snackbar(
        Get.find<LanguageController>().getTranslation('error'), 
        Get.find<LanguageController>().getTranslation('message_is_required'),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      isSubmitting(true);
      String? token = await getToken();

      if (token == null) {
        Get.snackbar(
          Get.find<LanguageController>().getTranslation('error'), 
          Get.find<LanguageController>().getTranslation('unable_to_authenticate'),
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
          // Show the message from API response
          String apiMessage = responseData['message'] ?? Get.find<LanguageController>().getTranslation('ticket_created_successfully');
          Get.snackbar(
            Get.find<LanguageController>().getTranslation('success'), 
            apiMessage,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
                      Get.off(ScreenSupportTicket());
            clearAllData();
            await fetchTickets();
        } else {
          print('Error creating ticket: ${responseData['message']}');
          Get.snackbar(
            Get.find<LanguageController>().getTranslation('error'), 
            "${Get.find<LanguageController>().getTranslation('error_creating_ticket')}: ${responseData['message']}",
              backgroundColor: Colors.red,
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        print('Error creating ticket: ${response.statusCode}');
        print('Response Body: ${response.body}');
        Get.snackbar(
          Get.find<LanguageController>().getTranslation('error'), 
          "${Get.find<LanguageController>().getTranslation('error_creating_ticket')}: ${response.statusCode}",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      print('Exception occurred: $e');
      Get.snackbar(
        Get.find<LanguageController>().getTranslation('error'), 
        "${Get.find<LanguageController>().getTranslation('an_error_occurred')}: $e",
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

  // Method to clear all data and reset state when opening new ticket screen
  void clearAllData() {
    selectedCategory.value = '';
    selectedCategoryId.value = null;
    titleController.clear();
    messageController.clear();
    selectedFiles.clear();
    isSubmitting.value = false;
    isSubmittingReply.value = false;
    error.value = '';
    // Reset pagination
    currentPage.value = 1;
    totalPages.value = 1;
    hasMoreData.value = true;
    isLoadingMore.value = false;
  }

  // Method to pick image files
  Future<void> _pickImageFile() async {
    try {
      // Check if user already has 2 files
      if (selectedFiles.length >= 2) {
        Get.snackbar(
          Get.find<LanguageController>().getTranslation('error'),
          Get.find<LanguageController>().getTranslation('max_files_reached'),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      final List<XFile> files = await _picker.pickMultiImage();
      if (files.isNotEmpty) {
        // Calculate how many more files can be added
        int remainingSlots = 2 - selectedFiles.length;
        
        // List of allowed image extensions
        List<String> allowedExtensions = ['jpg', 'jpeg', 'png', 'PNG'];
        
        // Filter files by allowed extensions
        List<XFile> validFiles = [];
        List<String> invalidFiles = [];
        
        for (int i = 0; i < files.length && validFiles.length < remainingSlots; i++) {
          var file = files[i];
          String extension = file.path.split('.').last.toLowerCase();
          if (allowedExtensions.contains(extension)) {
            validFiles.add(file);
          } else {
            invalidFiles.add(file.path.split('/').last);
          }
        }
        
        // Add valid files
        for (var file in validFiles) {
          selectedFiles.add(File(file.path));
        }
        
        // Show error for invalid files
        if (invalidFiles.isNotEmpty) {
          Get.snackbar(
            Get.find<LanguageController>().getTranslation('error'),
            "${Get.find<LanguageController>().getTranslation('invalid_file_type')}: ${invalidFiles.join(', ')}",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 4),
          );
        }
        
                 // Show message if some files were skipped due to limit
         if (files.length > remainingSlots && validFiles.length >= remainingSlots) {
           Get.snackbar(
             Get.find<LanguageController>().getTranslation('error'),
             Get.find<LanguageController>().getTranslation('you_can_only_upload_a_maximum_of_2_files'),
             backgroundColor: Colors.red,
             colorText: Colors.white,
             snackPosition: SnackPosition.BOTTOM,
           );
         }
      }
    } catch (e) {
      print('Error picking images: $e');
      Get.snackbar(
        Get.find<LanguageController>().getTranslation('error'),
        "${Get.find<LanguageController>().getTranslation('failed_to_pick_images')}: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Method to pick document files
  Future<void> _pickDocumentFile() async {
    try {
      // Check if user already has 2 files
      if (selectedFiles.length >= 2) {
        Get.snackbar(
          Get.find<LanguageController>().getTranslation('error'),
          Get.find<LanguageController>().getTranslation('max_files_reached'),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'jpg', 'jpeg', 'png', 'PNG'],
      );

      if (result != null && result.files.isNotEmpty) {
        // Calculate how many more files can be added
        int remainingSlots = 2 - selectedFiles.length;
        int filesToAdd = result.files.length > remainingSlots ? remainingSlots : result.files.length;
        
        // List of allowed file extensions
        List<String> allowedExtensions = ['pdf', 'docx', 'jpg', 'jpeg', 'png', 'PNG'];
        
        // Filter files by allowed extensions
        List<dynamic> validFiles = [];
        List<String> invalidFiles = [];
        
        for (int i = 0; i < result.files.length && validFiles.length < remainingSlots; i++) {
          var file = result.files[i];
          if (file.path != null) {
            String extension = file.extension?.toLowerCase() ?? '';
            if (allowedExtensions.contains(extension)) {
              validFiles.add(file);
            } else {
              invalidFiles.add(file.name);
            }
          }
        }
        
        // Add valid files
        for (var file in validFiles) {
          selectedFiles.add(File(file.path!));
        }
        
        // Show error for invalid files
        if (invalidFiles.isNotEmpty) {
          Get.snackbar(
            Get.find<LanguageController>().getTranslation('error'),
            "${Get.find<LanguageController>().getTranslation('invalid_file_type')}: ${invalidFiles.join(', ')}",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: Duration(seconds: 4),
          );
        }
        
                 // Show message if some files were skipped due to limit
         if (result.files.length > remainingSlots && validFiles.length >= remainingSlots) {
           Get.snackbar(
             Get.find<LanguageController>().getTranslation('error'),
             Get.find<LanguageController>().getTranslation('you_can_only_upload_a_maximum_of_2_files'),
             backgroundColor: Colors.red,
             colorText: Colors.white,
             snackPosition: SnackPosition.BOTTOM,
           );
         }
        
        print("Picked files: ${selectedFiles.length} files");
      }
    } catch (e) {
      print('Error picking documents: $e');
      Get.snackbar(
        Get.find<LanguageController>().getTranslation('error'),
        "${Get.find<LanguageController>().getTranslation('failed_to_pick_documents')}: $e",
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
                leading: Icon(
                  Icons.image, 
                  color: selectedFiles.length >= 2 ? Colors.grey : Colors.blue
                ),
                title: Text(
                  Get.find<LanguageController>().getTranslation('select_image'),
                  style: TextStyle(
                    color: selectedFiles.length >= 2 ? Colors.grey : Colors.black,
                  ),
                ),
                onTap: selectedFiles.length >= 2 ? null : () {
                  Navigator.pop(context);
                  _pickImageFile();
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.file_copy, 
                  color: selectedFiles.length >= 2 ? Colors.grey : Colors.green
                ),
                title: Text(
                  Get.find<LanguageController>().getTranslation('select_file'),
                  style: TextStyle(
                    color: selectedFiles.length >= 2 ? Colors.grey : Colors.black,
                  ),
                ),
                onTap: selectedFiles.length >= 2 ? null : () {
                  Navigator.pop(context);
                  _pickDocumentFile();
                },
              ),
                             if (selectedFiles.length >= 2)
                 Padding(
                   padding: const EdgeInsets.all(16.0),
                   child: Text(
                     Get.find<LanguageController>().getTranslation('max_files_reached'),
                     style: TextStyle(
                       color: Colors.red,
                       fontSize: 12,
                       fontStyle: FontStyle.italic,
                     ),
                     textAlign: TextAlign.center,
                   ),
                 ),
               Padding(
                 padding: const EdgeInsets.all(16.0),
                 child: Text(
                   "${Get.find<LanguageController>().getTranslation('allowed_file_types')}: PDF, DOCX, JPG, JPEG, PNG",
                   style: TextStyle(
                     color: Colors.grey[600],
                     fontSize: 11,
                     fontStyle: FontStyle.italic,
                   ),
                   textAlign: TextAlign.center,
                 ),
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
        print('Fetched Categories: ${categories.length} categories');
      } else {
        throw Exception('Failed to load categories. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      isLoading.value = false;
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
        Get.snackbar(
          Get.find<LanguageController>().getTranslation('error'), 
          Get.find<LanguageController>().getTranslation('token_is_null'),
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
          
          // Extract categories from the API response if available
          if (responseData['data'].containsKey('categories')) {
            var fetchedCategories = responseData['data']['categories'].map<Category>((category) => Category.fromJson(category)).toList();
            categories.assignAll(fetchedCategories);
            print('Categories updated from tickets API: ${categories.length} categories');
          }
          
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
        Get.snackbar(
          Get.find<LanguageController>().getTranslation('error'), 
          Get.find<LanguageController>().getTranslation('failed_to_fetch_tickets'),
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white);
      }
    } catch (e) {
      print('Exception occurred: $e');
      Get.snackbar(
        Get.find<LanguageController>().getTranslation('error'), 
        "${Get.find<LanguageController>().getTranslation('failed_to_fetch_tickets')}: $e",
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
      Get.snackbar(
        Get.find<LanguageController>().getTranslation('error'), 
        Get.find<LanguageController>().getTranslation('token_is_null')
      );
      isSubmittingReply.value = false;
      return;
    }
    
    if (message.isEmpty) {
      Get.snackbar(
        Get.find<LanguageController>().getTranslation('error'), 
        Get.find<LanguageController>().getTranslation('message_is_required'),
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
         
         // Show the message from API response
         String apiMessage = reply['message'] ?? Get.find<LanguageController>().getTranslation('reply_posted_successfully');
         Get.snackbar(
           Get.find<LanguageController>().getTranslation('success'),
           apiMessage,
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
          Get.find<LanguageController>().getTranslation('error'),
          Get.find<LanguageController>().getTranslation('failed_to_post_reply'),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print("Post Reply Error: $e");
      Get.snackbar(
        Get.find<LanguageController>().getTranslation('error'),
        Get.find<LanguageController>().getTranslation('error_occurred_posting_reply'),
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
        Get.find<LanguageController>().getTranslation('download_started'),
        "${Get.find<LanguageController>().getTranslation('downloading')}: $fileName",
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
        Get.find<LanguageController>().getTranslation('download_complete'),
        '$fileName ${Get.find<LanguageController>().getTranslation('saved_to')} $saveLocation',
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
          Get.find<LanguageController>().getTranslation('file_downloaded'),
          '$fileName ${Get.find<LanguageController>().getTranslation('saved_to')} $saveLocation',
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 3),
        );
      }
      
    } catch (e) {
      print('Download error: $e');
      Get.snackbar(
        Get.find<LanguageController>().getTranslation('download_error'),
        "${Get.find<LanguageController>().getTranslation('failed_to_download')} $fileName: ${e.toString()}",
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
        Get.snackbar(
          Get.find<LanguageController>().getTranslation('error'), 
          Get.find<LanguageController>().getTranslation('unable_to_authenticate'),
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
        Get.find<LanguageController>().getTranslation('download_error'),
        "${Get.find<LanguageController>().getTranslation('failed_to_download')} $fileName: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    clearAllData(); // Reset all data when controller is disposed
    super.onClose();
  }

}

class Ticket {
  final dynamic category; // Changed to dynamic to handle both String and Map
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
    print('========================');
    
    return Ticket(
      category: json['category'], // Store the entire category object
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
  final String? fr; // French translation field
  final String createdAt;
  final String updatedAt;

  Category({
    required this.id,
    required this.name,
    this.fr, // Make fr optional since it might not always be present
    required this.createdAt,
    required this.updatedAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      fr: json['fr'], // Parse the French field from API response
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}


