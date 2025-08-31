import 'package:get/get.dart';
import '../../crop_water_requirement/controller/crop_water_requirement_controller.dart';
import '../../crop/controller/crop_controller.dart';

class ScheduleController extends GetxController {
  final CropWaterRequirementController cropWaterRequirementController = Get.find<CropWaterRequirementController>();
  final CropController cropController = Get.find<CropController>();

  // Observable variables for summary values
  var totalGrossIrrigation = 0.0.obs;
  var totalVolumeOfWater = 0.0.obs;
  var actualWaterUseByCrop = 0.0.obs;
  var waterUseEfficiency = 0.0.obs;
  var expectedYield = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to changes in crop water requirement controller
    ever(cropWaterRequirementController.grossIrrigationValues, (_) => calculateSummary());
    ever(cropWaterRequirementController.volumeOfWaterValues, (_) => calculateSummary());
    ever(cropWaterRequirementController.etoValues, (_) => calculateSummary());
    
    // Listen to changes in crop controller
    ever(cropController.expectedYield, (_) => calculateSummary());
    
    // Initial calculation
    calculateSummary();
  }

  void calculateSummary() {
    // Calculate total gross irrigation
    double grossIrrigationSum = 0.0;
    for (String value in cropWaterRequirementController.grossIrrigationValues) {
      if (value.isNotEmpty) {
        grossIrrigationSum += double.tryParse(value) ?? 0.0;
      }
    }
    totalGrossIrrigation.value = grossIrrigationSum;

    // Calculate total volume of water
    double volumeSum = 0.0;
    for (String value in cropWaterRequirementController.volumeOfWaterValues) {
      if (value.isNotEmpty) {
        volumeSum += double.tryParse(value) ?? 0.0;
      }
    }
    totalVolumeOfWater.value = volumeSum;

    // Calculate actual water use by crop (sum of ETo values)
    double etoSum = 0.0;
    for (double value in cropWaterRequirementController.etoValues) {
      etoSum += value;
    }
    actualWaterUseByCrop.value = etoSum;

    // Get expected yield from crop controller
    expectedYield.value = cropController.expectedYield.value * (cropController.irrigationApplication / 100);
    waterUseEfficiency.value = expectedYield.value / totalGrossIrrigation.value;
  }
}
