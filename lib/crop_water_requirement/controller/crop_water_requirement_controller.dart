import 'package:crop_wat/climate/model/daily_climate_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../crop/controller/crop_controller.dart';
import '../../soil/controller/soil_controller.dart';
import '../../climate/controller/climate_controller.dart';
import '../../climate/model/precipitation_helper.dart';

class CropWaterRequirementController extends GetxController {
  final CropController cropController = Get.find<CropController>();
  final SoilController soilController = Get.find<SoilController>();
  final ClimateController climateController = Get.find<ClimateController>();

  // Observable variables
  var cropName = ''.obs;
  var plantingDate = Rxn<DateTime>();
  var cropStageData = <dynamic>[].obs;
  var stageRowCounts = <int>[4, 4, 4, 4, 4].obs;
  var rowDates = <DateTime>[].obs;
  var etoValues = <double>[].obs;
  var kcCoefValues = <double>[].obs;
  var rainValues = <double>[].obs;
  var effectiveRainValues = <RxDouble>[].obs; // Peff (mm/day) - individual observable strings
  var rainControllers = <TextEditingController>[].obs; // Controllers for rain TextFields
  var netIrrigationValues = <String>[].obs; // IRR (mm/day) = ETc - Peff
  var grossIrrigationValues = <String>[].obs; // Gross irrigation depth (mm/day)
  var volumeOfWaterValues = <String>[].obs; // Volume of Water (m³)
  var timeOfOperationValues = <String>[].obs; // Time of Operation (hrs)
  var tawValues = <double>[].obs; // TAW (mm) for each stage
  var rawValues = <double>[].obs; // RAW (mm) for each stage (RAW = TAW / 2)
  var depletionEndValues = <double>[].obs; // Depletion End (mm) for each row

  @override
  void onInit() {
    super.onInit();
    _assignValues();

    // Listen to changes in crop controller
    ever(cropController.cropName, (_) => _assignValues());
    ever(cropController.selectedDate, (_) => _assignValues());
    ever(cropController.cropData, (_) => _assignValues());
    ever(cropController.isDataLoaded, (_) => _assignValues());

    // Listen to changes in soil controller
    ever(soilController.soilData, (_) => _assignValues());
  }

  void _assignValues() {
    cropName.value = cropController.cropName.value;
    plantingDate.value = cropController.selectedDate.value;
    cropStageData.assignAll(cropController.cropData);
    _calculateStageRowCounts();
    _calculateRowDates();
    _calculateKcCoefValues();
    _calculateEtoValues();
    _calculateRainValues();
    _calculateEffectiveRainValues();
    _calculateTawValues();
    _calculateRawValues();
    _calculateDepletionEndValues();
  }

  // Calculate rows for each stage based on cumulative duration
  void _calculateStageRowCounts() {
    List<int> rowCounts = [];

    if (cropStageData.isEmpty) {
      // Default values if no data is loaded
      stageRowCounts.assignAll([4, 4, 4, 4, 4]);
      return;
    }

    int previousDuration = 0;
    for (int i = 0; i < cropStageData.length; i++) {
      int currentDuration = cropStageData[i].duration;
      int stageRows = currentDuration - previousDuration;
      rowCounts.add(stageRows);
      previousDuration = currentDuration;
    }

    stageRowCounts.assignAll(rowCounts);
  }

  // Calculate dates for each row based on planting date and stage durations
  void _calculateRowDates() {
    List<DateTime> dates = [];

    if (plantingDate.value == null || cropStageData.isEmpty) {
      rowDates.assignAll(dates);
      return;
    }

    DateTime currentDate = plantingDate.value!;

    for (int stageIndex = 0; stageIndex < cropStageData.length; stageIndex++) {
      int rowCount =
          stageRowCounts.length > stageIndex ? stageRowCounts[stageIndex] : 4;

      for (int rowIdx = 0; rowIdx < rowCount; rowIdx++) {
        dates.add(currentDate);
        currentDate = currentDate.add(Duration(days: 1));
      }
    }

    rowDates.assignAll(dates);
  }

  // Calculate ETo values for each row based on dates
  void _calculateEtoValues() {
    List<double> etoList = [];

    if (rowDates.isEmpty || climateController.climateRows.isEmpty) {
      etoValues.assignAll(etoList);
      return;
    }

    for (DateTime date in rowDates) {
      double etoValue = _getEtoForDate(date);
      var coEff = kcCoefValues[rowDates.indexOf(date)];
      etoList.add(etoValue * coEff);
    }

    etoValues.assignAll(etoList);
  }

  // Get ETo value for a specific date
  double _getEtoForDate(DateTime date) {
    int dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    var dailyClimateValues = DailyClimateHelper.dailyClimateData[dayOfYear];
    if (dailyClimateValues != null) {
      return _calculateEtoForDay(dailyClimateValues, dayOfYear);
    }
    else {
      return 0;
    }
  }

  // Calculate ETo for a specific day using climate data
  double _calculateEtoForDay(List<double> climateValues, int dayOfYear) {
    // Extract climate data

    // Call the climate controller's calculateETo method with the specific day
    String etoString = climateController.calculateETo(
      'Custom',
      climateValues,
      J: dayOfYear,
    );
    return double.tryParse(etoString) ?? 0.0;
  }

  // Calculate Kc coefficients for each row
  void _calculateKcCoefValues() {
    List<double> kcList = [];
    final cropData = cropController.cropData;
    List<int> stageStartIndices = [];
    List<double> stageKcValues = [];
    int runningIndex = 0;
    for (int i = 0; i < stageRowCounts.length; i++) {
      stageStartIndices.add(runningIndex + 1); // 1-based
      double kc =
          (i < cropData.length && cropData[i].kc != null)
              ? cropData[i].kc!
              : 0.0;
      stageKcValues.add(kc);
      runningIndex += stageRowCounts[i];
    }
    int totalRows = runningIndex;
    for (
      int globalRowIndex = 0, stageIndex = 0, subRowIdx = 0;
      globalRowIndex < totalRows;
      globalRowIndex++
    ) {
      int rowCount = stageRowCounts[stageIndex];
      int x = globalRowIndex + 1; // 1-based
      double kcValue = 0.0;
      if (subRowIdx == 0 || stageIndex == stageKcValues.length - 1) {
        kcValue = stageKcValues[stageIndex];
      } else {
        double y1 = stageKcValues[stageIndex];
        double y2 = stageKcValues[stageIndex + 1];
        int x1 = stageStartIndices[stageIndex];
        int x2 = stageStartIndices[stageIndex + 1];
        kcValue = y1 + ((x - x1) * (y2 - y1)) / (x2 - x1);
      }
      kcList.add(kcValue);
      subRowIdx++;
      if (subRowIdx >= rowCount) {
        stageIndex++;
        subRowIdx = 0;
      }
    }
    kcCoefValues.assignAll(kcList);
  }

  // Calculate rain values for each row
  void _calculateRainValues() {
    List<double> rainList = [];
    List<TextEditingController> controllerList = [];

    if (rowDates.isEmpty) {
      rainValues.assignAll(rainList);
      rainControllers.assignAll(controllerList);
      return;
    }

    for (DateTime date in rowDates) {
      rainList.add(0.0);
      controllerList.add(TextEditingController(text: '0.00'));
    }

    rainValues.assignAll(rainList);
    rainControllers.assignAll(controllerList);
  }

  // Get rain value for a specific date
  String _getRainForDate(DateTime date) {
    try {
      double? precipitation = PrecipitationHelper.getPrecipitationForDate(date);
      if (precipitation != null) {
        // Convert from mm to cm (1 cm = 10 mm)
        double rainCm = precipitation / 10.0;
        return rainCm.toStringAsFixed(2);
      } else {
        return '0.00'; // Default value if no precipitation data
      }
    } catch (e) {
      return '0.00'; // Default value if error occurs
    }
  }

  // Calculate Effective Rainfall (mm/day) based on USDA monthly method
  // Peff_month when P_total <= 250 mm:
  //   Peff = P_total * (125 - 0.2 * P_total) / 125
  // Peff_month when P_total > 250 mm:
  //   Peff = 125 + 0.1 * P_total
  // We then distribute the monthly Peff evenly across days in the month
  void _calculateEffectiveRainValues() {
    List<RxDouble> peffPerDayList = [];

    if (rowDates.isEmpty) {
      effectiveRainValues.assignAll(peffPerDayList);
      return;
    }

    // Map back to each row date
    for (final date in rowDates) {
      peffPerDayList.add(0.0.obs);
    }

    effectiveRainValues.assignAll(peffPerDayList);
  }


  // Calculate TAW (Total Available Water) for each stage
  void _calculateTawValues() {
    List<double> tawList = [];

    if (cropStageData.isEmpty || soilController.soilData.value == null) {
      tawValues.assignAll(tawList);
      return;
    }

    final soilData = soilController.soilData.value!;
    final fieldCapacity = soilData.fieldCapacity;
    final wiltingPoint = soilData.wiltingPoint;

    for (int stageIndex = 0; stageIndex < cropStageData.length; stageIndex++) {
      final stageData = cropStageData[stageIndex];
      final rootzoneDepth = stageData.rootzoneDepth * 10;
      
      // Calculate TAW using the formula: (fieldCapacity - wiltingPoint) * rootzoneDepth * 1.45 / 100
      // fieldCapacity and wiltingPoint are in %, rootzoneDepth is in cm
      // Result is in mm
      final taw = (fieldCapacity - wiltingPoint) * rootzoneDepth * 1.45 / 100;
      
      // Add TAW value for each row in this stage
      int rowCount = stageRowCounts.length > stageIndex ? stageRowCounts[stageIndex] : 4;
      for (int i = 0; i < rowCount; i++) {
        tawList.add(taw);
      }
    }

    tawValues.assignAll(tawList);
  }

  // Get TAW value for a specific stage
  double getTawForStage(String stageName) {
    if (cropStageData.isEmpty || soilController.soilData.value == null) {
      return 0.0;
    }

    final stageIndex = cropStageData.indexWhere((stage) => stage.stage == stageName);
    if (stageIndex == -1) return 0.0;

    final stageData = cropStageData[stageIndex];
    final soilData = soilController.soilData.value!;
    
    return (soilData.fieldCapacity - soilData.wiltingPoint) * stageData.rootzoneDepth * 1.45 / 100;
  }

  // Calculate RAW (Readily Available Water) values
  void _calculateRawValues() {
    List<double> rawList = [];

    if (tawValues.isEmpty) {
      rawValues.assignAll(rawList);
      return;
    }

    // Calculate RAW as TAW / 2 for each value
    for (double taw in tawValues) {
      rawList.add(taw / 2);
    }

    rawValues.assignAll(rawList);
  }

  // Calculate Depletion End values
  void _calculateDepletionEndValues() {
    List<double> depletionList = [];
    List<String> netIrrigationList =[];
    List<String> grossIrrigationList =[];
    List<String> volumeOfWaterList = [];
    List<String> timeOfOperationList = [];

    if (etoValues.isEmpty || rawValues.isEmpty) {
      depletionEndValues.assignAll(depletionList);
      netIrrigationValues.assignAll(netIrrigationList);
      grossIrrigationValues.assignAll(grossIrrigationList);
      volumeOfWaterValues.assignAll(volumeOfWaterList);
      timeOfOperationValues.assignAll(timeOfOperationList);
      return;
    }

    for (int i = 0; i < etoValues.length; i++) {
      double depletionValue;
      double netIrrigationvalue;
      
      if (i == 0) {
        // First value is always 0
        depletionValue = 0.0;
        netIrrigationvalue = tawValues[i];
      } else {
        // Next value = etc value in same row + previous row depletion end
        double etcValue = etoValues[i];
        double previousDepletion = depletionList[i - 1];
        double rawValue = i < rawValues.length ? rawValues[i] : 0.0;
        double effectiveRainFall = i < effectiveRainValues.length ? effectiveRainValues[i].value : 0.0;
        
        depletionValue = etcValue + previousDepletion - effectiveRainFall;
        
        // If previous row depletion end is greater than RAW of the same row, 
        // take value of Kc coef column value in same row
        if (previousDepletion > rawValue) {
          depletionValue = etcValue;
          netIrrigationvalue = previousDepletion;
        }
        else{
          netIrrigationvalue = 0;
        }
      }
      netIrrigationvalue = netIrrigationvalue * (cropController.irrigationApplication.value / 100);
      
      // Calculate gross irrigation
      double grossIrrigation = netIrrigationvalue > 0 ? (netIrrigationvalue / 0.7) : 0.0;
      
      // Calculate volume of water (m³)
      double volumeOfWater = grossIrrigation * 4.047;
      
      // Calculate time of operation (hrs)
      double timeOfOperation = (grossIrrigation * 4046) / (1000 * 10 * 3.6);
      
      depletionList.add(depletionValue);
      netIrrigationList.add(netIrrigationvalue > 0 ? netIrrigationvalue.toStringAsFixed(2) : "");
      grossIrrigationList.add(grossIrrigation > 0 ? grossIrrigation.toStringAsFixed(2) : "");
      volumeOfWaterList.add(volumeOfWater > 0 ? volumeOfWater.toStringAsFixed(2) : "");
      timeOfOperationList.add(timeOfOperation > 0 ? timeOfOperation.toStringAsFixed(2) : "");
    }

    depletionEndValues.assignAll(depletionList);
    netIrrigationValues.assignAll(netIrrigationList);
    grossIrrigationValues.assignAll(grossIrrigationList);
    volumeOfWaterValues.assignAll(volumeOfWaterList);
    timeOfOperationValues.assignAll(timeOfOperationList);

  }

  // Public method to refresh calculations
  void refreshCalculations() {
    _calculateDepletionEndValues();
  }
}
