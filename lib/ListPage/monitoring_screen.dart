import 'dart:typed_data';
import 'dart:convert'; // base64Decode
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  late WebSocketChannel _channel;
  Uint8List? _imageData;

  @override
  void initState() {
    super.initState();

    const socketUrl = 'ws://kongback.kro.kr:8080/ws/video';
    print("📡 WebSocket 연결 시도 중...");
    _channel = WebSocketChannel.connect(Uri.parse(socketUrl));

    _channel.stream.listen(
          (data) {
        print("📥 수신: ${data.runtimeType}, 길이: ${data.length}");

        if (data is String) {
          try {
            final decoded = base64Decode(data.trim());
            print("✅ base64 디코딩 성공 (decoded 길이: ${decoded.length})");
            setState(() {
              _imageData = decoded;
              print("🟢 _imageData 설정 완료 (length: ${_imageData!.length})");
            });
          } catch (e) {
            print("❌ base64 디코딩 실패: $e");
          }
        } else {
          print("❌ 예상치 못한 데이터 형식: ${data.runtimeType}");
        }
      },
      onError: (error) {
        print("❌ WebSocket 오류 발생: $error");
      },
      onDone: () {
        print("🔌 WebSocket 연결 종료됨");
      },
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('낙상 모니터링')),
      body: Center(
        child: _imageData != null
            ? Image.memory(
          _imageData!,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            print("❌ 이미지 렌더링 실패: $error");
            return const Text("⚠️ 이미지 표시 실패");
          },
        )
            : const Text("📡 실시간 영상 수신 중..."),
      ),
    );
  }
}
