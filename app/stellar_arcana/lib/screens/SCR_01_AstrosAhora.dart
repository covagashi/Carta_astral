import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../widgets/cosmic_background.dart';

class AstrosAhora extends StatefulWidget {
  const AstrosAhora({super.key});

  @override
  State<AstrosAhora> createState() => _AstrosAhoraState();
}

class _AstrosAhoraState extends State<AstrosAhora> {
  late WebViewController _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString('''
          <!DOCTYPE html>
          <html>
            <head>
              <meta name="viewport" content="width=device-width, initial-scale=1.0">
              <style>
                body { 
                  margin: 0; 
                  display: flex;
                  justify-content: center;
                  align-items: center;
                  min-height: 100vh;
                  background: transparent;
                }
                iframe {
                  border: none;
                  overflow: hidden;
                  width: 200px;
                  height: 355px;
                }
              </style>
            </head>
            <body>
              <iframe src="https://carta-natal.es/gadgets/ahora?n=m" scrolling="no"></iframe>
            </body>
          </html>
        ''')
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() => isLoading = false);
          },
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Los astros ahora',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: CosmicBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                child: WebViewWidget(controller: _controller),
              ),
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
            ],
          ),
        ),
      ),
    );
  }
}