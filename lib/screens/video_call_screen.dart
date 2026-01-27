import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../constants/app_colors.dart';
import '../services/video_service.dart';

class VideoCallScreen extends StatefulWidget {
  final String idosoId;
  final String idosoNome;
  final bool isIncoming;
  final String? token; // Adicionado token

  const VideoCallScreen({
    super.key,
    required this.idosoId,
    required this.idosoNome,
    this.isIncoming = false,
    this.token,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  WebViewController? _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.isIncoming) {
      _initializeCall();
    } else {
      _initializeCall();
    }
  }

  Future<void> _initializeCall() async {
    // 1. Obtém sessão do Backend
    final sessionId = await VideoService.startVideoCall(
      widget.idosoId,
      token: widget.token,
    );

    if (sessionId != null) {
      _loadWebRTC(sessionId);
    } else {
      setState(() {
        _errorMessage = 'Falha ao conectar ao servidor de vídeo.';
        _isLoading = false;
      });
    }
  }

  void _loadWebRTC(String sessionId) {
    // URL do WebRTC Client hospedado
    // role=family identifica que este é o lado do portal/familiar
    final url =
        "https://eva-ia.org/webrtc-client.html?session_id=$sessionId&role=family";

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            print('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. WebView (Vídeo)
          if (_controller != null && _errorMessage == null)
            SafeArea(child: WebViewWidget(controller: _controller!)),

          // 2. Loading State
          if (_isLoading)
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: AppColors.primary),
                    const SizedBox(height: 20),
                    Text(
                      widget.isIncoming
                          ? 'Conectando...'
                          : 'Ligando para ${widget.idosoNome}...',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),

          // 3. Error State
          if (_errorMessage != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Voltar'),
                  ),
                ],
              ),
            ),

          // 4. Overlay de Controles (Sair)
          if (!_isLoading && _errorMessage == null)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton(
                  backgroundColor: Colors.red,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Icon(Icons.call_end, color: Colors.white),
                ),
              ),
            ),

          // 5. Header (Voltar)
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
