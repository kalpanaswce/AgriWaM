# CropWat

CropWat is a Flutter application designed to help users analyze crop water requirements based on climate, soil, crop, and scheduling data. The app provides a step-by-step interface for inputting relevant data and generates a summary to assist in agricultural planning.

## Features

- **Step-by-step workflow:** The app uses a stepper interface to guide users through the process of entering climate, soil, crop, water requirement, and scheduling data.
- **Data import:** Supports importing climate and crop data from CSV and Excel files.
- **State management:** Utilizes the GetX and Provider packages for efficient state management and navigation.
- **Data models:** Includes robust models for climate, soil, and crop data, with helpers for daily climate and precipitation data.
- **Summary generation:** After all steps are completed, the app provides a summary of the crop water requirements and schedule.

## Project Structure

- `lib/main.dart`: Entry point of the app. Sets up controllers and the main stepper UI.
- `lib/global_data_store.dart`: Singleton for sharing data between views.
- `lib/climate/`: Handles climate data input and processing.
- `lib/soil/`: Handles soil data input and processing.
- `lib/crop/`: Handles crop data input and processing.
- `lib/crop_water_requirement/`: Calculates crop water requirements.
- `lib/schedule/`: Manages scheduling of irrigation and related activities.
- `lib/styles.dart`: Contains app-wide styles.

## Data Models

- **ClimateRow:** Represents a row of climate data (month, values, ETo).
- **DailyClimateHelper:** Provides auto-generated daily climate data for calculations.
- **PrecipitationHelper:** Supplies daily precipitation data and utility methods.

## Main Libraries Used

- `get`: State management and navigation.
- `provider`: State management.
- `easy_stepper`: Stepper UI component.
- `file_picker`: File selection dialogs.
- `csv`: CSV file handling.
- `excel`: Excel file handling.
- `cupertino_icons`: iOS-style icons.

## Getting Started

1. **Install dependencies:**
   ```
   flutter pub get
   ```
2. **Run the app:**
   ```
   flutter run
   ```
3. **Follow the stepper interface** to input your data and generate a summary.

## Contributing

Feel free to open issues or submit pull requests for improvements and bug fixes.
