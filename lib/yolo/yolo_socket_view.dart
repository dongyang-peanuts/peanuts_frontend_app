  import 'dart:async';
  import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:camera/camera.dart';
  import 'package:web_socket_channel/web_socket_channel.dart';
  import 'package:web_socket_channel/status.dart' as status;
  import 'fall_labels.dart';
  import 'package:dangkong_app/ListPage/monitoring_screen.dart';

  class YoloSocketView extends StatefulWidget {
    const YoloSocketView({super.key});
    @override
    State<YoloSocketView> createState() => _YoloSocketViewState();
  }

  class _YoloSocketViewState extends State<YoloSocketView> {
    late CameraController _cameraController;
    late WebSocketChannel _videoChannel; // 프레임 전송용
    late WebSocketChannel _alertChannel; // 알림 수신용
    Timer? _sendTimer;
    bool _isSending = false;
    String _status = "정상";
    Color _statusColor = Colors.green;

    @override
    void initState() {
      super.initState();
      _initCameraAndWebSockets();
    }

    void _initCameraAndWebSockets() async {
      try {
        _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
        await _cameraController.initialize();
        if (!mounted) return;
        setState(() {});
        _initWebSockets();
      } catch (e) {
        print("❌ 카메라 초기화 실패: $e");
      }
    }

    void _initWebSockets() {
      // 1. 프레임 전송용
      _videoChannel = WebSocketChannel.connect(
        Uri.parse('ws://kongback.kro.kr:8080/ws/video'),
      );

      // 2. 알림 수신용
      _alertChannel = WebSocketChannel.connect(
        Uri.parse('ws://kongback.kro.kr:8080/ws/alert'),
      );

      _alertChannel.stream.listen(
            (message) {
          print("📥 알림 수신: $message");
          try {
            final Map<String, dynamic> result = json.decode(message);
            final eventType = result['eventType'];
            final isFall = eventType == '낙상' || eventType == 'fall';


            setState(() {
              if (eventType == '낙상' || eventType == 'fall') {
                _status = "낙상 감지!";
                _statusColor = Colors.red;
              } else if (eventType == '낙상 해제' || eventType == 'clear') {
                _status = "정상";
                _statusColor = Colors.green;
              }
            });
          } catch (e) {
            print("❌ 알림 파싱 오류: $e");
          }
        },
        onError: (e) => print("❌ 알림 WebSocket 오류: $e"),
        onDone: () => print("🔌 알림 WebSocket 연결 종료됨"),
      );

      _sendTimer = Timer.periodic(
        const Duration(seconds: 1),
            (_) => _sendFrame(),
      );
    }

    void _sendFrame() async {
      if (!_cameraController.value.isInitialized || _isSending) return;
      _isSending = true;

      try {
        final XFile file = await _cameraController.takePicture();
        final bytes = await file.readAsBytes();
        final base64Image = base64Encode(bytes);
        final jsonPayload = jsonEncode({"image": base64Image});
        _videoChannel.sink.add(jsonPayload);
        print("📤 프레임 전송 완료");
      } catch (e) {
        print("❌ 프레임 전송 실패: $e");
      } finally {
        _isSending = false;
      }
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(title: const Text('낙상 감지 클라이언트')),
        body: _cameraController.value.isInitialized
            ? Stack(
          children: [
            CameraPreview(_cameraController),
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                color: _statusColor.withOpacity(0.8),
                child: Text(
                  _status,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        )
            : const Center(child: CircularProgressIndicator()),
      );
    }

    @override
    void dispose() {
      _sendTimer?.cancel();
      _cameraController.dispose();
      _videoChannel.sink.close(status.goingAway);
      _alertChannel.sink.close(status.goingAway);
      super.dispose();
    }
  }