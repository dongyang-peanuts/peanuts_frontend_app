import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AbnormalBehaviorSection extends StatelessWidget {
  const AbnormalBehaviorSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '오늘 이상행동 비율',
          style: TextStyle(
            color: Color(0xFF373737),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Container(
          width: double.infinity,
          height: screenHeight * 0.32,
          decoration: _cardDecoration(),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [

              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.spaceAround,
                spacing: 8,
                runSpacing: 4,
                children: const [

                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      border: Border.all(width: 1, color: const Color(0xFFE7E7E7)),
      borderRadius: BorderRadius.circular(10),
      boxShadow: const [
        BoxShadow(
          color: Color(0x19000000),
          blurRadius: 10,
          offset: Offset(0, 1),
        ),
      ],
    );
  }
}

class LegendItem extends StatelessWidget {
  final String label;
  final Color color;

  const LegendItem({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, color: color),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}

class RiskCircle extends StatelessWidget {
  final String label;
  final double percent;
  final Color color;

  const RiskCircle({
    super.key,
    required this.label,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 90,
      height: 90,
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE7E7E7)),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 10,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: percent,
              strokeWidth: 7,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              backgroundColor: const Color(0xFFE0E0E0),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${(percent * 100).toInt()}%',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 3),
              Text(label, style: const TextStyle(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
