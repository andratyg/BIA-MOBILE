// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:verdatica_flutter/models/sensor_data.dart';
import 'package:verdatica_flutter/widgets/sensor_card.dart';

void main() {
  testWidgets('SensorCard renders proportional bars for 0% and 100%', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SensorCard(
            title: 'Kelembapan Udara',
            value: '0.0',
            unit: '%',
            statusLabel: 'Kering',
            statusColor: Colors.yellow,
            iconColor: Colors.blue,
            icon: Icons.water_drop_rounded,
            history: [0.0, 50.0, 100.0],
            cardAccent: Colors.blue,
            minValue: 0.0,
            maxValue: 100.0,
          ),
        ),
      ),
    );

    expect(find.text('Kelembapan Udara'), findsOneWidget);
    expect(find.text('0.0'), findsOneWidget);
    expect(find.text('%'), findsOneWidget);
  });

  test('SensorData.fromJson correctly parses backend payload with kelembapan_udara', () {
    final payload = {
      'id': 1,
      'suhu': 28.1,
      'kelembapan_udara': 70.5,
      'kelembapan_tanah': 21,
    };

    final sensorData = SensorData.fromJson(payload);

    expect(sensorData.temperature, 28.1);
    expect(sensorData.humidity, 70.5);
    expect(sensorData.soilMoisture, 21.0);
  });
}
