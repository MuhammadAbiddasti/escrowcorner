import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../../widgets/custom_appbar/custom_appbar.dart';
import '../../../widgets/custom_bottom_container/custom_bottom_container.dart';
import '../user_profile/user_profile_controller.dart';
import 'merchant_controller.dart';

class ScreenMerchantTransactionDetails extends StatefulWidget {
  final String merchantId;
  final String merchantName;

  ScreenMerchantTransactionDetails({
    required this.merchantId,
    required this.merchantName,
  });

  @override
  _ScreenMerchantTransactionDetailsState createState() => _ScreenMerchantTransactionDetailsState();
}

class _ScreenMerchantTransactionDetailsState extends State<ScreenMerchantTransactionDetails> {
  late MerchantController controller;
  final UserProfileController userProfileController = Get.find<UserProfileController>();
  
  @override
  void initState() {
    super.initState();
    
    // Ensure controller is properly initialized
    controller = Get.put(MerchantController(), permanent: true);
    print('=== TRANSACTION DETAILS SCREEN INITIALIZED ===');
    print('Merchant ID: ${widget.merchantId}');
    print('Selected Filter: $selectedFilter');
    print('Controller initialized: ${controller != null}');
    
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    // Use WidgetsBinding to ensure the widget is fully built before making API call
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('Post frame callback - making API call');
      
      // Fetch merchant data if not already loaded
      if (controller.merchants.isEmpty) {
        print('Fetching merchants first...');
        controller.fetchMerchants().then((_) {
          print('Merchants fetched, now fetching transactions');
          controller.fetchMerchantTransactions(widget.merchantId, filter: selectedFilter);
        });
      } else {
        print('Merchants already loaded, fetching transactions directly');
        controller.fetchMerchantTransactions(widget.merchantId, filter: selectedFilter);
      }
    });
  }
  
  String selectedFilter = 'today'; // Default filter
  late ScrollController _scrollController;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Check if user has scrolled to the top (swipe up gesture)
    if (_scrollController.position.pixels <= 100) {
      // Load more when user scrolls up (swipe up) and is near the top
      print('User scrolled up - triggering load more');
      controller.loadMoreTransactions(widget.merchantId, selectedFilter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffE6F0F7),
      appBar: AppBar(
        backgroundColor: Color(0xff191f28),
        title: AppBarTitle(),
        leading: CustomPopupMenu(managerId: userProfileController.userId.value),
        actions: [
          // Debug refresh button
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              print('Manual refresh triggered');
              controller.fetchMerchantTransactions(widget.merchantId, filter: selectedFilter);
            },
          ),
          PopupMenuButtonAction(),
          AppBarProfileButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await controller.fetchMerchantTransactions(widget.merchantId, filter: selectedFilter);
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
                             // Header Card
               Container(
                 width: MediaQuery.of(context).size.width * 0.95,
                 margin: EdgeInsets.only(top: 20, bottom: 16, left: 10, right: 0),
                 decoration: BoxDecoration(
                   gradient: LinearGradient(
                     colors: [Color(0xff0766AD), Color(0xff0A8AFF)],
                     begin: Alignment.topLeft,
                     end: Alignment.bottomRight,
                   ),
                   borderRadius: BorderRadius.circular(15),
                   boxShadow: [
                     BoxShadow(
                       color: Colors.black.withOpacity(0.1),
                       blurRadius: 10,
                       offset: Offset(0, 5),
                     ),
                   ],
                 ),
                 child: Padding(
                   padding: EdgeInsets.all(20),
                   child: Column(
                     children: [
                       // Application Logo
                       Obx(() {
                         final merchant = controller.merchants.firstWhereOrNull(
                           (m) => m.id == widget.merchantId
                         );
                         
                         return Container(
                           width: 60,
                           height: 60,
                           decoration: BoxDecoration(
                             color: Colors.white,
                             borderRadius: BorderRadius.circular(12),
                             boxShadow: [
                               BoxShadow(
                                 color: Colors.black.withOpacity(0.1),
                                 blurRadius: 5,
                                 offset: Offset(0, 2),
                               ),
                             ],
                           ),
                           child: ClipRRect(
                             borderRadius: BorderRadius.circular(12),
                             child: merchant?.logo != null && merchant!.logo.isNotEmpty
                                 ? Image.network(
                                     merchant.logo,
                                     fit: BoxFit.cover,
                                     errorBuilder: (context, error, stackTrace) {
                                       return Icon(
                                         Icons.account_balance_wallet,
                                         color: Color(0xff0766AD),
                                         size: 30,
                                       );
                                     },
                                     loadingBuilder: (context, child, loadingProgress) {
                                       if (loadingProgress == null) return child;
                                       return Center(
                                         child: CircularProgressIndicator(
                                           value: loadingProgress.expectedTotalBytes != null
                                               ? loadingProgress.cumulativeBytesLoaded / 
                                                 loadingProgress.expectedTotalBytes!
                                               : null,
                                           valueColor: AlwaysStoppedAnimation<Color>(Color(0xff0766AD)),
                                         ),
                                       );
                                     },
                                   )
                                 : Icon(
                                     Icons.account_balance_wallet,
                                     color: Color(0xff0766AD),
                                     size: 30,
                                   ),
                           ),
                         );
                       }),
                       SizedBox(height: 15),
                       Text(
                         widget.merchantName,
                         style: TextStyle(
                           color: Colors.white,
                           fontSize: 20,
                           fontWeight: FontWeight.bold,
                         ),
                         textAlign: TextAlign.center,
                       ),
                       SizedBox(height: 5),
                       Text(
                         'Transaction History',
                         style: TextStyle(
                           color: Colors.white.withOpacity(0.9),
                           fontSize: 14,
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
               
               // Filter Dropdown
               Container(
                 width: MediaQuery.of(context).size.width * 0.95,
                 margin: EdgeInsets.only(bottom: 16, left: 10, right: 0),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(10),
                   boxShadow: [
                     BoxShadow(
                       color: Colors.black.withOpacity(0.05),
                       blurRadius: 5,
                       offset: Offset(0, 2),
                     ),
                   ],
                 ),
                 child: Padding(
                   padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                   child: Row(
                     children: [
                       Icon(
                         Icons.filter_list,
                         color: Color(0xff0766AD),
                         size: 20,
                       ),
                       SizedBox(width: 8),
                       Text(
                         'Filter:',
                         style: TextStyle(
                           fontSize: 14,
                           fontWeight: FontWeight.w600,
                           color: Colors.grey[700],
                         ),
                       ),
                       SizedBox(width: 12),
                       Expanded(
                         child: DropdownButtonHideUnderline(
                           child: DropdownButton<String>(
                             value: selectedFilter,
                             isExpanded: true,
                             icon: Icon(Icons.keyboard_arrow_down, color: Color(0xff0766AD)),
                             style: TextStyle(
                               fontSize: 14,
                               color: Colors.black87,
                               fontWeight: FontWeight.w500,
                             ),
                             items: [
                               DropdownMenuItem(
                                 value: 'today',
                                 child: Text('Today'),
                               ),
                               DropdownMenuItem(
                                 value: 'weekly',
                                 child: Text('Weekly'),
                               ),
                               DropdownMenuItem(
                                 value: 'monthly',
                                 child: Text('Monthly'),
                               ),
                               DropdownMenuItem(
                                 value: 'yearly',
                                 child: Text('Yearly'),
                               ),
                             ],
                             onChanged: (String? newValue) {
                               if (newValue != null) {
                                 setState(() {
                                   selectedFilter = newValue;
                                 });
                                 // Reset pagination and fetch new data
                                 controller.currentPage.value = 1;
                                 controller.hasMoreData.value = true;
                                 controller.fetchMerchantTransactions(
                                   widget.merchantId, 
                                   filter: newValue
                                 );
                               }
                             },
                           ),
                         ),
                       ),
                     ],
                   ),
                 ),
               ),
              
                             // Transactions List
               Obx(() {
                 print('UI Update - Loading: ${controller.isLoading.value}, Transactions Count: ${controller.merchantTransactions.length}');
                 print('Controller initialized: ${controller != null}');
                 print('Merchant ID: ${widget.merchantId}');
                 
                 if (controller.isLoading.value) {
                   print('Showing loading shimmer');
                   return _buildLoadingShimmer();
                 } else if (controller.merchantTransactions.isEmpty) {
                   print('Showing empty state - no transactions found');
                   return _buildEmptyState();
                 } else {
                   return _buildTransactionsList();
                 }
               }),
              
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
              bottomNavigationBar: CustomBottomContainerPostLogin(),
    );
  }

  Widget _buildLoadingShimmer() {
    return Column(
      children: List.generate(3, (index) => _buildShimmerCard()),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      margin: EdgeInsets.only(bottom: 16, left: 10, right: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 20, color: Colors.white),
              SizedBox(height: 10),
              Container(height: 16, color: Colors.white),
              SizedBox(height: 10),
              Container(height: 16, color: Colors.white),
              SizedBox(height: 10),
              Container(height: 16, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      margin: EdgeInsets.only(left: 10, right: 0),
      padding: EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long,
            size: 60,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No Transactions Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
                          'There are no transactions for this sub account yet.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    return Column(
      children: controller.merchantTransactions.map((transaction) {
        return _buildTransactionCard(transaction);
      }).toList(),
    );
  }

  Widget _buildTransactionCard(MerchantTransaction transaction) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      margin: EdgeInsets.only(bottom: 16, left: 10, right: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    transaction.activityTitle,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatusChip(transaction.status),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Transaction Details Grid
            _buildDetailRow('Transaction ID', transaction.transactionId),
            _buildDetailRow('Date & Time', _formatDateTime(transaction.dateTime)),
            _buildDetailRow('Method', transaction.method),
            _buildDetailRow('Description', transaction.description),
            
            SizedBox(height: 16),
            
            // Amount Details
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xffF8F9FA),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  _buildAmountRow('Gross Amount', transaction.gross, Colors.black87),
                  _buildAmountRow('Fee', transaction.fee, Colors.red),
                  Divider(height: 20, color: Colors.grey.withOpacity(0.3)),
                  _buildAmountRow('Net Amount', transaction.net, Color(0xff0766AD), isBold: true),
                  Divider(height: 20, color: Colors.grey.withOpacity(0.3)),
                  _buildAmountRow('Balance', transaction.balance, Colors.green, isBold: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountRow(String label, String amount, Color color, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color chipColor;
    Color textColor;
    
    switch (status.toLowerCase()) {
      case 'completed':
      case 'success':
        chipColor = Colors.green;
        textColor = Colors.white;
        break;
      case 'pending':
        chipColor = Colors.orange;
        textColor = Colors.white;
        break;
      case 'failed':
      case 'rejected':
        chipColor = Colors.red;
        textColor = Colors.white;
        break;
      default:
        chipColor = Colors.grey;
        textColor = Colors.white;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDateTime(String dateTime) {
    try {
      final DateTime parsed = DateTime.parse(dateTime);
      return DateFormat('MMM dd, yyyy - HH:mm').format(parsed);
    } catch (e) {
      return dateTime;
    }
  }
} 