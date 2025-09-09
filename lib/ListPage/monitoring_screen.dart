import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:dangkong_app/yolo/yolo_socket_view.dart'; // 실제 경로에 맞게 조정
import 'package:dangkong_app/alert/ alert_listener.dart';
late List<CameraDescription> cameras; // ✅ 전역 선언

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  bool _isCameraReady = false;

  @override
  void initState() {
    super.initState();
    _initCamerasIfNeeded();
  }

  Future<void> _initCamerasIfNeeded() async {
    try {
      cameras = await availableCameras(); // ← 무조건 초기화
      print("📸 카메라 ${cameras.length}개 초기화됨");
    } catch (e) {
      print("❌ 카메라 초기화 실패: $e");
    }

    if (mounted) {
      setState(() {
        _isCameraReady = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Stack(
        children: [
          _isCameraReady
              ? const YoloSocketView()
              : const Center(child: CircularProgressIndicator()),

          // ✅ 낙상 WebSocket 알림 리스너
          const AlertListener(),
        ],
      ),
    );
  }
}