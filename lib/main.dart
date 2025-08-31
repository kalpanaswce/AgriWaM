import 'package:crop_wat/crop_water_requirement/controller/crop_water_requirement_controller.dart';
import 'package:crop_wat/schedule/controller/schedule_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_stepper/easy_stepper.dart';
import 'climate/controller/climate_controller.dart';
import 'soil/controller/soil_controller.dart';
import 'crop/controller/crop_controller.dart';
import 'climate/view/climate_view.dart';
import 'soil/view/soil_view.dart';
import 'crop/view/crop_view.dart';
import 'schedule/view/schedule_view.dart';
import 'crop_water_requirement/view/crop_water_requirement_view.dart';

void main() {
  Get.lazyPut(() => ClimateController());
  Get.lazyPut(() => SoilController());
  Get.lazyPut(() => CropController());
  Get.lazyPut(() => CropWaterRequirementController());
  Get.lazyPut(() => ScheduleController());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AgriWaM',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const StepperHomePage(),
    );
  }
}

class StepperHomePage extends StatefulWidget {
  const StepperHomePage({super.key});

  @override
  State<StepperHomePage> createState() => _StepperHomePageState();
}

// ...existing code...

class _StepperHomePageState extends State<StepperHomePage> {
  int _currentStep = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    ClimateView(),
    SoilView(),
    CropView(),
    CropWaterRequirementView(),
    ScheduleView(),
  ];

  void _onStepContinue() {
    if (_currentStep < _pages.length - 1) {
      setState(() {
        _currentStep++;
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      });
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        _pageController.animateToPage(
          _currentStep,
          duration: const Duration(milliseconds: 300),
          curve: Curves.ease,
        );
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('AgriWaM'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            SizedBox(
              height: 100,
              child: EasyStepper(
                activeStep: _currentStep,
                stepShape: StepShape.circle,
                stepBorderRadius: 15,
                borderThickness: 2,
                showLoadingAnimation: false,
                lineStyle: const LineStyle(
                  lineLength: 150,
                  lineType: LineType.normal,
                  lineThickness: 2,
                  lineSpace: 1,
                  lineWidth: 10,
                  unreachedLineType: LineType.dashed,
                ),
                steps: [
                  EasyStep(icon: Icon(Icons.sunny), title: 'Climate'),
                  EasyStep(icon: Icon(Icons.water_drop), title: 'Soil'),
                  EasyStep(icon: Icon(Icons.grass), title: 'Crop'),
                  EasyStep(icon: Icon(Icons.opacity), title: 'Schedule'),
                  EasyStep(icon: Icon(Icons.calendar_month), title: 'Summary'),
                ],
                onStepReached: (index) {
                  setState(() {
                    _currentStep = index;
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.ease,
                    );
                  });
                },
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: _pages,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _currentStep > 0 ? _onStepCancel : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.arrow_back, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Previous',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _currentStep < _pages.length - 1
                        ? _onStepContinue
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 2,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Next',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ...existing code...
