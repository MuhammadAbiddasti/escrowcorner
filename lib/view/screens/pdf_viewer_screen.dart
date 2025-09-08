import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PDFViewerScreen extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PDFViewerScreen({Key? key, required this.pdfUrl, this.title = 'Document'}) : super(key: key);

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // Update loading progress
            print('Loading progress: $progress%');
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            print('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('Web resource error: ${error.description}');
            setState(() {
              _isLoading = false;
              _hasError = true;
              _errorMessage = error.description;
            });
          },
        ),
      );

    // Try different PDF viewer approaches
    _loadPDF();
  }

  void _loadPDF() {
    // Method 1: Try Google Docs viewer
    String googleDocsUrl = 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(widget.pdfUrl)}';
    print('Trying Google Docs viewer: $googleDocsUrl');
    
    _controller.loadRequest(Uri.parse(googleDocsUrl));
  }

  void _openInExternalApp() async {
    try {
      final Uri url = Uri.parse(widget.pdfUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar(
          'Error',
          'Could not open PDF in external app',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error opening PDF: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _retryLoading() {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    _loadPDF();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
          ),
        ),
        backgroundColor: Color(0xff2E7D32),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _retryLoading,
          ),
          IconButton(
            icon: Icon(Icons.open_in_new, color: Colors.white),
            onPressed: _openInExternalApp,
            tooltip: 'Open in external app',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (!_hasError)
            WebViewWidget(controller: _controller),
          
          if (_isLoading)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xff2E7D32)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Loading PDF...',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xff666565),
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          if (_hasError)
            Container(
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Failed to load PDF',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff666565),
                          fontFamily: 'Nunito',
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _errorMessage.isNotEmpty ? _errorMessage : 'Unable to display PDF in-app',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xff666565),
                          fontFamily: 'Nunito',
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _retryLoading,
                            icon: Icon(Icons.refresh, color: Colors.white),
                            label: Text('Retry', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xff2E7D32),
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                          SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _openInExternalApp,
                            icon: Icon(Icons.open_in_new, color: Colors.white),
                            label: Text('Open Externally', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
