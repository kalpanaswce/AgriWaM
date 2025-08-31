import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/schedule_controller.dart';

class ScheduleView extends GetView<ScheduleController> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            // Summary Fields
            Obx(() => _buildSummaryField(
              'Total Gross Irrigation requirement(mm)',
              controller.totalGrossIrrigation.value.toStringAsFixed(2),
              'mm',
            )),
            SizedBox(height: 24.0),
            
            Obx(() => _buildSummaryField(
              'Total volume of water (m³)',
              controller.totalVolumeOfWater.value.toStringAsFixed(2),
              'm³',
            )),
            SizedBox(height: 24.0),
            
            Obx(() => _buildSummaryField(
              'Expected Yield (kg/acre)',
              controller.expectedYield.value.toStringAsFixed(2),
              'kg/acre',
            )),
            SizedBox(height: 24.0),
            
            Obx(() => _buildSummaryField(
              'Actual water use by crop (mm)',
              controller.actualWaterUseByCrop.value.toStringAsFixed(2),
              'mm',
            )),
            SizedBox(height: 24.0),
            
             Obx(() => _buildSummaryField(
              'Water use efficiency (kg/ac/mm)',
               controller.waterUseEfficiency.value.toStringAsFixed(2),
              'kg/ac/mm',
            )),
            SizedBox(height: 40.0)
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryField(String label, String value, String unit) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 18.0,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 16.0),
        Container(
          width: 250.0, // Fixed width for all boxes
          height: 50.0,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue, width: 2.0),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.0),
        Container(
          width: 100.0, // Fixed width for unit labels
          child: Text(
            unit,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

}
